package com.rotasolidaria.config;

import com.rotasolidaria.models.User;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.security.AuthenticatedUser;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalControllerAdvice {

    private final UserRepository userRepository;
    private final boolean googleLoginEnabled;

    @Value("${app.base-url:}")
    private String configuredBaseUrl;

    public GlobalControllerAdvice(UserRepository userRepository, ObjectProvider<ClientRegistrationRepository> googleClient) {
        this.userRepository = userRepository;
        this.googleLoginEnabled = googleClient.getIfAvailable() != null;
    }

    // URL base da aplicação para tags Open Graph (WhatsApp, redes sociais) e links absolutos
    @ModelAttribute("appBaseUrl")
    public String getAppBaseUrl(HttpServletRequest request) {
        if (configuredBaseUrl != null && !configuredBaseUrl.isBlank() && !configuredBaseUrl.contains("localhost")) {
            return configuredBaseUrl.replaceAll("/$", "");
        }
        if (request != null) {
            String scheme = request.getScheme();
            String host = request.getServerName();
            int port = request.getServerPort();
            boolean isDefaultPort = ("http".equalsIgnoreCase(scheme) && port == 80) ||
                                    ("https".equalsIgnoreCase(scheme) && port == 443);
            return isDefaultPort ? scheme + "://" + host : scheme + "://" + host + ":" + port;
        }
        return configuredBaseUrl != null ? configuredBaseUrl.replaceAll("/$", "") : "";
    }

    // URL da requisição atual para og:url e canonical
    @ModelAttribute("currentUrl")
    public String getCurrentUrl(HttpServletRequest request) {
        if (request == null) {
            return "";
        }
        StringBuffer url = request.getRequestURL();
        return url != null ? url.toString() : "";
    }

    // Mostra o botão "Entrar com Google" só quando o login social está configurado (ver GoogleOAuthConfig)
    @ModelAttribute("googleLoginEnabled")
    public boolean isGoogleLoginEnabled() {
        return googleLoginEnabled;
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
