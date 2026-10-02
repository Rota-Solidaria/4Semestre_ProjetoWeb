package com.rotasolidaria.services;

import com.rotasolidaria.events.UserRegisteredEvent;
import com.rotasolidaria.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

/**
 * Envia o e-mail de boas-vindas quando uma conta é criada. Roda só depois do commit
 * (não envia se o cadastro falhar) e em segundo plano, para o cadastro não esperar o SMTP.
 */
@Service
public class WelcomeEmailService {

    private final UserRepository userRepository;
    private final EmailService emailService;
    private final String baseUrl;

    public WelcomeEmailService(UserRepository userRepository,
                               EmailService emailService,
                               @Value("${app.base-url}") String baseUrl) {
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.baseUrl = baseUrl;
    }

    @Async
    @TransactionalEventListener
    public void onUserRegistered(UserRegisteredEvent event) {
        userRepository.findById(event.userId()).ifPresent(user -> {
            String linkPerfil = UriComponentsBuilder.fromUriString(baseUrl).path("/perfil").fragment("editar").toUriString();
            String linkCampanhas = UriComponentsBuilder.fromUriString(baseUrl).path("/campanhas").toUriString();
            String firstName = user.getFirstName();

            String plainText = """
                    Olá, %s!

                    Sua conta no Rota Solidária está pronta. Obrigado por querer doar!

                    Próximos passos:
                    1. Complete seu perfil (tipo sanguíneo, peso e data de nascimento): %s
                    2. Veja as campanhas de doação perto de você: %s
                    3. Inscreva-se em uma campanha e garanta seu lugar no transporte.
                    """.formatted(firstName, linkPerfil, linkCampanhas);

            emailService.sendHtml(
                    user.getEmail(),
                    "Bem-vindo(a) ao Rota Solidária",
                    "emails/boas-vindas.ftlh",
                    Map.of("primeiroNome", firstName, "linkPerfil", linkPerfil, "linkCampanhas", linkCampanhas),
                    plainText);
        });
    }
}
