# Definição do MVP (Anexo C)

**Solução:** PontoLiga
**Usuário principal:** administrador (ADMIN) da liga.
**Resultado principal:** consultar a ata de presença de um dia, com períodos de entrada/saída e carga horária de cada membro, e salvá-la em PDF.

**Fluxo de ponta a ponta:** leitura do cartão (simulada por HTTP) → API valida chave, UID cadastrado e `eventId` → grava no PostgreSQL →
eventos do dia (fuso `America/Bahia`) formam a ata → ADMIN abre a ata → imprime/salva em PDF.

**Critérios de pronto**
1. Aplicação inicia seguindo o README e conecta ao PostgreSQL.
2. Login do ADMIN funciona; rotas e API do painel exigem sessão.
3. Membros podem ser cadastrados/listados/editados; matrícula e UID únicos.
4. `POST /api/rfid/eventos` aceita lote com `X-API-Key`, rejeita com motivo o que for inválido e não duplica o mesmo `eventId`.
5. Eventos atrasados entram na ata da data original; ordem cronológica independe da chegada.
6. Ata mostra períodos, "Saída pendente" e carga horária correta.
7. "Imprimir / Salvar como PDF" gera documento limpo, só com a ata do dia.
8. `tests/testes-api.sh` termina sem falhas em ambiente limpo (⚠️ confirmar em execução real).

**Fora do escopo:** software do Raspberry, relatórios/dashboards, soma de horas entre dias, horas complementares do estatuto,
correção/exclusão de eventos, múltiplos usuários, recuperação de senha, gestão avançada de cartões, Google Drive, app mobile.

**Maior risco:** integração real com o Raspberry (formato, relógio e reenvio), não coberta; e reprodutibilidade em outra máquina
(versão SNAPSHOT do Spring Boot).

**Teste principal:** `bash demo/popular-demo.sh` + `bash tests/testes-api.sh` + conferência visual da ata/PDF; ideal: comparar com uma lista manual de reunião real.

**Limitações conhecidas:** ver seção no README (equipamento simulado, `eventType` confiado ao equipamento, sem migrations, sem JUnit).
