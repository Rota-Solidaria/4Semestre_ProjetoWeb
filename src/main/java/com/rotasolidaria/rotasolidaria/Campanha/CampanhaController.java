// CampanhaController.java
package com.rotasolidaria.rotasolidaria.Campanha;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class CampanhaController {

    @GetMapping("/campanhas")
    public String listar(Model model) {
        return "campanhas"; // -> templates/campanhas.ftlh
    }

    @GetMapping("/campanhas/{id}")
    public String detalhes(@PathVariable Long id, Model model) {
        return "detalhes-campanha"; // -> templates/detalhes-campanha.ftlh
    }
}