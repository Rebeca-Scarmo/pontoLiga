# O que mudou em relação ao documento "PontoLiga" (Processos de Negócios)

O documento original (`pontoLiga6.pdf`, disciplina Processos de Negócios) é **material preexistente**, usado só como referência conceitual.
O software deste repositório foi simplificado.

| Tema | Documento original | Este MVP |
|---|---|---|
| Unidade de presença | "Reunião" escolhida no painel | **Ata automática por data** (`America/Bahia`), sem cadastro/encerramento de reunião |
| Envio dos registros | Raspberry guarda offline e envia ao apertar um botão (P3) | API HTTP recebe **lotes** de eventos; idempotência por `eventId`; equipamento só simulado |
| Entrada/saída | Sistema local alterna entrada/saída | `eventType` (ENTRY/EXIT) vem do equipamento e é gravado; a ata pareia os eventos |
| Horas | Horas complementares pelo estatuto (RN10, RQ06) | Apenas **saída − entrada** por período |
| Saída pendente | Presidência "resolve" depois | Exibida como "Saída pendente"; **sem correção manual** |
| Cadastro de cartão | Aproximar o cartão no leitor durante o cadastro (P1) | UID **digitado** no formulário (3 campos) |
| Banco | Nuvem | PostgreSQL local |
| Painel | Stitch + Google AI Studio, Google Drive opcional | Spring Boot + HTML/CSS/JS puro; sem Drive |
| PDF | Gerado pelo painel | `window.print()` + `@media print` |
| Acesso | Não detalhado | Um único ADMIN, sessão + BCrypt; API do equipamento com `X-API-Key` |

Mantidos do original: identidade visual (paleta e fontes Rubik/Cairo/Khula), foco em presença por RFID para a Calabotics,
"saída pendente", matrícula/UID únicos, só cartões cadastrados registram presença.
