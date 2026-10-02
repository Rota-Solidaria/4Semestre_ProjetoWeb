package com.rotasolidaria.services;

import com.rotasolidaria.dto.CampanhaForm;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.models.enums.TransportMode;
import com.rotasolidaria.repositories.CampanhaRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.OrganizerRepository;
import com.rotasolidaria.events.CampaignCancelledEvent;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Campanhas criadas e editadas pelo organizador (dados da campanha + rota do ônibus).
 */
@Service
public class OrganizadorCampanhaService {

    /** Fotos do projeto oferecidas no formulário (a primeira é a padrão). */
    public static final List<String> IMAGENS = List.of(
            "/images/doacaodesangue.jpeg",
            "/images/excursoes/foto-01.jpeg",
            "/images/excursoes/foto-02.jpg",
            "/images/excursoes/foto-03.jpg");

    private final CampanhaRepository campanhaRepository;
    private final InscricaoRepository inscricaoRepository;
    private final OrganizerRepository organizerRepository;
    private final RotaService rotaService;
    private final ApplicationEventPublisher events;

    public OrganizadorCampanhaService(CampanhaRepository campanhaRepository,
                                      InscricaoRepository inscricaoRepository,
                                      OrganizerRepository organizerRepository,
                                      RotaService rotaService,
                                      ApplicationEventPublisher events) {
        this.campanhaRepository = campanhaRepository;
        this.inscricaoRepository = inscricaoRepository;
        this.organizerRepository = organizerRepository;
        this.rotaService = rotaService;
        this.events = events;
    }

    public List<Campaign> campanhasDoOrganizador(Long organizerId) {
        return campanhaRepository.findByOrganizerIdOrderByEventDateDesc(organizerId);
    }

    /** Busca a campanha garantindo que ela pertence ao organizador logado. */
    public Optional<Campaign> buscarDoOrganizador(Long campaignId, Long organizerId) {
        return campanhaRepository.findById(campaignId)
                .filter(c -> c.getOrganizer() != null && c.getOrganizer().getId().equals(organizerId));
    }

    /** Formulário em branco para uma nova campanha. */
    public CampanhaForm novoForm() {
        CampanhaForm form = new CampanhaForm();
        form.setVagas(40);
        form.setStatus(CampaignStatus.OPEN);
        form.setModo(TransportMode.BUS);
        form.setImagemUrl(IMAGENS.get(0));
        return form;
    }

    /** Formulário com os dados atuais da campanha. */
    public CampanhaForm formDe(Campaign campaign) {
        CampanhaForm form = new CampanhaForm();
        form.setTitulo(campaign.getTitle());
        form.setDescricao(campaign.getDescription());
        form.setData(campaign.getEventDate());
        form.setVagas(campaign.getSlots());
        form.setStatus(campaign.getStatus());
        form.setModo(campaign.getTransportMode());
        if (campaign.getImageUrl() == null || IMAGENS.contains(campaign.getImageUrl())) {
            form.setImagemUrl(campaign.getImageUrl() == null ? IMAGENS.get(0) : campaign.getImageUrl());
        } else {
            form.setImagemLink(campaign.getImageUrl());
        }
        rotaService.preencher(form, campaign);
        form.setInscritos(inscritos(campaign));
        return form;
    }

    /** Recalcula o que é só exibição quando o formulário volta com erro. */
    public void completarExibicao(CampanhaForm form, Optional<Campaign> campaign) {
        rotaService.contarInscritos(form);
        campaign.ifPresent(c -> form.setInscritos(inscritos(c)));
    }

    @Transactional
    public Campaign criar(Long organizerId, CampanhaForm form) {
        Organizer organizer = organizerRepository.findById(organizerId)
                .orElseThrow(() -> new BusinessException("Apenas organizadores podem criar campanhas."));
        if (form.getData() != null && form.getData().isBefore(LocalDate.now())) {
            throw new BusinessException("A data da campanha não pode estar no passado.");
        }

        Campaign campaign = new Campaign();
        campaign.setOrganizer(organizer);
        aplicarDados(campaign, form, 0);
        campaign.setStatus(CampaignStatus.OPEN);
        rotaService.aplicar(campaign, form);
        return campanhaRepository.save(campaign);
    }

    @Transactional
    public void atualizar(Long campaignId, Long organizerId, CampanhaForm form) {
        Campaign campaign = buscarDoOrganizador(campaignId, organizerId)
                .orElseThrow(() -> new BusinessException("Campanha não encontrada."));
        CampaignStatus statusAnterior = campaign.getStatus();
        aplicarDados(campaign, form, inscritos(campaign));
        if (form.getStatus() != null) {
            campaign.setStatus(form.getStatus());
        }
        rotaService.aplicar(campaign, form);
        campanhaRepository.save(campaign);
        if (statusAnterior != CampaignStatus.CANCELLED && campaign.getStatus() == CampaignStatus.CANCELLED) {
            events.publishEvent(new CampaignCancelledEvent(campaign.getId()));
        }
    }

    private void aplicarDados(Campaign campaign, CampanhaForm form, long inscritos) {
        String titulo = form.getTitulo() == null ? "" : form.getTitulo().trim();
        if (titulo.isEmpty()) {
            throw new BusinessException("Dê um título para a campanha.");
        }
        if (titulo.length() > 140) {
            throw new BusinessException("O título pode ter no máximo 140 caracteres.");
        }
        if (form.getData() == null) {
            throw new BusinessException("Informe a data da campanha.");
        }
        if (form.getVagas() == null || form.getVagas() < 1) {
            throw new BusinessException("Informe quantas vagas o transporte tem.");
        }
        if (form.getVagas() < inscritos) {
            throw new BusinessException("Já há " + inscritos + " doadores inscritos: as vagas não podem ficar abaixo disso.");
        }

        campaign.setTitle(titulo);
        String descricao = form.getDescricao() == null ? null : form.getDescricao().trim();
        campaign.setDescription(descricao == null || descricao.isEmpty() ? null : descricao);
        campaign.setEventDate(form.getData());
        campaign.setSlots(form.getVagas());
        campaign.setTransportMode(TransportMode.BUS);
        campaign.setImageUrl(imagem(form));
    }

    private static String imagem(CampanhaForm form) {
        String link = form.getImagemLink() == null ? "" : form.getImagemLink().trim();
        if (!link.isEmpty()) {
            if (!link.matches("(?i)^https?://\\S+$") || link.length() > 255) {
                throw new BusinessException("O link da imagem precisa começar com http:// ou https://.");
            }
            return link;
        }
        return IMAGENS.contains(form.getImagemUrl()) ? form.getImagemUrl() : IMAGENS.get(0);
    }

    private long inscritos(Campaign campaign) {
        return campaign.getId() == null ? 0
                : inscricaoRepository.countByCampaignAndStatusNot(campaign, RegistrationStatus.CANCELLED);
    }
}
