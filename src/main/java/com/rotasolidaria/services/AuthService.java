package com.rotasolidaria.services;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.UserRepository;
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

    public AuthService(UserRepository userRepository, DonorRepository donorRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.donorRepository = donorRepository;
        this.passwordEncoder = passwordEncoder;
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
