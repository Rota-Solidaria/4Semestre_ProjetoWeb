package com.rotasolidaria.models;

import java.time.LocalDate;

import com.rotasolidaria.models.enums.BloodType;
import com.rotasolidaria.util.Datas;

import jakarta.persistence.*;

/** Perfil de doador de uma conta (mesmo id do usuário). */
@Entity
@Table(name = "donors")
public class Donor {

    @Id
    private Long id;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "blood_type", length = 15)
    private BloodType bloodType;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "weight")
    private Double weight;

    protected Donor() {
    }

    public Donor(User user) {
        this.user = user;
    }

    // Atalhos para os dados da conta (ex.: inscricao.donor.name nos templates)

    public String getName() {
        return user.getName();
    }

    public String getEmail() {
        return user.getEmail();
    }

    public String getPhone() {
        return user.getPhone();
    }

    public String getFirstName() {
        return user != null ? user.getFirstName() : "Doador";
    }

    public String getInitials() {
        return user != null ? user.getInitials() : "US";
    }

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

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

    /** Data de nascimento no padrão brasileiro, para as telas. */
    public String getBirthDateBr() {
        return Datas.br(birthDate);
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}
