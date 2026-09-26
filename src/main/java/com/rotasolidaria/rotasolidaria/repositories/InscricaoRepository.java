package com.rotasolidaria.rotasolidaria.repositories;

import com.rotasolidaria.rotasolidaria.models.Campaign;
import com.rotasolidaria.rotasolidaria.models.Donor;
import com.rotasolidaria.rotasolidaria.models.Registration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InscricaoRepository extends JpaRepository<Registration, Long> {
    List<Registration> findByCampaign(Campaign campaign);

    List<Registration> findByDonor(Donor donor);

    boolean existsByCampaignAndDonor(Campaign campaign, Donor donor);
}