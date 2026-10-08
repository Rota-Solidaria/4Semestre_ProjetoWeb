package com.rotasolidaria;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.rotasolidaria.models.Campaign;
import com.rotasolidaria.models.EducationalContent;
import com.rotasolidaria.models.Location;
import com.rotasolidaria.models.Organizer;
import com.rotasolidaria.models.RouteStop;
import com.rotasolidaria.models.User;
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
import com.rotasolidaria.models.enums.TransportMode;
import com.rotasolidaria.repositories.DonorRepository;
import com.rotasolidaria.repositories.InscricaoRepository;
import com.rotasolidaria.repositories.OrganizerRepository;

@Component
public class DataInitializer implements CommandLineRunner {

    private final CampanhaRepository campanhaRepository;
    private final LocalizacaoRepository localizacaoRepository;
    private final UserRepository usuarioRepository;
    private final ConteudoEducativoRepository conteudoEducativoRepository;
    private final InscricaoRepository inscricaoRepository;
    private final PasswordEncoder passwordEncoder;
    private final DonorRepository donorRepository;
    private final OrganizerRepository organizerRepository;
    private final TransactionTemplate transactionTemplate;

    public DataInitializer(CampanhaRepository campanhaRepository,
            LocalizacaoRepository localizacaoRepository,
            UserRepository usuarioRepository,
            ConteudoEducativoRepository conteudoEducativoRepository,
            InscricaoRepository inscricaoRepository,
            PasswordEncoder passwordEncoder,
            DonorRepository donorRepository,
            OrganizerRepository organizerRepository,
            PlatformTransactionManager transactionManager) {
        this.campanhaRepository = campanhaRepository;
        this.localizacaoRepository = localizacaoRepository;
        this.usuarioRepository = usuarioRepository;
        this.conteudoEducativoRepository = conteudoEducativoRepository;
        this.inscricaoRepository = inscricaoRepository;
        this.passwordEncoder = passwordEncoder;
        this.donorRepository = donorRepository;
        this.organizerRepository = organizerRepository;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    @Override
    public void run(String... args) throws Exception {
        // Só popula se ainda não houver campanhas cadastradas
        if (campanhaRepository.count() == 0) {

            // 1. Criar um Organizador
            User contaOrganizador = criarConta("Hemocentro Regional", "contato@hemocentro.org.br", "11999998888");
            Organizer organizador = new Organizer(contaOrganizador);
            organizador.setInstitution("Fundação Pró-Sangue");
            organizerRepository.save(organizador);

            // 2. Criar um Local de Doação
            Location hemocentro = new Location();
            hemocentro.setName("Posto Clínicas - Fundação Pró-Sangue");
            hemocentro.setStreet("Av. Dr. Enéas Carvalho de Aguiar");
            hemocentro.setNumber("155");
            hemocentro.setNeighborhood("Cerqueira César");
            hemocentro.setCity("São Paulo");
            hemocentro.setState("SP");
            hemocentro.setZipCode("05403000");
            hemocentro.setLatitude(new BigDecimal("-23.5573000"));
            hemocentro.setLongitude(new BigDecimal("-46.6697000"));
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
            c1.setDepartureLocation(criarPontoDeEmbarque());
            c1.setDepartureTime(LocalTime.of(6, 30));
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
                Donor doador = criarDoadorJoao();

                Registration inscricao = new Registration();
                inscricao.setCampaign(c1);
                inscricao.setDonor(doador);
                inscricao.setStatus(RegistrationStatus.CONFIRMED);
                inscricao.setBoardingPoint("Praça Matriz, Angatuba");
                inscricaoRepository.save(inscricao);
            }

            System.out.println(">>> [DataInitializer] Dados de teste carregados com sucesso no MySQL!");
        } else if (!usuarioRepository.existsByEmail("joao@email.com")) {
            Donor doador = criarDoadorJoao();

            var campanhas = campanhaRepository.findAll();
            if (!campanhas.isEmpty()) {
                Registration inscricao = new Registration();
                inscricao.setCampaign(campanhas.get(0));
                inscricao.setDonor(doador);
                inscricao.setStatus(RegistrationStatus.CONFIRMED);
                inscricao.setBoardingPoint("Praça Matriz, Angatuba");
                inscricaoRepository.save(inscricao);
            }
        }

        completarEmbarqueDaCampanhaDemo();
        transactionTemplate.executeWithoutResult(status -> completarRotaDaCampanhaDemo());
        transactionTemplate.executeWithoutResult(status -> removerCampanhasSemTransporte());
        transactionTemplate.executeWithoutResult(status -> garantirSegundaCampanhaComRota());
    }

