package com.rotasolidaria;

import java.time.LocalDate;
import java.time.LocalTime;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.EducationalContent;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.enums.CampaignStatus;
import com.rotasolidaria.models.enums.ContentType;
import com.rotasolidaria.repositories.CampanhaRepository;
import com.rotasolidaria.repositories.ConteudoEducativoRepository;
import com.rotasolidaria.repositories.LocalizacaoRepository;
import com.rotasolidaria.repositories.UserRepository;

import com.rotasolidaria.models.Donor;
import com.rotasolidaria.models.Registration;
import com.rotasolidaria.models.enums.BloodType;
import com.rotasolidaria.models.enums.RegistrationStatus;
import com.rotasolidaria.repositories.InscricaoRepository;

@Component
public class DataInitializer implements CommandLineRunner {

    private final CampanhaRepository campanhaRepository;
    private final LocalizacaoRepository localizacaoRepository;
    private final UserRepository usuarioRepository;
    private final ConteudoEducativoRepository conteudoEducativoRepository;
    private final InscricaoRepository inscricaoRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(CampanhaRepository campanhaRepository,
            LocalizacaoRepository localizacaoRepository,
            UserRepository usuarioRepository,
            ConteudoEducativoRepository conteudoEducativoRepository,
            InscricaoRepository inscricaoRepository,
            PasswordEncoder passwordEncoder) {
        this.campanhaRepository = campanhaRepository;
        this.localizacaoRepository = localizacaoRepository;
        this.usuarioRepository = usuarioRepository;
        this.conteudoEducativoRepository = conteudoEducativoRepository;
        this.inscricaoRepository = inscricaoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) throws Exception {
        // Só popula se ainda não houver campanhas cadastradas
        if (campanhaRepository.count() == 0) {

            // 1. Criar um Organizador
            Organizer organizador = new Organizer();
            organizador.setName("Hemocentro Regional");
            organizador.setEmail("contato@hemocentro.org.br");
            organizador.setPasswordHash(passwordEncoder.encode("123456"));
            organizador.setPhone("11999998888");
            organizador.setInstitution("Fundação Pró-Sangue");
            usuarioRepository.save(organizador);

            // 2. Criar um Local de Doação
            Location hemocentro = new Location();
            hemocentro.setName("Posto Clínicas - Fundação Pró-Sangue");
            hemocentro.setStreet("Av. Dr. Enéas Carvalho de Aguiar");
            hemocentro.setNumber("155");
            hemocentro.setNeighborhood("Cerqueira César");
            hemocentro.setCity("São Paulo");
            hemocentro.setState("SP");
            hemocentro.setZipCode("05403000");
            localizacaoRepository.save(hemocentro);

            // 3. Criar uma Campanha Ativa
            Campaign c1 = new Campaign();
            c1.setTitle("Campanha Sangue Solidário 2026");
            c1.setDescription(
                    "Participe da nossa caravana de doação de sangue para abastecer os estoques de hospitais regionais.");
            c1.setEventDate(LocalDate.now().plusDays(15));
            c1.setDonationTime(LocalTime.of(9, 30));
            c1.setSlots(40);
            c1.setStatus(CampaignStatus.OPEN);
            c1.setDonationLocation(hemocentro);
            c1.setOrganizer(organizador);
            campanhaRepository.save(c1);

            // 4. Criar Conteúdos Educativos
            EducationalContent dica1 = new EducationalContent();
            dica1.setTitle("Requisitos Básicos para Doar Sangue");
            dica1.setType(ContentType.ARTICLE);
            dica1.setText("Estar em boas condições de saúde, ter entre 16 e 69 anos e pesar no mínimo 50 kg.");
            dica1.setDisplayOrder(1);
            conteudoEducativoRepository.save(dica1);

            EducationalContent mito1 = new EducationalContent();
            mito1.setTitle("Mito: Doar sangue afina ou engrossa o sangue");
            mito1.setType(ContentType.ARTICLE);
            mito1.setText("Mito! O volume doado é reposto naturalmente pelo organismo em até 24 a 48 horas.");
            mito1.setDisplayOrder(2);
            conteudoEducativoRepository.save(mito1);

            // 5. Criar Doador Padrão de Teste
            if (!usuarioRepository.existsByEmail("joao@email.com")) {
                Donor doador = new Donor();
                doador.setName("João da Silva");
                doador.setEmail("joao@email.com");
                doador.setPasswordHash(passwordEncoder.encode("123456"));
                doador.setPhone("(15) 99999-0000");
                doador.setBloodType(BloodType.O_POSITIVE);
                doador.setBirthDate(LocalDate.of(1995, 5, 15));
                doador.setWeight(72.5);
                usuarioRepository.save(doador);

                Registration inscricao = new Registration();
                inscricao.setCampaign(c1);
                inscricao.setDonor(doador);
                inscricao.setStatus(RegistrationStatus.CONFIRMED);
                inscricao.setNotes("Embarque Praça Matriz.");
                inscricaoRepository.save(inscricao);
            }

            System.out.println(">>> [DataInitializer] Dados de teste carregados com sucesso no MySQL!");
        } else if (!usuarioRepository.existsByEmail("joao@email.com")) {
            Donor doador = new Donor();
            doador.setName("João da Silva");
            doador.setEmail("joao@email.com");
            doador.setPasswordHash(passwordEncoder.encode("123456"));
            doador.setPhone("(15) 99999-0000");
            doador.setBloodType(BloodType.O_POSITIVE);
            doador.setBirthDate(LocalDate.of(1995, 5, 15));
            doador.setWeight(72.5);
            usuarioRepository.save(doador);

            var campanhas = campanhaRepository.findAll();
            if (!campanhas.isEmpty()) {
                Registration inscricao = new Registration();
                inscricao.setCampaign(campanhas.get(0));
                inscricao.setDonor(doador);
                inscricao.setStatus(RegistrationStatus.CONFIRMED);
                inscricao.setNotes("Embarque Praça Matriz.");
                inscricaoRepository.save(inscricao);
            }
        }
    }
}