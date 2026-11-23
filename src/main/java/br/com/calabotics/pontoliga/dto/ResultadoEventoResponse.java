package br.com.calabotics.pontoliga.dto;

public record ResultadoEventoResponse(String eventId, String status, String mensagem) {

    public static final String CRIADO = "CRIADO";
    public static final String DUPLICADO = "DUPLICADO";
    public static final String REJEITADO = "REJEITADO";

    public static ResultadoEventoResponse criado(String eventId) {
        return new ResultadoEventoResponse(eventId, CRIADO, "Evento registrado.");
    }

    public static ResultadoEventoResponse duplicado(String eventId) {
        return new ResultadoEventoResponse(eventId, DUPLICADO, "Evento já recebido anteriormente. Nada foi alterado.");
    }

    public static ResultadoEventoResponse rejeitado(String eventId, String motivo) {
        return new ResultadoEventoResponse(eventId, REJEITADO, motivo);
    }
}
