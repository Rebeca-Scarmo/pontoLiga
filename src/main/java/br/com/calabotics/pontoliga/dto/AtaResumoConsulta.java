package br.com.calabotics.pontoliga.dto;

import java.time.Instant;
import java.time.LocalDate;

/** Resultado da consulta que agrupa os eventos por data local (usado pela listagem de atas). */
public record AtaResumoConsulta(LocalDate data, Instant primeiro, Instant ultimo) {
}
