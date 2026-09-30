package com.rotasolidaria.util;

import java.time.LocalDate;
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
}
