package com.rotasolidaria.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class SecurityConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        // Gera hashes usando o algoritmo Argon2id com os parâmetros recomendados:
        // salt: 16 bytes, hash: 32 bytes, paralelismo: 1, memória: 16MB (16384 KiB),
        // iterações: 2
        return Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();
    }
}