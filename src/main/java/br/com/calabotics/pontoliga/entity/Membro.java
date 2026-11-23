package br.com.calabotics.pontoliga.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "membros",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_membro_matricula", columnNames = "matricula"),
                @UniqueConstraint(name = "uk_membro_uid_tag", columnNames = "uid_tag")
        })
public class Membro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nome_completo", nullable = false, length = 150)
    private String nomeCompleto;

    @Column(name = "matricula", nullable = false, length = 30)
    private String matricula;

    @Column(name = "uid_tag", nullable = false, length = 20)
    private String uidTag;

    protected Membro() {
        // exigido pelo JPA
    }

    public Membro(String nomeCompleto, String matricula, String uidTag) {
        this.nomeCompleto = nomeCompleto;
        this.matricula = matricula;
        this.uidTag = uidTag;
    }

    public void atualizar(String nomeCompleto, String matricula, String uidTag) {
        this.nomeCompleto = nomeCompleto;
        this.matricula = matricula;
        this.uidTag = uidTag;
    }

    public Long getId() {
        return id;
    }

    public String getNomeCompleto() {
        return nomeCompleto;
    }

    public String getMatricula() {
        return matricula;
    }

    public String getUidTag() {
        return uidTag;
    }
}
