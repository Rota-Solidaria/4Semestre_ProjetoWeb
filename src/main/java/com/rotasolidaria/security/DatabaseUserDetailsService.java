package com.rotasolidaria.security;

import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.OrganizerRepository;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.services.AuthService;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Ensina o Spring Security a encontrar o usuário pelo e-mail digitado no login.
 * A comparação da senha (Argon2) é feita pelo próprio Spring Security.
 */
@Service
public class DatabaseUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final DonorRepository donorRepository;
    private final OrganizerRepository organizerRepository;

    public DatabaseUserDetailsService(UserRepository userRepository,
                                      DonorRepository donorRepository,
                                      OrganizerRepository organizerRepository) {
        this.userRepository = userRepository;
        this.donorRepository = donorRepository;
        this.organizerRepository = organizerRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return userRepository.findByEmail(AuthService.normalizeEmail(email))
                .map(this::principal)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado"));
    }

    /** Usuário da sessão com os papéis dos perfis que a conta tem (doador, organizador ou os dois). */
    public AuthenticatedUser principal(User user) {
        return new AuthenticatedUser(user,
                donorRepository.existsById(user.getId()),
                organizerRepository.existsById(user.getId()));
    }
}
