package br.com.calabotics.pontoliga.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Uma leitura de cartão enviada pelo equipamento.
 * - eventId: identificador externo, único (garante a idempotência);
 * - ocorridoEm: horário original da leitura (nunca é substituído pelo horário de recebimento);
 * - dataLocal: data de ocorridoEm no fuso America/Bahia (é a "ata" à qual o evento pertence);
 * - recebidoEm: horário em que o servidor recebeu o evento (auditoria).
 */
@Entity
@Table(name = "eventos_presenca",
        uniqueConstraints = @UniqueConstraint(name = "uk_evento_event_id", columnNames = "event_id"),
        indexes = {
                @Index(name = "idx_evento_data_local", columnList = "data_local, ocorrido_em"),
                @Index(name = "idx_evento_membro", columnList = "membro_id")
        })
public class EventoPresenca {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false, length = 100)
    private String eventId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "membro_id", nullable = false, foreignKey = @ForeignKey(name = "fk_evento_membro"))
    private Membro membro;

    @Column(name = "uid", nullable = false, length = 20)
    private String uid;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_evento", nullable = false, length = 10)
    private TipoEvento tipoEvento;

    @Column(name = "ocorrido_em", nullable = false)
    private Instant ocorridoEm;

    @Column(name = "data_local", nullable = false)
    private LocalDate dataLocal;

    @Column(name = "recebido_em", nullable = false)
    private Instant recebidoEm;

    protected EventoPresenca() {
        // exigido pelo JPA
    }

    public EventoPresenca(String eventId, Membro membro, String uid, TipoEvento tipoEvento,
                          Instant ocorridoEm, LocalDate dataLocal, Instant recebidoEm) {
        this.eventId = eventId;
        this.membro = membro;
        this.uid = uid;
        this.tipoEvento = tipoEvento;
        this.ocorridoEm = ocorridoEm;
        this.dataLocal = dataLocal;
        this.recebidoEm = recebidoEm;
    }

    public Long getId() {
        return id;
    }

    public String getEventId() {
        return eventId;
    }

    public Membro getMembro() {
        return membro;
    }

    public String getUid() {
        return uid;
    }

    public TipoEvento getTipoEvento() {
        return tipoEvento;
    }

    public Instant getOcorridoEm() {
        return ocorridoEm;
    }

    public LocalDate getDataLocal() {
        return dataLocal;
    }

    public Instant getRecebidoEm() {
        return recebidoEm;
    }
}
