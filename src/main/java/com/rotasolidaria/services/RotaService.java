package com.rotasolidaria.services;

import com.rotasolidaria.dto.PontoForm;
import com.rotasolidaria.dto.RotaForm;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.RouteStop;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.LocalizacaoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Rota do ônibus de uma campanha: partida → paradas → hemocentro, editada pelo organizador.
 */
@Service
public class RotaService {

    private final LocalizacaoRepository localizacaoRepository;
    private final InscricaoRepository inscricaoRepository;

    public RotaService(LocalizacaoRepository localizacaoRepository,
                       InscricaoRepository inscricaoRepository) {
        this.localizacaoRepository = localizacaoRepository;
        this.inscricaoRepository = inscricaoRepository;
    }

    /** Preenche o formulário com a rota atual da campanha. */
    public void preencher(RotaForm form, Campaign campaign) {
        form.setPartida(pontoDe(campaign.getDepartureLocation(), campaign.getDepartureTime()));
        for (RouteStop stop : campaign.getStops()) {
            form.getParadas().add(pontoDe(stop.getLocation(), stop.getStopTime()));
        }
        form.setDestino(pontoDe(campaign.getDonationLocation(), campaign.getDonationTime()));
        contarInscritos(form);
    }

    /** Preenche quantos doadores (não cancelados) vão embarcar em cada ponto já salvo. */
    public void contarInscritos(RotaForm form) {
        List<PontoForm> pontos = new ArrayList<>(form.getParadas());
        pontos.add(form.getPartida());
        for (PontoForm ponto : pontos) {
            if (ponto.getLocationId() != null) {
                localizacaoRepository.findById(ponto.getLocationId()).ifPresent(l ->
                        ponto.setInscritos(inscricaoRepository.countByBoardingLocationAndStatusNot(l, RegistrationStatus.CANCELLED)));
            }
        }
    }

    /**
     * Valida a rota do formulário e aplica na campanha (nova ou existente).
     * Salva os locais; quem chama salva a campanha, dentro da mesma transação.
     */
    @Transactional
    public void aplicar(Campaign campaign, RotaForm form) {
        List<PontoForm> paradas = form.getParadas().stream().filter(p -> p != null && !p.isVazio()).toList();
        exigirNomeECidade(form.getPartida(), "a partida");
        for (int i = 0; i < paradas.size(); i++) {
            exigirNomeECidade(paradas.get(i), "a parada " + (i + 1));
        }
        exigirNomeECidade(form.getDestino(), "o hemocentro");
        exigirHorariosEmOrdem(form.getPartida(), paradas, form.getDestino());

        // Locais que já fazem parte desta rota: só eles podem ser editados pelo id vindo do formulário
        Map<Long, Location> atuais = new HashMap<>();
        guardar(atuais, campaign.getDepartureLocation());
        guardar(atuais, campaign.getDonationLocation());
        campaign.getStops().forEach(s -> guardar(atuais, s.getLocation()));

        Location partida = aplicar(form.getPartida(), atuais);
        List<Location> locaisDasParadas = paradas.stream().map(p -> aplicar(p, atuais)).toList();
        Location destino = aplicar(form.getDestino(), atuais);

        // Pontos de embarque que saíram da rota não podem ter doadores inscritos
        List<Location> embarquesAntigos = new ArrayList<>();
        if (campaign.getDepartureLocation() != null) {
            embarquesAntigos.add(campaign.getDepartureLocation());
        }
        campaign.getStops().forEach(s -> embarquesAntigos.add(s.getLocation()));
        for (Location antigo : embarquesAntigos) {
            boolean continua = antigo == partida || locaisDasParadas.contains(antigo);
            if (!continua && inscricaoRepository.countByBoardingLocationAndStatusNot(antigo, RegistrationStatus.CANCELLED) > 0) {
                throw new BusinessException("Há doadores inscritos para embarcar em \"" + antigo.getName()
                        + "\". Mantenha esse ponto na rota ou fale com eles antes de removê-lo.");
            }
        }

        campaign.setDepartureLocation(localizacaoRepository.save(partida));
        campaign.setDepartureTime(form.getPartida().getHorario());
        campaign.setDonationLocation(localizacaoRepository.save(destino));
        campaign.setDonationTime(form.getDestino().getHorario());

        campaign.getStops().clear();
        for (int i = 0; i < paradas.size(); i++) {
            RouteStop stop = new RouteStop();
            stop.setCampaign(campaign);
            stop.setLocation(localizacaoRepository.save(locaisDasParadas.get(i)));
            stop.setPosition(i);
            stop.setStopTime(paradas.get(i).getHorario());
            campaign.getStops().add(stop);
        }
    }

