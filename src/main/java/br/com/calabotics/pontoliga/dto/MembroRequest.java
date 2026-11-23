package br.com.calabotics.pontoliga.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record MembroRequest(

        @NotBlank(message = "Informe o nome completo.")
        @Size(max = 150, message = "O nome deve ter no máximo 150 caracteres.")
        String nomeCompleto,

        @NotBlank(message = "Informe a matrícula.")
        @Size(max = 30, message = "A matrícula deve ter no máximo 30 caracteres.")
        String matricula,

        @NotBlank(message = "Informe o UID da tag RFID.")
        @Pattern(regexp = "[0-9A-Fa-f]{4,20}",
                message = "O UID deve ter de 4 a 20 caracteres hexadecimais (0-9 e A-F), sem espaços.")
        String uidTag) {
}
