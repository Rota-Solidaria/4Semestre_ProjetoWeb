package com.rotasolidaria.controllers;

import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.User;
import com.rotasolidaria.models.enums.BloodType;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.OrganizerRepository;
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
import com.rotasolidaria.util.Datas;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Controller
public class ProfileController {


    private final UserRepository userRepository;
    private final DonorRepository donorRepository;
    private final OrganizerRepository organizerRepository;
    private final InscricaoRepository inscricaoRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;

    public ProfileController(UserRepository userRepository,
                             DonorRepository donorRepository,
                             OrganizerRepository organizerRepository,
                             InscricaoRepository inscricaoRepository,
                             PasswordEncoder passwordEncoder,
                             AuthService authService) {
        this.userRepository = userRepository;
        this.donorRepository = donorRepository;
        this.organizerRepository = organizerRepository;
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

        if (isDonor) {
            addDonorCard(inscricoes, model);
        }

        Optional<Organizer> organizerOpt = organizerRepository.findById(user.getId());
        Organizer organizer = organizerOpt.orElse(null);

        model.addAttribute("usuario", user);
        // Contas criadas pelo Google começam sem senha: o perfil oferece "Definir senha"
        model.addAttribute("temSenha", user.hasPassword());
        model.addAttribute("isDonor", isDonor);
        model.addAttribute("donor", donor);
        model.addAttribute("organizer", organizer);
        model.addAttribute("inscricoes", inscricoes);
        model.addAttribute("bloodTypes", BloodType.values());

        return "pages/perfil";
    }

    /**
     * Dados da carteirinha do doador: doações feitas (inscrições confirmadas em campanhas
     * que já aconteceram) e quando poderá doar de novo. O intervalo mínimo entre doações é
     * de 60 dias para homens e 90 para mulheres; como o cadastro não tem sexo, mostramos os dois.
     */
    private void addDonorCard(List<Registration> inscricoes, Model model) {
        LocalDate hoje = LocalDate.now();
        List<LocalDate> doacoes = inscricoes.stream()
                .filter(r -> r.getStatus() == RegistrationStatus.CONFIRMED)
                .map(r -> r.getCampaign().getEventDate())
                .filter(d -> d != null && d.isBefore(hoje))
                .sorted()
                .toList();

        model.addAttribute("totalDoacoes", doacoes.size());
        if (!doacoes.isEmpty()) {
            LocalDate ultima = doacoes.get(doacoes.size() - 1);
            LocalDate proximaHomens = ultima.plusDays(60);
            LocalDate proximaMulheres = ultima.plusDays(90);
            long diasDesde = ChronoUnit.DAYS.between(ultima, hoje);
            model.addAttribute("ultimaDoacaoBr", ultima.format(Datas.DATA_BR));
            model.addAttribute("proximaHomensBr", proximaHomens.format(Datas.DATA_BR));
            model.addAttribute("proximaMulheresBr", proximaMulheres.format(Datas.DATA_BR));
            model.addAttribute("diasRestantes", Math.max(0, ChronoUnit.DAYS.between(hoje, proximaHomens)));
            model.addAttribute("progressoIntervalo", Math.min(100, diasDesde * 100 / 60));
        }

        inscricoes.stream()
                .filter(r -> r.getStatus() == RegistrationStatus.CONFIRMED)
                .filter(r -> r.getCampaign().getEventDate() != null && !r.getCampaign().getEventDate().isBefore(hoje))
                .min(Comparator.comparing(r -> r.getCampaign().getEventDate()))
                .ifPresent(r -> {
                    model.addAttribute("proximaInscricao", r);
                    model.addAttribute("proximaInscricaoDataBr", r.getCampaign().getEventDate().format(Datas.DATA_BR));
                });
    }

    @PostMapping("/perfil/editar")
    public String editarPerfil(@RequestParam String name,
                               @RequestParam(required = false) String phone,
                               @RequestParam(required = false) String institution,
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

        userRepository.save(user);

        // Se for organizador, atualiza os dados específicos da instituição
        Optional<Organizer> organizerOpt = organizerRepository.findById(user.getId());
        if (organizerOpt.isPresent() && institution != null) {
            Organizer organizer = organizerOpt.get();
            organizer.setInstitution(institution.trim());
            organizerRepository.save(organizer);
        }

        // Se a conta tiver perfil de doador, atualiza os campos específicos
        Optional<Donor> donorOpt = donorRepository.findById(user.getId());
        if (donorOpt.isPresent()) {
            Donor donor = donorOpt.get();
            if (bloodType != null && !bloodType.isBlank()) {
                try {
                    donor.setBloodType(BloodType.valueOf(bloodType));
                } catch (IllegalArgumentException ignored) {
                }
            } else {
                donor.setBloodType(null);
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
        }

        // Alteração de senha, se solicitada
        if (novaSenha != null && !novaSenha.isBlank()) {
            // Os demais dados já foram salvos acima; só a troca de senha é recusada
            // Quem entrou pelo Google e ainda não tem senha pode defini-la sem informar a atual
            if (user.hasPassword() && (senhaAtual == null || !passwordEncoder.matches(senhaAtual, user.getPasswordHash()))) {
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
