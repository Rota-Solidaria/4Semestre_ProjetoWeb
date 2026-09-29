package com.rotasolidaria.services;

import freemarker.template.Configuration;
import freemarker.template.TemplateException;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.ui.freemarker.FreeMarkerTemplateUtils;

import java.io.IOException;
import java.util.Map;

/**
 * Envia e-mails em HTML a partir dos templates em templates/emails/.
 * Cada e-mail leva também uma versão em texto puro e a logo anexada inline (cid:logo),
 * para que ela apareça mesmo quando o cliente bloqueia imagens externas.
 */
@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);
    private static final ClassPathResource LOGO = new ClassPathResource("templates/emails/logo.png");

    private final JavaMailSender mailSender;
    private final Configuration freemarker;
    private final String from;
    private final String fromName;

    public EmailService(JavaMailSender mailSender,
                        Configuration freemarker,
                        @Value("${app.mail.from}") String from,
                        @Value("${app.mail.from-name:Rota Solidária}") String fromName) {
        this.mailSender = mailSender;
        this.freemarker = freemarker;
        this.from = from;
        this.fromName = fromName;
    }

    /**
     * Envia o e-mail. Falhas são registradas no log e não interrompem a requisição.
     *
     * @param template caminho do template, ex.: "emails/redefinir-senha.ftlh"
     */
    public void sendHtml(String to, String subject, String template, Map<String, Object> model, String plainText) {
        if (from.isBlank()) {
            log.error("E-mail não configurado: preencha MAIL_USERNAME e MAIL_PASSWORD no arquivo .env e reinicie a aplicação.");
            return;
        }

        try {
            String html = FreeMarkerTemplateUtils.processTemplateIntoString(freemarker.getTemplate(template), model);

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, MimeMessageHelper.MULTIPART_MODE_MIXED_RELATED, "UTF-8");
            helper.setFrom(from, fromName);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(plainText, html);
            helper.addInline("logo", LOGO, "image/png");

            mailSender.send(message);
        } catch (MailException | MessagingException | IOException | TemplateException e) {
            log.error("Falha ao enviar o e-mail \"{}\"", subject, e);
        }
    }
}
