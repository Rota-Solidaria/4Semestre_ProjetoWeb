// CampanhaController.java
package com.rotasolidaria.controllers;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.services.CampaignService;

@Controller
public class CampaignController {

    private final CampaignService campanhaService;

    public CampaignController(CampaignService campanhaService) {
        this.campanhaService = campanhaService;
    }

    @GetMapping("/campanhas")
    public String listar(Model model) {
        List<Campaign> campanhas = campanhaService.listarTodas();
        model.addAttribute("campanhas", campanhas);
        return "campanhas"; // -> templates/campanhas.ftlh
    }

    @GetMapping("/campanhas/{id}")
    public String detalhes(@PathVariable Long id,
            Model model) {
        Optional<Campaign> campanha = campanhaService.buscarPorId(id);
        if (campanha.isPresent()) {
            model.addAttribute("campanha", campanha.get());
            return "detalhes-campanha"; // -> templates/detalhes-campanha.ftlh
        }
        return "redirect:/campanhas";
    }
}