package com.rotasolidaria.services;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.repositories.CampanhaRepository;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CampaignService {

    private final CampanhaRepository campanhaRepository;

    public CampaignService(CampanhaRepository campanhaRepository) {
        this.campanhaRepository = campanhaRepository;
    }

    public List<Campaign> listarTodas() {
        return campanhaRepository.findAll();
    }

    public List<Campaign> listarAbertas() {
        return campanhaRepository.findTop6ByStatus(com.rotasolidaria.models.enums.CampaignStatus.OPEN);
    }

    public Optional<Campaign> buscarPorId(Long id) {
        return campanhaRepository.findById(id);
    }
}