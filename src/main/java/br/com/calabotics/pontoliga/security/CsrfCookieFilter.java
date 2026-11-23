package br.com.calabotics.pontoliga.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * O Spring Security só gera o token CSRF quando alguém o lê. Este filtro força a leitura em toda
 * requisição, para o cookie XSRF-TOKEN estar sempre presente quando o JavaScript precisar dele.
 * Não é um bean: é registrado apenas na cadeia do painel (ver SegurancaConfig).
 */
public class CsrfCookieFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        CsrfToken token = (CsrfToken) request.getAttribute("_csrf");
        if (token != null) {
            token.getToken();
        }
        filterChain.doFilter(request, response);
    }
}
