package com.rotasolidaria.events;

/**
 * Publicado quando uma conta nova é criada (formulário de cadastro ou Google).
 * Ouvido pelo WelcomeEmailService, que envia o e-mail de boas-vindas após o commit.
 */
public record UserRegisteredEvent(Long userId) {
}
