package com.rotasolidaria.dto;

import java.util.ArrayList;
import java.util.List;

/**
 * Formulário do editor de rota (templates/pages/organizador-rota.ftlh).
 * Os campos chegam como partida.nome, paradas[0].nome, paradas[1].nome, ..., destino.nome.
 */
public class RotaForm {

    private PontoForm partida = new PontoForm();
    private List<PontoForm> paradas = new ArrayList<>();
    private PontoForm destino = new PontoForm();

    public PontoForm getPartida() {
        return partida;
    }

    public void setPartida(PontoForm partida) {
        this.partida = partida;
    }

    public List<PontoForm> getParadas() {
        return paradas;
    }

    public void setParadas(List<PontoForm> paradas) {
        this.paradas = paradas;
    }

    public PontoForm getDestino() {
        return destino;
    }

    public void setDestino(PontoForm destino) {
        this.destino = destino;
    }
}
