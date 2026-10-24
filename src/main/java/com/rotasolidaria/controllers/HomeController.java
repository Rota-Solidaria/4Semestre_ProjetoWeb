package com.rotasolidaria.controllers;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.services.CampaignService;

@Controller
public class HomeController {

    private static final int CARAVANAS_NO_MAPA = 60;

    private final CampaignService campaignService;

    public HomeController(CampaignService campaignService) {
        this.campaignService = campaignService;
    }

    /** Início: landing page que explica a caravana e leva para as campanhas. */
    @GetMapping("/")
    public String index(Model model) {
        return doar(model);
    }

    /** Landing para quem nunca doou: explica a caravana e leva para as campanhas. */
    @GetMapping("/doar")
    public String doar(Model model) {
        model.addAttribute("caravanasAbertas", abertas().size());
        return "pages/doar"; // -> templates/pages/doar.ftlh
    }

    /** Caravanas com inscrições abertas e data de hoje em diante, das mais próximas no tempo. */
    private List<Campaign> abertas() {
        LocalDate hoje = LocalDate.now();
        return campaignService.listarAbertasPaginadas(PageRequest.of(0, CARAVANAS_NO_MAPA))
                .getContent().stream()
                .filter(c -> c.getEventDate() == null || !c.getEventDate().isBefore(hoje))
                .toList();
    }
}
