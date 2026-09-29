package com.rotasolidaria.security;

import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.User;
import org.springframework.security.core.CredentialsContainer;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * Usuário autenticado guardado pelo Spring Security na sessão.
 * Guarda só o necessário para identificar o usuário; os dados completos
 * são buscados no banco quando precisamos deles (ver GlobalControllerAdvice).
 */
public class AuthenticatedUser implements UserDetails, CredentialsContainer {

    private final Long id;
    private final String email;
    private String passwordHash;
    private final boolean active;
    private final List<GrantedAuthority> authorities;

    public AuthenticatedUser(User user) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.passwordHash = user.getPasswordHash();
        this.active = Boolean.TRUE.equals(user.getActive());
        this.authorities = List.of(new SimpleGrantedAuthority(roleOf(user)));
    }

    private static String roleOf(User user) {
        if (user instanceof Organizer) {
            return "ROLE_ORGANIZER";
        }
        if (user instanceof Donor) {
            return "ROLE_DONOR";
        }
        return "ROLE_USER";
    }

    public Long getId() {
        return id;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public String getPassword() {
        return passwordHash;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    // Remove o hash da senha da memória/sessão depois que o login é concluído
    @Override
    public void eraseCredentials() {
        this.passwordHash = null;
    }
}
