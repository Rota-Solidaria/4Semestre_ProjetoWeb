package com.rotasolidaria.controllers;

import com.rotasolidaria.dto.CampanhaForm;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.OrganizadorCampanhaService;
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

    public OrganizadorController(OrganizadorCampanhaService campanhaService) {
        this.campanhaService = campanhaService;
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
            redirectAttributes.addFlashAttribute("toast", Toast.success("Campanha criada", "As inscrições já estão abertas.")
                    .withIcon("campaign")
                    .withAction("Ver campanha", "/campanhas/" + campanha.getId()));
            return "redirect:/organizador/campanhas/" + campanha.getId() + "/editar";
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
                    .withAction("Ver campanha", "/campanhas/" + id));
            return "redirect:/organizador/campanhas/" + id + "/editar";
        } catch (BusinessException e) {
            // Mostra o formulário de novo com o que foi digitado, sem perder as paradas
            // (recarrega a campanha: o rollback descarta as alterações feitas nela)
            Optional<Campaign> campanha = campanhaService.buscarDoOrganizador(id, principal.getId());
            campanhaService.completarExibicao(form, campanha);
            model.addAttribute("toast", Toast.error("Não foi possível salvar a campanha", e.getMessage()));
            return formulario(model, form, campanha.orElse(null));
        }
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
