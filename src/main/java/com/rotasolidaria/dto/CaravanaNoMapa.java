package com.rotasolidaria.dto;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.services.BoardingOption;

/**
 * Uma caravana aberta na home: a campanha, as vagas que ainda sobram e os pontos de embarque
 * com coordenadas (viram os pinos do mapa em static/js/home-mapa.js).
 */
public class CaravanaNoMapa {

    private static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm");

    private final Campaign campanha;
    private final long vagasRestantes;
    private final List<Embarque> embarques = new ArrayList<>();

    public CaravanaNoMapa(Campaign campanha, long vagasRestantes, List<BoardingOption> opcoes) {
        this.campanha = campanha;
        this.vagasRestantes = vagasRestantes;
        for (BoardingOption opcao : opcoes) {
            Location local = opcao.getLocation();
            if (opcao.isBus() && local != null && local.hasCoordinates()) {
                String cidade = local.getCity() != null && !local.getCity().isBlank() ? local.getCity() : local.getName();
                embarques.add(new Embarque(cidade, local.getName(), local.getLatitude(), local.getLongitude(),
                        opcao.getTime() == null ? "" : opcao.getTime().format(HORA)));
            }
        }
    }

    public Campaign getCampanha() {
        return campanha;
    }

    public long getVagasRestantes() {
        return vagasRestantes;
    }

    /** Sobram poucas vagas: até 5 ou até um quinto do ônibus. */
    public boolean isPoucasVagas() {
        int total = campanha.getSlots() == null ? 0 : campanha.getSlots();
        return vagasRestantes > 0 && vagasRestantes <= Math.max(5, total / 5);
    }

    public boolean isLotada() {
        return vagasRestantes == 0;
    }

    public List<Embarque> getEmbarques() {
        return embarques;
    }

    /** Ponto onde o ônibus passa: cidade, nome do lugar, coordenadas e horário ("" se ainda não definido). */
    public static class Embarque {
        private final String cidade;
        private final String nome;
        private final BigDecimal latitude;
        private final BigDecimal longitude;
        private final String horario;

        Embarque(String cidade, String nome, BigDecimal latitude, BigDecimal longitude, String horario) {
            this.cidade = cidade;
            this.nome = nome;
            this.latitude = latitude;
            this.longitude = longitude;
            this.horario = horario;
        }

        public String getCidade() {
            return cidade;
        }

        public String getNome() {
            return nome;
        }

        public BigDecimal getLatitude() {
            return latitude;
        }

        public BigDecimal getLongitude() {
            return longitude;
        }

        public String getHorario() {
            return horario;
        }
    }
}
