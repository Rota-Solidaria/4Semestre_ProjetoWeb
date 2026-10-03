package com.rotasolidaria.services;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.repositories.CampanhaRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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

    public Page<Campaign> listarAbertasPaginadas(Pageable pageable) {
        return campanhaRepository.findByStatusOrderByEventDateAsc(com.rotasolidaria.models.enums.CampaignStatus.OPEN, pageable);
    }

    public Page<Campaign> buscarAbertas(String busca, Pageable pageable) {
        if (busca == null || busca.isBlank()) {
            return listarAbertasPaginadas(pageable);
        }
        return campanhaRepository.buscarAbertasComFiltro(
                com.rotasolidaria.models.enums.CampaignStatus.OPEN,
                busca.trim(),
                pageable
        );
    }

    public Optional<Campaign> buscarPorId(Long id) {
        return campanhaRepository.findById(id);
    }
}