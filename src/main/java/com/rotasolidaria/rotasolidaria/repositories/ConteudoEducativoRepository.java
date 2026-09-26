package com.rotasolidaria.rotasolidaria.repositories;

import com.rotasolidaria.rotasolidaria.models.EducationalContent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConteudoEducativoRepository extends JpaRepository<EducationalContent, Long> {
    List<EducationalContent> findAllByOrderByDisplayOrderAsc();
}