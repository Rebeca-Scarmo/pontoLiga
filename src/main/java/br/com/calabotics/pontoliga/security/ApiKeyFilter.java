package br.com.calabotics.pontoliga.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;

/**
 * Autentica o equipamento pelo cabeçalho X-API-Key.
 * Esta classe NÃO é um bean: ela só é usada dentro da cadeia /api/rfid/** (ver SegurancaConfig).
 */
public class ApiKeyFilter extends OncePerRequestFilter {

    private static final String CABECALHO = "X-API-Key";

    private final byte[] chaveEsperada;

    public ApiKeyFilter(String chave) {
        this.chaveEsperada = chave.getBytes(StandardCharsets.UTF_8);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String recebida = request.getHeader(CABECALHO);

        // MessageDigest.isEqual compara em tempo constante (evita ataques por tempo de resposta)
        boolean valida = recebida != null
                && MessageDigest.isEqual(chaveEsperada, recebida.getBytes(StandardCharsets.UTF_8));

        if (!valida) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"mensagem\":\"API Key ausente ou inválida.\",\"campos\":{}}");
            return;
        }

        SecurityContext contexto = SecurityContextHolder.createEmptyContext();
        contexto.setAuthentication(new UsernamePasswordAuthenticationToken(
                "equipamento-rfid", null, List.of(new SimpleGrantedAuthority("ROLE_EQUIPAMENTO"))));
        SecurityContextHolder.setContext(contexto);

        filterChain.doFilter(request, response);
    }
}
