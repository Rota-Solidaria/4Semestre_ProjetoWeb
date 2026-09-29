package com.rotasolidaria.security;

import com.rotasolidaria.models.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.context.SecurityContextHolderStrategy;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;
import org.springframework.stereotype.Component;

/**
 * Autentica o usuário sem passar pelo formulário de login — usado logo após o
 * cadastro e após a redefinição de senha, quando a identidade já foi comprovada.
 */
@Component
public class AutoLogin {

    private final SecurityContextHolderStrategy contextHolder = SecurityContextHolder.getContextHolderStrategy();
    private final SecurityContextRepository contextRepository = new HttpSessionSecurityContextRepository();
    private final RequestCache requestCache = new HttpSessionRequestCache();

    public void login(User user, HttpServletRequest request, HttpServletResponse response) {
        AuthenticatedUser principal = new AuthenticatedUser(user);
        principal.eraseCredentials();

        // Troca o ID da sessão para evitar "session fixation", como o login normal do Spring faz
        if (request.getSession(false) != null) {
            request.changeSessionId();
        }

        SecurityContext context = contextHolder.createEmptyContext();
        context.setAuthentication(UsernamePasswordAuthenticationToken.authenticated(
                principal, null, principal.getAuthorities()));
        contextHolder.setContext(context);
        contextRepository.saveContext(context, request, response);
    }

    /**
     * Página que o usuário tentava acessar antes de ser mandado para o login
     * (ex.: inscrição em uma campanha), ou o destino padrão informado.
     */
    public String redirectTarget(HttpServletRequest request, HttpServletResponse response, String defaultUrl) {
        SavedRequest saved = requestCache.getRequest(request, response);
        if (saved == null) {
            return defaultUrl;
        }
        requestCache.removeRequest(request, response);
        return saved.getRedirectUrl();
    }
}
