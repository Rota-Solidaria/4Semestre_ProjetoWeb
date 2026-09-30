package com.rotasolidaria.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.enums.RegistrationStatus;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface InscricaoRepository extends JpaRepository<Registration, Long> {
    List<Registration> findByCampaign(Campaign campaign);

    List<Registration> findByDonor(Donor donor);

    boolean existsByCampaignAndDonor(Campaign campaign, Donor donor);

    Optional<Registration> findByCampaignAndDonor(Campaign campaign, Donor donor);

    long countByCampaignAndStatusNot(Campaign campaign, RegistrationStatus status);

    long countByBoardingLocationAndStatusNot(Location location, RegistrationStatus status);

    /** Inscrições ativas de uma campanha, já com o doador carregado (para enviar e-mails). */
    @Query("""
            select r from Registration r
            join fetch r.donor d join fetch d.user
            where r.campaign.id = :campaignId and r.status <> com.rotasolidaria.models.enums.RegistrationStatus.CANCELLED
            """)
    List<Registration> findAtivasComDoador(Long campaignId);

    /** Inscrições ativas, sem lembrete enviado, de campanhas não canceladas entre as datas informadas. */
    @Query("""
            select r from Registration r
            join fetch r.campaign c join fetch r.donor d join fetch d.user
            left join fetch r.boardingLocation
            where r.status <> com.rotasolidaria.models.enums.RegistrationStatus.CANCELLED
              and r.reminderSentAt is null
              and c.status <> com.rotasolidaria.models.enums.CampaignStatus.CANCELLED
              and c.eventDate between :de and :ate
            """)
    List<Registration> findPendentesDeLembrete(LocalDate de, LocalDate ate);
}
