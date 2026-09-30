package com.rotasolidaria.services;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.PasswordResetToken;
import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.PasswordResetTokenRepository;
import com.rotasolidaria.repositories.UserRepository;
import org.hibernate.Hibernate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.UriComponentsBuilder;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Map;
import java.util.Optional;

/**
 * Fluxo de "esqueci minha senha": gera um token de uso único, envia o link por
 * e-mail e troca a senha quando o usuário abre o link.
 */
@Service
public class PasswordResetService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;
    private final EmailService emailService;
    private final String baseUrl;
    private final long tokenValidityMinutes;

    public PasswordResetService(UserRepository userRepository,
                                PasswordResetTokenRepository tokenRepository,
                                PasswordEncoder passwordEncoder,
                                AuthService authService,
                                EmailService emailService,
                                @Value("${app.base-url}") String baseUrl,
                                @Value("${app.password-reset.validity-minutes:30}") long tokenValidityMinutes) {
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.authService = authService;
        this.emailService = emailService;
        this.baseUrl = baseUrl;
        this.tokenValidityMinutes = tokenValidityMinutes;
    }

    /**
     * Envia o link de redefinição se o e-mail existir. Não informa ao chamador se o
     * e-mail está cadastrado, para não permitir descobrir quais e-mails têm conta.
     */
    @Transactional
    public void requestReset(String email) {
        Optional<User> userOpt = userRepository.findByEmail(AuthService.normalizeEmail(email));
        if (userOpt.isEmpty() || !Boolean.TRUE.equals(userOpt.get().getActive())) {
            return;
        }
        User user = userOpt.get();

        // Um pedido novo invalida os links enviados anteriormente
        LocalDateTime now = LocalDateTime.now();
        tokenRepository.findByUserAndUsedAtIsNull(user).forEach(t -> t.setUsedAt(now));

        byte[] randomBytes = new byte[32];
        RANDOM.nextBytes(randomBytes);
        String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);

        PasswordResetToken token = new PasswordResetToken();
        token.setUser(user);
        token.setTokenHash(hash(rawToken));
        token.setExpiresAt(now.plusMinutes(tokenValidityMinutes));
        tokenRepository.save(token);

        sendResetEmail(user, rawToken);
    }

    public boolean isTokenValid(String rawToken) {
        return findValidToken(rawToken).isPresent();
    }

    /**
     * Troca a senha e devolve o usuário, para que ele já seja autenticado em seguida.
     */
    @Transactional
    public User resetPassword(String rawToken, String newPassword, String passwordConfirmation) {
        PasswordResetToken token = findValidToken(rawToken)
                .orElseThrow(() -> new BusinessException("Este link de redefinição é inválido ou expirou. Solicite um novo."));
        authService.validatePassword(newPassword, passwordConfirmation);

        // unproxy: token.getUser() é um proxy LAZY; o AutoLogin usa o usuário fora desta transação
        User user = Hibernate.unproxy(token.getUser(), User.class);
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        token.setUsedAt(LocalDateTime.now());
        return user;
    }

    private Optional<PasswordResetToken> findValidToken(String rawToken) {
        if (rawToken == null || rawToken.isBlank()) {
            return Optional.empty();
        }
        return tokenRepository.findByTokenHash(hash(rawToken)).filter(PasswordResetToken::isValid);
    }

    private void sendResetEmail(User user, String rawToken) {
        String link = UriComponentsBuilder.fromUriString(baseUrl)
                .path("/redefinir-senha")
                .queryParam("token", rawToken)
                .toUriString();
        String firstName = user.getName().trim().split("\\s+")[0];

        String plainText = """
                Olá, %s!

                Recebemos um pedido para redefinir a senha da sua conta no Rota Solidária.
                Para criar uma nova senha, acesse o link abaixo (válido por %d minutos):

                %s

                Se você não fez este pedido, ignore este e-mail. Sua senha continua a mesma.
                """.formatted(firstName, tokenValidityMinutes, link);

        emailService.sendHtml(
                user.getEmail(),
                "Redefinição de senha - Rota Solidária",
                "emails/redefinir-senha.ftlh",
                Map.of("primeiroNome", firstName, "link", link, "validadeMinutos", tokenValidityMinutes),
                plainText);
    }

    private static String hash(String rawToken) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 indisponível", e);
        }
    }
}
