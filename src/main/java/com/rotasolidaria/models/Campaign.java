package com.rotasolidaria.models;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import com.rotasolidaria.util.Datas;

import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.models.enums.TransportMode;

@Entity
@Table(name = "campaigns")
public class Campaign {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 140)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "event_date")
    private LocalDate eventDate;

    @Column(name = "donation_time")
    private LocalTime donationTime;

    @Column(name = "departure_time")
    private LocalTime departureTime;

    private Integer slots;

    @Enumerated(EnumType.STRING)
    private CampaignStatus status; 

    @Column(name = "image_url")
    private String imageUrl;

    // Ônibus com rota ou encontro direto no local; nulo (campanhas antigas) vale ônibus
    @Enumerated(EnumType.STRING)
    @Column(name = "transport_mode", length = 10)
    private TransportMode transportMode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "donation_location_id", nullable = false)
    private Location donationLocation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "departure_location_id")
    private Location departureLocation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organizer_id", nullable = false)
    private Organizer organizer;

    // Paradas intermediárias da rota, entre a partida (departureLocation) e o destino (donationLocation)
    @OneToMany(mappedBy = "campaign", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position ASC")
    private List<RouteStop> stops = new ArrayList<>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDate getEventDate() {
        return eventDate;
    }

    public void setEventDate(LocalDate eventDate) {
        this.eventDate = eventDate;
    }

    /** Data da campanha no padrão brasileiro, para as telas (ex.: 14/10/2026). */
    public String getEventDateBr() {
        return Datas.br(eventDate);
    }

    public LocalTime getDonationTime() {
        return donationTime;
    }

    public void setDonationTime(LocalTime donationTime) {
        this.donationTime = donationTime;
    }

    public LocalTime getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(LocalTime departureTime) {
        this.departureTime = departureTime;
    }

    public Integer getSlots() {
        return slots;
    }

    public void setSlots(Integer slots) {
        this.slots = slots;
    }

    public CampaignStatus getStatus() {
        return status;
    }

    public void setStatus(CampaignStatus status) {
        this.status = status;
    }

    public TransportMode getTransportMode() {
        return transportMode == null ? TransportMode.BUS : transportMode;
    }

    public void setTransportMode(TransportMode transportMode) {
        this.transportMode = transportMode;
    }

    /** Modo Encontro: sem ônibus nem rota, cada doador vai por conta própria até o local da doação. */
    public boolean isMeeting() {
        return getTransportMode() == TransportMode.MEETING;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Location getDonationLocation() {
        return donationLocation;
    }

    public void setDonationLocation(Location donationLocation) {
        this.donationLocation = donationLocation;
    }

    public Location getDepartureLocation() {
        return departureLocation;
    }

    public void setDepartureLocation(Location departureLocation) {
        this.departureLocation = departureLocation;
    }

    public Organizer getOrganizer() {
        return organizer;
    }

    public void setOrganizer(Organizer organizer) {
        this.organizer = organizer;
    }

    public List<RouteStop> getStops() {
        return stops;
    }

    public void setStops(List<RouteStop> stops) {
        this.stops = stops;
    }

    /**
     * Cidades por onde a caravana passa, na ordem da rota, sem repetição e sem a cidade de
     * partida nem a do hemocentro (elas já aparecem em destaque). Serve para o resumo do story
     * e da mensagem compartilhada: duas paradas em Itapetininga viram só "Itapetininga".
     */
    public List<String> getCidadesIntermediarias() {
        List<String> cidades = new ArrayList<>();
        String partida = cidadeDe(departureLocation);
        String destino = cidadeDe(donationLocation);
        for (RouteStop parada : stops) {
            String cidade = cidadeDe(parada.getLocation());
            if (cidade.isEmpty() || mesmaCidade(cidade, partida) || mesmaCidade(cidade, destino)) {
                continue;
            }
            boolean repetida = false;
            for (String existente : cidades) {
                if (mesmaCidade(existente, cidade)) { repetida = true; break; }
            }
            if (!repetida) {
                cidades.add(cidade);
            }
        }
        return cidades;
    }

    /** "Itapetininga, Tatuí e Sorocaba" (ou "" quando não há cidade intermediária). */
    public String getPassaPor() {
        List<String> cidades = getCidadesIntermediarias();
        if (cidades.isEmpty()) {
            return "";
        }
        if (cidades.size() == 1) {
            return cidades.get(0);
        }
        return String.join(", ", cidades.subList(0, cidades.size() - 1)) + " e " + cidades.get(cidades.size() - 1);
    }

    private static String cidadeDe(Location local) {
        if (local == null) {
            return "";
        }
        String cidade = local.getCity() != null && !local.getCity().isBlank() ? local.getCity() : local.getName();
        return cidade == null ? "" : cidade.trim();
    }

    private static boolean mesmaCidade(String a, String b) {
        return !a.isEmpty() && a.equalsIgnoreCase(b);
    }

}
