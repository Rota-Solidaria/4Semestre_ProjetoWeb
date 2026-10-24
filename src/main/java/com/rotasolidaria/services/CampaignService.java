package com.rotasolidaria.services;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.repositories.CampanhaRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
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
        return campanhaRepository.findTop6ByStatus(CampaignStatus.OPEN);
    }

    public Page<Campaign> listarAbertasPaginadas(Pageable pageable) {
        return campanhaRepository.findAbertasValidas(CampaignStatus.OPEN, LocalDate.now(), pageable);
    }

    public Page<Campaign> buscarAbertas(String busca, Pageable pageable) {
        LocalDate hoje = LocalDate.now();
        if (busca == null || busca.isBlank()) {
            return campanhaRepository.findAbertasValidas(CampaignStatus.OPEN, hoje, pageable);
        }
        return campanhaRepository.buscarAbertasComFiltro(
                CampaignStatus.OPEN,
                busca.trim(),
                hoje,
                pageable
        );
    }

    public Optional<Campaign> buscarPorId(Long id) {
        return campanhaRepository.findById(id);
    }
}
