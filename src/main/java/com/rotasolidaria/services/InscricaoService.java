package com.rotasolidaria.services;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.RouteStop;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Inscrição de doadores nas campanhas (a vaga no ônibus).
 */
@Service
public class InscricaoService {

    public static final String OWN_TRANSPORT = "Vou por conta própria";
    /** Valor do formulário para "Vou por conta própria". */
    public static final String OWN_TRANSPORT_KEY = "proprio";
    /** Ponto de embarque gravado nas inscrições do modo Encontro (não há ônibus). */
    public static final String MEETING_POINT = "Encontro no local da doação";
    public static final String MEETING_KEY = "encontro";

    private final InscricaoRepository inscricaoRepository;
    private final DonorRepository donorRepository;
    private final UserRepository userRepository;

    public InscricaoService(InscricaoRepository inscricaoRepository, DonorRepository donorRepository,
                            UserRepository userRepository) {
        this.inscricaoRepository = inscricaoRepository;
        this.donorRepository = donorRepository;
        this.userRepository = userRepository;
    }

    /**
     * Opções de embarque da campanha: a partida, cada parada da rota (em ordem) e ir por conta própria.
     * No modo Encontro só existe o encontro no local da doação.
     */
    public List<BoardingOption> boardingOptions(Campaign campaign) {
        List<BoardingOption> options = new ArrayList<>();
        if (campaign.isMeeting()) {
            options.add(new BoardingOption(MEETING_KEY, MEETING_POINT, campaign.getDonationTime(), null, false));
            return options;
        }
        Location departure = campaign.getDepartureLocation();
        if (departure != null) {
            options.add(busOption(departure, campaign.getDepartureTime()));
            for (RouteStop stop : campaign.getStops()) {
                options.add(busOption(stop.getLocation(), stop.getStopTime()));
            }
        } else {
            options.add(new BoardingOption("cidade", "Embarque na minha cidade (o organizador confirma o ponto)",
                    campaign.getDepartureTime(), null, true));
        }
        options.add(new BoardingOption(OWN_TRANSPORT_KEY, OWN_TRANSPORT, campaign.getDonationTime(), null, false));
        return options;
    }

    /** Vai de ônibus? Inscrições antigas só têm o texto do ponto de embarque. */
    public static boolean goesByBus(Registration registration) {
        return !registration.getCampaign().isMeeting() && !OWN_TRANSPORT.equals(registration.getBoardingPoint());
    }

    /** Horário em que o ônibus passa no ponto escolhido pelo doador (nulo se vai por conta própria). */
    public static LocalTime boardingTime(Registration registration) {
        if (!goesByBus(registration)) {
            return null;
        }
        Campaign campaign = registration.getCampaign();
        Location chosen = registration.getBoardingLocation();
        if (chosen != null) {
            for (RouteStop stop : campaign.getStops()) {
                if (stop.getLocation().getId().equals(chosen.getId())) {
                    return stop.getStopTime();
                }
            }
        }
        return campaign.getDepartureTime();
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
    public Registration register(Campaign campaign, Long userId, String boardingKey, String notes, boolean lgpdAccepted) {
        if (campaign.getOrganizer() != null && campaign.getOrganizer().getId().equals(userId)) {
            throw new BusinessException("Você organiza esta campanha. Para doar, escolha a campanha de outro organizador.");
        }
        // Quem ainda não tem perfil de doador (ex.: um organizador) ganha um na primeira inscrição
        Donor donor = donorRepository.findById(userId).orElseGet(() -> donorRepository.save(new Donor(
                userRepository.findById(userId).orElseThrow(() -> new BusinessException("Faça login para se inscrever.")))));

        if (inscricaoRepository.existsByCampaignAndDonor(campaign, donor)) {
            throw new BusinessException("Você já está inscrito nesta campanha.");
        }
        if (campaign.getStatus() != CampaignStatus.OPEN
                || (campaign.getEventDate() != null && campaign.getEventDate().isBefore(LocalDate.now()))) {
            throw new BusinessException("As inscrições desta campanha estão encerradas.");
        }
        if (slotsLeft(campaign) <= 0) {
            throw new BusinessException(campaign.isMeeting() ? "Não há mais vagas nesta campanha."
                    : "Não há mais vagas no ônibus desta campanha.");
        }
        if (!lgpdAccepted) {
            throw new BusinessException("É preciso autorizar o envio dos seus dados ao organizador.");
        }
        // No modo Encontro só há um jeito de chegar, então o formulário nem pergunta
        BoardingOption boarding = boardingOptions(campaign).stream()
                .filter(o -> campaign.isMeeting() || o.getKey().equals(boardingKey))
                .findFirst()
                .orElseThrow(() -> new BusinessException("Escolha um local de embarque."));

        Registration registration = new Registration();
        registration.setCampaign(campaign);
        registration.setDonor(donor);
        registration.setStatus(RegistrationStatus.CONFIRMED);
        String label = boarding.getLabel();
        registration.setBoardingPoint(label.length() > 160 ? label.substring(0, 160) : label);
        registration.setBoardingLocation(boarding.getLocation());
        registration.setNotes(notes == null || notes.isBlank() ? null : notes.trim());
        return inscricaoRepository.save(registration);
    }

    private static BoardingOption busOption(Location location, LocalTime time) {
        return new BoardingOption(location.getId().toString(), describe(location.getName(), location.getCity()), time, location, true);
    }

    public static String describe(String name, String city) {
        return city == null || city.isBlank() ? name : name + ", " + city;
    }
}
