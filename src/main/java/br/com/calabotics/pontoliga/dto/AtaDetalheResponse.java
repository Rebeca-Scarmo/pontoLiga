package br.com.calabotics.pontoliga.dto;

import java.util.List;

public record AtaDetalheResponse(String data, String dataFormatada, String titulo,
                                 String primeiroRegistro, String ultimoRegistro,
                                 List<ParticipanteResponse> participantes) {

    public record ParticipanteResponse(String nomeCompleto, String matricula, List<PeriodoResponse> periodos) {
    }

    /**
     * Um par entrada/saída.
     * - entrada == null: houve uma saída sem entrada correspondente no dia;
     * - saidaPendente == true: houve entrada, mas ainda não há saída (saida e cargaHoraria ficam nulos).
     */
    public record PeriodoResponse(String entrada, String saida, String cargaHoraria, boolean saidaPendente) {
    }
}
