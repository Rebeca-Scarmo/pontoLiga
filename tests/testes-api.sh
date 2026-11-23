#!/usr/bin/env bash
# Roteiro automatizado de testes do PontoLiga via curl (aplicação rodando em localhost).
# Uso:  export ADMIN_PASSWORD=...  RFID_API_KEY=...  &&  bash tests/testes-api.sh
# Cada execução usa dados únicos (sufixo aleatório e data aleatória de 2025), então pode ser repetida.
BASE="${BASE:-http://localhost:8080}"
: "${ADMIN_PASSWORD:?Defina ADMIN_PASSWORD}"
: "${RFID_API_KEY:?Defina RFID_API_KEY}"

JAR="$(mktemp)"; TMP="$(mktemp -d)"
trap 'rm -rf "$JAR" "$TMP"' EXIT
PASSOU=0; FALHOU=0

SUF=$(printf '%06X' $(( (RANDOM * 32768 + RANDOM) % 16777216 )))   # 6 dígitos hexadecimais
MES=$(printf '%02d' $(( RANDOM % 12 + 1 )))
DIA=$(( RANDOM % 26 + 1 ));  D=$(printf '%02d' "$DIA");  D2=$(printf '%02d' $(( DIA + 1 )))
DATA="2025-$MES-$D"; DATA2="2025-$MES-$D2"          # dia do teste e dia seguinte
echo "Execução $SUF | atas de teste: $DATA e $DATA2 | servidor: $BASE"

# ---------- utilitários ----------
token() { awk '$6=="XSRF-TOKEN"{t=$7} END{print t}' "$JAR"; }
CODE=""; BODY=""
separar() { CODE=$(printf '%s' "$1" | tail -n1); BODY=$(printf '%s' "$1" | sed '$d'); }
adm() {   # método caminho [json]  -> preenche CODE e BODY (sessão do ADMIN)
  local r
  if [ -n "${3:-}" ]; then
    r=$(curl -s -b "$JAR" -c "$JAR" -X "$1" "$BASE$2" -H "Content-Type: application/json" \
        -H "X-XSRF-TOKEN: $(token)" -d "$3" -w '\n%{http_code}')
  else
    r=$(curl -s -b "$JAR" -c "$JAR" -X "$1" "$BASE$2" -H "X-XSRF-TOKEN: $(token)" -w '\n%{http_code}')
  fi
  separar "$r"
}
rfid() {  # json [chave]  -> preenche CODE e BODY (equipamento)
  local r; r=$(curl -s -X POST "$BASE/api/rfid/eventos" -H "Content-Type: application/json" \
      -H "X-API-Key: ${2-$RFID_API_KEY}" -d "$1" -w '\n%{http_code}')
  separar "$r"
}
ev() { printf '{"eventId":"%s","uid":"%s","timestamp":"%s","eventType":"%s"}' "$1" "$2" "$3" "$4"; }
checar() {  # descrição condição(0=ok)
  if [ "$2" -eq 0 ]; then echo "  OK      $1"; PASSOU=$((PASSOU+1)); else echo "  FALHOU  $1  (HTTP $CODE) $BODY"; FALHOU=$((FALHOU+1)); fi
}
codigo_e()   { [ "$CODE" = "$1" ]; }
corpo_tem()  { printf '%s' "$BODY" | grep -q -- "$1"; }
# Trecho do JSON de um participante (do nome até o fim da lista de períodos)
trecho() { printf '%s' "$BODY" | sed "s/.*\(\"nomeCompleto\":\"$1\"[^]]*\]\).*/\1/"; }

# ---------- dados desta execução ----------
UID1="1A${SUF}"; UID2="2B${SUF}"; UID3="3C${SUF}"; UID4="4D${SUF}"; UID_DESCONHECIDO="EE${SUF}"
N1="Teste Auto ${SUF} A"; N2="Teste Auto ${SUF} B"; N3="Teste Auto ${SUF} C"; N4="Teste Auto ${SUF} D"

echo; echo "[AUTENTICAÇÃO]"
CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/membros"); BODY=""
checar "A1 sem login, GET /api/membros retorna 401" $(codigo_e 401; echo $?)
CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/pages/atas.html"); BODY=""
checar "A2 sem login, página protegida redireciona (302) para o login" $(codigo_e 302; echo $?)

