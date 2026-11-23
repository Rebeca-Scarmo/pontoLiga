# Anexo E — Declaração de uso de IA e de componentes de terceiros

**Solução:** PontoLiga
**Turma:** ⚠️ PREENCHER  **Equipe:** ⚠️ PREENCHER
**Integrantes:** ⚠️ PREENCHER

> ⚠️ Confira cada linha: a equipe responde pela veracidade desta declaração. Ajuste se usou outras ferramentas.

## 1. Uso de inteligência artificial

Houve uso de IA? **(X) Sim  (  ) Não**

| Ferramenta ou modelo | Finalidade ou tarefa | Parte afetada | Revisão e validação realizadas |
|---|---|---|---|
| Assistente de IA (⚠️ confirmar ferramenta/modelo usado no desenvolvimento) | Geração do código a partir de um prompt de especificação escrito pela equipe | Backend Java/Spring, frontend HTML/CSS/JS, `pom.xml` | ⚠️ descrever: execução local, leitura do código, testes manuais |
| Claude (Anthropic) | Elaboração do README, documentos de `docs/`, roteiro e script de testes (`tests/`), script de demonstração (`demo/`), estrutura do pitch | Documentação e testes | Scripts e documentos foram escritos a partir do código real; ⚠️ a equipe deve executá-los e revisá-los (não foram executados no momento da geração) |
| Google Stitch | Protótipo visual do painel (disciplina de Processos de Negócios) | Referência visual | Usado só como referência |

Observações: saídas de IA **não** são apresentadas como evidência de validação com usuários. Os campos de evidência em
`docs/problema-validacao.md` estão em branco até a equipe coletar dados reais.

## 2. Componentes e recursos de terceiros

Houve uso de componentes de terceiros? **(X) Sim  (  ) Não**

| Componente ou recurso | Origem ou link | Versão e licença | Função e alterações |
|---|---|---|---|
| Spring Boot (Web MVC, Data JPA, Security, Validation), Hibernate | https://spring.io/projects/spring-boot | 4.2.1-SNAPSHOT (ver `pom.xml`); Apache 2.0 | Framework do backend; sem alterações |
| PostgreSQL JDBC Driver | https://jdbc.postgresql.org | versão gerenciada pelo Spring Boot; BSD-2-Clause | Acesso ao banco |
| PostgreSQL | https://www.postgresql.org | ⚠️ informar versão; PostgreSQL License | Banco de dados |
| Maven Wrapper | https://maven.apache.org/wrapper/ | Apache 2.0 | Execução do build |
| Fontes Rubik, Cairo, Khula | Google Fonts | SIL Open Font License 1.1 | Tipografia do painel (carregadas da internet, com fontes de reserva) |
| Paleta e identidade visual Calabotics | Arquivo de identidade da liga | uso autorizado pela liga (⚠️ confirmar) | Cores e fontes do painel |

## 3. Materiais ou código preexistentes

Houve material produzido antes do POOALAB? **(X) Sim  (  ) Não**

**Identificação e origem:** documento "PontoLiga" (`pontoLiga6.pdf`) da disciplina Processos de Negócios (Prof. Haroldo Peon, UCSal,
2026) — descritivo, BMC, processos BPMN, Canvas de Projeto e protótipo no Stitch; elaborado antes e para outra disciplina.
⚠️ Informe se alguma parte do código ou protótipo já existia antes de iniciar o POOALAB.

**Contribuição nova realizada pela equipe no POOALAB:** implementação do backend e do painel web (Spring Boot, PostgreSQL, API RFID com
idempotência, atas por data, impressão em PDF), README, testes e demonstração, conforme descrito em `docs/mudancas-em-relacao-ao-projeto-original.md`.

## 4. Declaração da equipe

Declaramos que as informações acima são completas e verdadeiras; que revisamos e testamos as contribuições apoiadas por IA; que identificamos as fontes,
licenças e partes preexistentes relevantes; que não apresentamos como autoria própria material de terceiros; e que não compartilhamos dados pessoais,
credenciais ou informações restritas de forma indevida.

**Responsável pela submissão:** ⚠️ PREENCHER

| Nome completo | Assinatura ou registro de ciência |
|---|---|
| ⚠️ | ⚠️ |
| ⚠️ | ⚠️ |
| ⚠️ | ⚠️ |
| ⚠️ | ⚠️ |

**Data:** ____/____/________
