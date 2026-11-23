#!/usr/bin/env bash
# Popula o PontoLiga com DADOS FICTÍCIOS para demonstração.
# Simula o equipamento (Raspberry Pi) enviando eventos por HTTP.
# Pode ser executado mais de uma vez: membros repetidos retornam 409 e eventos repetidos retornam DUPLICADO.
#
# Variáveis: ADMIN_PASSWORD e RFID_API_KEY (as mesmas usadas ao iniciar a aplicação). BASE é opcional.
BASE="${BASE:-http://localhost:8080}"
: "${ADMIN_PASSWORD:?Defina ADMIN_PASSWORD}"
: "${RFID_API_KEY:?Defina RFID_API_KEY}"

JAR="$(mktemp)"
trap 'rm -f "$JAR"' EXIT
token() { awk '$6=="XSRF-TOKEN"{t=$7} END{print t}' "$JAR"; }

echo "== 1. Login do ADMIN =="
curl -s -c "$JAR" -o /dev/null "$BASE/pages/login.html"
CODIGO=$(curl -s -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' -X POST "$BASE/api/auth/login" \
  -H "X-XSRF-TOKEN: $(token)" --data-urlencode "username=ADMIN" --data-urlencode "password=$ADMIN_PASSWORD")
if [ "$CODIGO" != "200" ]; then
  echo "Login falhou (HTTP $CODIGO). Confira ADMIN_PASSWORD e se a aplicação está em $BASE."; exit 1
fi
curl -s -b "$JAR" -c "$JAR" -o /dev/null "$BASE/api/auth/me"   # renova o token CSRF após o login

echo "== 2. Cadastro de membros fictícios =="
membro() {
  curl -s -b "$JAR" -c "$JAR" -X POST "$BASE/api/membros" -H "Content-Type: application/json" \
    -H "X-XSRF-TOKEN: $(token)" -w ' [HTTP %{http_code}]\n' \
    -d "{\"nomeCompleto\":\"$1\",\"matricula\":\"$2\",\"uidTag\":\"$3\"}"
}
membro "Ana Souza (demo)"      "DEMO0001" "A1B2C3D4"
membro "Bruno Lima (demo)"     "DEMO0002" "B2C3D4E5"
membro "Carla Mendes (demo)"   "DEMO0003" "C3D4E5F6"
membro "Diego Santos (demo)"   "DEMO0004" "D4E5F6A7"

echo "== 3. Eventos enviados pelo 'equipamento' (X-API-Key) =="
enviar() {
  curl -s -X POST "$BASE/api/rfid/eventos" -H "Content-Type: application/json" \
    -H "X-API-Key: $RFID_API_KEY" -w ' [HTTP %{http_code}]\n' -d "$1"
}

echo "-- Lote 1: dia 20/11/2026 (fora de ordem de propósito: a ata ordena pelo horário da leitura)"
enviar '[
 {"eventId":"demo-1120-a-03","uid":"A1B2C3D4","timestamp":"2026-11-20T10:30:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-01","uid":"A1B2C3D4","timestamp":"2026-11-20T08:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-02","uid":"A1B2C3D4","timestamp":"2026-11-20T10:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-a-04","uid":"A1B2C3D4","timestamp":"2026-11-20T12:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-a-05","uid":"A1B2C3D4","timestamp":"2026-11-20T14:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-06","uid":"A1B2C3D4","timestamp":"2026-11-20T15:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-c-01","uid":"C3D4E5F6","timestamp":"2026-11-20T09:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-d-01","uid":"D4E5F6A7","timestamp":"2026-11-20T13:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-d-02","uid":"D4E5F6A7","timestamp":"2026-11-20T13:00:05-03:00","eventType":"EXIT"}
]'

echo "-- Lote 2: dia 21/11/2026 e virada de data (Diego entra às 23:58 do dia 21 e sai às 00:02 do dia 22)"
enviar '[
 {"eventId":"demo-1121-a-01","uid":"A1B2C3D4","timestamp":"2026-11-21T09:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-a-02","uid":"A1B2C3D4","timestamp":"2026-11-21T09:40:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-c-01","uid":"C3D4E5F6","timestamp":"2026-11-21T09:05:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-c-02","uid":"C3D4E5F6","timestamp":"2026-11-21T10:35:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-d-01","uid":"D4E5F6A7","timestamp":"2026-11-21T23:58:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1122-d-02","uid":"D4E5F6A7","timestamp":"2026-11-22T00:02:00-03:00","eventType":"EXIT"}
]'

echo "-- Lote 3: evento ATRASADO (Bruno do dia 20, enviado só agora) + REENVIO de um evento já recebido + UID desconhecido"
enviar '[
 {"eventId":"demo-1120-b-01","uid":"B2C3D4E5","timestamp":"2026-11-20T08:15:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-b-02","uid":"B2C3D4E5","timestamp":"2026-11-20T11:45:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-a-01","uid":"A1B2C3D4","timestamp":"2026-11-20T08:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-x-01","uid":"FFFFFFFF","timestamp":"2026-11-20T08:00:00-03:00","eventType":"ENTRY"}
]'

echo
echo "Pronto. Abra $BASE, entre como ADMIN e consulte as atas de 20/11, 21/11 e 22/11/2026."
echo "Esperado na ata de 20/11: Ana com 3 períodos (2h00min, 1h30min, 1h00min); Bruno 3h30min;"
echo "Carla com 'Saída pendente'; Diego com 5s. Em 21/11: Ana 40min, Carla 1h30min e Diego com 'Saída pendente'."
echo "Em 22/11: Diego com saída 00:02:00 e entrada 'Não registrada' (a entrada pertence à ata de 21/11)."
