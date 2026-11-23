package br.com.calabotics.pontoliga.repository;

import br.com.calabotics.pontoliga.dto.AtaResumoConsulta;
import br.com.calabotics.pontoliga.entity.EventoPresenca;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface EventoPresencaRepository extends JpaRepository<EventoPresenca, Long> {

    boolean existsByEventId(String eventId);

    /** Uma linha por data local, da mais recente para a mais antiga. */
    @Query("select new br.com.calabotics.pontoliga.dto.AtaResumoConsulta("
            + "e.dataLocal, min(e.ocorridoEm), max(e.ocorridoEm)) "
            + "from EventoPresenca e "
            + "group by e.dataLocal "
            + "order by e.dataLocal desc")
    List<AtaResumoConsulta> listarAtas();

    /** Todos os eventos de uma data local, em ordem cronológica (o id desempata horários iguais). */
    @Query("select e from EventoPresenca e join fetch e.membro "
            + "where e.dataLocal = :data "
            + "order by e.ocorridoEm asc, e.id asc")
    List<EventoPresenca> buscarDoDia(@Param("data") LocalDate data);
}
