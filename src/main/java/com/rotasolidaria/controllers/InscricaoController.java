// InscricaoController.java
package com.rotasolidaria.controllers;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.CampaignService;
import com.rotasolidaria.services.InscricaoService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import com.rotasolidaria.util.Datas;
import com.rotasolidaria.util.Navegacao;
import java.util.Locale;
import java.util.Optional;

@Controller
public class InscricaoController {

    private static final DateTimeFormatter DATA_EXTENSO = DateTimeFormatter.ofPattern("d 'de' MMMM 'de' yyyy", Locale.of("pt", "BR"));

    private final CampaignService campaignService;
    private final InscricaoService inscricaoService;
    private final UserRepository userRepository;
    private final String baseUrl;

    public InscricaoController(CampaignService campaignService,
                               InscricaoService inscricaoService,
                               UserRepository userRepository,
                               @Value("${app.base-url}") String baseUrl) {
        this.campaignService = campaignService;
        this.inscricaoService = inscricaoService;
        this.userRepository = userRepository;
        this.baseUrl = baseUrl;
    }

    @GetMapping("/campanhas/{id}/inscrever")
    public String formInscricao(@PathVariable Long id,
                                @AuthenticationPrincipal AuthenticatedUser principal,
                                RedirectAttributes redirectAttributes,
                                Model model) {
        Optional<Campaign> campanhaOpt = campaignService.buscarPorId(id);
        if (campanhaOpt.isEmpty()) {
            return "redirect:/campanhas";
        }
        Campaign campanha = campanhaOpt.get();

        // Já inscrito: mostra o bilhete em vez de outro formulário
        Optional<Registration> existente = inscricaoService.findForDonor(campanha, principal.getId());
        if (existente.isPresent()) {
            redirectAttributes.addFlashAttribute("toast",
                    Toast.info("Você já está inscrito", "Este é o seu bilhete de embarque.").withIcon("confirmation_number"));
            return "redirect:/inscricoes/" + existente.get().getId();
        }

        model.addAttribute("campanha", campanha);
        model.addAttribute("usuario", userRepository.findById(principal.getId()).orElse(null));
        model.addAttribute("opcoesEmbarque", inscricaoService.boardingOptions(campanha));
        model.addAttribute("vagasRestantes", inscricaoService.slotsLeft(campanha));
        model.addAttribute("dataExtenso", campanha.getEventDate() == null ? null : campanha.getEventDate().format(DATA_EXTENSO));
        return "pages/inscrever-campanha"; // -> templates/pages/inscrever-campanha.ftlh
    }

    @PostMapping("/campanhas/{id}/inscrever")
    public String processarInscricao(@PathVariable Long id,
                                     @AuthenticationPrincipal AuthenticatedUser principal,
                                     @RequestParam(required = false) String embarque,
                                     @RequestParam(required = false) String observacoes,
                                     @RequestParam(required = false) String lgpd,
                                     RedirectAttributes redirectAttributes) {
        Optional<Campaign> campanhaOpt = campaignService.buscarPorId(id);
        if (campanhaOpt.isEmpty()) {
            return "redirect:/campanhas";
        }
        try {
            Registration inscricao = inscricaoService.register(campanhaOpt.get(), principal.getId(), embarque, observacoes, lgpd != null);
            String garantida = "Sua vaga no transporte está garantida.";
            redirectAttributes.addFlashAttribute("toast",
                    Toast.success("Inscrição confirmada", garantida).withIcon("check_circle"));
            redirectAttributes.addFlashAttribute("celebrar", true);
            return "redirect:/inscricoes/" + inscricao.getId();
        } catch (BusinessException e) {
            redirectAttributes.addFlashAttribute("toast", Toast.error("Não foi possível concluir a inscrição", e.getMessage()));
            return "redirect:/campanhas/" + id + "/inscrever";
        }
    }

