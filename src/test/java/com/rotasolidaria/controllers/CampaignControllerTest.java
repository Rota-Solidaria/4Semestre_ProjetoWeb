package com.rotasolidaria.controllers;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.services.CampaignService;
import com.rotasolidaria.services.InscricaoService;

@ExtendWith(MockitoExtension.class)
class CampaignControllerTest {

    @Mock
    private CampaignService campaignService;

    @Mock
    private InscricaoService inscricaoService;

    private CampaignController campaignController;

    @BeforeEach
    void setUp() {
        campaignController = new CampaignController(campaignService, inscricaoService);
    }

    @Test
    void listarAplicaLimiteEPaginacaoCorretamente() {
        List<Campaign> lista = new ArrayList<>();
        for (int i = 1; i <= 6; i++) {
            Campaign c = new Campaign();
            c.setTitle("Campanha " + i);
            lista.add(c);
        }

        Page<Campaign> page = new PageImpl<>(lista, PageRequest.of(0, 6), 18);
        when(campaignService.buscarAbertas(eq(null), any(Pageable.class))).thenReturn(page);

        Model model = new ConcurrentModel();
        String view = campaignController.listar(1, null, null, null, null, null, model);

        assertEquals("pages/campanhas", view);
        assertEquals(lista, model.getAttribute("campanhas"));
        assertEquals(1, model.getAttribute("paginaAtual"));
        assertEquals(3, model.getAttribute("totalPaginas"));
        assertEquals(18L, model.getAttribute("totalElementos"));
        assertEquals(6, model.getAttribute("limite"));
    }

    @Test
    void listarNavegaParaProximaPagina() {
        List<Campaign> lista = new ArrayList<>();
        for (int i = 7; i <= 12; i++) {
            Campaign c = new Campaign();
            c.setTitle("Campanha " + i);
            lista.add(c);
        }

        Page<Campaign> page = new PageImpl<>(lista, PageRequest.of(1, 6), 18);
        when(campaignService.buscarAbertas(eq(null), any(Pageable.class))).thenReturn(page);

        Model model = new ConcurrentModel();
        String view = campaignController.listar(2, null, null, null, null, null, model);

        assertEquals("pages/campanhas", view);
        assertEquals(2, model.getAttribute("paginaAtual"));
        assertEquals(3, model.getAttribute("totalPaginas"));
        assertTrue((Boolean) model.getAttribute("temAnterior"));
        assertTrue((Boolean) model.getAttribute("temProxima"));
    }
}
