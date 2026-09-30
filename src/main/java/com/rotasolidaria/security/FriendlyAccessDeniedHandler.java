package com.rotasolidaria.security;

import com.rotasolidaria.controllers.Toast;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.csrf.CsrfException;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.FlashMap;
import org.springframework.web.servlet.support.SessionFlashMapManager;

import java.io.IOException;

/**
 * Troca a página crua de erro 403 por um redirecionamento com aviso. Casos comuns:
 * voltar do login para uma página de organizador sem ser organizador, ou enviar um
 * formulário depois que a sessão expirou (token CSRF inválido).
 */
@Component
public class FriendlyAccessDeniedHandler implements AccessDeniedHandler {

    private final SessionFlashMapManager flashMapManager = new SessionFlashMapManager();

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException accessDeniedException) throws IOException {
        Toast toast;
        String target;
        if (accessDeniedException instanceof CsrfException) {
            toast = Toast.warning("Sua sessão expirou", "Recarregamos a página. Tente novamente.");
            target = "/login";
        } else {
            toast = Toast.warning("Acesso restrito", "Esta área é exclusiva para organizadores de campanhas.");
            target = "/campanhas";
        }

        FlashMap flashMap = new FlashMap();
        flashMap.put("toast", toast);
        flashMapManager.saveOutputFlashMap(flashMap, request, response);
        response.sendRedirect(target);
    }
}
