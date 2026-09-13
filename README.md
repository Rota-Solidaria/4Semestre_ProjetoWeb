# 🩸 Rota Solidária

## 📌 Sobre o Projeto

O **Rota Solidária** é uma plataforma web voltada para a **divulgação de excursões para doação de sangue**.
A plataforma tem como objetivo conectar pessoas interessadas em realizar doações de sangue às **excursões disponíveis**, facilitando o acesso às informações sobre as viagens, campanhas, datas, locais e demais detalhes necessários para a participação.
Este repositório contém a **implementação web do projeto**, desenvolvida com base no protótipo do Rota Solidária.

---

## 🎯 Objetivo

O projeto busca facilitar a participação da população em ações de doação de sangue por meio da **divulgação e organização de excursões destinadas aos locais de coleta**.
A plataforma permite centralizar informações sobre as excursões, tornando mais fácil para os interessados encontrar uma oportunidade de doação e participar de uma viagem organizada para esse propósito.

---

## 🌐 Como funciona?

A proposta do Rota Solidária é:

1. 🩸 **Divulgar excursões** destinadas à doação de sangue;
2. 📅 Apresentar **datas e horários** das excursões;
3. 📍 Informar o **local de destino para a doação**;
4. 🚌 Disponibilizar informações sobre a **viagem e transporte**;
5. 👥 Facilitar o acesso das pessoas interessadas às excursões disponíveis;

---

## 🛠️ Tecnologias Utilizadas

* Java 21
* Spring Boot
* Maven
* Spring MVC
* FreeMarker
* Spring Boot Test
* Spring Boot DevTools
* HTML
* CSS

---

## 📚 Principais Dependências

### Spring Web
Utilizado para o desenvolvimento da aplicação web, criação de **controllers e rotas**.

### FreeMarker
Utilizado como mecanismo de templates para a construção das páginas da aplicação por meio dos arquivos `.ftlh`.

### Spring Boot DevTools
Auxilia durante o desenvolvimento permitindo o **recarregamento automático da aplicação** após alterações no código.

### Spring Boot Test
Utilizado para a realização de **testes automatizados** na aplicação.

---

## 📁 Estrutura do Projeto

```text
4Semestre_ProjetoWeb/
│
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── rotasolidaria/
│   │   │
│   │   └── resources/
│   │       ├── static/
│   │       │   ├── css/
│   │       │   └── images/
│   │       │
│   │       └── templates/
│   │           └── *.ftlh
│   │
│   └── test/
│
├── pom.xml
└── README.md
```

---

## ⚙️ Requisitos

Para executar o projeto, é necessário possuir:
* Java JDK 21
* Maven
* Git
* IDE de desenvolvimento Java, como IntelliJ IDEA, Eclipse ou Visual Studio Code.

---

## 🚀 Como Executar

### 1. Clone o repositório

```bash
git clone https://github.com/Rota-Solidaria/4Semestre_ProjetoWeb.git
```

### 2. Acesse a pasta

```bash
cd 4Semestre_ProjetoWeb
```

### 3. Execute a aplicação

No Windows:

```bash
mvnw.cmd spring-boot:run
```

No Linux/macOS:

```bash
./mvnw spring-boot:run
```

---

## 🌐 Acesso

Após iniciar a aplicação, acesse:

```text
http://localhost:8080
```

A aplicação será executada localmente na porta **8080**.

---

## 🔗 Projeto Relacionado

O desenvolvimento deste projeto foi baseado no protótipo do Rota Solidária:

**4Semestre_Prototipo**

O protótipo apresenta a estrutura visual e a proposta inicial da plataforma, enquanto este repositório contém a **implementação web utilizando Java e Spring Boot**.

---

## 👥 Equipe
<table>
  <tr>
    <td align="center"><a href="https://github.com/andrwza"><img src="https://github.com/andrwza.png" width="80" height="80" style="border-radius:50%"/><br><sub>Andreza</sub></a></td>
    <td align="center"><a href="https://github.com/FernandoNino38"><img src="https://github.com/FernandoNino38.png" width="80" height="80" style="border-radius:50%"/><br><sub>Fernando</sub></a></td>
    <td align="center"><a href="https://github.com/gabztx"><img src="https://github.com/gabztx.png" width="80" height="80" style="border-radius:50%"/><br><sub>Gabriela</sub></a></td>
    <td align="center"><a href="https://github.com/Buenno0"><img src="https://github.com/Buenno0.png" width="80" height="80" style="border-radius:50%"/><br><sub>Mateus</sub></a></td>
    <td align="center"><a href="https://github.com/Ramos902"><img src="https://github.com/Ramos902.png" width="80" height="80" style="border-radius:50%"/><br><sub>Ramos</sub></a></td>
  </tr>
</table>

---

## 🎓 Projeto Acadêmico
Projeto desenvolvido como parte das atividades acadêmicas do curso de **Tecnologia em Sistemas para Internet**.

### ❤️ Rota Solidária
**Conectando pessoas às excursões para doação de sangue.**
