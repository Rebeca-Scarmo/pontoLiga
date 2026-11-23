package br.com.calabotics.pontoliga.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Evento enviado pelo equipamento. Todos os campos chegam como texto para que um evento malformado
 * seja rejeitado individualmente (com motivo), sem derrubar o lote inteiro.
 */
public record EventoRfidRequest(

        @NotBlank(message = "eventId é obrigatório.")
        @Size(max = 100, message = "eventId deve ter no máximo 100 caracteres.")
        String eventId,

        @NotBlank(message = "uid é obrigatório.")
        @Pattern(regexp = "[0-9A-Fa-f]{4,20}",
                message = "uid inválido: use de 4 a 20 caracteres hexadecimais, sem separadores.")
        String uid,

        @NotBlank(message = "timestamp é obrigatório.")
        String timestamp,

        @NotBlank(message = "eventType é obrigatório.")
        @Pattern(regexp = "ENTRY|EXIT", message = "eventType deve ser ENTRY ou EXIT.")
        String eventType) {
}