    /** Informações da inscrição (só o próprio doador vê). */
    @GetMapping("/inscricoes/{id}")
    public String bilhete(@PathVariable Long id,
                          @AuthenticationPrincipal AuthenticatedUser principal,
                          Model model) {
        Optional<Registration> inscricaoOpt = inscricaoService.findOwned(id, principal.getId());
        if (inscricaoOpt.isEmpty()) {
            return "redirect:/perfil";
        }
        Registration inscricao = inscricaoOpt.get();
        Campaign campanha = inscricao.getCampaign();

        String dataBr = campanha.getEventDate() == null ? "a definir" : campanha.getEventDate().format(Datas.DATA_BR);
        String mensagem = "Vou doar sangue na " + campanha.getTitle() + " em " + dataBr
                + ", com o transporte do Rota Solidária. Vamos juntos? "
                + baseUrl + "/campanhas/" + campanha.getId();

        model.addAttribute("inscricao", inscricao);
        model.addAttribute("campanha", campanha);
        model.addAttribute("dataBr", dataBr);
        model.addAttribute("origem", origem(inscricao));
        model.addAttribute("vaiDeOnibus", true);
        model.addAttribute("encontro", false);
        // Quem chega por conta própria (modo Encontro ou "Vou por conta própria") segue direto para o hemocentro
        String wazeUrl = InscricaoService.goesByBus(inscricao) ? null : Navegacao.waze(campanha.getDonationLocation());
        if (wazeUrl != null) {
            model.addAttribute("wazeUrl", wazeUrl);
        }
        String horarioEmbarque = InscricaoService.boardingTimeTexto(inscricao); // "07:20" ou "≈ 07:20" se estimado
        if (horarioEmbarque != null) {
            model.addAttribute("horarioEmbarque", horarioEmbarque);
        }
        model.addAttribute("whatsappUrl", "https://wa.me/?text=" + UriUtils.encodeQueryParam(mensagem, StandardCharsets.UTF_8));
        return "pages/bilhete"; // -> templates/pages/bilhete.ftlh
    }

    /** Evento de calendário (.ics) da doação, para "Adicionar ao calendário". */
    @GetMapping("/inscricoes/{id}/calendario.ics")
    public ResponseEntity<String> calendario(@PathVariable Long id, @AuthenticationPrincipal AuthenticatedUser principal) {
        Optional<Registration> inscricaoOpt = inscricaoService.findOwned(id, principal.getId());
        if (inscricaoOpt.isEmpty() || inscricaoOpt.get().getCampaign().getEventDate() == null) {
            return ResponseEntity.notFound().build();
        }
        Registration inscricao = inscricaoOpt.get();
        Campaign campanha = inscricao.getCampaign();

        LocalTime embarque = InscricaoService.boardingTime(inscricao);
        LocalTime inicio = embarque != null ? embarque : campanha.getDonationTime();

        StringBuilder ics = new StringBuilder()
                .append("BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Rota Solidaria//PT-BR\r\nCALSCALE:GREGORIAN\r\n")
                .append("BEGIN:VEVENT\r\n")
                .append("UID:inscricao-").append(inscricao.getId()).append("@rotasolidaria\r\n")
                .append("DTSTAMP:").append(LocalDateTime.now(ZoneOffset.UTC).format(DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss'Z'"))).append("\r\n");
        if (inicio != null) {
            LocalDateTime start = campanha.getEventDate().atTime(inicio);
            DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyyMMdd'T'HHmmss");
            ics.append("DTSTART:").append(start.format(f)).append("\r\n")
               .append("DTEND:").append(start.plusHours(4).format(f)).append("\r\n");
        } else {
            ics.append("DTSTART;VALUE=DATE:").append(campanha.getEventDate().format(DateTimeFormatter.BASIC_ISO_DATE)).append("\r\n");
        }
        ics.append("SUMMARY:").append(escapeIcs("Doação de sangue · " + campanha.getTitle())).append("\r\n");
        if (campanha.getDonationLocation() != null) {
            ics.append("LOCATION:").append(escapeIcs(local(campanha.getDonationLocation()))).append("\r\n");
        }
        String ondeVai = "Embarque: " + inscricao.getBoardingPoint();
        ics.append("DESCRIPTION:").append(escapeIcs(ondeVai
                        + "\nCódigo de inscrição: " + inscricao.getCode()
                        + "\nLeve documento oficial com foto."))
           .append("\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n");

        return ResponseEntity.ok()
                .contentType(new MediaType("text", "calendar", StandardCharsets.UTF_8))
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.attachment().filename("doacao-" + inscricao.getCode() + ".ics").build().toString())
                .body(ics.toString());
    }

    /** Cidade de embarque para o bilhete: a do ponto escolhido (ou da partida), ou "Sua cidade" quando não há. */
    private static String origem(Registration inscricao) {
        if (!InscricaoService.goesByBus(inscricao)) {
            return "Por conta própria";
        }
        Location saida = inscricao.getBoardingLocation() != null
                ? inscricao.getBoardingLocation()
                : inscricao.getCampaign().getDepartureLocation();
        return saida != null && saida.getCity() != null ? saida.getCity() : "Sua cidade";
    }

    private static String local(Location l) {
        return l.getCity() == null ? l.getName() : l.getName() + ", " + l.getCity();
    }

    private static String escapeIcs(String text) {
        return text.replace("\\", "\\\\").replace(";", "\\;").replace(",", "\\,").replace("\n", "\\n");
    }
}
