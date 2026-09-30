package com.rotasolidaria.controllers;

import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.models.User;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.security.AutoLogin;
import com.rotasolidaria.services.AuthService;
import com.rotasolidaria.services.PasswordResetService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Telas de login, cadastro e redefinição de senha.
 * O POST /login e o POST /logout são processados pelo Spring Security (ver SecurityConfig).
 */
@Controller
public class AuthController {

    private final AuthService authService;
    private final PasswordResetService passwordResetService;
    private final AutoLogin autoLogin;

    public AuthController(AuthService authService, PasswordResetService passwordResetService, AutoLogin autoLogin) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
        this.autoLogin = autoLogin;
    }

    @GetMapping("/login")
    public String loginForm(@AuthenticationPrincipal AuthenticatedUser principal,
                            @RequestParam(required = false) String erro,
                            @RequestParam(required = false) String logout,
                            Model model) {
        // Se já estiver logado, vai direto para as campanhas
        if (principal != null) {
            return "redirect:/campanhas";
        }
        if (erro != null) {
            model.addAttribute("toast", Toast.error("E-mail ou senha inválidos", "Confira os dados ou redefina sua senha.")
                    .withAction("Redefinir senha", "/esqueci-senha"));
        }
        if (logout != null) {
            model.addAttribute("toast", Toast.info("Você saiu da sua conta", "Volte sempre que quiser doar.").withIcon("logout"));
        }
        return "pages/login"; // -> templates/pages/login.ftlh
    }

    @GetMapping("/cadastro")
    public String cadastroForm(@AuthenticationPrincipal AuthenticatedUser principal, Model model) {
        if (principal != null) {
            return "redirect:/campanhas";
        }
        model.addAttribute("minSenha", AuthService.MIN_PASSWORD_LENGTH);
        return "pages/cadastro"; // -> templates/pages/cadastro.ftlh
    }

    @PostMapping("/cadastro")
    public String processarCadastro(@RequestParam String name,
                                    @RequestParam String email,
                                    @RequestParam(required = false) String phone,
                                    @RequestParam String senha,
                                    @RequestParam String confirmarSenha,
                                    HttpServletRequest request,
                                    HttpServletResponse response,
                                    RedirectAttributes redirectAttributes,
                                    Model model) {
        try {
            User usuario = authService.register(name, email, phone, senha, confirmarSenha);
            // Já entra logado e volta para onde estava (ex.: inscrição) ou vai completar o perfil
            autoLogin.login(usuario, request, response);
            redirectAttributes.addFlashAttribute("toast",
                    Toast.success("Conta criada", "Complete seus dados de doador para agilizar suas inscrições.")
                            .withAction("Completar", "/perfil#editar"));
            return "redirect:" + autoLogin.redirectTarget(request, response, "/perfil");
        } catch (BusinessException e) {
            // Devolve o formulário preenchido (menos as senhas) com a mensagem de erro
            model.addAttribute("toast", Toast.error("Não foi possível criar a conta", e.getMessage()));
            model.addAttribute("name", name);
            model.addAttribute("email", email);
            model.addAttribute("phone", phone);
            model.addAttribute("minSenha", AuthService.MIN_PASSWORD_LENGTH);
            return "pages/cadastro";
        }
    }

    @GetMapping("/esqueci-senha")
    public String esqueciSenhaForm() {
        return "pages/esqueci-senha"; // -> templates/pages/esqueci-senha.ftlh
    }

    @PostMapping("/esqueci-senha")
    public String processarEsqueciSenha(@RequestParam String email, Model model) {
        passwordResetService.requestReset(email);
        // Mesma mensagem exista ou não o e-mail, para não revelar quem tem conta
        model.addAttribute("enviado", true);
        model.addAttribute("toast", Toast.info("Link enviado", "Se o e-mail estiver cadastrado, o link chega em instantes.").withIcon("mail"));
        return "pages/esqueci-senha";
    }

    @GetMapping("/redefinir-senha")
    public String redefinirSenhaForm(@RequestParam(required = false) String token, Model model) {
        model.addAttribute("tokenValido", passwordResetService.isTokenValid(token));
        model.addAttribute("token", token);
        model.addAttribute("minSenha", AuthService.MIN_PASSWORD_LENGTH);
        return "pages/redefinir-senha"; // -> templates/pages/redefinir-senha.ftlh
    }

    @PostMapping("/redefinir-senha")
    public String processarRedefinirSenha(@RequestParam String token,
                                          @RequestParam String senha,
                                          @RequestParam String confirmarSenha,
                                          HttpServletRequest request,
                                          HttpServletResponse response,
                                          RedirectAttributes redirectAttributes,
                                          Model model) {
        try {
            User user = passwordResetService.resetPassword(token, senha, confirmarSenha);
            // Quem abriu o link do e-mail já comprovou ser o dono da conta: entra logado
            if (!Boolean.TRUE.equals(user.getActive())) {
                return "redirect:/login";
            }
            autoLogin.login(user, request, response);
            redirectAttributes.addFlashAttribute("toast", Toast.success("Senha redefinida", "Você já está conectado."));
            return "redirect:/perfil";
        } catch (BusinessException e) {
            model.addAttribute("toast", Toast.error("Não foi possível redefinir a senha", e.getMessage()));
            model.addAttribute("tokenValido", passwordResetService.isTokenValid(token));
            model.addAttribute("token", token);
            model.addAttribute("minSenha", AuthService.MIN_PASSWORD_LENGTH);
            return "pages/redefinir-senha";
        }
    }
}
