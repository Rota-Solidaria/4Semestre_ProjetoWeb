package com.rotasolidaria.controllers;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.User;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.OrganizadorCampanhaService;

@ExtendWith(MockitoExtension.class)
class OrganizadorControllerTest {

    @Mock
    private OrganizadorCampanhaService campanhaService;

    private OrganizadorController controller;

    @BeforeEach
    void setUp() {
        controller = new OrganizadorController(campanhaService, "http://localhost:8080");
    }

    private AuthenticatedUser criarOrganizador(Long id) {
        User u = new User();
        u.setId(id);
        u.setEmail("org@teste.com");
        u.setName("Organizador Teste");
        u.setActive(true);
        return new AuthenticatedUser(u, false, true);
    }

    @Test
    void campanhas_retornaListaDoOrganizador() {
        AuthenticatedUser principal = criarOrganizador(1L);
        Model model = new ConcurrentModel();

        when(campanhaService.campanhasDoOrganizador(1L)).thenReturn(List.of(new Campaign()));

        String view = controller.campanhas(principal, model);

        assertEquals("pages/organizador-campanhas", view);
        assertTrue(model.containsAttribute("campanhas"));
    }

    @Test
    void alterarStatus_sucesso_redirecionaComToast() {
        AuthenticatedUser principal = criarOrganizador(1L);
        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.alterarStatus(10L, CampaignStatus.CLOSED, principal, ra);

        assertEquals("redirect:/organizador/campanhas", view);
        assertTrue(ra.getFlashAttributes().containsKey("toast"));
        verify(campanhaService).atualizarStatus(10L, 1L, CampaignStatus.CLOSED);
    }

    @Test
    void excluirCampanha_sucesso_redirecionaComToast() {
        AuthenticatedUser principal = criarOrganizador(1L);
        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.excluirCampanha(10L, principal, ra);

        assertEquals("redirect:/organizador/campanhas", view);
        assertTrue(ra.getFlashAttributes().containsKey("toast"));
        verify(campanhaService).excluir(10L, 1L);
    }
}

