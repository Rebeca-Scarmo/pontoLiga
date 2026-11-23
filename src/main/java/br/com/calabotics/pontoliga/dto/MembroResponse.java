package br.com.calabotics.pontoliga.dto;

import br.com.calabotics.pontoliga.entity.Membro;

public record MembroResponse(Long id, String nomeCompleto, String matricula, String uidTag) {

    public static MembroResponse de(Membro membro) {
        return new MembroResponse(membro.getId(), membro.getNomeCompleto(),
                membro.getMatricula(), membro.getUidTag());
    }
}
