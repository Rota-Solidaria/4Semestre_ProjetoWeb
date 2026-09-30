package com.rotasolidaria.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.enums.RegistrationStatus;

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
}