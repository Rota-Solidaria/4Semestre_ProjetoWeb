package com.rotasolidaria.controllers;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.CampanhaRepository;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.OrganizerRepository;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.AuthService;

@ExtendWith(MockitoExtension.class)
class ProfileControllerTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private DonorRepository donorRepository;

    @Mock
    private OrganizerRepository organizerRepository;

    @Mock
    private InscricaoRepository inscricaoRepository;

    @Mock
    private CampanhaRepository campanhaRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private AuthService authService;

    private ProfileController controller;

    @BeforeEach
    void setUp() {
        controller = new ProfileController(userRepository, donorRepository, organizerRepository,
                inscricaoRepository, campanhaRepository, passwordEncoder, authService);
    }

    private User criarUsuario(Long id) {
        User u = new User();
        u.setId(id);
        u.setName("João Ramos");
        u.setEmail("joao@teste.com");
        u.setActive(true);
        return u;
    }

    @Test
    void perfil_organizador_naoCarregaInscricoesECarregaCampanhas() {
        Long orgId = 1L;
        User user = criarUsuario(orgId);
        AuthenticatedUser principal = new AuthenticatedUser(user, false, true); // isOrganizer = true

        Organizer org = new Organizer(user);
        org.setInstitution("Colsan Sorocaba");

        when(userRepository.findById(orgId)).thenReturn(Optional.of(user));
        when(organizerRepository.findById(orgId)).thenReturn(Optional.of(org));

        Campaign c = new Campaign();
        c.setId(10L);
        c.setTitle("Caravana Sorocaba");
        when(campanhaRepository.findByOrganizerIdOrderByEventDateDesc(orgId)).thenReturn(List.of(c));

        Model model = new ConcurrentModel();
        MockHttpSession session = new MockHttpSession();

        String view = controller.perfil(principal, session, model);

        assertEquals("pages/perfil", view);
        assertFalse((Boolean) model.getAttribute("isDonor"));
        assertTrue(model.containsAttribute("campanhasOrganizador"));
        assertEquals(List.of(c), model.getAttribute("campanhasOrganizador"));
        assertEquals(List.of(), model.getAttribute("inscricoes"));
        verify(inscricaoRepository, never()).findByDonor(any());
    }

    @Test
    void perfil_doador_carregaInscricoes() {
        Long donorId = 2L;
        User user = criarUsuario(donorId);
        AuthenticatedUser principal = new AuthenticatedUser(user, true, false); // isDonor = true

        Donor donor = new Donor(user);

        Registration reg = new Registration();
        reg.setId(50L);

        when(userRepository.findById(donorId)).thenReturn(Optional.of(user));
        when(organizerRepository.findById(donorId)).thenReturn(Optional.empty());
        when(donorRepository.findById(donorId)).thenReturn(Optional.of(donor));
        when(inscricaoRepository.findByDonor(donor)).thenReturn(List.of(reg));

        Model model = new ConcurrentModel();
        MockHttpSession session = new MockHttpSession();

        String view = controller.perfil(principal, session, model);

        assertEquals("pages/perfil", view);
        assertTrue((Boolean) model.getAttribute("isDonor"));
        assertEquals(List.of(reg), model.getAttribute("inscricoes"));
        assertFalse(model.containsAttribute("campanhasOrganizador"));
        verify(campanhaRepository, never()).findByOrganizerIdOrderByEventDateDesc(any());
    }
}

