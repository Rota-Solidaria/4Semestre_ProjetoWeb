// AuthController.java
package com.rotasolidaria.rotasolidaria.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AuthController {

    @GetMapping("/login")
    public String loginForm() {
        return "login"; // -> templates/login.ftlh
    }

    @PostMapping("/login")
    public String processarLogin(@RequestParam String email, @RequestParam String senha) {
        return "login";
    }
}