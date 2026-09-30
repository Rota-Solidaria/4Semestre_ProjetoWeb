package com.rotasolidaria.dto;

import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalTime;

/** Um ponto da rota no editor do organizador (partida, parada ou destino). */
public class PontoForm {

    // Local já salvo que este ponto edita (nulo = ponto novo)
    private Long locationId;
    private String nome;
    private String cep;
    private String rua;
    private String numero;
    private String bairro;
    private String cidade;
    private String uf;
    private String referencia;
    private BigDecimal lat;
    private BigDecimal lng;

    @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
    private LocalTime horario;

    // Só para exibição: doadores inscritos para embarcar neste ponto
    private long inscritos;

    /** Parada adicionada no formulário mas deixada toda em branco. */
    public boolean isVazio() {
        return isBlank(nome) && isBlank(rua) && isBlank(cidade) && isBlank(cep) && lat == null;
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    // Getters e Setters

    public Long getLocationId() {
        return locationId;
    }

    public void setLocationId(Long locationId) {
        this.locationId = locationId;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCep() {
        return cep;
    }

    public void setCep(String cep) {
        this.cep = cep;
    }

    public String getRua() {
        return rua;
    }

    public void setRua(String rua) {
        this.rua = rua;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getBairro() {
        return bairro;
    }

    public void setBairro(String bairro) {
        this.bairro = bairro;
    }

    public String getCidade() {
        return cidade;
    }

    public void setCidade(String cidade) {
        this.cidade = cidade;
    }

    public String getUf() {
        return uf;
    }

    public void setUf(String uf) {
        this.uf = uf;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }

    public BigDecimal getLat() {
        return lat;
    }

    public void setLat(BigDecimal lat) {
        this.lat = lat;
    }

    public BigDecimal getLng() {
        return lng;
    }

    public void setLng(BigDecimal lng) {
        this.lng = lng;
    }

    public LocalTime getHorario() {
        return horario;
    }

    public void setHorario(LocalTime horario) {
        this.horario = horario;
    }

    public long getInscritos() {
        return inscritos;
    }

    public void setInscritos(long inscritos) {
        this.inscritos = inscritos;
    }
}
