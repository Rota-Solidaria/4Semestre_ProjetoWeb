// InscricaoController.java
package com.rotasolidaria.rotasolidaria.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class InscricaoController {

    @GetMapping("/campanhas/{id}/inscrever")
    public String formInscricao(@PathVariable Long id) {
        return "inscrever-campanha"; // -> templates/inscrever-campanha.ftlh
    }

    @PostMapping("/campanhas/{id}/inscrever")
    public String processarInscricao(@PathVariable Long id, @RequestParam(required = false) String observacoes) {
        return "redirect:/sucesso";
    }

    @GetMapping("/sucesso")
    public String sucesso() {
        return "sucesso"; // -> templates/sucesso.ftlh
    }
}