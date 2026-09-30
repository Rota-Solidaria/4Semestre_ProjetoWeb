package com.rotasolidaria.config;

import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.security.AuthenticatedUser;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalControllerAdvice {

    private final UserRepository userRepository;

    public GlobalControllerAdvice(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // Disponibiliza o usuário logado (dados atualizados do banco) para todos os templates
    @ModelAttribute("usuarioLogado")
    public User getUsuarioLogado(@AuthenticationPrincipal AuthenticatedUser principal) {
        if (principal == null) {
            return null;
        }
        return userRepository.findById(principal.getId()).orElse(null);
    }

    // Mostra no menu do usuário o atalho para a área do organizador
    @ModelAttribute("ehOrganizador")
    public boolean isOrganizador(@AuthenticationPrincipal AuthenticatedUser principal) {
        return principal != null && principal.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ORGANIZER".equals(a.getAuthority()));
    }
}
