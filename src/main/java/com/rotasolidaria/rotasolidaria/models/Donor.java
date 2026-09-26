package com.rotasolidaria.rotasolidaria.models;

import java.time.LocalDate;
import org.springframework.context.annotation.Primary;
import com.rotasolidaria.rotasolidaria.models.enums.BloodType;
import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "donors")
@PrimaryKeyJoinColumn(name = "user_id")
public class Donor extends User {

    @Enumerated(EnumType.STRING)
    @Column(name = "blood_type", length = 15)
    private BloodType bloodType; 

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "weight")
    private Double weight;

    // Getters and Setters

    public BloodType getBloodType() {
        return bloodType;
    }    

    public void setBloodType(BloodType bloodType) {
        this.bloodType = bloodType;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

}