    // Garante que exista uma segunda campanha de demonstração com rota completa de transporte
    private void garantirSegundaCampanhaComRota() {
        if (campanhaRepository.findAll().stream().anyMatch(c -> "Caravana Regional para Sorocaba".equals(c.getTitle()))) {
            return;
        }
        Organizer organizador = campanhaRepository.findAll().stream()
                .map(Campaign::getOrganizer).findFirst().orElse(null);
        if (organizador == null) {
            return;
        }
        Location hemocentro = new Location();
        hemocentro.setName("Hemocentro de Sorocaba - Colsan");
        hemocentro.setStreet("Av. Comendador Camilo Julião");
        hemocentro.setNumber("1000");
        hemocentro.setNeighborhood("Vila Jardini");
        hemocentro.setCity("Sorocaba");
        hemocentro.setState("SP");
        hemocentro.setLatitude(new BigDecimal("-23.4871000"));
        hemocentro.setLongitude(new BigDecimal("-47.4586000"));
        localizacaoRepository.save(hemocentro);

        Location partida = new Location();
        partida.setName("Terminal Rodoviário");
        partida.setCity("Itapetininga");
        partida.setState("SP");
        partida.setLatitude(new BigDecimal("-23.5886000"));
        partida.setLongitude(new BigDecimal("-48.0483000"));
        localizacaoRepository.save(partida);

        Campaign c2 = new Campaign();
        c2.setTitle("Caravana Regional para Sorocaba");
        c2.setDescription("Transporte saindo de Itapetininga com paradas até o Hemocentro de Sorocaba.");
        c2.setEventDate(LocalDate.now().plusDays(20));
        c2.setDepartureLocation(partida);
        c2.setDepartureTime(LocalTime.of(7, 0));
        c2.setDonationTime(LocalTime.of(9, 30));
        c2.setSlots(30);
        c2.setStatus(CampaignStatus.OPEN);
        c2.setTransportMode(TransportMode.BUS);
        c2.setDonationLocation(hemocentro);
        c2.setOrganizer(organizador);
        campanhaRepository.save(c2);

        RouteStop stop1 = criarParada(c2, 0, "Praça Central", "Alambari", "-23.5512000", "-47.8967000", LocalTime.of(7, 30));
        c2.getStops().add(stop1);
        campanhaRepository.save(c2);

        // Se João existir, inscreve ele na campanha 2 para ter a inscrição #2
        donorRepository.findAll().stream().findFirst().ifPresent(doador -> {
            if (!inscricaoRepository.existsByCampaignAndDonor(c2, doador)) {
                Registration inscricao2 = new Registration();
                inscricao2.setCampaign(c2);
                inscricao2.setDonor(doador);
                inscricao2.setStatus(RegistrationStatus.CONFIRMED);
                inscricao2.setBoardingPoint("Terminal Rodoviário, Itapetininga");
                inscricao2.setBoardingLocation(partida);
                inscricaoRepository.save(inscricao2);
            }
        });

        garantirCampanhasExemploParaPaginacao();
    }

