package com.rotasolidaria.services;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Inscrição de doadores nas campanhas (a vaga no ônibus).
 */
@Service
public class InscricaoService {

    public static final String OWN_TRANSPORT = "Vou por conta própria";

    private final InscricaoRepository inscricaoRepository;
    private final DonorRepository donorRepository;

    public InscricaoService(InscricaoRepository inscricaoRepository, DonorRepository donorRepository) {
        this.inscricaoRepository = inscricaoRepository;
        this.donorRepository = donorRepository;
    }

    /** Opções de embarque da campanha: o ponto cadastrado (se houver) ou ir por conta própria. */
    public List<String> boardingOptions(Campaign campaign) {
        if (campaign.getDepartureLocation() != null) {
            return List.of(describe(campaign.getDepartureLocation().getName(), campaign.getDepartureLocation().getCity()),
                    OWN_TRANSPORT);
        }
        return List.of("Embarque na minha cidade (o organizador confirma o ponto)", OWN_TRANSPORT);
    }

    public Optional<Registration> findForDonor(Campaign campaign, Long userId) {
        return donorRepository.findById(userId).flatMap(donor -> inscricaoRepository.findByCampaignAndDonor(campaign, donor));
    }

    /** Busca uma inscrição garantindo que ela pertence ao usuário logado. */
    public Optional<Registration> findOwned(Long registrationId, Long userId) {
        return inscricaoRepository.findById(registrationId)
                .filter(r -> r.getDonor().getId().equals(userId));
    }

    public long slotsLeft(Campaign campaign) {
        int slots = campaign.getSlots() == null ? 0 : campaign.getSlots();
        long taken = inscricaoRepository.countByCampaignAndStatusNot(campaign, RegistrationStatus.CANCELLED);
        return Math.max(0, slots - taken);
    }

    @Transactional
    public Registration register(Campaign campaign, Long userId, String boardingPoint, String notes, boolean lgpdAccepted) {
        Donor donor = donorRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("Apenas doadores podem se inscrever nas campanhas."));

        if (inscricaoRepository.existsByCampaignAndDonor(campaign, donor)) {
            throw new BusinessException("Você já está inscrito nesta campanha.");
        }
        if (campaign.getStatus() != CampaignStatus.OPEN
                || (campaign.getEventDate() != null && campaign.getEventDate().isBefore(LocalDate.now()))) {
            throw new BusinessException("As inscrições desta campanha estão encerradas.");
        }
        if (slotsLeft(campaign) <= 0) {
            throw new BusinessException("Não há mais vagas no ônibus desta campanha.");
        }
        if (!lgpdAccepted) {
            throw new BusinessException("É preciso autorizar o envio dos seus dados ao organizador.");
        }
        if (boardingPoint == null || !boardingOptions(campaign).contains(boardingPoint)) {
            throw new BusinessException("Escolha um local de embarque.");
        }

        Registration registration = new Registration();
        registration.setCampaign(campaign);
        registration.setDonor(donor);
        registration.setStatus(RegistrationStatus.CONFIRMED);
        registration.setBoardingPoint(boardingPoint);
        registration.setNotes(notes == null || notes.isBlank() ? null : notes.trim());
        return inscricaoRepository.save(registration);
    }

    private static String describe(String name, String city) {
        return city == null || city.isBlank() ? name : name + ", " + city;
    }
}
