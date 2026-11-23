package br.com.calabotics.pontoliga.dto;

import java.util.List;

public record ResultadoLoteResponse(int recebidos, int criados, int duplicados, int rejeitados,
                                    List<ResultadoEventoResponse> resultados) {
}
