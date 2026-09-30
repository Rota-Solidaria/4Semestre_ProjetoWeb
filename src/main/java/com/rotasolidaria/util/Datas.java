package com.rotasolidaria.util;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/** Datas no padrão brasileiro (dd/MM/aaaa) para mostrar nas telas. */
public final class Datas {

    public static final DateTimeFormatter DATA_BR = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private Datas() {
    }

    /** "14/10/2026", ou nulo se não houver data. */
    public static String br(LocalDate data) {
        return data == null ? null : data.format(DATA_BR);
    }

    public static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm");

    /** "07:20", ou "≈ 07:20" quando o horário foi estimado pela rota; nulo sem horário. */
    public static String hora(LocalTime hora, boolean estimada) {
        if (hora == null) {
            return null;
        }
        return (estimada ? "≈ " : "") + hora.format(HORA);
    }
}
