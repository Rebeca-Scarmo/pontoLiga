# PontoLiga

Sistema web de controle de presença por cartões RFID para a Liga Acadêmica de Robótica Calabotics (UCSal).
Um equipamento externo (Raspberry Pi + leitor RFID) envia as leituras por HTTP; o backend valida, grava no
PostgreSQL e monta **uma ata de presença por dia**; o painel web permite cadastrar membros, consultar as atas e
**exportar cada ata em PDF** pela impressão nativa do navegador (`window.print()`).

> POOALAB 2026.2 — Programação Orientada a Objetos Avançada (Prof. Mario Jorge Pereira) — UCSal.

## Integrantes

| Nome completo | Turma |
|---|---|
| ALANA ALVES ADORNO | ESW-MAT-PIT-4S-T1 - 55376 |
| ANIELLY MARIA DIAS NUNES | ESW-MAT-PIT-4S-T1 - 55376 |
| MARIA EDUARDA ROCHA QUEIROZ LIMA | ESW-MAT-PIT-4S-T1 - 55376 |
| MATHEUS SAMA DE SOUZA LIMA | ESW-MAT-PIT-4S-T1 - 55376 |
| REBECA SIMÃO DO CARMO | ESW-MAT-PIT-4S-T1 - 55376 |

## Problema, público e proposta de valor

- **Público:** membros e diretoria do Calabotics (e ligas/laboratórios com rotina parecida).
- **Problema:** o controle de presença e a ata das reuniões são feitos à mão: toma tempo, deixa registros
  desorganizados e permite erros. Detalhes e evidências em [`docs/problema-validacao.md`](docs/problema-validacao.md).
- **Proposta:** aproximar o cartão registra entrada/saída automaticamente e a ata do dia fica pronta para
  consulta e exportação, sem digitação manual.

## Escopo do MVP (fluxo principal)

`Raspberry/curl envia leitura → API valida e grava → ata do dia é montada → admin consulta e imprime/salva em PDF`

Dentro do escopo: login do ADMIN, CRUD simples de membros (cadastrar/listar/editar), API de eventos RFID com
`X-API-Key`, idempotência por `eventId`, atas automáticas por data (`America/Bahia`), saída pendente,
carga horária por período, impressão/PDF.
Fora do escopo: software do Raspberry, relatórios consolidados, horas complementares do estatuto, correção manual
de registros, múltiplos usuários. Ver [`docs/definicao-mvp.md`](docs/definicao-mvp.md).

## Tecnologias e justificativas

| Tecnologia | Versão | Por quê |
|---|---|---|
| Java | 21 | LTS; `records`, `stream` e tipos de data/hora (`java.time`) usados no código |
| Spring Boot (Web MVC, Data JPA, Security, Validation) | **4.2.1-SNAPSHOT** (ver "Riscos conhecidos") | API REST, persistência, sessão + BCrypt, validação |
| PostgreSQL | 14 ou superior (qualquer versão atual) | restrições de unicidade e índices exigidos pela idempotência |
| Maven (wrapper `mvnw`) | incluído | não exige instalar Maven |
| HTML5 + CSS3 + JavaScript puro | — | painel pequeno; sem frameworks |

## Pré-requisitos

- JDK 21 (`java -version`)
- PostgreSQL em execução local (porta 5432)
- `curl` (para testes e demonstração); `bash` para os scripts de `tests/` e `demo/`
- Navegador moderno (Chrome/Edge/Firefox) para o painel e para "Salvar como PDF"
- Acesso à internet na primeira execução (Maven baixa dependências; fontes Rubik/Cairo/Khula vêm do Google Fonts —
  sem internet a interface usa fontes de reserva e continua funcional)

## Instalação e execução (passo a passo)

### 1. Criar o banco

```bash
psql -U postgres
```
```sql
CREATE USER pontoliga_app WITH PASSWORD 'troque_esta_senha_local';
CREATE DATABASE pontoliga OWNER pontoliga_app ENCODING 'UTF8';
\c pontoliga
GRANT ALL ON SCHEMA public TO pontoliga_app;
\q
```
As tabelas são criadas automaticamente na primeira execução (`spring.jpa.hibernate.ddl-auto=update`).

### 2. Definir as variáveis de ambiente

Use os valores de [`.env.example`](.env.example) (fictícios). Obrigatórias:

| Variável | Função |
|---|---|
| `DB_PASSWORD` | senha do usuário do banco |
| `ADMIN_PASSWORD` | senha inicial do ADMIN (mín. 8 caracteres; usada só se ainda não existir administrador) |
| `RFID_API_KEY` | chave do equipamento, enviada em `X-API-Key` (mín. 16 caracteres) |

Opcionais: `DB_URL`, `DB_USERNAME`, `COOKIE_SECURE` (use `true` apenas com HTTPS).
A aplicação **não inicia** sem `DB_PASSWORD`, `ADMIN_PASSWORD` (1ª execução) e `RFID_API_KEY` válidos.

Linux/macOS:
```bash
export DB_PASSWORD='troque_esta_senha_local'
export ADMIN_PASSWORD='admin_demo_2026'
export RFID_API_KEY='chave-demo-rfid-0123456789abcdef'
```
Windows (PowerShell):
```powershell
$env:DB_PASSWORD='troque_esta_senha_local'
$env:ADMIN_PASSWORD='admin_demo_2026'
$env:RFID_API_KEY='chave-demo-rfid-0123456789abcdef'
```

