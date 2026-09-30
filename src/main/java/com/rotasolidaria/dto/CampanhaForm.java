package com.rotasolidaria.dto;

import com.rotasolidaria.models.enums.CampaignStatus;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/**
 * Formulário de nova campanha / editar campanha (templates/pages/organizador-campanha.ftlh):
 * os dados da campanha mais a rota do ônibus (partida.*, paradas[i].*, destino.* herdados de RotaForm).
 */
public class CampanhaForm extends RotaForm {

    private String titulo;
    private String descricao;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate data;

    private Integer vagas;
    private CampaignStatus status;

    // Uma das fotos do projeto (/images/...) ou, se preenchido, o link de outra imagem
    private String imagemUrl;
    private String imagemLink;

    // Só para exibição: doadores inscritos (vagas não podem ficar abaixo disso)
    private long inscritos;

    // Getters e Setters

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public LocalDate getData() {
        return data;
    }

    public void setData(LocalDate data) {
        this.data = data;
    }

    public Integer getVagas() {
        return vagas;
    }

    public void setVagas(Integer vagas) {
        this.vagas = vagas;
    }

    public CampaignStatus getStatus() {
        return status;
    }

    public void setStatus(CampaignStatus status) {
        this.status = status;
    }

    public String getImagemUrl() {
        return imagemUrl;
    }

    public void setImagemUrl(String imagemUrl) {
        this.imagemUrl = imagemUrl;
    }

    public String getImagemLink() {
        return imagemLink;
    }

    public void setImagemLink(String imagemLink) {
        this.imagemLink = imagemLink;
    }

    public long getInscritos() {
        return inscritos;
    }

    public void setInscritos(long inscritos) {
        this.inscritos = inscritos;
    }
}
