package com.rotasolidaria.config;

import com.rotasolidaria.security.FriendlyAccessDeniedHandler;
import com.rotasolidaria.security.GoogleLoginSuccessHandler;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http,
                                                   ObjectProvider<ClientRegistrationRepository> googleClient,
                                                   GoogleLoginSuccessHandler googleLoginSuccessHandler,
                                                   FriendlyAccessDeniedHandler accessDeniedHandler) throws Exception {
        http
                // Rotas que exigem login; todo o resto é público
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/organizador/**").hasRole("ORGANIZER")
                        .requestMatchers("/perfil/**", "/campanhas/*/inscrever", "/inscricoes/**").authenticated()
                        .anyRequest().permitAll())
                // O Spring Security processa o POST /login do formulário em pages/login.ftlh
                .formLogin(form -> form
                        .loginPage("/login")
                        .usernameParameter("email")
                        .passwordParameter("senha")
                        .defaultSuccessUrl("/campanhas")
                        .failureUrl("/login?erro"))
                // Logout via POST /logout (com token CSRF)
                .logout(logout -> logout
                        .logoutSuccessUrl("/login?logout"))
                // Acesso negado (403): redireciona com aviso em vez da página de erro
                .exceptionHandling(ex -> ex.accessDeniedHandler(accessDeniedHandler));

        // Login com o Google (GET /oauth2/authorization/google), só se GOOGLE_CLIENT_ID estiver definido
        if (googleClient.getIfAvailable() != null) {
            http.oauth2Login(oauth -> oauth
                    .loginPage("/login")
                    .successHandler(googleLoginSuccessHandler)
                    .failureUrl("/login?erro=google"));
        }

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // Gera hashes usando o algoritmo Argon2id com os parâmetros recomendados:
        // salt: 16 bytes, hash: 32 bytes, paralelismo: 1, memória: 16MB (16384 KiB),
        // iterações: 2
        return Argon2PasswordEncoder.defaultsForSpringSecurity_v5_8();
    }
}
