# Anexo E — Declaração de uso de IA e de componentes de terceiros

**Solução:** PontoLiga
**Turma:** ESW-MAT-PIT-4S-T1 - 55376  **Equipe:** PontoLiga
**Integrantes:** Alana Adorno, Anielly Nunes, Maria Eduarda Lima, Matheus Lima, Rebeca Carmo

## 1. Uso de inteligência artificial

Houve uso de IA? **(X) Sim  (  ) Não**

| Ferramenta ou modelo | Finalidade ou tarefa | Parte afetada | Revisão e validação realizadas |
|---|---|---|---|
| Claude (Anthropic) | Revisão do código a partir de um prompt de especificação escrito pela equipe | Backend Java/Spring, frontend HTML/CSS/JS, `pom.xml` | execução local, leitura do código, testes manuais |
| Claude (Anthropic) | Elaboração do README, documentos de `docs/`, roteiro e script de testes (`tests/`), script de demonstração (`demo/`), estrutura do pitch | Documentação e testes | Scripts e documentos foram escritos a partir do código real; revisados pela equipe |
| Google Stitch | Protótipo visual do painel (disciplina de Processos de Negócios) | Referência visual | Usado só como referência |

Observações: saídas de IA **não** são apresentadas como evidência de validação com usuários. Os campos de evidência em
`docs/problema-validacao.md`.

## 2. Componentes e recursos de terceiros

Houve uso de componentes de terceiros? **(X) Sim  (  ) Não**

| Componente ou recurso | Origem ou link | Versão e licença | Função e alterações |
|---|---|---|---|
| Spring Boot (Web MVC, Data JPA, Security, Validation), Hibernate | https://spring.io/projects/spring-boot | 4.2.1-SNAPSHOT (ver `pom.xml`); Apache 2.0 | Framework do backend; sem alterações |
| PostgreSQL JDBC Driver | https://jdbc.postgresql.org | versão gerenciada pelo Spring Boot; BSD-2-Clause | Acesso ao banco |
| PostgreSQL | https://www.postgresql.org | 19.0; PostgreSQL License | Banco de dados |
| Maven Wrapper | https://maven.apache.org/wrapper/ | Apache 2.0 | Execução do build |
| Fontes Rubik, Cairo, Khula | Google Fonts | SIL Open Font License 1.1 | Tipografia do painel (carregadas da internet, com fontes de reserva) |
| Paleta e identidade visual Calabotics | Arquivo de identidade da liga | uso autorizado pela liga | Cores e fontes do painel |

## 3. Materiais ou código preexistentes

Houve material produzido antes do POOALAB? **(X) Sim  (  ) Não**

**Identificação e origem:** documento "PontoLiga" (`pontoLiga6.pdf`) da disciplina Processos de Negócios (Prof. Haroldo Peon, UCSal, 2026) — descritivo, BMC, processos BPMN, Canvas de Projeto e protótipo no Stitch; elaborado antes e para outra disciplina.

**Contribuição nova realizada pela equipe no POOALAB:** implementação do backend e do painel web (Spring Boot, PostgreSQL, API RFID com
idempotência, atas por data, impressão em PDF), README, testes e demonstração, conforme descrito em `docs/mudancas-em-relacao-ao-projeto-original.md`.

## 4. Declaração da equipe

Declaramos que as informações acima são completas e verdadeiras; que revisamos e testamos as contribuições apoiadas por IA; que identificamos as fontes,
licenças e partes preexistentes relevantes; que não apresentamos como autoria própria material de terceiros; e que não compartilhamos dados pessoais,
credenciais ou informações restritas de forma indevida.

**Responsável pela submissão:** Alana Alves Adorno

| Nome completo | Assinatura ou registro de ciência |
|---|---|
| ALANA ALVES ADORNO | Alana |
| ANIELLY MARIA DIAS NUNES | Anielly |
| MARIA EDUARDA ROCHA QUEIROZ LIMA | Maria |
| MATHEUS SAMA DE SOUZA LIMA | Matheus |
| REBECA SIMÃO DO CARMO | Rebeca |

**Data:** 23/11/2026
