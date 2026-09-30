package com.rotasolidaria.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Ajustes de esquema que o ddl-auto=update não faz sozinho em tabelas já existentes.
 * Os comandos são idempotentes: podem rodar a cada inicialização.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class SchemaUpdates implements ApplicationRunner {

    private final JdbcTemplate jdbc;

    public SchemaUpdates(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public void run(ApplicationArguments args) {
        // Contas criadas pelo Google não têm senha (User.passwordHash passou a aceitar nulo)
        jdbc.execute("ALTER TABLE users MODIFY password_hash VARCHAR(255) NULL");
    }
}
