package com.rotasolidaria.security;

import com.rotasolidaria.controllers.Toast;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.services.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.FlashMap;
import org.springframework.web.servlet.support.SessionFlashMapManager;

import java.io.IOException;

/**
 * Depois que o Google confirma a identidade, encontra (ou cria) a conta local e troca o
 * usuário do Google pelo AuthenticatedUser, que é o que os controllers esperam.
 */
@Component
public class GoogleLoginSuccessHandler implements AuthenticationSuccessHandler {

    private final AuthService authService;
    private final AutoLogin autoLogin;
    private final SessionFlashMapManager flashMapManager = new SessionFlashMapManager();

    public GoogleLoginSuccessHandler(AuthService authService, AutoLogin autoLogin) {
        this.authService = authService;
        this.autoLogin = autoLogin;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        OidcUser google = (OidcUser) authentication.getPrincipal();
        AuthService.GoogleLogin result;
        try {
            result = authService.loginWithGoogle(google.getSubject(), google.getEmail(),
                    Boolean.TRUE.equals(google.getEmailVerified()), google.getFullName());
        } catch (BusinessException e) {
            // Desfaz a sessão aberta pelo Google e volta ao login com o motivo
            new SecurityContextLogoutHandler().logout(request, response, authentication);
            flash(Toast.error("Não foi possível entrar com o Google", e.getMessage()), request, response);
            response.sendRedirect("/login");
            return;
        }

        autoLogin.login(result.user(), request, response);
        String target;
        if (result.newAccount()) {
            flash(Toast.success("Conta criada", "Complete seus dados de doador para agilizar suas inscrições.")
                    .withAction("Completar", "/perfil#editar"), request, response);
            target = autoLogin.redirectTarget(request, response, "/perfil");
        } else {
            target = autoLogin.redirectTarget(request, response, "/campanhas");
        }
        response.sendRedirect(target);
    }

    // Equivalente a redirectAttributes.addFlashAttribute fora de um controller
    private void flash(Toast toast, HttpServletRequest request, HttpServletResponse response) {
        FlashMap flashMap = new FlashMap();
        flashMap.put("toast", toast);
        flashMapManager.saveOutputFlashMap(flashMap, request, response);
    }
}