curl -s -c "$JAR" -o /dev/null "$BASE/pages/login.html"      # recebe o cookie XSRF-TOKEN
CODE=$(curl -s -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' -X POST "$BASE/api/auth/login" \
  -H "X-XSRF-TOKEN: $(token)" --data-urlencode "username=ADMIN" --data-urlencode "password=senha-errada-$SUF"); BODY=""
checar "A3 login com senha errada retorna 401" $(codigo_e 401; echo $?)

curl -s -b "$JAR" -c "$JAR" -o /dev/null "$BASE/pages/login.html"
CODE=$(curl -s -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' -X POST "$BASE/api/auth/login" \
  -H "X-XSRF-TOKEN: $(token)" --data-urlencode "username=ADMIN" --data-urlencode "password=$ADMIN_PASSWORD"); BODY=""
checar "A4 login válido retorna 200" $(codigo_e 200; echo $?)
adm GET /api/auth/me
checar "A5 /api/auth/me mostra o usuário ADMIN" $(codigo_e 200 && corpo_tem '"username":"ADMIN"'; echo $?)

echo; echo "[MEMBROS]"
adm POST /api/membros "{\"nomeCompleto\":\"$N1\",\"matricula\":\"T$SUF-1\",\"uidTag\":\"$UID1\"}"
checar "M1 cadastro válido retorna 201" $(codigo_e 201 && corpo_tem "\"uidTag\":\"$UID1\""; echo $?)
adm POST /api/membros "{\"nomeCompleto\":\"Outro $SUF\",\"matricula\":\"T$SUF-1\",\"uidTag\":\"9F${SUF}\"}"
checar "M2 matrícula duplicada retorna 409" $(codigo_e 409; echo $?)
adm POST /api/membros "{\"nomeCompleto\":\"Outro $SUF\",\"matricula\":\"T$SUF-X\",\"uidTag\":\"$UID1\"}"
checar "M3 UID duplicado retorna 409" $(codigo_e 409; echo $?)
adm POST /api/membros '{"nomeCompleto":"","matricula":"","uidTag":""}'
checar "M4 campos obrigatórios vazios retornam 400 com mensagens" $(codigo_e 400 && corpo_tem '"campos"'; echo $?)
adm POST /api/membros "{\"nomeCompleto\":\"Fulano\",\"matricula\":\"T$SUF-Y\",\"uidTag\":\"ZZ ZZ\"}"
checar "M5 UID com formato inválido retorna 400" $(codigo_e 400; echo $?)
adm POST /api/membros "{\"nomeCompleto\":\"$N2\",\"matricula\":\"T$SUF-2\",\"uidTag\":\"$UID2\"}"; checar "M6a cadastro do membro B" $(codigo_e 201; echo $?)
adm POST /api/membros "{\"nomeCompleto\":\"$N3\",\"matricula\":\"T$SUF-3\",\"uidTag\":\"$UID3\"}"; checar "M6b cadastro do membro C" $(codigo_e 201; echo $?)
adm POST /api/membros "{\"nomeCompleto\":\"$N4\",\"matricula\":\"T$SUF-4\",\"uidTag\":\"$UID4\"}"; checar "M6c cadastro do membro D" $(codigo_e 201; echo $?)
adm GET /api/membros
checar "M7 listagem contém o membro cadastrado" $(codigo_e 200 && corpo_tem "$N1"; echo $?)

echo; echo "[API RFID]"
rfid "[$(ev "x-$SUF" "$UID1" "${DATA}T07:00:00-03:00" ENTRY)]" "chave-errada-123456"
checar "R1 chave de API errada retorna 401" $(codigo_e 401; echo $?)
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE/api/rfid/eventos" -H "Content-Type: application/json" -d '[]'); BODY=""
checar "R2 sem cabeçalho X-API-Key retorna 401" $(codigo_e 401; echo $?)
rfid "[$(ev "x-$SUF" "$UID1" "${DATA}T07:00:00-03:00" ENTRY)]"
checar "R3 evento válido é criado (CRIADO)" $(codigo_e 200 && corpo_tem '"criados":1'; echo $?)
rfid "[$(ev "x-$SUF" "$UID1" "${DATA}T07:00:00-03:00" ENTRY)]"
checar "R4 reenvio do mesmo eventId vira DUPLICADO e não cria registro" $(codigo_e 200 && corpo_tem '"duplicados":1' && corpo_tem '"criados":0'; echo $?)
rfid "[$(ev "u-$SUF" "$UID_DESCONHECIDO" "${DATA}T07:00:00-03:00" ENTRY)]"
checar "R5 UID não cadastrado é REJEITADO com motivo" $(codigo_e 200 && corpo_tem '"rejeitados":1' && corpo_tem 'UID não cadastrado'; echo $?)
rfid "[$(ev "t-$SUF" "$UID1" "${DATA}T07:00:00-03:00" SAIDA)]"
checar "R6 eventType inválido é REJEITADO" $(codigo_e 200 && corpo_tem '"rejeitados":1' && corpo_tem 'ENTRY ou EXIT'; echo $?)
rfid "[$(ev "h-$SUF" "XYZ" "${DATA}T07:00:00-03:00" ENTRY)]"
checar "R7 UID com formato inválido é REJEITADO" $(codigo_e 200 && corpo_tem '"rejeitados":1'; echo $?)
rfid "[$(ev "s-$SUF" "$UID1" "ontem de manhã" ENTRY)]"
checar "R8 timestamp inválido é REJEITADO" $(codigo_e 200 && corpo_tem '"rejeitados":1' && corpo_tem 'timestamp'; echo $?)
rfid '{isso nao e json'
checar "R9 corpo que não é JSON retorna 400" $(codigo_e 400; echo $?)
rfid '[]'
checar "R10 lista vazia retorna 400" $(codigo_e 400; echo $?)
rfid "[$(ev "l1-$SUF" "$UID2" "${DATA}T09:00:00-03:00" ENTRY),$(ev "l2-$SUF" "$UID2" "${DATA}T09:30:00-03:00" EXIT),$(ev "l3-$SUF" "$UID_DESCONHECIDO" "${DATA}T09:30:00-03:00" EXIT)]"
checar "R11 lote misto: 2 criados e 1 rejeitado (nada é descartado em silêncio)" $(codigo_e 200 && corpo_tem '"recebidos":3' && corpo_tem '"criados":2' && corpo_tem '"rejeitados":1'; echo $?)

# Concorrência: o mesmo eventId enviado ao mesmo tempo por duas requisições
curl -s -X POST "$BASE/api/rfid/eventos" -H "Content-Type: application/json" -H "X-API-Key: $RFID_API_KEY" \
  -d "[$(ev "conc-$SUF" "$UID2" "${DATA}T16:00:00-03:00" ENTRY)]" > "$TMP/c1" &
curl -s -X POST "$BASE/api/rfid/eventos" -H "Content-Type: application/json" -H "X-API-Key: $RFID_API_KEY" \
  -d "[$(ev "conc-$SUF" "$UID2" "${DATA}T16:00:00-03:00" ENTRY)]" > "$TMP/c2" &
wait
CRIADOS=$(cat "$TMP/c1" "$TMP/c2" | grep -o '"status":"CRIADO"' | wc -l | tr -d ' ')
DUPLIC=$(cat "$TMP/c1" "$TMP/c2" | grep -o '"status":"DUPLICADO"' | wc -l | tr -d ' ')
CODE=200; BODY="CRIADO=$CRIADOS DUPLICADO=$DUPLIC"
checar "R12 duas requisições simultâneas com o mesmo eventId: 1 CRIADO e 1 DUPLICADO" $([ "$CRIADOS" = "1" ] && [ "$DUPLIC" = "1" ]; echo $?)

echo; echo "[REGRAS DAS ATAS]"
# Membro A: enviado FORA de ordem (saída antes da entrada); 08:00-10:30 = 2h30min; 13:00 entrada sem saída
rfid "[$(ev "a2-$SUF" "$UID1" "${DATA}T10:30:00-03:00" EXIT),$(ev "a3-$SUF" "$UID1" "${DATA}T13:00:00-03:00" ENTRY),$(ev "a1-$SUF" "$UID1" "${DATA}T08:00:00-03:00" ENTRY)]"
checar "T1 lote fora de ordem de chegada é aceito" $(codigo_e 200 && corpo_tem '"criados":3'; echo $?)
# Membro C: duas leituras físicas em 3 segundos, ambas válidas
rfid "[$(ev "c1-$SUF" "$UID3" "${DATA}T15:00:00-03:00" ENTRY),$(ev "c2-$SUF" "$UID3" "${DATA}T15:00:03-03:00" EXIT)]"
checar "T2 duas leituras distintas em 3s são preservadas (sem debounce)" $(codigo_e 200 && corpo_tem '"criados":2'; echo $?)
# Membro D: virada de data (23:59 no dia D, 00:01 no dia seguinte) e horário em UTC (12:00Z = 09:00 em Salvador)
rfid "[$(ev "d1-$SUF" "$UID4" "${DATA}T23:59:00-03:00" ENTRY),$(ev "d2-$SUF" "$UID4" "${DATA2}T00:01:00-03:00" EXIT),$(ev "d3-$SUF" "$UID4" "${DATA}T12:00:00Z" ENTRY)]"
checar "T3 eventos próximos da virada de data e em UTC são aceitos" $(codigo_e 200 && corpo_tem '"criados":3'; echo $?)

adm GET "/api/atas/$DATA"
checar "T4 detalhe da ata do dia retorna 200" $(codigo_e 200; echo $?)
SEG=$(trecho "$N1")
CODE=200; BODY="$SEG"
checar "T5 membro A: período 08:00:00 a 10:30:00 com carga horária 2h30min (cronológico, mesmo chegando fora de ordem)" \
  $(corpo_tem '"entrada":"08:00:00","saida":"10:30:00","cargaHoraria":"2h30min"'; echo $?)
checar "T6 membro A: entrada das 13:00 aparece como saída pendente, sem carga horária" \
  $(corpo_tem '"entrada":"13:00:00","saida":null,"cargaHoraria":null,"saidaPendente":true'; echo $?)
BODY="$(trecho "$N3")"
checar "T7 membro C: leituras com 3 segundos de diferença geram carga horária 3s" $(corpo_tem '"cargaHoraria":"3s"'; echo $?)
BODY="$(trecho "$N2")"
checar "T8 membro B: período 09:00-09:30 = 30min e entrada das 16:00 pendente" \
  $(corpo_tem '"cargaHoraria":"30min"' && corpo_tem '"saidaPendente":true'; echo $?)
BODY="$(trecho "$N4")"
checar "T9 membro D: horário em UTC (12:00Z) vira 09:00:00 em Salvador e a entrada 23:59 fica na ata do dia" \
  $(corpo_tem '"entrada":"09:00:00"' && corpo_tem '"entrada":"23:59:00","saida":null'; echo $?)

adm GET "/api/atas/$DATA2"
BODY="$(trecho "$N4")"
checar "T10 a saída 00:01 pertence à ata do dia seguinte (sem entrada registrada nesse dia)" \
  $(codigo_e 200 && corpo_tem '"entrada":null,"saida":"00:01:00"'; echo $?)
BODY="$(adm GET "/api/atas/$DATA2"; echo "$BODY")"
CODE=200
checar "T11 a ata do dia seguinte NÃO contém os eventos do dia anterior" $(! corpo_tem '"saida":"10:30:00"'; echo $?)

# Evento atrasado: chega agora, mas pertence à data original
rfid "[$(ev "late-$SUF" "$UID2" "${DATA}T17:00:00-03:00" EXIT)]"
adm GET "/api/atas/$DATA"; BODY="$(trecho "$N2")"
checar "T12 evento atrasado entra na ata da data original (entrada 16:00 -> saída 17:00 = 1h00min)" \
  $(corpo_tem '"entrada":"16:00:00","saida":"17:00:00","cargaHoraria":"1h00min"'; echo $?)

adm GET /api/atas
checar "T13 listagem de atas contém a data do teste" $(codigo_e 200 && corpo_tem "\"data\":\"$DATA\""; echo $?)
P1=$(printf '%s' "$BODY" | grep -o '"data":"[0-9-]*"' | head -n1)
ULT=$(printf '%s' "$BODY" | grep -o '"data":"[0-9-]*"' | tail -n1)
CODE=200; BODY="primeira=$P1 última=$ULT"
checar "T14 listagem ordenada da mais recente para a mais antiga" $([ "$P1" \> "$ULT" ] || [ "$P1" = "$ULT" ]; echo $?)
adm GET /api/atas/1999-01-01
checar "T15 ata de data sem registros retorna 404" $(codigo_e 404; echo $?)
adm GET /api/atas/data-invalida
checar "T16 data em formato inválido retorna 400" $(codigo_e 400; echo $?)

echo; echo "[ENCERRAMENTO DA SESSÃO]"
adm POST /api/auth/logout
checar "S1 logout retorna 200" $(codigo_e 200; echo $?)
CODE=$(curl -s -b "$JAR" -o /dev/null -w '%{http_code}' "$BASE/api/membros"); BODY=""
checar "S2 após o logout, /api/membros volta a exigir login (401)" $(codigo_e 401; echo $?)

echo; echo "Resultado: $PASSOU OK, $FALHOU falha(s)."
[ "$FALHOU" -eq 0 ]
