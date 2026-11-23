# Roteiro de demonstração (≈ 100 s) e contingência

Antes: aplicação rodando, `bash demo/popular-demo.sh` já executado, painel logado em outra aba, terminal com as variáveis definidas.

1. **(15 s)** Painel → *Atas*: mostrar a lista (22/11, 21/11, 20/11) criada sem cadastro de reunião.
2. **(30 s)** No terminal, simular o Raspberry lendo um cartão:
   ```bash
   curl -s -X POST http://localhost:8080/api/rfid/eventos -H "Content-Type: application/json" \
     -H "X-API-Key: $RFID_API_KEY" \
     -d '[{"eventId":"demo-ao-vivo-1","uid":"C3D4E5F6","timestamp":"2026-11-20T11:00:00-03:00","eventType":"EXIT"}]'
   ```
   Resposta `"criados":1`. Repetir o mesmo comando → `"duplicados":1`.
3. **(25 s)** Abrir a ata de 20/11: Carla agora tem 09:00–11:00 = 2h00min (antes estava "Saída pendente"); Ana com três períodos.
4. **(20 s)** *Imprimir / Salvar como PDF* → mostrar a pré-visualização limpa → salvar.
5. **(10 s)** Mostrar um erro tratado: cadastrar membro com matrícula repetida.

Observação: o equipamento é simulado por `curl` (ver limitações no README).

## Contingência (não substitui o MVP)

- Gravar uma tela de 1–2 min seguindo este roteiro e salvar em `demo/demonstracao.mp4`.
- Levar o PDF de uma ata já exportada e o `docs/pitch.pdf`.
