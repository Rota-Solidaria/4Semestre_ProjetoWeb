// EducativoController.java
package com.rotasolidaria.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class EducativoController {

    @GetMapping("/educativo")
    public String educativo() {
        return "pages/educativo"; // -> templates/pages/educativo.ftlh
    }
}