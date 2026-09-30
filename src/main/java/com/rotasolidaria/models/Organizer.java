package com.rotasolidaria.models;

import jakarta.persistence.*;

/** Perfil de organizador de uma conta (mesmo id do usuário): quem cria campanhas e rotas. */
@Entity
@Table(name = "organizers")
public class Organizer {

    @Id
    private Long id;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(length = 120)
    private String institution;

    protected Organizer() {
    }

    public Organizer(User user) {
        this.user = user;
    }

    // Atalhos para os dados da conta (ex.: campanha.organizer.name nos templates)

    public String getName() {
        return user.getName();
    }

    public String getEmail() {
        return user.getEmail();
    }

    public String getPhone() {
        return user.getPhone();
    }

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public String getInstitution() {
        return institution;
    }

    public void setInstitution(String institution) {
        this.institution = institution;
    }
}
