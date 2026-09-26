package com.rotasolidaria.rotasolidaria.repositories;

import com.rotasolidaria.rotasolidaria.models.Campaign;
import com.rotasolidaria.rotasolidaria.models.enums.CampaignStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CampanhaRepository extends JpaRepository<Campaign, Long> { 
    List<Campaign> findByStatus(CampaignStatus status);
}