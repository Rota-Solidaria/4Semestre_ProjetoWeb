package com.rotasolidaria.config;

import com.rotasolidaria.models.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalControllerAdvice {

    @ModelAttribute("usuarioLogado")
    public User getUsuarioLogado(HttpSession session) {
        return (User) session.getAttribute("usuarioLogado");
    }
}
