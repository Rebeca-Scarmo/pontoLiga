# Conteúdos de POOA aplicados (para o bônus)

Lista do que **existe de fato** no código, com onde ver e por que foi usado.

| Conteúdo | Onde está | Justificativa |
|---|---|---|
| **SRP** (responsabilidade única) | `controller` (HTTP), `service` (regras), `repository` (acesso a dados), `entity`, `dto`, `exception`, `security` | Cada camada muda por um motivo; `AtaService` só monta atas, `EventoPresencaService` só recebe eventos |
| **DIP** e injeção de dependência | Construtores recebem `Repository`/`Service`/`PasswordEncoder`; `AdminUserDetailsService implements UserDetailsService` | Serviços dependem de abstrações do Spring/Spring Data, não de implementações concretas |
| **Encapsulamento / imutabilidade** | Entidades sem setters públicos (`Membro.atualizar(...)`); `record` nos DTOs (`MembroRequest`, `AtaDetalheResponse`…) | Estados válidos garantidos e DTOs imutáveis |
| **Collections e Streams** | `AtaService.detalhar`: `LinkedHashMap` + `computeIfAbsent` para agrupar por membro, `Comparator` para ordenar, `stream().map(...).toList()` na listagem; `EventoPresencaService`: `stream().map().sorted().collect(joining)` | Agrupar eventos por membro mantendo a ordem cronológica |
| **Factory Method (estático)** | `ResultadoEventoResponse.criado/duplicado/rejeitado`, `MembroResponse.de(...)` | Criação padronizada dos resultados |
| **Template Method / Chain of Responsibility** | `ApiKeyFilter` e `CsrfCookieFilter` estendem `OncePerRequestFilter`; duas `SecurityFilterChain` (`SegurancaConfig`) | Autenticação do equipamento separada da sessão do admin, cada uma como cadeia de filtros |
| **Anotações** | Bean Validation (`@NotBlank`, `@Pattern`) nos DTOs; JPA (`@Entity`, `@UniqueConstraint`, `@Index`); `@RestControllerAdvice` | Validação e mapeamento declarativos; unicidade de `eventId` garantida no banco |
| **Exceções próprias + tratamento global** | `exception/*`, `TratadorGlobalDeErros` | Respostas de erro padronizadas sem vazar detalhes |
| **Transações e concorrência** | `EventoPresencaService` grava cada evento em transação própria e trata `DataIntegrityViolationException` | Deduplicação segura mesmo com requisições simultâneas |


