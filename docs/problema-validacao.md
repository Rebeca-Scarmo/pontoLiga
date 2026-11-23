# Problema e validação (Anexos A e B)

> ⚠️ **Honestidade da validação:** este arquivo separa o que é *fato documentado*, *hipótese* e *evidência a coletar*.
> Os campos marcados **PREENCHER** devem ser completados pela equipe com observações/entrevistas **reais**. Não invente
> dados: o manual considera evidência inventada uma situação que compromete a avaliação.

## Anexo A — Ficha do problema

**Solução:** PontoLiga — presença por cartão RFID com ata automática.
**Equipe, turma e integrantes:** ⚠️ PREENCHER

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
| ⚠️ __/__/____ — membro da diretoria (sem nome) | O controle manual consome tempo e gera erros | ⚠️ PREENCHER (o que foi dito/medido) | ⚠️ PREENCHER |
| ⚠️ __/__/____ — membro da liga (sem nome) | Aproximar o cartão é simples o bastante | ⚠️ PREENCHER | ⚠️ PREENCHER |
| ⚠️ __/__/____ — reunião real ou ensaio | A ata do sistema bate com a lista manual | ⚠️ PREENCHER (nº de divergências) | ⚠️ PREENCHER |
| ⚠️ __/__/____ — colega/par testando o painel | O painel é compreensível sem explicação | ⚠️ PREENCHER (onde travou) | ⚠️ PREENCHER |

### Decisões já tomadas (registradas no desenvolvimento)

Estas são decisões de escopo, **não** evidências com usuários:

- Ata por **dia** (sem cadastro de reunião) para simplificar o fluxo e evitar abertura/encerramento manual.
- Carga horária = saída − entrada; regras do estatuto ficaram **fora** do MVP.
- Sem correção manual de registros (a ata mostra "Saída pendente" em vez de inventar horário).
- Exportação por `window.print()` em vez de biblioteca de PDF.

**Síntese dos aprendizados:** ⚠️ PREENCHER após as observações.
**Mudanças realizadas no problema ou na solução:** ver [`mudancas-em-relacao-ao-projeto-original.md`](mudancas-em-relacao-ao-projeto-original.md).
