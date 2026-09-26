package com.rotasolidaria.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.enums.CampaignStatus;

import java.util.List;

@Repository
public interface CampanhaRepository extends JpaRepository<Campaign, Long> { 
    List<Campaign> findByStatus(CampaignStatus status);
    List<Campaign> findTop6ByStatus(CampaignStatus status);
}