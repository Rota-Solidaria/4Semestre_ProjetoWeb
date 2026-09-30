package com.rotasolidaria.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.enums.RegistrationStatus;

@Entity
@Table(
    name = "registrations", 
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"campaign_id", "donor_id"})
    }
)
public class Registration {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "campaign_id", nullable = false)
    private Campaign campaign;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "donor_id", nullable = false)
    private Donor donor;

    @Enumerated(EnumType.STRING)
    private RegistrationStatus status;

    @Column(columnDefinition = "TEXT")
    private String notes;

    // Onde o doador vai embarcar (ou "Vou por conta própria")
    @Column(name = "boarding_point", length = 160)
    private String boardingPoint;

    // Ponto da rota escolhido para embarcar (partida ou parada); nulo = vai por conta própria
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "boarding_location_id")
    private Location boardingLocation;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters e Setters
    
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Campaign getCampaign() {
        return campaign;
    }

    public void setCampaign(Campaign campaign) {
        this.campaign = campaign;
    }

    public Donor getDonor() {
        return donor;
    }

    public void setDonor(Donor donor) {
        this.donor = donor;
    }

    public RegistrationStatus getStatus() {
        return status;
    }

    public void setStatus(RegistrationStatus status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getBoardingPoint() {
        return boardingPoint;
    }

    public void setBoardingPoint(String boardingPoint) {
        this.boardingPoint = boardingPoint;
    }

    public Location getBoardingLocation() {
        return boardingLocation;
    }

    public void setBoardingLocation(Location boardingLocation) {
        this.boardingLocation = boardingLocation;
    }

    /** Código exibido no bilhete de embarque, ex.: RS-00042. */
    public String getCode() {
        return id == null ? null : "RS-%05d".formatted(id);
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
