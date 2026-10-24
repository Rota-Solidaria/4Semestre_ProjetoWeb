package com.rotasolidaria.services;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
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
import org.springframework.context.ApplicationEventPublisher;

import com.rotasolidaria.events.CampaignCancelledEvent;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.repositories.CampanhaRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.OrganizerRepository;

@ExtendWith(MockitoExtension.class)
class OrganizadorCampanhaServiceTest {

    @Mock
    private CampanhaRepository campanhaRepository;

    @Mock
    private InscricaoRepository inscricaoRepository;

    @Mock
    private OrganizerRepository organizerRepository;

    @Mock
    private RotaService rotaService;

    @Mock
    private ApplicationEventPublisher events;

    private OrganizadorCampanhaService service;

    @BeforeEach
    void setUp() {
        service = new OrganizadorCampanhaService(campanhaRepository, inscricaoRepository, organizerRepository, rotaService, events);
    }

    private Campaign criarCampanha(Long id, Long organizerId, LocalDate date, CampaignStatus status) {
        Campaign c = new Campaign();
        c.setId(id);
        c.setEventDate(date);
        c.setStatus(status);

        User u = new User();
        u.setId(organizerId);
        Organizer org = new Organizer(u);
        c.setOrganizer(org);
        return c;
    }

    @Test
    void atualizarStatus_paraClosed_sucesso() {
        Long orgId = 1L;
        Long campId = 10L;
        Campaign c = criarCampanha(campId, orgId, LocalDate.now().plusDays(5), CampaignStatus.OPEN);

        when(campanhaRepository.findById(campId)).thenReturn(Optional.of(c));

        service.atualizarStatus(campId, orgId, CampaignStatus.CLOSED);

        assertEquals(CampaignStatus.CLOSED, c.getStatus());
        verify(campanhaRepository).save(c);
        verify(events, never()).publishEvent(any());
    }

    @Test
    void atualizarStatus_paraOpen_comDataFutura_sucesso() {
        Long orgId = 1L;
        Long campId = 10L;
        Campaign c = criarCampanha(campId, orgId, LocalDate.now().plusDays(5), CampaignStatus.CLOSED);

        when(campanhaRepository.findById(campId)).thenReturn(Optional.of(c));

        service.atualizarStatus(campId, orgId, CampaignStatus.OPEN);

        assertEquals(CampaignStatus.OPEN, c.getStatus());
        verify(campanhaRepository).save(c);
    }

    @Test
    void atualizarStatus_paraOpen_comDataPassada_lancaExcecao() {
        Long orgId = 1L;
        Long campId = 10L;
        Campaign c = criarCampanha(campId, orgId, LocalDate.now().minusDays(2), CampaignStatus.CLOSED);

        when(campanhaRepository.findById(campId)).thenReturn(Optional.of(c));

        BusinessException ex = assertThrows(BusinessException.class, () ->
                service.atualizarStatus(campId, orgId, CampaignStatus.OPEN)
        );

        assertEquals("Não é possível reabrir inscrições de uma campanha cuja data de realização já passou.", ex.getMessage());
        verify(campanhaRepository, never()).save(any());
    }

    @Test
    void atualizarStatus_paraCancelled_publicaEvento() {
        Long orgId = 1L;
        Long campId = 10L;
        Campaign c = criarCampanha(campId, orgId, LocalDate.now().plusDays(5), CampaignStatus.OPEN);

        when(campanhaRepository.findById(campId)).thenReturn(Optional.of(c));

        service.atualizarStatus(campId, orgId, CampaignStatus.CANCELLED);

        assertEquals(CampaignStatus.CANCELLED, c.getStatus());
        verify(campanhaRepository).save(c);
        verify(events).publishEvent(any(CampaignCancelledEvent.class));
    }

    @Test
    void excluir_removeInscricoesECampanha() {
        Long orgId = 1L;
        Long campId = 10L;
        Campaign c = criarCampanha(campId, orgId, LocalDate.now().plusDays(5), CampaignStatus.OPEN);

        Registration r1 = new Registration();
        r1.setId(100L);
        r1.setCampaign(c);

        when(campanhaRepository.findById(campId)).thenReturn(Optional.of(c));
        when(inscricaoRepository.findByCampaign(c)).thenReturn(List.of(r1));

        service.excluir(campId, orgId);

        verify(inscricaoRepository).deleteAll(List.of(r1));
        verify(campanhaRepository).delete(c);
    }
}

