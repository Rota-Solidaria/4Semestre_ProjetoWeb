package com.rotasolidaria.models;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class UserTest {

    @Test
    void usuarioComUmNomeApenas() {
        User user = new User();
        user.setName("Lucas");

        assertEquals("Lucas", user.getFirstName());
        assertEquals("L", user.getInitials());
    }

    @Test
    void usuarioComNomeSobrenome() {
        User user = new User();
        user.setName("Lucas Silva");

        assertEquals("Lucas", user.getFirstName());
        assertEquals("LS", user.getInitials());
    }

    @Test
    void usuarioComNomeCompostoEMultiplosSobrenomes() {
        User user = new User();
        user.setName("Maria Eduarda dos Santos Silva");

        assertEquals("Maria", user.getFirstName());
        assertEquals("MS", user.getInitials());
    }

    @Test
    void usuarioComEspacosExtras() {
        User user = new User();
        user.setName("   Lucas   Silva   ");

        assertEquals("Lucas", user.getFirstName());
        assertEquals("LS", user.getInitials());
    }

    @Test
    void usuarioComNomeNuloOuVazio() {
        User user = new User();
        user.setName(null);
        assertEquals("Usuário", user.getFirstName());
        assertEquals("US", user.getInitials());

        user.setName("");
        assertEquals("Usuário", user.getFirstName());
        assertEquals("US", user.getInitials());

        user.setName("   ");
        assertEquals("Usuário", user.getFirstName());
        assertEquals("US", user.getInitials());
    }

    @Test
    void donorDelegaNomeEIniciaisParaUser() {
        User user = new User();
        user.setName("Mateus");
        Donor donor = new Donor(user);

        assertEquals("Mateus", donor.getFirstName());
        assertEquals("M", donor.getInitials());
    }
}
