package br.com.calabotics.pontoliga.config;

import br.com.calabotics.pontoliga.security.ApiKeyFilter;
import br.com.calabotics.pontoliga.security.CsrfCookieFilter;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;

/**
 * Duas cadeias de segurança independentes:
 * 1) /api/rfid/**  -> equipamento (Raspberry Pi), autenticado por X-API-Key, sem sessão.
 * 2) todo o resto  -> painel do administrador, autenticado por sessão (login e senha).
 */
@Configuration
@EnableWebSecurity
public class SegurancaConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    @Order(1)
    public SecurityFilterChain cadeiaDoEquipamento(HttpSecurity http,
                                                   @Value("${app.rfid.api-key}") String chaveApi) throws Exception {
        if (chaveApi == null || chaveApi.trim().length() < 16) {
            throw new IllegalStateException(
                    "Defina a variável de ambiente RFID_API_KEY com pelo menos 16 caracteres.");
        }

        http.securityMatcher("/api/rfid/**")
                .csrf(csrf -> csrf.disable()) // API sem sessão e sem cookies: não há o que proteger com CSRF
                .sessionManagement(sessao -> sessao.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(regras -> regras.anyRequest().authenticated())
                .addFilterBefore(new ApiKeyFilter(chaveApi.trim()), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    @Order(2)
    public SecurityFilterChain cadeiaDoPainel(HttpSecurity http) throws Exception {
        // O token CSRF fica num cookie legível pelo JavaScript, que o devolve no cabeçalho X-XSRF-TOKEN.
        CsrfTokenRequestAttributeHandler tratadorCsrf = new CsrfTokenRequestAttributeHandler();

        http
                .csrf(csrf -> csrf
                        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                        .csrfTokenRequestHandler(tratadorCsrf))
                .addFilterAfter(new CsrfCookieFilter(), BasicAuthenticationFilter.class)
                .authorizeHttpRequests(regras -> regras
                        .requestMatchers("/", "/index.html", "/pages/login.html",
                                "/css/**", "/js/**", "/favicon.ico", "/error").permitAll()
                        .anyRequest().authenticated())
                .formLogin(login -> login
                        .loginPage("/pages/login.html")
                        .loginProcessingUrl("/api/auth/login")
                        .successHandler((req, res, auth) -> res.setStatus(HttpServletResponse.SC_OK))
                        .failureHandler((req, res, erro) -> res.setStatus(HttpServletResponse.SC_UNAUTHORIZED))
                        .permitAll())
                .logout(logout -> logout
                        .logoutUrl("/api/auth/logout")
                        .logoutSuccessHandler((req, res, auth) -> res.setStatus(HttpServletResponse.SC_OK))
                        .deleteCookies("JSESSIONID"))
                .exceptionHandling(erros -> erros
                        .authenticationEntryPoint((req, res, excecao) -> {
                            // Chamadas da API recebem 401; páginas são redirecionadas para o login.
                            if (req.getRequestURI().startsWith("/api/")) {
                                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            } else {
                                res.sendRedirect("/pages/login.html");
                            }
                        }));

        return http.build();
    }
}
