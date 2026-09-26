package com.rotasolidaria.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.rotasolidaria.services.CampaignService;

@Controller
public class HomeController {

    private final CampaignService campaignService;

    public HomeController(CampaignService campaignService) {
        this.campaignService = campaignService;
    }

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("campanhas", campaignService.listarAbertas());
        return "pages/index"; // -> templates/pages/index.ftlh
    }
}