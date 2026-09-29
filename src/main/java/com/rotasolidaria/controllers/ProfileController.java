package com.rotasolidaria.controllers;

import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.models.enums.BloodType;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.UserRepository;
import com.rotasolidaria.exception.BusinessException;
import com.rotasolidaria.security.AuthenticatedUser;
import com.rotasolidaria.services.AuthService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Controller
public class ProfileController {

    private final UserRepository userRepository;
    private final DonorRepository donorRepository;
    private final InscricaoRepository inscricaoRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;

    public ProfileController(UserRepository userRepository,
                             DonorRepository donorRepository,
                             InscricaoRepository inscricaoRepository,
                             PasswordEncoder passwordEncoder,
                             AuthService authService) {
        this.userRepository = userRepository;
        this.donorRepository = donorRepository;
        this.inscricaoRepository = inscricaoRepository;
        this.passwordEncoder = passwordEncoder;
        this.authService = authService;
    }

    @GetMapping("/perfil")
    public String perfil(@AuthenticationPrincipal AuthenticatedUser principal,
                         HttpSession session,
                         Model model) {
        // A rota exige login (ver SecurityConfig); buscamos os dados mais recentes do banco
        Optional<User> userOpt = userRepository.findById(principal.getId());
        if (userOpt.isEmpty()) {
            session.invalidate();
            return "redirect:/login";
        }

        User user = userOpt.get();

        boolean isDonor = false;
        Donor donor = null;
        List<Registration> inscricoes = Collections.emptyList();

        Optional<Donor> donorOpt = donorRepository.findById(user.getId());
        if (donorOpt.isPresent()) {
            isDonor = true;
            donor = donorOpt.get();
            inscricoes = inscricaoRepository.findByDonor(donor);
        }

        model.addAttribute("usuario", user);
        model.addAttribute("isDonor", isDonor);
        model.addAttribute("donor", donor);
        model.addAttribute("inscricoes", inscricoes);
        model.addAttribute("bloodTypes", BloodType.values());

        return "pages/perfil";
    }

    @PostMapping("/perfil/editar")
    public String editarPerfil(@RequestParam String name,
                               @RequestParam(required = false) String phone,
                               @RequestParam(required = false) String bloodType,
                               @RequestParam(required = false) Double weight,
                               @RequestParam(required = false) String birthDate,
                               @RequestParam(required = false) String senhaAtual,
                               @RequestParam(required = false) String novaSenha,
                               @AuthenticationPrincipal AuthenticatedUser principal,
                               HttpSession session,
                               RedirectAttributes redirectAttributes) {
        Optional<User> userOpt = userRepository.findById(principal.getId());
        if (userOpt.isEmpty()) {
            session.invalidate();
            return "redirect:/login";
        }

        User user = userOpt.get();
        user.setName(name);
        user.setPhone(phone);

        // Se o usuário for Doador, atualiza os campos específicos
        Optional<Donor> donorOpt = donorRepository.findById(user.getId());
        if (donorOpt.isPresent()) {
            Donor donor = donorOpt.get();
            donor.setName(name);
            donor.setPhone(phone);
            if (bloodType != null && !bloodType.isBlank()) {
                try {
                    donor.setBloodType(BloodType.valueOf(bloodType));
                } catch (IllegalArgumentException ignored) {
                }
            }
            if (weight != null) {
                donor.setWeight(weight);
            }
            if (birthDate != null && !birthDate.isBlank()) {
                try {
                    donor.setBirthDate(LocalDate.parse(birthDate));
                } catch (Exception ignored) {
                }
            }
            donorRepository.save(donor);
            user = donor;
        } else {
            userRepository.save(user);
        }

        // Alteração de senha, se solicitada
        if (novaSenha != null && !novaSenha.isBlank()) {
            // Os demais dados já foram salvos acima; só a troca de senha é recusada
            if (senhaAtual == null || !passwordEncoder.matches(senhaAtual, user.getPasswordHash())) {
                redirectAttributes.addFlashAttribute("toast",
                        Toast.error("Senha não alterada", "Seus dados foram salvos, mas a senha atual está incorreta."));
                return "redirect:/perfil";
            }
            try {
                authService.validatePasswordLength(novaSenha);
            } catch (BusinessException e) {
                redirectAttributes.addFlashAttribute("toast",
                        Toast.error("Senha não alterada", "Seus dados foram salvos. " + e.getMessage()));
                return "redirect:/perfil";
            }
            user.setPasswordHash(passwordEncoder.encode(novaSenha));
            userRepository.save(user);
        }

        redirectAttributes.addFlashAttribute("toast", Toast.success("Perfil atualizado", "Suas alterações foram salvas."));
        return "redirect:/perfil";
    }
}
