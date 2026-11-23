package br.com.calabotics.pontoliga.controller;

import br.com.calabotics.pontoliga.dto.MembroRequest;
import br.com.calabotics.pontoliga.dto.MembroResponse;
import br.com.calabotics.pontoliga.service.MembroService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/membros")
public class MembroController {

    private final MembroService membroService;

    public MembroController(MembroService membroService) {
        this.membroService = membroService;
    }

    @GetMapping
    public List<MembroResponse> listar() {
        return membroService.listar();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MembroResponse cadastrar(@Valid @RequestBody MembroRequest dados) {
        return membroService.cadastrar(dados);
    }

    @PutMapping("/{id}")
    public MembroResponse atualizar(@PathVariable Long id, @Valid @RequestBody MembroRequest dados) {
        return membroService.atualizar(id, dados);
    }
}
