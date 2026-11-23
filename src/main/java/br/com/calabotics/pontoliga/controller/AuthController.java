package br.com.calabotics.pontoliga.controller;

import br.com.calabotics.pontoliga.dto.UsuarioLogadoResponse;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * O login e o logout são tratados pelo Spring Security (POST /api/auth/login e POST /api/auth/logout).
 * Aqui fica apenas a consulta de quem está logado.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @GetMapping("/me")
    public UsuarioLogadoResponse me(Authentication autenticacao) {
        return new UsuarioLogadoResponse(autenticacao.getName());
    }
}
