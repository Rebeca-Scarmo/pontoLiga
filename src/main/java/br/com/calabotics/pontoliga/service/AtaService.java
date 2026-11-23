package br.com.calabotics.pontoliga.service;

import br.com.calabotics.pontoliga.config.Fuso;
import br.com.calabotics.pontoliga.dto.AtaDetalheResponse;
import br.com.calabotics.pontoliga.dto.AtaDetalheResponse.ParticipanteResponse;
import br.com.calabotics.pontoliga.dto.AtaDetalheResponse.PeriodoResponse;
import br.com.calabotics.pontoliga.dto.AtaResumoResponse;
import br.com.calabotics.pontoliga.entity.EventoPresenca;
import br.com.calabotics.pontoliga.entity.Membro;
import br.com.calabotics.pontoliga.entity.TipoEvento;
import br.com.calabotics.pontoliga.exception.RecursoNaoEncontradoException;
import br.com.calabotics.pontoliga.repository.EventoPresencaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Monta as atas a partir dos eventos gravados. Não existe tabela de atas:
 * cada data local (America/Bahia) com eventos é uma ata.
 */
@Service
@Transactional(readOnly = true)
public class AtaService {

    private static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm:ss");
    private static final DateTimeFormatter DATA_BR = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final EventoPresencaRepository eventoRepository;

    public AtaService(EventoPresencaRepository eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    public List<AtaResumoResponse> listar() {
        return eventoRepository.listarAtas().stream()
                .map(ata -> new AtaResumoResponse(
                        ata.data().toString(),
                        ata.data().format(DATA_BR),
                        titulo(ata.data()),
                        hora(ata.primeiro()),
                        hora(ata.ultimo())))
                .toList();
    }

    public AtaDetalheResponse detalhar(LocalDate data) {
        List<EventoPresenca> eventos = eventoRepository.buscarDoDia(data);
        if (eventos.isEmpty()) {
            throw new RecursoNaoEncontradoException(
                    "Não há registros de presença em " + data.format(DATA_BR) + ".");
        }

        // A lista já vem em ordem cronológica; o primeiro e o último evento definem o cabeçalho.
        Instant primeiro = eventos.get(0).getOcorridoEm();
        Instant ultimo = eventos.get(eventos.size() - 1).getOcorridoEm();

        // Agrupa por membro mantendo a ordem cronológica dentro de cada grupo
        Map<Long, List<EventoPresenca>> porMembro = new LinkedHashMap<>();
        for (EventoPresenca evento : eventos) {
            porMembro.computeIfAbsent(evento.getMembro().getId(), id -> new ArrayList<>()).add(evento);
        }

        List<ParticipanteResponse> participantes = new ArrayList<>();
        for (List<EventoPresenca> doMembro : porMembro.values()) {
            Membro membro = doMembro.get(0).getMembro();
            participantes.add(new ParticipanteResponse(
                    membro.getNomeCompleto(), membro.getMatricula(), montarPeriodos(doMembro)));
        }
        participantes.sort(Comparator.comparing(ParticipanteResponse::nomeCompleto, String.CASE_INSENSITIVE_ORDER));

        return new AtaDetalheResponse(
                data.toString(), data.format(DATA_BR), titulo(data), hora(primeiro), hora(ultimo), participantes);
    }

    /**
     * Pareia as entradas e saídas de um membro, em ordem cronológica:
     * - ENTRY abre um período; o EXIT seguinte o fecha e a carga horária é saída - entrada;
     * - ENTRY sem EXIT depois dela fica como "saída pendente" (sem horário e sem duração);
     * - EXIT sem ENTRY aberta aparece sem entrada, sem inventar horário nem duração.
     */
    private List<PeriodoResponse> montarPeriodos(List<EventoPresenca> eventosDoMembro) {
        List<PeriodoResponse> periodos = new ArrayList<>();
        EventoPresenca entradaAberta = null;

        for (EventoPresenca evento : eventosDoMembro) {
            if (evento.getTipoEvento() == TipoEvento.ENTRY) {
                if (entradaAberta != null) {
                    periodos.add(periodoPendente(entradaAberta));
                }
                entradaAberta = evento;
            } else if (entradaAberta != null) {
                periodos.add(periodoCompleto(entradaAberta, evento));
                entradaAberta = null;
            } else {
                periodos.add(new PeriodoResponse(null, hora(evento.getOcorridoEm()), null, false));
            }
        }

        if (entradaAberta != null) {
            periodos.add(periodoPendente(entradaAberta));
        }
        return periodos;
    }

    private PeriodoResponse periodoCompleto(EventoPresenca entrada, EventoPresenca saida) {
        Duration duracao = Duration.between(entrada.getOcorridoEm(), saida.getOcorridoEm());
        return new PeriodoResponse(
                hora(entrada.getOcorridoEm()), hora(saida.getOcorridoEm()), formatarDuracao(duracao), false);
    }

    private PeriodoResponse periodoPendente(EventoPresenca entrada) {
        return new PeriodoResponse(hora(entrada.getOcorridoEm()), null, null, true);
    }

    private String titulo(LocalDate data) {
        return "Ata de presença - " + data.format(DATA_BR);
    }

    private String hora(Instant instante) {
        return HORA.format(instante.atZone(Fuso.BAHIA));
    }

    /** 2h30min, 45min ou 30s (os segundos só aparecem quando o período é menor que 1 minuto). */
    private String formatarDuracao(Duration duracao) {
        long horas = duracao.toHours();
        int minutos = duracao.toMinutesPart();
        int segundos = duracao.toSecondsPart();

        if (horas > 0) {
            return horas + "h" + String.format("%02d", minutos) + "min";
        }
        if (minutos > 0) {
            return minutos + "min";
        }
        return segundos + "s";
    }
}
