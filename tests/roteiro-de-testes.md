# Roteiro de testes — PontoLiga

Pré-condição: aplicação rodando em `http://localhost:8080`, PostgreSQL ativo, variáveis `ADMIN_PASSWORD` e `RFID_API_KEY` definidas.

## Parte 1 — Automatizada via curl (`tests/testes-api.sh`)

```bash
export ADMIN_PASSWORD='admin_demo_2026'
export RFID_API_KEY='chave-demo-rfid-0123456789abcdef'
bash tests/testes-api.sh
```

| ID | O que verifica | Resultado esperado |
|---|---|---|
| A1–A2 | acesso sem login (API e página) | 401 / redirecionamento 302 |
| A3–A5 | login inválido, válido e `/me` | 401 / 200 / usuário ADMIN |
| M1–M7 | cadastro válido, matrícula e UID duplicados, campos vazios, UID inválido, listagem | 201 / 409 / 409 / 400 / 400 / 200 |
| R1–R2 | API sem chave ou com chave errada | 401 |
| R3–R4 | evento válido e reenvio do mesmo `eventId` | CRIADO, depois DUPLICADO |
| R5–R8 | UID desconhecido, `eventType`, UID e `timestamp` inválidos | REJEITADO com motivo |
| R9–R10 | JSON malformado e lista vazia | 400 |
| R11 | lote misto | 2 criados, 1 rejeitado |
| R12 | mesmo `eventId` em duas requisições simultâneas | 1 CRIADO e 1 DUPLICADO |
| T1–T3 | lote fora de ordem, leituras com 3 s de diferença, virada de data e UTC | todos aceitos |
| T4–T9 | ata do dia: ordem cronológica, 2h30min, saída pendente, 3s, UTC→Salvador | conforme o script |
| T10–T11 | ata do dia seguinte contém só a saída 00:01 e não mistura dias | conforme o script |
| T12 | evento atrasado cai na data original | 1h00min na ata de origem |
| T13–T16 | listagem de atas, ordem decrescente, 404, 400 | conforme o script |
| S1–S2 | logout e bloqueio posterior | 200 / 401 |

Como saber que passou: cada linha mostra `OK`; o fim mostra `Resultado: N OK, 0 falha(s).` e o código de saída é 0.
Ao falhar, a linha traz o código HTTP e o corpo da resposta.

Comandos avulsos (equipamento simulado):
```bash
curl -i -X POST http://localhost:8080/api/rfid/eventos \
  -H "Content-Type: application/json" -H "X-API-Key: $RFID_API_KEY" \
  -d '[{"eventId":"meu-evento-001","uid":"A1B2C3D4","timestamp":"2026-11-23T08:30:00-03:00","eventType":"ENTRY"}]'
```
(UID precisa estar cadastrado; rode antes `bash demo/popular-demo.sh`.)

## Parte 2 — Manual (painel e impressão)

| ID | Passos | Esperado |
|---|---|---|
| P1 | Abrir `/pages/atas.html` sem login | vai para o login |
| P2 | Login ADMIN com senha errada / correta | mensagem de erro / entra na lista de atas |
| P3 | Membros → Cadastrar com matrícula repetida | mensagem clara de erro |
| P4 | Atas → abrir 20/11/2026 (após o demo) | Ana com 3 períodos; Carla "Saída pendente"; Bruno 3h30min |
| P5 | Clicar em "Imprimir / Salvar como PDF" | abre a janela de impressão do navegador |
| P6 | Escolher destino "Salvar como PDF" e salvar | PDF só com identificação do PontoLiga, título, data, 1º/último registro e tabela; sem menu nem botões |
| P7 | Conferir o PDF | nenhum dado de outra data; texto legível em preto e branco |
| P8 | Reduzir a janela do navegador | tabela rola na horizontal, sem quebrar o layout |

Registre abaixo o resultado de cada execução real (data, quem executou, ambiente, resultado):

| Data | Executor | Ambiente (SO/navegador) | Parte 1 | Parte 2 | Observações |
|---|---|---|---|---|---|
| ⚠️ PREENCHER | | | | | |
