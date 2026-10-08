package com.rotasolidaria.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.enums.CampaignStatus;

import java.util.List;

@Repository
public interface CampanhaRepository extends JpaRepository<Campaign, Long> { 
    List<Campaign> findByStatus(CampaignStatus status);
    List<Campaign> findTop6ByStatus(CampaignStatus status);
    List<Campaign> findByOrganizerIdOrderByEventDateDesc(Long organizerId);

    Page<Campaign> findByStatusOrderByEventDateAsc(CampaignStatus status, Pageable pageable);

    @Query("SELECT c FROM Campaign c " +
           "LEFT JOIN c.donationLocation dl " +
           "LEFT JOIN c.departureLocation dpl " +
           "LEFT JOIN c.organizer o " +
           "LEFT JOIN o.user u " +
           "WHERE c.status = :status " +
           "AND (:busca IS NULL OR :busca = '' OR " +
           "LOWER(c.title) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(dl.city) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(dl.name) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(dpl.city) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(u.name) LIKE LOWER(CONCAT('%', :busca, '%')) OR " +
           "LOWER(o.institution) LIKE LOWER(CONCAT('%', :busca, '%'))) " +
           "ORDER BY c.eventDate ASC, c.id ASC")
    Page<Campaign> buscarAbertasComFiltro(@Param("status") CampaignStatus status, @Param("busca") String busca, Pageable pageable);
}