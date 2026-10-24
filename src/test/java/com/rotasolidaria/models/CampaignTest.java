package com.rotasolidaria.models;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.rotasolidaria.models.enums.CampaignStatus;

class CampaignTest {

    private static Location local(String cidade, String nome) {
        Location l = new Location();
        l.setCity(cidade);
        l.setName(nome);
        return l;
    }

    private static Campaign campanha(Location partida, Location destino, Location... paradas) {
        Campaign c = new Campaign();
        c.setDepartureLocation(partida);
        c.setDonationLocation(destino);
        int i = 0;
        for (Location p : paradas) {
            RouteStop s = new RouteStop();
            s.setLocation(p);
            s.setPosition(++i);
            c.getStops().add(s);
        }
        return c;
    }

    @Test
    void duasParadasNaMesmaCidadeViramUmaSo() {
        Campaign c = campanha(local("Angatuba", "Rua Aurélio Moura"), local("Sorocaba", "Colsan Sorocaba"),
                local("Itapetininga", "Rodovia Raposo Tavares"), local("Itapetininga", "Rua Sebastião Moreno"));
        assertEquals(List.of("Itapetininga"), c.getCidadesIntermediarias());
        assertEquals("Itapetininga", c.getPassaPor());
    }

    @Test
    void cidadeDePartidaNaoEntraNoPassaPor() {
        Campaign c = campanha(local("Itapetininga", "Rua Silva Jardim"), local("Sorocaba", "Colsan Sorocaba"),
                local("Itapetininga", "Rodovia Raposo Tavares"), local("Alambari", "Rodovia Raposo Tavares"));
        assertEquals("Alambari", c.getPassaPor());
    }

    @Test
    void variasCidadesFicamSeparadasPorVirgulaEE() {
        Campaign c = campanha(local("Angatuba", "Praça Matriz"), local("São Paulo", "Pró-Sangue"),
                local("Itapetininga", "Rodoviária"), local("Tatuí", "Rodoviária"), local("Sorocaba", "Rodoviária"));
        assertEquals("Itapetininga, Tatuí e Sorocaba", c.getPassaPor());
    }

    @Test
    void semCidadeIntermediariaFicaVazio() {
        Campaign c = campanha(local("Sorocaba", "Rodoviária"), local("Sorocaba", "Colsan Sorocaba"),
                local("sorocaba", "Terminal"));
        assertEquals("", c.getPassaPor());
        assertEquals("", campanha(local("Angatuba", "Praça"), local("São Paulo", "Pró-Sangue")).getPassaPor());
    }

    @Test
    void usaONomeDoLocalQuandoNaoHaCidade() {
        Campaign c = campanha(local("Angatuba", "Praça"), local("São Paulo", "Pró-Sangue"), local(null, "Posto da Raposo"));
        assertEquals("Posto da Raposo", c.getPassaPor());
    }

    // --- Testes de regras de negócio de Status e Data de Realização ---

    @Test
    void campanhaComDataFuturaEStatusOpenTemInscricoesAbertas() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.OPEN);
        c.setEventDate(LocalDate.now().plusDays(5));

        assertTrue(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.OPEN, c.getStatusEfetivo());
        assertEquals("Inscrições abertas", c.getStatusRotulo());
    }

    @Test
    void campanhaComDataDeHojeEStatusOpenPermaneceAberta() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.OPEN);
        c.setEventDate(LocalDate.now());

        assertTrue(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.OPEN, c.getStatusEfetivo());
        assertEquals("Inscrições abertas", c.getStatusRotulo());
    }

    @Test
    void campanhaComDataPassadaEStatusOpenTemInscricoesEncerradas() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.OPEN);
        c.setEventDate(LocalDate.now().minusDays(1));

        assertFalse(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.CLOSED, c.getStatusEfetivo());
        assertEquals("Inscrições encerradas", c.getStatusRotulo());
    }

    @Test
    void campanhaComDataPassadaHaVariosDiasTemInscricoesEncerradas() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.OPEN);
        c.setEventDate(LocalDate.of(2026, 10, 17)); // Caso real relatado: 17/10/2026

        assertFalse(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.CLOSED, c.getStatusEfetivo());
        assertEquals("Inscrições encerradas", c.getStatusRotulo());
    }

    @Test
    void campanhaSemDataDefinidaEStatusOpenPermaneceAberta() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.OPEN);
        c.setEventDate(null);

        assertTrue(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.OPEN, c.getStatusEfetivo());
        assertEquals("Inscrições abertas", c.getStatusRotulo());
    }

    @Test
    void campanhaCanceladaPermaneceCanceladaMesmoComDataFutura() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.CANCELLED);
        c.setEventDate(LocalDate.now().plusDays(10));

        assertFalse(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.CANCELLED, c.getStatusEfetivo());
        assertEquals("Cancelada", c.getStatusRotulo());
    }

    @Test
    void campanhaCanceladaPermaneceCanceladaMesmoComDataPassada() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.CANCELLED);
        c.setEventDate(LocalDate.now().minusDays(5));

        assertFalse(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.CANCELLED, c.getStatusEfetivo());
        assertEquals("Cancelada", c.getStatusRotulo());
    }

    @Test
    void campanhaFechadaManualmentePermaneceFechadaMesmoComDataFutura() {
        Campaign c = new Campaign();
        c.setStatus(CampaignStatus.CLOSED);
        c.setEventDate(LocalDate.now().plusDays(10));

        assertFalse(c.isInscricoesAbertas());
        assertEquals(CampaignStatus.CLOSED, c.getStatusEfetivo());
        assertEquals("Inscrições encerradas", c.getStatusRotulo());
    }
}
