package com.rotasolidaria.controllers;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

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
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.repositories.OrganizerRepository;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.CampaignService;
import com.rotasolidaria.services.InscricaoService;

@ExtendWith(MockitoExtension.class)
class InscricaoControllerTest {

    @Mock
    private CampaignService campaignService;

    @Mock
    private InscricaoService inscricaoService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private OrganizerRepository organizerRepository;

    private InscricaoController controller;

    @BeforeEach
    void setUp() {
        controller = new InscricaoController(campaignService, inscricaoService, userRepository, organizerRepository, "http://localhost:8080");
    }

    private User criarUsuario(Long id, String email) {
        User u = new User();
        u.setId(id);
        u.setEmail(email);
        u.setName("Usuário Teste");
        u.setActive(true);
        return u;
    }

    private Campaign criarCampanha(Long id, LocalDate date, CampaignStatus status) {
        Campaign c = new Campaign();
        c.setId(id);
        c.setTitle("Campanha Teste");
        c.setEventDate(date);
        c.setStatus(status);
        c.setSlots(30);

        Location loc = new Location();
        loc.setId(10L);
        loc.setName("Terminal Central");
        c.setDepartureLocation(loc);
        c.setDonationLocation(loc);
        return c;
    }

    @Test
    void formInscricao_organizacaoTentandoAcessar_bloqueadaERedirecionadaComAviso() {
        User u = criarUsuario(1L, "ong@exemplo.com");
        AuthenticatedUser principal = new AuthenticatedUser(u, false, true); // isOrganizer = true

        Campaign c = criarCampanha(10L, LocalDate.now().plusDays(5), CampaignStatus.OPEN);
        when(campaignService.buscarPorId(10L)).thenReturn(Optional.of(c));

        Model model = new ConcurrentModel();
        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.formInscricao(10L, principal, ra, model);

        assertEquals("redirect:/campanhas/10", view);
        assertTrue(ra.getFlashAttributes().containsKey("toast"));
    }

    @Test
    void processarInscricao_organizacaoTentandoSeInscrever_bloqueadaERedirecionadaComAviso() {
        User u = criarUsuario(1L, "ong@exemplo.com");
        AuthenticatedUser principal = new AuthenticatedUser(u, false, true); // isOrganizer = true

        Campaign c = criarCampanha(10L, LocalDate.now().plusDays(5), CampaignStatus.OPEN);
        when(campaignService.buscarPorId(10L)).thenReturn(Optional.of(c));

        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.processarInscricao(10L, principal, "10", "Obs", "on", ra);

        assertEquals("redirect:/campanhas/10", view);
        assertTrue(ra.getFlashAttributes().containsKey("toast"));
        verify(inscricaoService, never()).register(any(), anyLong(), anyString(), anyString(), anyBoolean());
    }

    @Test
    void formInscricao_campanhaComDataPassada_bloqueiaInscricao() {
        User u = criarUsuario(2L, "doador@exemplo.com");
        AuthenticatedUser principal = new AuthenticatedUser(u, true, false); // isDonor = true

        Campaign c = criarCampanha(10L, LocalDate.now().minusDays(2), CampaignStatus.OPEN);
        when(campaignService.buscarPorId(10L)).thenReturn(Optional.of(c));
        when(organizerRepository.existsById(2L)).thenReturn(false);

        Model model = new ConcurrentModel();
        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.formInscricao(10L, principal, ra, model);

        assertEquals("redirect:/campanhas/10", view);
        assertTrue(ra.getFlashAttributes().containsKey("toast"));
    }

    @Test
    void formInscricao_doadorComCampanhaAberta_renderizaPaginaDeInscricao() {
        User u = criarUsuario(2L, "doador@exemplo.com");
        AuthenticatedUser principal = new AuthenticatedUser(u, true, false);

        Campaign c = criarCampanha(10L, LocalDate.now().plusDays(5), CampaignStatus.OPEN);
        when(campaignService.buscarPorId(10L)).thenReturn(Optional.of(c));
        when(organizerRepository.existsById(2L)).thenReturn(false);
        when(inscricaoService.slotsLeft(c)).thenReturn(15L);
        when(inscricaoService.boardingOptions(c)).thenReturn(List.of());

        Model model = new ConcurrentModel();
        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.formInscricao(10L, principal, ra, model);

        assertEquals("pages/inscrever-campanha", view);
        assertEquals(c, model.getAttribute("campanha"));
        assertEquals(15L, model.getAttribute("vagasRestantes"));
    }

    @Test
    void processarInscricao_doadorValido_realizaInscricaoComSucesso() {
        User u = criarUsuario(2L, "doador@exemplo.com");
        AuthenticatedUser principal = new AuthenticatedUser(u, true, false);

        Campaign c = criarCampanha(10L, LocalDate.now().plusDays(5), CampaignStatus.OPEN);
        when(campaignService.buscarPorId(10L)).thenReturn(Optional.of(c));
        when(organizerRepository.existsById(2L)).thenReturn(false);

        Registration reg = new Registration();
        reg.setId(500L);
        when(inscricaoService.register(eq(c), eq(2L), eq("10"), eq("Sem bagagem"), eq(true))).thenReturn(reg);

        RedirectAttributes ra = new RedirectAttributesModelMap();

        String view = controller.processarInscricao(10L, principal, "10", "Sem bagagem", "on", ra);

        assertEquals("redirect:/inscricoes/500", view);
        verify(inscricaoService).register(eq(c), eq(2L), eq("10"), eq("Sem bagagem"), eq(true));
    }
}

