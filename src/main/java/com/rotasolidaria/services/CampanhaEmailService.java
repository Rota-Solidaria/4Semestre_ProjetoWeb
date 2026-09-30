package com.rotasolidaria.services;

import com.rotasolidaria.events.CampaignCancelledEvent;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.CampanhaRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * Avisa por e-mail os inscritos quando uma campanha é cancelada. Roda depois do commit
 * e em segundo plano, para o organizador não esperar o envio de todos os e-mails.
 */
@Service
public class CampanhaEmailService {

    static final DateTimeFormatter DATA_BR = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final CampanhaRepository campanhaRepository;
    private final InscricaoRepository inscricaoRepository;
    private final EmailService emailService;
    private final String baseUrl;

    public CampanhaEmailService(CampanhaRepository campanhaRepository,
                                InscricaoRepository inscricaoRepository,
                                EmailService emailService,
                                @Value("${app.base-url}") String baseUrl) {
        this.campanhaRepository = campanhaRepository;
        this.inscricaoRepository = inscricaoRepository;
        this.emailService = emailService;
        this.baseUrl = baseUrl;
    }

    @Async
    @TransactionalEventListener
    @Transactional(propagation = Propagation.REQUIRES_NEW, readOnly = true)
    public void onCampaignCancelled(CampaignCancelledEvent event) {
        campanhaRepository.findById(event.campaignId()).ifPresent(campanha -> {
            String linkCampanhas = UriComponentsBuilder.fromUriString(baseUrl).path("/campanhas").toUriString();
            String data = campanha.getEventDate() == null ? "" : campanha.getEventDate().format(DATA_BR);
            String local = campanha.getDonationLocation() == null ? "" : campanha.getDonationLocation().getName();

            for (Registration inscricao : inscricaoRepository.findAtivasComDoador(campanha.getId())) {
                enviar(inscricao.getDonor().getUser(), campanha, data, local, linkCampanhas);
            }
        });
    }

    private void enviar(User user, Campaign campanha, String data, String local, String linkCampanhas) {
        String firstName = primeiroNome(user);
        String plainText = """
                Olá, %s!

                Infelizmente a campanha "%s", marcada para %s (%s), foi cancelada pelo organizador.
                Sua inscrição não vale mais para essa data.

                Veja outras campanhas de doação: %s
                """.formatted(firstName, campanha.getTitle(), data, local, linkCampanhas);

        emailService.sendHtml(
                user.getEmail(),
                "Campanha cancelada: " + campanha.getTitle(),
                "emails/campanha-cancelada.ftlh",
                Map.of("primeiroNome", firstName, "titulo", campanha.getTitle(), "data", data,
                        "local", local, "linkCampanhas", linkCampanhas),
                plainText);
    }

    static String primeiroNome(User user) {
        return user.getName().trim().split("\\s+")[0];
    }
}
