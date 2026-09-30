package com.rotasolidaria.services;

import com.rotasolidaria.models.Location;

import java.time.LocalTime;

/**
 * Uma opção de embarque no formulário de inscrição: a partida, uma parada da rota
 * ou ir por conta própria. {@code key} é o valor enviado pelo formulário.
 */
public class BoardingOption {

    private final String key;
    private final String label;
    private final LocalTime time;
    private final Location location;
    private final boolean bus;

    BoardingOption(String key, String label, LocalTime time, Location location, boolean bus) {
        this.key = key;
        this.label = label;
        this.time = time;
        this.location = location;
        this.bus = bus;
    }

    public String getKey() {
        return key;
    }

    public String getLabel() {
        return label;
    }

    /** Horário em que o ônibus passa neste ponto (nulo se ainda não definido ou se não for de ônibus). */
    public LocalTime getTime() {
        return time;
    }

    public Location getLocation() {
        return location;
    }

    public boolean isBus() {
        return bus;
    }
}
