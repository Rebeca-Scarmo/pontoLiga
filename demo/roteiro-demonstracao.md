# Roteiro de demonstração (≈ 100 s) e contingência

Antes: banco limpo (membros e eventos), aplicação rodando, `bash demo/popular-demo.sh` já executado, painel logado em outra aba, terminal com a variável `RFID_API_KEY` definida.

Atenção: os eventos ao vivo (passo 2) não fazem parte do script. Se já foram enviados em um ensaio, a ata de 23/11 já existirá. Nesse caso, apague membros e eventos e execute o script de novo antes de apresentar.

1. **(15 s)** Painel → *Atas*: mostrar a lista com 3 atas (22/11, 21/11 e 20/11), criadas a partir das leituras, sem cadastro de reunião. Cada data diferente gerou uma ata diferente.
2. **(30 s)** No terminal, simular o Raspberry lendo o cartão do Bruno em um dia novo (23/11):
   ```bash
   curl -s -X POST http://localhost:8080/api/rfid/eventos -H "Content-Type: application/json" \
     -H "X-API-Key: $RFID_API_KEY" \
     -d '[{"eventId":"demo-ao-vivo-1","uid":"04B2C3D4E5","timestamp":"2026-11-23T09:00:00-03:00","eventType":"ENTRY"},
          {"eventId":"demo-ao-vivo-2","uid":"04B2C3D4E5","timestamp":"2026-11-23T10:00:00-03:00","eventType":"EXIT"}]'
   ```
   Resposta `"criados":2`. Repetir o mesmo comando → `"duplicados":2`.
3. **(25 s)** Voltar a *Atas* e atualizar: surgiu a ata de 23/11 (agora são 4), criada pela própria requisição. Abri-la: Bruno 09:00–10:00 = 1h00min. Se sobrar tempo, mostrar a ata de 20/11: Ana com dois períodos (2h00min e 1h30min) em ordem cronológica, mesmo tendo sido enviados fora de ordem, e a de 21/11 com o Bruno em "Saída pendente".
4. **(20 s)** *Imprimir / Salvar como PDF* → mostrar a pré-visualização limpa → salvar.
5. **(10 s)** Mostrar um erro tratado: cadastrar membro com matrícula repetida (por exemplo, `2024001`, que é a da Ana, com nome e UID novos) → o sistema responde com conflito (409) e exibe a mensagem de erro.

Observação: o equipamento é simulado por `curl` (ver limitações no README).

## Estado esperado das atas

- **20/11:** Ana 2h00min e 1h30min; Bruno 2h30min.
- **21/11:** Ana 40min; Carla 1h30min; Bruno com "Saída pendente".
- **22/11:** Carla 2h30min; Ana 45min.
- **23/11 (criada ao vivo):** Bruno 1h00min.

## Contingência (não substitui o MVP)

- Gravar uma tela de 1–2 min seguindo este roteiro e salvar em `demo/demonstracao.mp4`.
- Levar o PDF de uma ata já exportada e o `docs/pitch.pdf`.