### 3. Executar

Pelo terminal:
```bash
./mvnw spring-boot:run          # Windows: mvnw.cmd spring-boot:run
```
Pelo IntelliJ: abrir a pasta como projeto Maven, abrir `PontoligaApplication`, definir as variáveis em
*Run > Edit Configurations > Environment variables* e executar.

Sucesso = log com `Started PontoligaApplication` e a página http://localhost:8080 abrindo o login.

### 4. Acessar

http://localhost:8080 — usuário **ADMIN** (maiúsculas ou minúsculas), senha = valor de `ADMIN_PASSWORD`.

## Dados de demonstração (fictícios)

Com a aplicação rodando:
```bash
export ADMIN_PASSWORD='admin_demo_2026'
export RFID_API_KEY='chave-demo-rfid-0123456789abcdef'
bash demo/popular-demo.sh
```
Cria 4 membros fictícios e envia eventos que geram três atas (20/11, 21/11 e 22/11/2026), incluindo vários
períodos, saída pendente, evento atrasado e reenvio duplicado. O script pode ser repetido sem duplicar dados.

## Roteiro curto para reproduzir o fluxo principal

1. Rodar `bash demo/popular-demo.sh`.
2. Entrar no painel como ADMIN → **Atas** → abrir **Ata de presença - 20/11/2026**.
3. Conferir períodos, "Saída pendente" e carga horária.
4. Clicar em **Imprimir / Salvar como PDF** → destino "Salvar como PDF".
5. Opcional: enviar uma leitura nova com `curl` (ver `demo/roteiro-demonstracao.md`) e recarregar a ata.

## Testes

Roteiro de testes de ponta a ponta via `curl` (a pedido do projeto, sem classes JUnit):
```bash
export ADMIN_PASSWORD='admin_demo_2026'
export RFID_API_KEY='chave-demo-rfid-0123456789abcdef'
bash tests/testes-api.sh
```
Cada teste imprime `OK`/`FALHOU`; o script termina com código ≠ 0 se algum falhar. Descrição dos casos e do que
é validado manualmente (impressão/PDF) em [`tests/roteiro-de-testes.md`](tests/roteiro-de-testes.md).

## API (resumo)

| Método | Rota | Autenticação | Função |
|---|---|---|---|
| POST | `/api/auth/login` | — (form: username, password + CSRF) | login |
| POST | `/api/auth/logout` | sessão | logout |
| GET | `/api/auth/me` | sessão | usuário logado |
| GET/POST/PUT | `/api/membros`, `/api/membros/{id}` | sessão | listar / cadastrar / editar |
| GET | `/api/atas`, `/api/atas/{yyyy-MM-dd}` | sessão | listar atas / detalhar |
| POST | `/api/rfid/eventos` | `X-API-Key` | recebe lista de eventos |

Exemplo de evento: `{"eventId":"uuid","uid":"04A1B2C3D4","timestamp":"2026-11-22T08:30:00-03:00","eventType":"ENTRY"}`.

## Limitações conhecidas e próximos passos

- O software do Raspberry Pi **não faz parte** deste projeto: o equipamento é **simulado** com `curl`/scripts (integração
  simulada com dados controlados).
- O backend confia no `eventType` enviado pelo equipamento; ENTRY repetida vira "saída pendente" e EXIT sem ENTRY aparece
  sem horário de entrada. Não há validação rígida da alternância.
- Sem correção manual de registros, sem exclusão de membros, sem recuperação de senha, um único ADMIN.
- Carga horária = saída − entrada; não implementa horas complementares do estatuto.
- Tabelas criadas por `ddl-auto=update` (sem migrations).
- Não há testes JUnit; a verificação é por roteiro `curl` + conferência visual do painel.
- Fontes do Google Fonts exigem internet (há fallback).
- Próximos passos: validar com uma reunião real do Calabotics, integrar o Raspberry real, regras do estatuto.

## Riscos conhecidos

- **Versão do Spring Boot:** o `pom.xml` usa `4.2.1-SNAPSHOT` (repositório de snapshots do Spring). Snapshots mudam
  ou somem; se o build falhar em outra máquina, troque `<version>` do parent por uma versão estável (por exemplo 4.1.2) e
  rode `./mvnw clean package`.

## Documentação do projeto

| Arquivo | Conteúdo |
|---|---|
| `docs/problema-validacao.md` | Anexos A e B (ficha do problema, registro de validação) |
| `docs/definicao-mvp.md` | Anexo C |
| `docs/pitch.pdf` · `docs/roteiro-pitch.md` | Pitch (Anexo D) |
| `docs/declaracao-ia-terceiros.md` | Anexo E |
| `docs/poo-aplicada.md` | Aplicação de conteúdos de POOA (bônus) |
| `docs/mudancas-em-relacao-ao-projeto-original.md` | O que mudou em relação ao documento de Processos de Negócios |
| `demo/` | dados e roteiro de demonstração |
| `tests/` | roteiro e script de testes |

## Fontes, licenças, componentes de terceiros e uso de IA

Ver [`docs/declaracao-ia-terceiros.md`](docs/declaracao-ia-terceiros.md).
