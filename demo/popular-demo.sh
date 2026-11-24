#!/usr/bin/env bash
# Popula o PontoLiga com os dados da DEMONSTRAÇÃO.
# Simula o equipamento (Raspberry Pi) enviando eventos por HTTP.
#
# Contém (1) os dados que já existem hoje no sistema e (2) dados ACRESCENTADOS para a demonstração.
# A ata de 22/11 (Ana, Bruno e Carla) fica exatamente como já existe hoje: os dados acrescentados
# só mexem nas atas de 20/11 e 21/11.
# Pode ser executado quantas vezes quiser: membros repetidos retornam 409 e eventos repetidos retornam DUPLICADO,
# então nada é duplicado, e funciona tanto num banco que já tem os dados quanto num banco novo.
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
membro "Ana Souza"    "2024001"   "04A1B2C3D4"
membro "Bruno Lima"   "2024002"   "04B2C3D4E5"
membro "Carla Dias"   "2024003"   "04C3D4E5F6"
membro "Beres"        "20000007"  "04A1B2A5A5"
membro "Rebeca Simão" "200037887" "04A1B2A5F7"

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

echo "-- Dados que já existem hoje (22/11, 23/11 e 20/11)"
# 22/11: Ana, Bruno e Carla. Esta ata NÃO recebe nenhum evento extra da demonstração.
enviar "Base 22/11/2026 (11 eventos)" '[
 {"eventId":"t-0001","uid":"04A1B2C3D4","timestamp":"2026-11-22T08:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"t-0002","uid":"04A1B2C3D4","timestamp":"2026-11-22T10:00:00-03:00","eventType":"EXIT"},
 {"eventId":"t-0003","uid":"04A1B2C3D4","timestamp":"2026-11-22T10:30:00-03:00","eventType":"ENTRY"},
 {"eventId":"t-0004","uid":"04A1B2C3D4","timestamp":"2026-11-22T12:00:00-03:00","eventType":"EXIT"},
 {"eventId":"t-0005","uid":"04A1B2C3D4","timestamp":"2026-11-22T14:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"t-0006","uid":"04B2C3D4E5","timestamp":"2026-11-22T09:15:00-03:00","eventType":"ENTRY"},
 {"eventId":"t-0007","uid":"04B2C3D4E5","timestamp":"2026-11-22T11:45:30-03:00","eventType":"EXIT"},
 {"eventId":"t-0101","uid":"04C3D4E5F6","timestamp":"2026-11-22T09:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"t-0102","uid":"04C3D4E5F6","timestamp":"2026-11-22T09:00:05-03:00","eventType":"EXIT"},
 {"eventId":"t-0301","uid":"04C3D4E5F6","timestamp":"2026-11-22T23:59:30-03:00","eventType":"ENTRY"},
 {"eventId":"t-0303","uid":"04B2C3D4E5","timestamp":"2026-11-23T02:30:00Z","eventType":"ENTRY"}
]'
enviar "Base 23/11/2026 (2 eventos, virada de data e UTC)" '[
 {"eventId":"t-0302","uid":"04C3D4E5F6","timestamp":"2026-11-23T00:00:30-03:00","eventType":"EXIT"},
 {"eventId":"t-0304","uid":"04B2C3D4E5","timestamp":"2026-11-23T03:10:00Z","eventType":"EXIT"}
]'
enviar "Base 20/11/2026 (2 eventos, Bruno)" '[
 {"eventId":"t-0201","uid":"04B2C3D4E5","timestamp":"2026-11-20T18:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"t-0202","uid":"04B2C3D4E5","timestamp":"2026-11-20T19:30:00-03:00","eventType":"EXIT"}
]'

echo "-- Acrescentados para a demonstração (só 20/11 e 21/11)"
# 20/11: enviado fora de ordem de propósito (a ata ordena pelo horário da leitura).
# A Carla fica com ENTRADA SEM SAÍDA: a saída será enviada ao vivo durante a demonstração.
enviar "Demo 20/11/2026 (11 eventos)" '[
 {"eventId":"demo-1120-a-03","uid":"04A1B2C3D4","timestamp":"2026-11-20T10:30:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-01","uid":"04A1B2C3D4","timestamp":"2026-11-20T08:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-02","uid":"04A1B2C3D4","timestamp":"2026-11-20T10:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-a-04","uid":"04A1B2C3D4","timestamp":"2026-11-20T12:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-a-05","uid":"04A1B2C3D4","timestamp":"2026-11-20T14:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-a-06","uid":"04A1B2C3D4","timestamp":"2026-11-20T15:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-be-01","uid":"04A1B2A5A5","timestamp":"2026-11-20T08:20:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-be-02","uid":"04A1B2A5A5","timestamp":"2026-11-20T11:50:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1120-c-01","uid":"04C3D4E5F6","timestamp":"2026-11-20T09:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-r-01","uid":"04A1B2A5F7","timestamp":"2026-11-20T13:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1120-r-02","uid":"04A1B2A5F7","timestamp":"2026-11-20T13:45:00-03:00","eventType":"EXIT"}
]'
# 21/11: ata nova (a lista passa a ter 4 atas)
enviar "Demo 21/11/2026 (7 eventos)" '[
 {"eventId":"demo-1121-a-01","uid":"04A1B2C3D4","timestamp":"2026-11-21T09:00:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-a-02","uid":"04A1B2C3D4","timestamp":"2026-11-21T09:40:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-c-01","uid":"04C3D4E5F6","timestamp":"2026-11-21T09:05:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-c-02","uid":"04C3D4E5F6","timestamp":"2026-11-21T10:35:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-r-01","uid":"04A1B2A5F7","timestamp":"2026-11-21T08:30:00-03:00","eventType":"ENTRY"},
 {"eventId":"demo-1121-r-02","uid":"04A1B2A5F7","timestamp":"2026-11-21T11:00:00-03:00","eventType":"EXIT"},
 {"eventId":"demo-1121-be-01","uid":"04A1B2A5A5","timestamp":"2026-11-21T16:00:00-03:00","eventType":"ENTRY"}
]'

echo
echo "Pronto. Abra $BASE, entre como ADMIN e confira as atas."
echo "Primeira execução em banco novo: 15 eventos da base + 18 da demonstração = 33 criados."
echo "Execuções seguintes: tudo DUPLICADO (nada muda)."
echo
echo "Estado esperado ANTES da demonstração ao vivo:"
echo "  Atas: 23/11, 22/11, 21/11 e 20/11/2026."
echo "  20/11: Ana 3 períodos (2h00min, 1h30min, 1h00min); Beres 3h30min; Bruno 1h30min;"
echo "         Carla 09:00 com 'Saída pendente'; Rebeca 45min."
echo "  21/11: Ana 40min; Carla 1h30min; Rebeca 2h30min; Beres com 'Saída pendente'."
echo "  22/11: inalterada, igual ao que já existe hoje: Ana 2h00min, 1h30min e 14:00 'Saída pendente';"
echo "         Bruno 2h30min e 23:30 pendente; Carla 5s e 23:59:30 pendente."
echo "  23/11: Bruno e Carla só com saída (entrada 'Não registrada'; a entrada está na ata de 22/11)."
