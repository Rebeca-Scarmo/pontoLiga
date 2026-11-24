#!/usr/bin/env bash
# Popula o PontoLiga com dados de demonstração.
# Simula o equipamento (Raspberry Pi) enviando eventos por HTTP.
#
# Nenhuma reunião é cadastrada: cada data enviada vira uma ata própria
# (datas diferentes = atas diferentes). Este script cria 3 atas: 20/11, 21/11 e 22/11/2026.
# Pode ser executado mais de uma vez: membros repetidos retornam 409 e eventos repetidos
# retornam DUPLICADO, então nada é duplicado.
#
# Uso:  export ADMIN_PASSWORD=...  RFID_API_KEY=...  &&  bash demo/popular-demo.sh
# (use os mesmos valores com que a aplicação foi iniciada; BASE é opcional)
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

echo "== 2. Membros =="
membro() {  # nome matrícula uid
  local codigo
  codigo=$(curl -s -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' -X POST "$BASE/api/membros" \
    -H "Content-Type: application/json" -H "X-XSRF-TOKEN: $(token)" \
    -d "{\"nomeCompleto\":\"$1\",\"matricula\":\"$2\",\"uidTag\":\"$3\"}")
  case "$codigo" in
    201) echo "  $1: cadastrado" ;;
    409) echo "  $1: já existia (409), nada alterado" ;;
    *)   echo "  $1: ATENÇÃO, HTTP $codigo" ;;
  esac
}
membro "Ana Souza"  "2024001" "04A1B2C3D4"
membro "Bruno Lima" "2024002" "04B2C3D4E5"
membro "Carla Dias" "2024003" "04C3D4E5F6"

echo "== 3. Eventos enviados pelo 'equipamento' (X-API-Key) =="
enviar() {  # descrição json
  local resposta codigo corpo
  resposta=$(curl -s -X POST "$BASE/api/rfid/eventos" -H "Content-Type: application/json" \
    -H "X-API-Key: $RFID_API_KEY" -w '\n%{http_code}' -d "$2")
  codigo=$(printf '%s' "$resposta" | tail -n1)
  corpo=$(printf '%s' "$resposta" | sed '$d')
  echo "  $1: HTTP $codigo $(printf '%s' "$corpo" | grep -o '"recebidos":[0-9]*,"criados":[0-9]*,"duplicados":[0-9]*,"rejeitados":[0-9]*')"
  if [ "$codigo" != "200" ]; then echo "    $corpo"; fi
}

# 20/11: a leitura da Ana das 10:30 é enviada antes da das 08:00 de propósito
# (a ata ordena pelo horário da leitura, não pela ordem de chegada).
enviar "20/11/2026 (6 eventos)" '[
 {"eventId":"demo-1120-a-03","uid":"04A1B2C3D4","timestamp":"2026-11-20T10:30:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-01","uid":"04A1B2C3D4","timestamp":"2026-11-20T08:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-02","uid":"04A1B2C3D4","timestamp":"2026-11-20T10:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-a-04","uid":"04A1B2C3D4","timestamp":"2026-11-20T12:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-b-01","uid":"04B2C3D4E5","timestamp":"2026-11-20T09:15:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-b-02","uid":"04B2C3D4E5","timestamp":"2026-11-20T11:45:00-03:00","eventType":"EXIT"}
]'
# 21/11: o Bruno entra e não registra a saída ("Saída pendente").
enviar "21/11/2026 (5 eventos)" '[
 {"eventId":"demo-1121-a-01","uid":"04A1B2C3D4","timestamp":"2026-11-21T09:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-a-02","uid":"04A1B2C3D4","timestamp":"2026-11-21T09:40:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-c-01","uid":"04C3D4E5F6","timestamp":"2026-11-21T09:05:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-c-02","uid":"04C3D4E5F6","timestamp":"2026-11-21T10:35:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-b-01","uid":"04B2C3D4E5","timestamp":"2026-11-21T14:00:00-03:00","eventType":"ENTRY"}
]'
# 22/11
enviar "22/11/2026 (4 eventos)" '[
 {"eventId":"demo-1122-c-01","uid":"04C3D4E5F6","timestamp":"2026-11-22T08:30:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1122-c-02","uid":"04C3D4E5F6","timestamp":"2026-11-22T11:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1122-a-01","uid":"04A1B2C3D4","timestamp":"2026-11-22T13:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1122-a-02","uid":"04A1B2C3D4","timestamp":"2026-11-22T13:45:00-03:00","eventType":"EXIT"}
]'

echo
echo "Pronto. Abra $BASE, entre como ADMIN e confira as atas."
echo "Primeira execução: 15 eventos criados. Execuções seguintes: tudo DUPLICADO (nada muda)."
echo
echo "Estado esperado ANTES da demonstração ao vivo (3 atas: 22/11, 21/11 e 20/11/2026):"
echo "  20/11: Ana 2h00min e 1h30min; Bruno 2h30min."
echo "  21/11: Ana 40min; Carla 1h30min; Bruno com 'Saída pendente'."
echo "  22/11: Carla 2h30min; Ana 45min."
echo "A ata de 23/11 será criada ao vivo, enviando eventos com essa data."
