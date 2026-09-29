// CampanhaController.java
package com.rotasolidaria.controllers;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.CampaignService;
import com.rotasolidaria.services.InscricaoService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

@Controller
public class CampaignController {

    private final CampaignService campanhaService;
    private final InscricaoService inscricaoService;

    public CampaignController(CampaignService campanhaService, InscricaoService inscricaoService) {
        this.campanhaService = campanhaService;
        this.inscricaoService = inscricaoService;
    }

    @GetMapping("/campanhas")
    public String listar(Model model) {
        List<Campaign> campanhas = campanhaService.listarTodas();
        model.addAttribute("campanhas", campanhas);
        return "pages/campanhas"; // -> templates/pages/campanhas.ftlh
    }

    @GetMapping("/campanhas/{id}")
    public String detalhes(@PathVariable Long id,
            @AuthenticationPrincipal AuthenticatedUser principal,
            Model model) {
        Optional<Campaign> campanha = campanhaService.buscarPorId(id);
        if (campanha.isPresent()) {
            model.addAttribute("campanha", campanha.get());
            model.addAttribute("vagasRestantes", inscricaoService.slotsLeft(campanha.get()));
            // Quem já se inscreveu vê o atalho para o bilhete no lugar de "Fazer inscrição"
            if (principal != null) {
                inscricaoService.findForDonor(campanha.get(), principal.getId())
                        .ifPresent(inscricao -> model.addAttribute("minhaInscricao", inscricao));
            }
            return "pages/detalhes-campanha"; // -> templates/pages/detalhes-campanha.ftlh
        }
        return "redirect:/campanhas";
    }
}