package com.rotasolidaria.services;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.OrganizerRepository;
import com.rotasolidaria.repositories.UserRepository;

@ExtendWith(MockitoExtension.class)
class InscricaoServiceTest {

    @Mock
    private InscricaoRepository inscricaoRepository;

    @Mock
    private DonorRepository donorRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private OrganizerRepository organizerRepository;

    private InscricaoService inscricaoService;

    @BeforeEach
    void setUp() {
        inscricaoService = new InscricaoService(inscricaoRepository, donorRepository, userRepository, organizerRepository);
    }

    private Campaign criarCampanha(LocalDate eventDate, CampaignStatus status, Integer slots) {
        Campaign c = new Campaign();
        c.setId(10L);
        c.setTitle("Campanha Teste");
        c.setEventDate(eventDate);
        c.setStatus(status);
        c.setSlots(slots);

        Location partida = new Location();
        partida.setId(100L);
        partida.setName("Terminal Rodoviário");
        partida.setCity("Itapetininga");
        c.setDepartureLocation(partida);

        Location destino = new Location();
        destino.setId(200L);
        destino.setName("Hemocentro Regional");
        destino.setCity("Sorocaba");
        c.setDonationLocation(destino);

        return c;
    }

    @Test
    void organizacaoNaoPodeSeInscreverEmNenhumaCampanha() {
        Long organizerUserId = 99L;
        Campaign c = criarCampanha(LocalDate.now().plusDays(7), CampaignStatus.OPEN, 30);

        when(organizerRepository.existsById(organizerUserId)).thenReturn(true);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                inscricaoService.register(c, organizerUserId, "100", "Nota", true)
        );

        assertEquals("Organizações não podem realizar inscrições em campanhas.", ex.getMessage());
        verify(inscricaoRepository, never()).save(any(Registration.class));
    }

    @Test
    void inscricaoFalhaQuandoCampanhaTemDataPassada() {
        Long donorUserId = 5L;
        // Data no passado (ex: 22/10/2026 quando hoje é 24/10/2026)
        Campaign c = criarCampanha(LocalDate.now().minusDays(2), CampaignStatus.OPEN, 30);

        when(organizerRepository.existsById(donorUserId)).thenReturn(false);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                inscricaoService.register(c, donorUserId, "100", null, true)
        );

        assertEquals("As inscrições desta campanha estão encerradas.", ex.getMessage());
        verify(inscricaoRepository, never()).save(any(Registration.class));
    }

    @Test
    void inscricaoFalhaQuandoCampanhaEstaCancelada() {
        Long donorUserId = 5L;
        Campaign c = criarCampanha(LocalDate.now().plusDays(5), CampaignStatus.CANCELLED, 30);

        when(organizerRepository.existsById(donorUserId)).thenReturn(false);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                inscricaoService.register(c, donorUserId, "100", null, true)
        );

        assertEquals("As inscrições desta campanha estão encerradas.", ex.getMessage());
        verify(inscricaoRepository, never()).save(any(Registration.class));
    }

    @Test
    void inscricaoFalhaQuandoCampanhaEstaFechada() {
        Long donorUserId = 5L;
        Campaign c = criarCampanha(LocalDate.now().plusDays(5), CampaignStatus.CLOSED, 30);

        when(organizerRepository.existsById(donorUserId)).thenReturn(false);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                inscricaoService.register(c, donorUserId, "100", null, true)
        );

        assertEquals("As inscrições desta campanha estão encerradas.", ex.getMessage());
        verify(inscricaoRepository, never()).save(any(Registration.class));
    }

    @Test
    void inscricaoFalhaQuandoVagasEsgotadas() {
        Long donorUserId = 5L;
        Campaign c = criarCampanha(LocalDate.now().plusDays(5), CampaignStatus.OPEN, 20);

        when(organizerRepository.existsById(donorUserId)).thenReturn(false);
        when(inscricaoRepository.countByCampaignAndStatusNot(c, RegistrationStatus.CANCELLED)).thenReturn(20L);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                inscricaoService.register(c, donorUserId, "100", null, true)
        );

        assertEquals("Não há mais vagas no transporte desta campanha.", ex.getMessage());
        verify(inscricaoRepository, never()).save(any(Registration.class));
    }

    @Test
    void inscricaoFalhaQuandoNaoAceitaLgpd() {
        Long donorUserId = 5L;
        Campaign c = criarCampanha(LocalDate.now().plusDays(5), CampaignStatus.OPEN, 20);

        when(organizerRepository.existsById(donorUserId)).thenReturn(false);
        when(inscricaoRepository.countByCampaignAndStatusNot(c, RegistrationStatus.CANCELLED)).thenReturn(0L);

        BusinessException ex = assertThrows(BusinessException.class, () ->
                inscricaoService.register(c, donorUserId, "100", null, false)
        );

        assertEquals("É preciso autorizar o envio dos seus dados ao organizador.", ex.getMessage());
        verify(inscricaoRepository, never()).save(any(Registration.class));
    }

    @Test
    void doadorValidoSeInscreveComSucessoEmCampanhaAberta() {
        Long donorUserId = 5L;
        Campaign c = criarCampanha(LocalDate.now().plusDays(5), CampaignStatus.OPEN, 20);

        User user = new User();
        user.setId(donorUserId);
        user.setName("Doador João");

        Donor donor = new Donor(user);

        when(organizerRepository.existsById(donorUserId)).thenReturn(false);
        when(inscricaoRepository.countByCampaignAndStatusNot(c, RegistrationStatus.CANCELLED)).thenReturn(5L);
        when(donorRepository.findById(donorUserId)).thenReturn(Optional.of(donor));
        when(inscricaoRepository.existsByCampaignAndDonor(c, donor)).thenReturn(false);
        when(inscricaoRepository.save(any(Registration.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Registration reg = inscricaoService.register(c, donorUserId, "100", "Sem bagagem", true);

        assertNotNull(reg);
        assertEquals(RegistrationStatus.CONFIRMED, reg.getStatus());
        assertEquals(c, reg.getCampaign());
        assertEquals(donor, reg.getDonor());
        assertEquals("Sem bagagem", reg.getNotes());
        verify(inscricaoRepository).save(any(Registration.class));
    }
}

