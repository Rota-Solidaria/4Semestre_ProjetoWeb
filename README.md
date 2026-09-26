# 🩸 Rota Solidária

Plataforma web voltada para a **divulgação e organização de excursões para doação de sangue**, conectando voluntários a campanhas e coletas regionais com transporte gratuito.

---

## 📌 Sobre o Projeto

O **Rota Solidária** tem como objetivo facilitar e incentivar a doação de sangue, integrando doadores, pontos de coleta e organizadores de caravanas. A plataforma centraliza informações sobre viagens, datas, horários, pontos de embarque e requisitos necessários, permitindo que qualquer pessoa encontre coletas próximas e garanta sua vaga em poucos cliques.

### Funcionalidades Principais:
1. **Agenda Regional de Campanhas**: visualização de campanhas abertas e finalizadas, ordenadas por data e proximidade.
2. **Listagem Dinâmica na Home**: exibição das próximas campanhas confirmadas diretamente na página inicial (limite de até 6 coletas ativas).
3. **Detalhes e Triagem Prévia**: informações detalhadas sobre local de doação, horários de saída, organizador e checklist pré-embarque.
4. **Reserva de Vagas e Inscrições**: fluxo simplificado para voluntários garantirem lugar no transporte da caravana.
5. **Autenticação e Sessão**: login e logout de usuários com senhas criptografadas via Argon2id.
6. **Área do Doador / Perfil**: painel exclusivo acessível após login contendo:
   - Indicador de vidas impactadas estimadas (cada doação pode salvar até 4 vidas).
   - Histórico e status das inscrições em caravanas.
   - Pílula de destaque para o tipo sanguíneo e status de aptidão.
   - Formulário de edição de dados pessoais, médicos (peso, nascimento, tipo sanguíneo) e alteração de senha.
7. **Menu Dropdown no Header**: menu dinâmico no cabeçalho com identificação do usuário logado, atalhos rápidos para o perfil e logout seguro.
8. **Guia Educativo**: orientações completas sobre requisitos básicos, mitos e etapas do processo de doação.

---

## 🚀 Tecnologias e Dependências

* **Java 21**
* **Spring Boot 3.x / 4.x**
* **Spring MVC**: arquitetura MVC para roteamento e controle de requisições.
* **Spring Data JPA & Hibernate**: persistência e mapeamento objeto-relacional.
* **MySQL**: banco de dados relacional.
* **FreeMarker (`.ftlh`)**: template engine modular com layouts e macros reutilizáveis.
* **Spring Security Crypto**: criptografia de senhas usando o algoritmo seguro Argon2id.
* **Spring Boot DevTools**: recarregamento dinâmico em tempo de desenvolvimento.
* **Spring Boot Test & JUnit 5**: suíte para testes automatizados.

---

## 📁 Estrutura do Projeto

O projeto adota uma arquitetura limpa e modular de templates e assets:

```text
4Semestre_ProjetoWeb/
├── src/
│   ├── main/
│   │   ├── java/com/rotasolidaria/
│   │   │   ├── config/              # Configurações globais (Segurança, Advice de Sessão)
│   │   │   ├── controllers/         # Controladores Spring MVC (Home, Campanhas, Perfil, Auth, etc.)
│   │   │   ├── models/              # Entidades JPA (User, Donor, Organizer, Campaign, Registration)
│   │   │   ├── models/enums/        # Enums de domínio (BloodType, CampaignStatus, etc.)
│   │   │   ├── repositories/        # Repositórios Spring Data JPA
│   │   │   ├── services/            # Camada de regras de negócio
│   │   │   └── DataInitializer.java # Povoamento automático de dados de demonstração
│   │   │
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── static/
│   │       │   ├── css/             # Folhas de estilo modulares (campanhas, perfil, header, etc.)
│   │       │   ├── js/              # Scripts utilitários
│   │       │   └── images/          # Imagens, fotos de excursões e favicon
│   │       │
│   │       └── templates/
│   │           ├── layout/          # Layouts base (main.ftlh, admin.ftlh)
│   │           ├── includes/        # Componentes compartilhados (header, navbar, footer, scripts)
│   │           ├── pages/           # Views das rotas (index, campanhas, perfil, login, etc.)
│   │           └── errors/          # Páginas de erro customizadas (404.ftlh, 500.ftlh)
│   │
│   └── test/                        # Testes unitários e de integração
│
├── pom.xml
└── README.md
```

---

## 🔑 Credenciais para Testes Locais

A aplicação inclui um inicializador automático de dados (`DataInitializer`) que cria registros de teste caso o banco esteja vazio:

| Perfil | E-mail | Senha | Detalhes |
| :--- | :--- | :--- | :--- |
| **Doador** | `joao@email.com` | `123456` | Tipo O+, peso 72.5kg, inscrição confirmada em campanha |
| **Organizador** | `contato@hemocentro.org.br` | `123456` | Fundação Pró-Sangue / Hemocentro Regional |

---

## 🛠️ Como Executar a Aplicação

### Pré-requisitos
* **Java JDK 21** ou superior
* **Maven** (ou utilize o wrapper `./mvnw`)
* **MySQL** em execução (configurado em `src/main/resources/application.properties`)

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/Ramos902/4Semestre_ProjetoWeb.git
   cd 4Semestre_ProjetoWeb
   ```

2. **Configure o banco de dados:**
   Para inicializar o banco de dados MySQL e a infraestrutura local via Docker Compose, siga o guia detalhado em [docs/setup-local.md](docs/setup-local.md).

   As credenciais e configurações de conexão estão definidas no arquivo `src/main/resources/application.properties`:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3307/database_dev?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
   spring.datasource.username=admin
   spring.datasource.password=admin
   ```

3. **Compile e execute a aplicação:**
   ```bash
   ./mvnw spring-boot:run
   ```

4. **Acesse no navegador:**
   [http://localhost:8082](http://localhost:8082) *(ou a porta definida na variável `SERVER_PORT`)*.

---

## 👥 Autores

<table>
  <tr>
    <td align="center"><a href="https://github.com/andrwza"><img src="https://github.com/andrwza.png" width="80" height="80" style="border-radius:50%"/><br><sub>Andreza</sub></a></td>
    <td align="center"><a href="https://github.com/FernandoNino38"><img src="https://github.com/FernandoNino38.png" width="80" height="80" style="border-radius:50%"/><br><sub>Fernando</sub></a></td>
    <td align="center"><a href="https://github.com/gabztx"><img src="https://github.com/gabztx.png" width="80" height="80" style="border-radius:50%"/><br><sub>Gabriela</sub></a></td>
    <td align="center"><a href="https://github.com/Buenno0"><img src="https://github.com/Buenno0.png" width="80" height="80" style="border-radius:50%"/><br><sub>Mateus</sub></a></td>
    <td align="center"><a href="https://github.com/Ramos902"><img src="https://github.com/Ramos902.png" width="80" height="80" style="border-radius:50%"/><br><sub>Ramos</sub></a></td>
  </tr>
</table>
