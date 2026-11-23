package br.com.calabotics.pontoliga.config;

import br.com.calabotics.pontoliga.entity.Admin;
import br.com.calabotics.pontoliga.repository.AdminRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Locale;

/**
 * Cria o único administrador na primeira execução, usando a senha da variável de ambiente ADMIN_PASSWORD.
 * Se o administrador já existir, nada é feito (a variável deixa de ser necessária).
 */
@Component
public class AdminInicializador implements CommandLineRunner {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final String usuario;
    private final String senha;

    public AdminInicializador(AdminRepository adminRepository,
                              PasswordEncoder passwordEncoder,
                              @Value("${app.admin.username}") String usuario,
                              @Value("${app.admin.password}") String senha) {
        this.adminRepository = adminRepository;
        this.passwordEncoder = passwordEncoder;
        this.usuario = usuario;
        this.senha = senha;
    }

    @Override
    public void run(String... args) {
        if (adminRepository.count() > 0) {
            return;
        }
        if (senha == null || senha.length() < 8) {
            throw new IllegalStateException(
                    "Nenhum administrador cadastrado. Defina a variável de ambiente ADMIN_PASSWORD "
                            + "(mínimo de 8 caracteres) e reinicie a aplicação.");
        }
        adminRepository.save(new Admin(usuario.trim().toUpperCase(Locale.ROOT), passwordEncoder.encode(senha)));
    }
}