    private void garantirCampanhasExemploParaPaginacao() {
        if (campanhaRepository.count() >= 20) {
            return;
        }

        Organizer organizador = organizerRepository.findAll().stream().findFirst().orElse(null);
        Location hemocentro = localizacaoRepository.findAll().stream().findFirst().orElse(null);
        if (organizador == null || hemocentro == null) {
            return;
        }

        String[][] dadosExemplo = {
            {"Caravana da Esperança - Tatuí", "Saída da Rodoviária de Tatuí com transporte gratuito até o Hemocentro.", "Tatuí", "-23.3556000", "-47.8569000", "5", "35"},
            {"Doadores de Votorantim", "Transporte e acompanhamento para doadores da região de Votorantim.", "Votorantim", "-23.5419000", "-47.4389000", "8", "40"},
            {"Caravana Solidária Botucatu", "Condução organizada para abastecer os bancos de sangue da região.", "Botucatu", "-22.8858000", "-48.4450000", "11", "30"},
            {"Coleta Regional Campinas", "Caravana especial de doadores saindo do Centro de Campinas.", "Campinas", "-22.9099000", "-47.0626000", "14", "45"},
            {"Amigos do Sangue - São Roque", "Transporte seguro e lanche no retorno para os voluntários de São Roque.", "São Roque", "-23.5298000", "-47.1353000", "17", "32"},
            {"Caravana Itapetininga II", "Segunda saída do mês com paradas estratégicas pelo centro.", "Itapetininga", "-23.5886000", "-48.0483000", "20", "28"},
            {"Coleta de Sangue Boituva", "Voluntários de Boituva unidos para salvar vidas em Sorocaba.", "Boituva", "-23.2847000", "-47.6789000", "23", "36"},
            {"Caravana Porto Feliz", "Transporte ida e volta saindo da Praça Matriz de Porto Feliz.", "Porto Feliz", "-23.2158000", "-47.5239000", "26", "30"},
            {"Doação Coletiva Itu", "Grupo de doação de sangue organizado para voluntários de Itu.", "Itu", "-23.2642000", "-47.2992000", "29", "40"},
            {"Unidos pela Vida - Salto", "Ônibus executivo gratuito para doadores de Salto.", "Salto", "-23.2003000", "-47.2869000", "32", "34"},
            {"Caravana Cerquilho", "Caravana regional saindo da prefeitura municipal de Cerquilho.", "Cerquilho", "-23.1678000", "-47.7436000", "35", "30"},
            {"Doadores do Tietê", "Mobilização de doadores com saída matutina e lanche especial.", "Tietê", "-23.1022000", "-47.7144000", "38", "38"},
            {"Caravana Piedade", "Condução saindo da rodoviária de Piedade rumo ao hemocentro.", "Piedade", "-23.7125000", "-47.4264000", "41", "30"},
            {"Doadores de Capão Bonito", "Caravana regional intermunicipal para atendimento em Sorocaba.", "Capão Bonito", "-24.0064000", "-48.3497000", "44", "42"},
            {"Caravana Angatuba", "Transporte exclusivo para os doadores cadastrados de Angatuba.", "Angatuba", "-23.4917000", "-48.4128000", "47", "30"},
            {"Jovens Solidários de Sorocaba", "Transporte metropolitano com voluntários universitários.", "Sorocaba", "-23.4871000", "-47.4586000", "50", "40"},
            {"Caravana de Primavera", "Coleta comemorativa regional de sangue para reforço de estoques.", "Tatuí", "-23.3556000", "-47.8569000", "53", "35"},
            {"Corrente do Bem Sorocaba", "Caravana especial de encerramento do ciclo regional de coletas.", "Sorocaba", "-23.4871000", "-47.4586000", "56", "45"}
        };

        for (String[] d : dadosExemplo) {
            if (campanhaRepository.count() >= 20) {
                break;
            }

            Location partida = new Location();
            partida.setName("Ponto Central - " + d[2]);
            partida.setCity(d[2]);
            partida.setState("SP");
            partida.setLatitude(new BigDecimal(d[3]));
            partida.setLongitude(new BigDecimal(d[4]));
            localizacaoRepository.save(partida);

            Campaign c = new Campaign();
            c.setTitle(d[0]);
            c.setDescription(d[1]);
            c.setEventDate(LocalDate.now().plusDays(Long.parseLong(d[5])));
            c.setDepartureLocation(partida);
            c.setDepartureTime(LocalTime.of(7, 30));
            c.setDonationTime(LocalTime.of(10, 0));
            c.setSlots(Integer.parseInt(d[6]));
            c.setStatus(CampaignStatus.OPEN);
            c.setTransportMode(TransportMode.BUS);
            c.setDonationLocation(hemocentro);
            c.setOrganizer(organizador);
            campanhaRepository.save(c);
        }
    }

    // Remove eventuais campanhas antigas cadastradas no modo sem transporte
    private void removerCampanhasSemTransporte() {
        var semTransporte = campanhaRepository.findAll().stream()
                .filter(c -> c.getDepartureLocation() == null)
                .toList();
        for (Campaign c : semTransporte) {
            inscricaoRepository.deleteAll(inscricaoRepository.findByCampaign(c));
            campanhaRepository.delete(c);
        }
    }