    private static void exigirNomeECidade(PontoForm ponto, String qual) {
        if (ponto == null || isBlank(ponto.getNome()) || isBlank(ponto.getCidade())) {
            throw new BusinessException("Informe o nome e a cidade d" + qual + ".");
        }
    }

    private static void exigirHorariosEmOrdem(PontoForm partida, List<PontoForm> paradas, PontoForm destino) {
        List<PontoForm> ordem = new ArrayList<>();
        ordem.add(partida);
        ordem.addAll(paradas);
        ordem.add(destino);
        LocalTime anterior = null;
        for (PontoForm ponto : ordem) {
            LocalTime horario = ponto.getHorario();
            if (horario == null) {
                continue;
            }
            if (anterior != null && !horario.isAfter(anterior)) {
                throw new BusinessException("Os horários precisam seguir a ordem da rota: \""
                        + ponto.getNome().trim() + "\" está marcado para " + horario + ", antes ou junto do ponto anterior.");
            }
            anterior = horario;
        }
    }

    private static void guardar(Map<Long, Location> mapa, Location location) {
        if (location != null && location.getId() != null) {
            mapa.put(location.getId(), location);
        }
    }

    /** Copia os dados do formulário para o local existente (se for desta rota) ou para um local novo. */
    private static Location aplicar(PontoForm ponto, Map<Long, Location> atuais) {
        Location location = ponto.getLocationId() == null ? null : atuais.get(ponto.getLocationId());
        if (location == null) {
            location = new Location();
        }
        location.setName(limpar(ponto.getNome(), 140));
        location.setZipCode(limparCep(ponto.getCep()));
        location.setStreet(limpar(ponto.getRua(), 200));
        location.setNumber(limpar(ponto.getNumero(), 10));
        location.setNeighborhood(limpar(ponto.getBairro(), 80));
        location.setCity(limpar(ponto.getCidade(), 80));
        String uf = limpar(ponto.getUf(), 2);
        location.setState(uf == null ? null : uf.toUpperCase());
        location.setReferencePoint(limpar(ponto.getReferencia(), 200));
        boolean coordenadasValidas = dentro(ponto.getLat(), 90) && dentro(ponto.getLng(), 180);
        location.setLatitude(coordenadasValidas ? ponto.getLat().setScale(7, RoundingMode.HALF_UP) : null);
        location.setLongitude(coordenadasValidas ? ponto.getLng().setScale(7, RoundingMode.HALF_UP) : null);
        return location;
    }

    private static PontoForm pontoDe(Location location, LocalTime horario) {
        PontoForm ponto = new PontoForm();
        ponto.setHorario(horario);
        if (location == null) {
            return ponto;
        }
        ponto.setLocationId(location.getId());
        ponto.setNome(location.getName());
        ponto.setCep(location.getZipCode());
        ponto.setRua(location.getStreet());
        ponto.setNumero(location.getNumber());
        ponto.setBairro(location.getNeighborhood());
        ponto.setCidade(location.getCity());
        ponto.setUf(location.getState());
        ponto.setReferencia(location.getReferencePoint());
        ponto.setLat(location.getLatitude());
        ponto.setLng(location.getLongitude());
        return ponto;
    }

    private static boolean dentro(BigDecimal valor, int limite) {
        return valor != null && valor.abs().compareTo(BigDecimal.valueOf(limite)) <= 0;
    }

    private static String limpar(String valor, int max) {
        if (isBlank(valor)) {
            return null;
        }
        String v = valor.trim();
        return v.length() > max ? v.substring(0, max) : v;
    }

    private static String limparCep(String cep) {
        if (cep == null) {
            return null;
        }
        String digitos = cep.replaceAll("\\D", "");
        return digitos.length() == 8 ? digitos : null;
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
