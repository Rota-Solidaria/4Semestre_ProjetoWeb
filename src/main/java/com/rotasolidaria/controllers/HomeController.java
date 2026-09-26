// HomeController.java
package com.rotasolidaria.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String index() {
        return "pages/index"; // -> templates/pages/index.ftlh
    }
}