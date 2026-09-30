package com.rotasolidaria.services;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.InscricaoRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * A cada 15 minutos, envia o lembrete por e-mail para quem tem campanha nas próximas 24 horas.
 * O horário usado é o do embarque (ônibus) ou o da doação (quem vai por conta própria).
 * Cada inscrição recebe um lembrete só (reminderSentAt).
 */
@Service
public class LembreteCampanhaService {

    private static final DateTimeFormatter HORA = DateTimeFormatter.ofPattern("HH:mm");
    private static final LocalTime HORARIO_PADRAO = LocalTime.of(8, 0);

    private final InscricaoRepository inscricaoRepository;
    private final EmailService emailService;
    private final String baseUrl;

    public LembreteCampanhaService(InscricaoRepository inscricaoRepository,
                                   EmailService emailService,
                                   @Value("${app.base-url}") String baseUrl) {
        this.inscricaoRepository = inscricaoRepository;
        this.emailService = emailService;
        this.baseUrl = baseUrl;
    }

    @Scheduled(cron = "0 */15 * * * *")
    @Transactional
    public void enviarLembretes() {
        LocalDateTime agora = LocalDateTime.now();
        LocalDateTime limite = agora.plusHours(24);

        for (Registration inscricao : inscricaoRepository.findPendentesDeLembrete(LocalDate.now(), limite.toLocalDate())) {
            boolean onibus = InscricaoService.goesByBus(inscricao);
            LocalTime horario = onibus ? InscricaoService.boardingTime(inscricao) : inscricao.getCampaign().getDonationTime();
            boolean estimado = horario != null
                    && (onibus ? InscricaoService.boardingTimeEstimated(inscricao) : inscricao.getCampaign().isDonationTimeEstimated());
            if (horario == null) {
                horario = HORARIO_PADRAO;
            }
            LocalDateTime quando = inscricao.getCampaign().getEventDate().atTime(horario);
            if (quando.isAfter(agora) && !quando.isAfter(limite)) {
                enviar(inscricao, onibus, horario, estimado);
                inscricao.setReminderSentAt(agora);
            }
        }
    }

    private void enviar(Registration inscricao, boolean onibus, LocalTime horario, boolean estimado) {
        Campaign campanha = inscricao.getCampaign();
        User user = inscricao.getDonor().getUser();
        String firstName = CampanhaEmailService.primeiroNome(user);
        String data = campanha.getEventDate().format(CampanhaEmailService.DATA_BR);
        String hora = (estimado ? "≈ " : "") + horario.format(HORA); // ≈: estimado pela rota
        String rotuloLocal = onibus ? "Embarque" : "Local da doação";
        String local = onibus ? pontoDeEmbarque(inscricao) : nome(campanha.getDonationLocation());
        String linkBilhete = UriComponentsBuilder.fromUriString(baseUrl)
                .path("/inscricoes/{id}").buildAndExpand(inscricao.getId()).toUriString();

        String plainText = """
                Olá, %s!

                Lembrete: falta menos de um dia para a campanha "%s".

                Data: %s
                Horário: %s
                %s: %s

                Leve um documento com foto, esteja descansado(a) e alimentado(a).
                Seu bilhete: %s
                """.formatted(firstName, campanha.getTitle(), data, hora, rotuloLocal, local, linkBilhete);

        emailService.sendHtml(
                user.getEmail(),
                "Lembrete: " + campanha.getTitle() + " em " + data + " às " + hora,
                "emails/lembrete-campanha.ftlh",
                Map.of("primeiroNome", firstName, "titulo", campanha.getTitle(), "data", data, "hora", hora,
                        "rotuloLocal", rotuloLocal, "local", local, "codigo", inscricao.getCode(),
                        "linkBilhete", linkBilhete),
                plainText);
    }

    private static String pontoDeEmbarque(Registration inscricao) {
        if (inscricao.getBoardingLocation() != null) {
            return nome(inscricao.getBoardingLocation());
        }
        return inscricao.getBoardingPoint() == null ? "" : inscricao.getBoardingPoint();
    }

    private static String nome(com.rotasolidaria.models.Location local) {
        return local == null || local.getName() == null ? "" : local.getName();
    }
}