    private User criarConta(String nome, String email, String telefone) {
        User conta = new User();
        conta.setName(nome);
        conta.setEmail(email);
        conta.setPasswordHash(passwordEncoder.encode("123456"));
        conta.setPhone(telefone);
        return usuarioRepository.save(conta);
    }

    private Donor criarDoadorJoao() {
        Donor doador = new Donor(criarConta("João da Silva", "joao@email.com", "(15) 99999-0000"));
        doador.setBloodType(BloodType.O_POSITIVE);
        doador.setBirthDate(LocalDate.of(1995, 5, 15));
        doador.setWeight(72.5);
        return donorRepository.save(doador);
    }

    // Bancos criados antes das paradas e do mapa: coordenadas e duas paradas na campanha de demonstração
    private void completarRotaDaCampanhaDemo() {
        campanhaRepository.findAll().stream()
                .filter(c -> "Campanha Sangue Solidário 2026".equals(c.getTitle()))
                .forEach(c -> {
                    Location saida = c.getDepartureLocation();
                    if (saida != null && !saida.hasCoordinates() && "Praça Matriz".equals(saida.getName())) {
                        saida.setLatitude(new BigDecimal("-23.4897000"));
                        saida.setLongitude(new BigDecimal("-48.4128000"));
                    }
                    Location destino = c.getDonationLocation();
                    if (destino != null && !destino.hasCoordinates() && destino.getName() != null
                            && destino.getName().startsWith("Posto Clínicas")) {
                        destino.setLatitude(new BigDecimal("-23.5573000"));
                        destino.setLongitude(new BigDecimal("-46.6697000"));
                    }
                    if (c.getStops().isEmpty()) {
                        c.getStops().add(criarParada(c, 0, "Rodoviária de Itapetininga", "Itapetininga",
                                "-23.5886000", "-48.0483000", LocalTime.of(7, 0)));
                        c.getStops().add(criarParada(c, 1, "Rodoviária de Sorocaba", "Sorocaba",
                                "-23.4886000", "-47.4455000", LocalTime.of(7, 45)));
                    }
                    // Inscrições antigas só guardavam o texto do ponto de embarque
                    if (saida != null) {
                        inscricaoRepository.findByCampaign(c).stream()
                                .filter(r -> r.getBoardingLocation() == null && "Praça Matriz, Angatuba".equals(r.getBoardingPoint()))
                                .forEach(r -> r.setBoardingLocation(saida));
                    }
                });
    }

    private RouteStop criarParada(Campaign campanha, int posicao, String nome, String cidade,
            String lat, String lng, LocalTime horario) {
        Location local = new Location();
        local.setName(nome);
        local.setCity(cidade);
        local.setState("SP");
        local.setLatitude(new BigDecimal(lat));
        local.setLongitude(new BigDecimal(lng));
        RouteStop parada = new RouteStop();
        parada.setCampaign(campanha);
        parada.setLocation(localizacaoRepository.save(local));
        parada.setPosition(posicao);
        parada.setStopTime(horario);
        return parada;
    }

    // Bancos criados antes do campo de embarque existir: completa a campanha de demonstração
    private void completarEmbarqueDaCampanhaDemo() {
        campanhaRepository.findAll().stream()
                .filter(c -> "Campanha Sangue Solidário 2026".equals(c.getTitle()) && c.getDepartureLocation() == null)
                .forEach(c -> {
                    c.setDepartureLocation(criarPontoDeEmbarque());
                    if (c.getDepartureTime() == null) {
                        c.setDepartureTime(LocalTime.of(6, 30));
                    }
                    campanhaRepository.save(c);
                    inscricaoRepository.findByCampaign(c).stream()
                            .filter(r -> r.getBoardingPoint() == null)
                            .forEach(r -> {
                                r.setBoardingPoint("Praça Matriz, Angatuba");
                                inscricaoRepository.save(r);
                            });
                });
    }

    private Location criarPontoDeEmbarque() {
        Location pracaMatriz = new Location();
        pracaMatriz.setName("Praça Matriz");
        pracaMatriz.setCity("Angatuba");
        pracaMatriz.setState("SP");
        pracaMatriz.setLatitude(new BigDecimal("-23.4897000"));
        pracaMatriz.setLongitude(new BigDecimal("-48.4128000"));
        return localizacaoRepository.save(pracaMatriz);
    }
}