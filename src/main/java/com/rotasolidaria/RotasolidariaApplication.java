package com.rotasolidaria;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync // envio de e-mails em segundo plano (WelcomeEmailService)
public class RotasolidariaApplication {

	public static void main(String[] args) {
		SpringApplication.run(RotasolidariaApplication.class, args);
	}

}
