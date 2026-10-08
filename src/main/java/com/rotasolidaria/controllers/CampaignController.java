// CampanhaController.java
package com.rotasolidaria.controllers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.CampaignService;
import com.rotasolidaria.services.InscricaoService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CampaignController {

    public static final int LIMITE_PADRAO = 6;

    private final CampaignService campanhaService;
    private final InscricaoService inscricaoService;

    public CampaignController(CampaignService campanhaService, InscricaoService inscricaoService) {
        this.campanhaService = campanhaService;
        this.inscricaoService = inscricaoService;
    }

    @GetMapping("/campanhas")
    public String listar(
            @RequestParam(name = "pagina", required = false) Integer pagina,
            @RequestParam(name = "page", required = false) Integer page,
            @RequestParam(name = "limite", required = false) Integer limite,
            @RequestParam(name = "size", required = false) Integer size,
            @RequestParam(name = "q", required = false) String busca,
            @AuthenticationPrincipal AuthenticatedUser principal,
            Model model) {

        int tamanho = LIMITE_PADRAO;
        if (size != null && size > 0 && size <= 50) {
            tamanho = size;
        } else if (limite != null && limite > 0 && limite <= 50) {
            tamanho = limite;
        }

        int numeroPagina = 1;
        if (pagina != null && pagina > 0) {
            numeroPagina = pagina;
        } else if (page != null && page > 0) {
            numeroPagina = page;
        }

        Pageable pageable = PageRequest.of(numeroPagina - 1, tamanho);
        Page<Campaign> paginaCampanhas = campanhaService.buscarAbertas(busca, pageable);

        if (paginaCampanhas.getTotalPages() > 0 && numeroPagina > paginaCampanhas.getTotalPages()) {
            numeroPagina = paginaCampanhas.getTotalPages();
            pageable = PageRequest.of(numeroPagina - 1, tamanho);
            paginaCampanhas = campanhaService.buscarAbertas(busca, pageable);
        }

        model.addAttribute("campanhas", paginaCampanhas.getContent());
        model.addAttribute("paginaAtual", numeroPagina);
        model.addAttribute("totalPaginas", paginaCampanhas.getTotalPages());
        model.addAttribute("totalElementos", paginaCampanhas.getTotalElements());
        model.addAttribute("temAnterior", paginaCampanhas.hasPrevious());
        model.addAttribute("temProxima", paginaCampanhas.hasNext());
        model.addAttribute("busca", busca != null ? busca.trim() : "");
        model.addAttribute("limite", tamanho);

        // Campanhas em que o usuário já se inscreveu mostram o selo e o atalho para o bilhete
        if (principal != null) {
            Map<String, Registration> minhas = inscricaoService.activeByCampaign(principal.getId());
            Map<String, String> chegadas = new HashMap<>();
            minhas.forEach((id, inscricao) -> chegadas.put(id, InscricaoService.arrivalSummary(inscricao)));
            model.addAttribute("minhasInscricoes", minhas);
            model.addAttribute("minhasChegadas", chegadas);
        }
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
                inscricaoService.findForDonor(campanha.get(), principal.getId()).ifPresent(inscricao -> {
                    model.addAttribute("minhaInscricao", inscricao);
                    // Ponto da rota destacado como "você embarca aqui" (ou o hemocentro, se vai por conta própria)
                    if (!InscricaoService.goesByBus(inscricao)) {
                        model.addAttribute("vouDireto", true);
                    } else {
                        Location embarque = inscricao.getBoardingLocation() != null
                                ? inscricao.getBoardingLocation()
                                : campanha.get().getDepartureLocation();
                        if (embarque != null) {
                            model.addAttribute("meuEmbarqueId", embarque.getId());
                            model.addAttribute("meuEmbarqueNome", InscricaoService.describe(embarque.getName(), embarque.getCity()));
                            model.addAttribute("meuEmbarqueHorario", InscricaoService.boardingTimeTexto(inscricao));
                        }
                    }
                });
            }
            return "pages/detalhes-campanha"; // -> templates/pages/detalhes-campanha.ftlh
        }
        return "redirect:/campanhas";
    }
}