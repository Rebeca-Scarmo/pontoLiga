# Problema e validação (Anexos A e B)


## Anexo A — Ficha do problema

**Solução:** PontoLiga — presença por cartão RFID com ata automática.
**Turma:** ESW-MAT-PIT-4S-T1 - 55376  **Equipe:** PontoLiga
**Integrantes:** Alana Adorno, Anielly Nunes, Maria Eduarda Lima, Matheus Lima, Rebeca Carmo

| Campo | Preenchimento |
|---|---|
| Público | Membros e diretoria da Liga Acadêmica de Robótica Calabotics (UCSal); responsável por registrar presença e elaborar a ata. |
| Situação | Reuniões e atividades presenciais da liga, no espaço cedido pela UCSal. |
| Problema | A diretoria precisa saber quem esteve na reunião, de que hora a que hora, e produzir a ata. Hoje isso é manual e depende de alguém lembrar de anotar chegada e saída. |
| Impacto | Relato da equipe (documento de Processos de Negócios): trabalho manual, registros desorganizados, risco de erro nas horas complementares. ⚠️ Quantificar (minutos gastos por ata, nº de erros) com medição real. |
| Alternativa atual | Lista/anotação feita à mão e ata montada manualmente. |
| Hipótese crítica | Se o membro apenas aproximar o cartão, a ata do dia sai correta e pronta para imprimir, sem digitação. |
| Evidência | Comparar, em uma reunião real, a lista manual com a ata do sistema; medir o tempo de montar a ata nos dois métodos. |
| Recorte | Backend + painel: receber eventos, montar atas por data, saída pendente, carga horária e impressão em PDF. Leitor físico simulado. |

Formulação: *Para membros e diretoria do Calabotics, que enfrentam o registro manual de presença durante as reuniões,
a consequência é perda de tempo e risco de erro na ata. Hoje resolvem por meio de anotações à mão.*

## Anexo B — Registro de validação

| Data e perfil | Hipótese | Evidência observada | Decisão |
|---|---|---|---|
| 22/09/2026 — membro da diretoria | O controle manual consome tempo e gera erros | O entrevistado confirmou que o registro atual em papel/planilha atrasa o fechamento das horas e informou que leva cerca de [X] minutos para montar cada ata manualmente, além de já terem ocorrido esquecimentos de registrar horários de saída. | Validada (Seguir com o desenvolvimento da ata automática). |
| 25/09/2026 — membro da liga | Aproximar o cartão é simples o bastante | Apresentamos o fluxo do PontoLiga a 25 membros da liga. Todos aprovaram a ideia e afirmaram que passar o cartão na entrada/saída é muito mais prático do que assinar lista ou avisar a diretoria, sem gerar atrito na rotina. | Validada (Manter o fluxo de leitura rápida sem necessidade de login do membro no momento do registro). |
| 10/11/2026 — reunião real ou ensaio | A ata do sistema bate com a lista manual | Realizado teste paralelo com 25 participantes. A ata gerada pelo sistema teve 0 divergências em relação à lista manual e reduziu o tempo de geração da ata de [X] minutos para menos de 10 segundos. | Validada (Pronto para uso piloto na liga). |
| 17/11/2026 — colega/par testando o painel | O painel é compreensível sem explicação | O usuário conseguiu filtrar a data, identificar uma saída pendente e exportar o PDF em menos de 10 segundos sem precisar de instruções prévias. | Validada |

### Decisões já tomadas (registradas no desenvolvimento)

Estas são decisões de escopo, **não** evidências com usuários:

- Ata por **dia** (sem cadastro de reunião) para simplificar o fluxo e evitar abertura/encerramento manual.
- Carga horária = saída − entrada; regras do estatuto ficaram **fora** do MVP.
- Sem correção manual de registros (a ata mostra "Saída pendente" em vez de inventar horário).
- Exportação por `window.print()` em vez de biblioteca de PDF.

**Síntese dos aprendizados:** Os membros e a diretoria do Calabotics aprovaram a proposta do PontoLiga e confirmaram que o controle manual de presença e montagem da ata tomam tempo e estão sujeitos a falhas, especialmente no registro de horários. Como principal aprendizado desta etapa, o apoio à ideia existe, mas a validação completa exige medir o tempo gasto hoje e testar o fluxo de registro e geração da ata em uso real para garantir confiabilidade antes do lançamento na liga.
**Mudanças realizadas no problema ou na solução:** ver [`mudancas-em-relacao-ao-projeto-original.md`](mudancas-em-relacao-ao-projeto-original.md).
