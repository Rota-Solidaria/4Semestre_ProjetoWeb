package com.rotasolidaria.rotasolidaria.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.rotasolidaria.rotasolidaria.models.Location;

@Repository
public interface LocalizacaoRepository extends JpaRepository<Location, Long> {

}