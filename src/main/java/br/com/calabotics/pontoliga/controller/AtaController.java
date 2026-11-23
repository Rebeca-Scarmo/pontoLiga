package br.com.calabotics.pontoliga.controller;

import br.com.calabotics.pontoliga.dto.AtaDetalheResponse;
import br.com.calabotics.pontoliga.dto.AtaResumoResponse;
import br.com.calabotics.pontoliga.service.AtaService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/atas")
public class AtaController {

    private final AtaService ataService;

    public AtaController(AtaService ataService) {
        this.ataService = ataService;
    }

    @GetMapping
    public List<AtaResumoResponse> listar() {
        return ataService.listar();
    }

    /** A data vai no formato yyyy-MM-dd, por exemplo /api/atas/2026-11-22. */
    @GetMapping("/{data}")
    public AtaDetalheResponse detalhar(@PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate data) {
        return ataService.detalhar(data);
    }
}
