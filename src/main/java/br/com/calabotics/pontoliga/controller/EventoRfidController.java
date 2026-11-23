package br.com.calabotics.pontoliga.controller;

import br.com.calabotics.pontoliga.dto.EventoRfidRequest;
import br.com.calabotics.pontoliga.dto.ResultadoLoteResponse;
import br.com.calabotics.pontoliga.exception.RequisicaoInvalidaException;
import br.com.calabotics.pontoliga.service.EventoPresencaService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Endpoint usado pelo Raspberry Pi. Autenticado por X-API-Key (ver SegurancaConfig).
 * O corpo é sempre uma lista JSON de eventos (um único evento = lista com um item).
 */
@RestController
@RequestMapping("/api/rfid")
public class EventoRfidController {

    private static final int MAXIMO_POR_LOTE = 500;

    private final EventoPresencaService eventoService;

    public EventoRfidController(EventoPresencaService eventoService) {
        this.eventoService = eventoService;
    }

    @PostMapping("/eventos")
    public ResultadoLoteResponse receber(@RequestBody List<EventoRfidRequest> eventos) {
        if (eventos == null || eventos.isEmpty()) {
            throw new RequisicaoInvalidaException("Envie ao menos um evento.");
        }
        if (eventos.size() > MAXIMO_POR_LOTE) {
            throw new RequisicaoInvalidaException("Envie no máximo " + MAXIMO_POR_LOTE + " eventos por requisição.");
        }
        return eventoService.receberLote(eventos);
    }
}
