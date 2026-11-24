# Roteiro de demonstração (≈ 100 s) e contingência

Antes: aplicação rodando, `bash demo/popular-demo.sh` já executado, painel logado em outra aba, terminal com as variáveis definidas (`RFID_API_KEY`).

Atenção: o evento ao vivo (passo 2) não faz parte do script. Se ele já foi enviado em um ensaio, a Carla não aparecerá mais com "Saída pendente" em 20/11. Nesse caso, recrie o banco e execute o script de novo antes de apresentar.

1. **(15 s)** Painel → *Atas*: mostrar a lista com 4 atas (23/11, 22/11, 21/11 e 20/11), criadas a partir das leituras, sem cadastro de reunião.
2. **(30 s)** No terminal, simular o Raspberry lendo o cartão da Carla:
   ```bash
   curl -s -X POST http://localhost:8080/api/rfid/eventos -H "Content-Type: application/json" \
     -H "X-API-Key: $RFID_API_KEY" \
     -d '[{"eventId":"demo-ao-vivo-1","uid":"04C3D4E5F6","timestamp":"2026-11-20T11:00:00-03:00","eventType":"EXIT"}]'
   ```
   Resposta `"criados":1`. Repetir o mesmo comando → `"duplicados":1`.
3. **(25 s)** Abrir a ata de 20/11: Carla agora tem 09:00–11:00 = 2h00min (antes estava "Saída pendente"). Ana aparece com três períodos (2h00min, 1h30min, 1h00min), em ordem cronológica mesmo tendo sido enviados fora de ordem. Os demais: Beres 3h30min, Bruno 1h30min e Rebeca 45min.
4. **(20 s)** *Imprimir / Salvar como PDF* → mostrar a pré-visualização limpa → salvar.
5. **(10 s)** Mostrar um erro tratado: cadastrar membro com matrícula repetida (por exemplo, `2024001`, que é a da Ana, com nome e UID novos) → o sistema responde com conflito (409) e exibe a mensagem de erro.

Observação: o equipamento é simulado por `curl` (ver limitações no README).

## Contingência (não substitui o MVP)

- Gravar uma tela de 1–2 min seguindo este roteiro e salvar em `demo/demonstracao.mp4`.
- Levar o PDF de uma ata já exportada e o `docs/pitch.pdf`.
