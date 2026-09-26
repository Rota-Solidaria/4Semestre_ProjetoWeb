package com.rotasolidaria.models;

import jakarta.persistence.*;

@Entity
@Table(name = "organizers")
@PrimaryKeyJoinColumn(name = "user_id")
public class Organizer extends User {

    @Column(length = 120)
    private String institution;

    // Getters and Setters
    
    public String getInstitution() {
        return institution;
    }

    public void setInstitution(String institution) {
        this.institution = institution;
    }
}