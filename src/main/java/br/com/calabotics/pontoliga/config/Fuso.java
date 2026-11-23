package br.com.calabotics.pontoliga.config;

import java.time.ZoneId;

/**
 * Fuso horário usado para agrupar os eventos em atas (uma ata por data local).
 */
public final class Fuso {

    public static final ZoneId BAHIA = ZoneId.of("America/Bahia");

    private Fuso() {
    }
}
