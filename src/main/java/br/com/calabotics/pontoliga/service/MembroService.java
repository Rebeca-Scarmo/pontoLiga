package br.com.calabotics.pontoliga.service;

import br.com.calabotics.pontoliga.dto.MembroRequest;
import br.com.calabotics.pontoliga.dto.MembroResponse;
import br.com.calabotics.pontoliga.entity.Membro;
import br.com.calabotics.pontoliga.exception.ConflitoException;
import br.com.calabotics.pontoliga.exception.RecursoNaoEncontradoException;
import br.com.calabotics.pontoliga.repository.MembroRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;

@Service
public class MembroService {

    private final MembroRepository membroRepository;

    public MembroService(MembroRepository membroRepository) {
        this.membroRepository = membroRepository;
    }

    @Transactional(readOnly = true)
    public List<MembroResponse> listar() {
        return membroRepository.findAllByOrderByNomeCompletoAsc().stream()
                .map(MembroResponse::de)
                .toList();
    }

    @Transactional
    public MembroResponse cadastrar(MembroRequest dados) {
        String nome = dados.nomeCompleto().trim();
        String matricula = dados.matricula().trim();
        String uid = normalizarUid(dados.uidTag());

        if (membroRepository.existsByMatricula(matricula)) {
            throw new ConflitoException("Já existe um membro cadastrado com esta matrícula.");
        }
        if (membroRepository.existsByUidTag(uid)) {
            throw new ConflitoException("Esta tag RFID já está associada a outro membro.");
        }

        Membro salvo = membroRepository.saveAndFlush(new Membro(nome, matricula, uid));
        return MembroResponse.de(salvo);
    }

    @Transactional
    public MembroResponse atualizar(Long id, MembroRequest dados) {
        Membro membro = membroRepository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Membro não encontrado."));

        String nome = dados.nomeCompleto().trim();
        String matricula = dados.matricula().trim();
        String uid = normalizarUid(dados.uidTag());

        if (membroRepository.existsByMatriculaAndIdNot(matricula, id)) {
            throw new ConflitoException("Já existe outro membro cadastrado com esta matrícula.");
        }
        if (membroRepository.existsByUidTagAndIdNot(uid, id)) {
            throw new ConflitoException("Esta tag RFID já está associada a outro membro.");
        }

        membro.atualizar(nome, matricula, uid);
        return MembroResponse.de(membroRepository.saveAndFlush(membro));
    }

    private String normalizarUid(String uid) {
        return uid.trim().toUpperCase(Locale.ROOT);
    }
}
