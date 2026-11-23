package br.com.calabotics.pontoliga.repository;

import br.com.calabotics.pontoliga.entity.Membro;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MembroRepository extends JpaRepository<Membro, Long> {

    List<Membro> findAllByOrderByNomeCompletoAsc();

    Optional<Membro> findByUidTag(String uidTag);

    boolean existsByMatricula(String matricula);

    boolean existsByUidTag(String uidTag);

    boolean existsByMatriculaAndIdNot(String matricula, Long id);

    boolean existsByUidTagAndIdNot(String uidTag, Long id);
}
