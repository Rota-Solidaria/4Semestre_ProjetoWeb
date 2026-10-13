package com.rotasolidaria.controllers;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.rotasolidaria.dto.CaravanaNoMapa;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.services.CampaignService;
import com.rotasolidaria.services.InscricaoService;

@Controller
public class HomeController {

    /** Quantas caravanas abertas a home carrega para o mapa (as próximas, por data). */
    private static final int CARAVANAS_NO_MAPA = 60;

    private final CampaignService campaignService;
    private final InscricaoService inscricaoService;

    public HomeController(CampaignService campaignService, InscricaoService inscricaoService) {
        this.campaignService = campaignService;
        this.inscricaoService = inscricaoService;
    }

    @GetMapping("/")
    public String index(Model model) {
        List<CaravanaNoMapa> caravanas = abertas().stream()
                .map(c -> new CaravanaNoMapa(c, inscricaoService.slotsLeft(c), inscricaoService.boardingOptions(c)))
                .toList();
        model.addAttribute("caravanas", caravanas);
        return "pages/index"; // -> templates/pages/index.ftlh
    }

    /** Landing para quem nunca doou: explica a caravana e leva para o mapa da home. */
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
