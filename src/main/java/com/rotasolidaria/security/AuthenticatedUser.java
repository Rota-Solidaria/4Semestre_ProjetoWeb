package com.rotasolidaria.security;

import com.rotasolidaria.models.User;
import org.springframework.security.core.CredentialsContainer;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
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

    /** Os papéis vêm dos perfis da conta: uma pessoa pode ser doadora e organizadora ao mesmo tempo. */
    public AuthenticatedUser(User user, boolean donor, boolean organizer) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.passwordHash = user.getPasswordHash();
        this.active = Boolean.TRUE.equals(user.getActive());
        List<GrantedAuthority> roles = new ArrayList<>();
        roles.add(new SimpleGrantedAuthority("ROLE_USER"));
        if (donor) {
            roles.add(new SimpleGrantedAuthority("ROLE_DONOR"));
        }
        if (organizer) {
            roles.add(new SimpleGrantedAuthority("ROLE_ORGANIZER"));
        }
        this.authorities = List.copyOf(roles);
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
