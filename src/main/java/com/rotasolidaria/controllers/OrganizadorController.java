package com.rotasolidaria.controllers;

import com.rotasolidaria.dto.CampanhaForm;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.OrganizadorCampanhaService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

/** Área do organizador (/organizador/**, só ROLE_ORGANIZER): criar e editar campanhas, com a rota do ônibus. */
@Controller
public class OrganizadorController {

    private final OrganizadorCampanhaService campanhaService;
    private final String baseUrl;

    public OrganizadorController(OrganizadorCampanhaService campanhaService,
                                 @Value("${app.base-url}") String baseUrl) {
        this.campanhaService = campanhaService;
        this.baseUrl = baseUrl;
    }

    @GetMapping("/organizador/campanhas")
    public String campanhas(@AuthenticationPrincipal AuthenticatedUser principal, Model model) {
        model.addAttribute("campanhas", campanhaService.campanhasDoOrganizador(principal.getId()));
        return "pages/organizador-campanhas"; // -> templates/pages/organizador-campanhas.ftlh
    }

    @GetMapping("/organizador/campanhas/nova")
    public String novaCampanha(Model model) {
        return formulario(model, campanhaService.novoForm(), null);
    }

    @PostMapping("/organizador/campanhas/nova")
    public String criarCampanha(@AuthenticationPrincipal AuthenticatedUser principal,
                                @ModelAttribute("form") CampanhaForm form,
                                BindingResult binding,
                                RedirectAttributes redirectAttributes,
                                Model model) {
        try {
            exigirSemErrosDeFormato(binding);
            Campaign campanha = campanhaService.criar(principal.getId(), form);
            // Campanha nova: vai para o bilhete de divulgação, com as gotas comemorando
            redirectAttributes.addFlashAttribute("celebrar", true);
            return "redirect:/organizador/campanhas/" + campanha.getId() + "/divulgar";
        } catch (BusinessException e) {
            campanhaService.completarExibicao(form, Optional.empty());
            model.addAttribute("toast", Toast.error("Não foi possível criar a campanha", e.getMessage()));
            return formulario(model, form, null);
        }
    }

    @GetMapping("/organizador/campanhas/{id}/editar")
    public String editarCampanha(@PathVariable Long id,
                                 @AuthenticationPrincipal AuthenticatedUser principal,
                                 RedirectAttributes redirectAttributes,
                                 Model model) {
        Optional<Campaign> campanhaOpt = campanhaService.buscarDoOrganizador(id, principal.getId());
        if (campanhaOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("toast", Toast.error("Campanha não encontrada", "Escolha uma das suas campanhas."));
            return "redirect:/organizador/campanhas";
        }
        return formulario(model, campanhaService.formDe(campanhaOpt.get()), campanhaOpt.get());
    }

    @PostMapping("/organizador/campanhas/{id}/editar")
    public String salvarCampanha(@PathVariable Long id,
                                 @AuthenticationPrincipal AuthenticatedUser principal,
                                 @ModelAttribute("form") CampanhaForm form,
                                 BindingResult binding,
                                 RedirectAttributes redirectAttributes,
                                 Model model) {
        if (campanhaService.buscarDoOrganizador(id, principal.getId()).isEmpty()) {
            return "redirect:/organizador/campanhas";
        }
        try {
            exigirSemErrosDeFormato(binding);
            campanhaService.atualizar(id, principal.getId(), form);
            redirectAttributes.addFlashAttribute("toast", Toast.success("Campanha salva", "Os doadores já veem as mudanças.")
                    .withIcon("campaign")
                    .withAction("Divulgar", "/organizador/campanhas/" + id + "/divulgar"));
            return "redirect:/organizador/campanhas";
        } catch (BusinessException e) {
            // Mostra o formulário de novo com o que foi digitado, sem perder as paradas
            // (recarrega a campanha: o rollback descarta as alterações feitas nela)
            Optional<Campaign> campanha = campanhaService.buscarDoOrganizador(id, principal.getId());
            campanhaService.completarExibicao(form, campanha);
            model.addAttribute("toast", Toast.error("Não foi possível salvar a campanha", e.getMessage()));
            return formulario(model, form, campanha.orElse(null));
        }
    }

    /** Bilhete da campanha para divulgar: imagem para as redes, WhatsApp, link e QR code. */
    @GetMapping("/organizador/campanhas/{id}/divulgar")
    public String divulgar(@PathVariable Long id,
                           @AuthenticationPrincipal AuthenticatedUser principal,
                           RedirectAttributes redirectAttributes,
                           Model model) {
        Optional<Campaign> campanhaOpt = campanhaService.buscarDoOrganizador(id, principal.getId());
        if (campanhaOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("toast", Toast.error("Campanha não encontrada", "Escolha uma das suas campanhas."));
            return "redirect:/organizador/campanhas";
        }
        Campaign campanha = campanhaOpt.get();
        model.addAttribute("campanha", campanha);
        model.addAttribute("linkPublico", baseUrl + "/campanhas/" + campanha.getId());
        // "Itapetininga, Tatuí e Sorocaba": sem repetições e sem a cidade de partida nem a do hemocentro
        model.addAttribute("paradasTexto", campanha.getPassaPor());
        return "pages/organizador-divulgar"; // -> templates/pages/organizador-divulgar.ftlh
    }

    private static void exigirSemErrosDeFormato(BindingResult binding) {
        if (binding.hasErrors()) {
            throw new BusinessException("Confira a data, as vagas, os horários e as coordenadas dos pontos.");
        }
    }

    /** campanha nula = nova campanha. */
    private static String formulario(Model model, CampanhaForm form, Campaign campanha) {
        model.addAttribute("form", form);
        model.addAttribute("campanha", campanha);
        model.addAttribute("imagens", OrganizadorCampanhaService.IMAGENS);
        model.addAttribute("statusOpcoes", CampaignStatus.values());
        return "pages/organizador-campanha"; // -> templates/pages/organizador-campanha.ftlh
    }
}
