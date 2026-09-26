package com.rotasolidaria.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Registration;

import java.util.List;

@Repository
public interface InscricaoRepository extends JpaRepository<Registration, Long> {
    List<Registration> findByCampaign(Campaign campaign);

    List<Registration> findByDonor(Donor donor);

    boolean existsByCampaignAndDonor(Campaign campaign, Donor donor);
}