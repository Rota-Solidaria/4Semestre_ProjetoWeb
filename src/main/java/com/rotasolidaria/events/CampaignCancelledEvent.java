package com.rotasolidaria.events;

/**
 * Publicado quando o organizador cancela uma campanha.
 * Ouvido pelo CampanhaEmailService, que avisa os inscritos após o commit.
 */
public record CampaignCancelledEvent(Long campaignId) {
}
