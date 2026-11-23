package br.com.calabotics.pontoliga.service;

import br.com.calabotics.pontoliga.config.Fuso;
import br.com.calabotics.pontoliga.dto.EventoRfidRequest;
import br.com.calabotics.pontoliga.dto.ResultadoEventoResponse;
import br.com.calabotics.pontoliga.dto.ResultadoLoteResponse;
import br.com.calabotics.pontoliga.entity.EventoPresenca;
import br.com.calabotics.pontoliga.entity.Membro;
import br.com.calabotics.pontoliga.entity.TipoEvento;
import br.com.calabotics.pontoliga.repository.EventoPresencaRepository;
import br.com.calabotics.pontoliga.repository.MembroRepository;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Recebe os eventos do equipamento.
 *
 * Esta classe propositalmente NÃO é @Transactional: cada evento é gravado na sua própria transação
 * (o saveAndFlush do repositório). Assim, se um evento falhar (ex.: duplicado por concorrência),
 * os demais do lote continuam sendo gravados normalmente.
 */
@Service
public class EventoPresencaService {

    private final EventoPresencaRepository eventoRepository;
    private final MembroRepository membroRepository;
    private final Validator validator;

    public EventoPresencaService(EventoPresencaRepository eventoRepository,
                                 MembroRepository membroRepository,
                                 Validator validator) {
        this.eventoRepository = eventoRepository;
        this.membroRepository = membroRepository;
        this.validator = validator;
    }

    public ResultadoLoteResponse receberLote(List<EventoRfidRequest> eventos) {
        List<ResultadoEventoResponse> resultados = new ArrayList<>();
        int criados = 0;
        int duplicados = 0;
        int rejeitados = 0;

        for (EventoRfidRequest evento : eventos) {
            ResultadoEventoResponse resultado = processar(evento);
            resultados.add(resultado);

            switch (resultado.status()) {
                case ResultadoEventoResponse.CRIADO -> criados++;
                case ResultadoEventoResponse.DUPLICADO -> duplicados++;
                default -> rejeitados++;
            }
        }

        return new ResultadoLoteResponse(eventos.size(), criados, duplicados, rejeitados, resultados);
    }

    private ResultadoEventoResponse processar(EventoRfidRequest evento) {
        if (evento == null) {
            return ResultadoEventoResponse.rejeitado(null, "Evento vazio.");
        }

        // 1. Validação dos campos (Bean Validation)
        Set<ConstraintViolation<EventoRfidRequest>> violacoes = validator.validate(evento);
        if (!violacoes.isEmpty()) {
            String motivo = violacoes.stream()
                    .map(ConstraintViolation::getMessage)
                    .sorted()
                    .collect(Collectors.joining(" "));
            return ResultadoEventoResponse.rejeitado(evento.eventId(), motivo);
        }

        String eventId = evento.eventId().trim();
        String uid = evento.uid().trim().toUpperCase(Locale.ROOT);
        TipoEvento tipo = TipoEvento.valueOf(evento.eventType());

        // 2. Horário original da leitura
        Instant ocorridoEm;
        try {
            ocorridoEm = interpretarHorario(evento.timestamp().trim());
        } catch (DateTimeParseException e) {
            return ResultadoEventoResponse.rejeitado(eventId,
                    "timestamp inválido. Use ISO 8601, por exemplo 2026-11-22T08:30:00-03:00.");
        }

        // 3. Idempotência: o mesmo eventId nunca gera um segundo registro
        if (eventoRepository.existsByEventId(eventId)) {
            return ResultadoEventoResponse.duplicado(eventId);
        }

        // 4. O cartão precisa estar cadastrado
        Optional<Membro> membro = membroRepository.findByUidTag(uid);
        if (membro.isEmpty()) {
            return ResultadoEventoResponse.rejeitado(eventId, "UID não cadastrado: " + uid + ".");
        }

        // 5. A data da ata vem do horário em que a leitura aconteceu, no fuso de Salvador
        LocalDate dataLocal = ocorridoEm.atZone(Fuso.BAHIA).toLocalDate();

        try {
            eventoRepository.saveAndFlush(new EventoPresenca(
                    eventId, membro.get(), uid, tipo, ocorridoEm, dataLocal, Instant.now()));
            return ResultadoEventoResponse.criado(eventId);
        } catch (DataIntegrityViolationException e) {
            // Duas requisições com o mesmo eventId ao mesmo tempo: a restrição única do banco barra a segunda.
            return ResultadoEventoResponse.duplicado(eventId);
        }
    }

    /**
     * Aceita ISO 8601 com fuso (preferencial). Se vier sem fuso, assume America/Bahia.
     */
    private Instant interpretarHorario(String texto) {
        try {
            return OffsetDateTime.parse(texto).toInstant();
        } catch (DateTimeParseException comFusoInvalido) {
            return LocalDateTime.parse(texto).atZone(Fuso.BAHIA).toInstant();
        }
    }
}
