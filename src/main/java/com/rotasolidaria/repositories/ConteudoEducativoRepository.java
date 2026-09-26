package com.rotasolidaria.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.models.EducationalContent;

import java.util.List;

@Repository
public interface ConteudoEducativoRepository extends JpaRepository<EducationalContent, Long> {
    List<EducationalContent> findAllByOrderByDisplayOrderAsc();
}