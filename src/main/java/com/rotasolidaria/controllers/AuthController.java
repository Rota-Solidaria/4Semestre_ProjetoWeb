package com.rotasolidaria.controllers;

import com.rotasolidaria.models.User;
import com.rotasolidaria.services.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Optional;

@Controller
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @GetMapping("/login")
    public String loginForm(HttpSession session) {
        // Se já estiver logado, vai direto para as campanhas
        if (session.getAttribute("usuarioLogado") != null) {
            return "redirect:/campanhas";
        }
        return "pages/login"; // -> templates/pages/login.ftlh
    }

    @PostMapping("/login")
    public String processarLogin(@RequestParam String email,
                                 @RequestParam String senha,
                                 HttpSession session,
                                 Model model) {
        Optional<User> usuario = authService.authenticate(email, senha);

        if (usuario.isPresent()) {
            // Guarda o usuário na sessão do navegador
            session.setAttribute("usuarioLogado", usuario.get());
            return "redirect:/campanhas";
        }

        // Se errar a senha ou o e-mail não existir
        model.addAttribute("erro", "E-mail ou senha inválidos. Tente novamente.");
        return "pages/login";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}