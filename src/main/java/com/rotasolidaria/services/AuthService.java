package com.rotasolidaria.services;

import com.rotasolidaria.events.UserRegisteredEvent;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.UserRepository;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Regras de cadastro e de senha. O login em si é feito pelo Spring Security
 * (ver SecurityConfig e DatabaseUserDetailsService).
 */
@Service
public class AuthService {

    public static final int MIN_PASSWORD_LENGTH = 8;

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    private final DonorRepository donorRepository;
    private final ApplicationEventPublisher events;

    public AuthService(UserRepository userRepository, DonorRepository donorRepository, PasswordEncoder passwordEncoder,
                       ApplicationEventPublisher events) {
        this.userRepository = userRepository;
        this.donorRepository = donorRepository;
        this.passwordEncoder = passwordEncoder;
        this.events = events;
    }

    @Transactional
    /** Cria a conta já com o perfil de doador (o de organizador é dado à parte). */
    public User register(String name, String email, String phone, String password, String passwordConfirmation) {
        String normalizedName = name == null ? "" : name.trim();
        String normalizedEmail = normalizeEmail(email);
        String normalizedPhone = phone == null || phone.isBlank() ? null : phone.trim();

        if (normalizedName.isEmpty() || normalizedName.length() > 120) {
            throw new BusinessException("Informe seu nome completo (até 120 caracteres).");
        }
        if (!normalizedEmail.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$") || normalizedEmail.length() > 160) {
            throw new BusinessException("Informe um e-mail válido.");
        }
        if (normalizedPhone != null && normalizedPhone.length() > 20) {
            throw new BusinessException("O telefone deve ter no máximo 20 caracteres.");
        }
        validatePassword(password, passwordConfirmation);
        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new BusinessException("Este e-mail já está cadastrado. Faça login ou redefina sua senha.");
        }

        User user = new User();
        user.setName(normalizedName);
        user.setEmail(normalizedEmail);
        user.setPhone(normalizedPhone);
        user.setPasswordHash(passwordEncoder.encode(password));
        user = userRepository.save(user);
        donorRepository.save(new Donor(user));
        events.publishEvent(new UserRegisteredEvent(user.getId()));
        return user;
    }

    /** Resultado do login pelo Google: a conta e se ela acabou de ser criada. */
    public record GoogleLogin(User user, boolean newAccount) {
    }

    /**
     * Entra com a conta Google (identificada pelo "sub"). Se ainda não houver vínculo,
     * vincula a conta que tem o mesmo e-mail (verificado pelo Google) ou cria uma nova,
     * sem senha e já com o perfil de doador.
     */
    @Transactional
    public GoogleLogin loginWithGoogle(String googleId, String email, boolean emailVerified, String name) {
        if (googleId == null || googleId.isBlank()) {
            throw new BusinessException("O Google não informou a identificação da conta.");
        }

        User linked = userRepository.findByGoogleId(googleId).orElse(null);
        if (linked != null) {
            return new GoogleLogin(requireActive(linked), false);
        }

        String normalizedEmail = normalizeEmail(email);
        if (!emailVerified || normalizedEmail.isEmpty()) {
            throw new BusinessException("Seu e-mail do Google ainda não foi verificado.");
        }

        User existing = userRepository.findByEmail(normalizedEmail).orElse(null);
        if (existing != null) {
            requireActive(existing);
            existing.setGoogleId(googleId);
            return new GoogleLogin(userRepository.save(existing), false);
        }
        if (normalizedEmail.length() > 160) {
            throw new BusinessException("Informe um e-mail válido.");
        }

        String normalizedName = name == null || name.isBlank() ? normalizedEmail.split("@")[0] : name.trim();
        User user = new User();
        user.setName(normalizedName.length() > 120 ? normalizedName.substring(0, 120) : normalizedName);
        user.setEmail(normalizedEmail);
        user.setGoogleId(googleId);
        user = userRepository.save(user);
        donorRepository.save(new Donor(user));
        events.publishEvent(new UserRegisteredEvent(user.getId()));
        return new GoogleLogin(user, true);
    }

    private static User requireActive(User user) {
        if (!Boolean.TRUE.equals(user.getActive())) {
            throw new BusinessException("Esta conta está desativada.");
        }
        return user;
    }

    public void validatePassword(String password, String passwordConfirmation) {
        validatePasswordLength(password);
        if (!password.equals(passwordConfirmation)) {
            throw new BusinessException("As senhas não conferem.");
        }
    }

    public void validatePasswordLength(String password) {
        if (password == null || password.length() < MIN_PASSWORD_LENGTH) {
            throw new BusinessException("A senha deve ter pelo menos " + MIN_PASSWORD_LENGTH + " caracteres.");
        }
    }

    public static String normalizeEmail(String email) {
        return email == null ? "" : email.trim().toLowerCase();
    }
}
