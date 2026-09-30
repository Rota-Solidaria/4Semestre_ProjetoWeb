package com.rotasolidaria;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableAsync // envio de e-mails em segundo plano (WelcomeEmailService)
@EnableScheduling // lembrete de campanha 24h antes (LembreteCampanhaService)
public class RotasolidariaApplication {

	public static void main(String[] args) {
		SpringApplication.run(RotasolidariaApplication.class, args);
	}

}
