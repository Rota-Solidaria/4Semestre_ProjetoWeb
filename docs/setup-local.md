# Ambiente de Desenvolvimento

Documentação para execução da infraestrutura local do projeto (**MySQL** e **DBeaver em container**) via Docker Compose. O projeto Spring Boot deve ser executado separadamente na IDE.

---

## Pré-requisitos

1. **Docker e Docker Compose** instalados e em execução.
2. **JDK 17** ou superior.
3. **IDE** para desenvolvimento (IntelliJ IDEA, VS Code, Eclipse).

---

## 1. Inicialização da Infraestrutura (Docker)

1. Na raiz do projeto, crie seu arquivo de configuração local a partir do modelo:
   ```bash
   cp .env.example .env
   ```
2. Verifique os valores das variáveis no arquivo `.env`:
   ```properties
   # Configurações do MySQL
   DB_NAME=meubanco_dev
   DB_USER=admin
   DB_PASS=admin
   DB_ROOT_PASS=root_password
   DB_PORT=3307

   # Configurações do DBeaver Web (CloudBeaver)
   CB_PORT=8978

   # Configurações da Aplicação (Spring Boot)
   SERVER_PORT=8081
   ```
   > **Nota sobre a porta `DB_PORT`:** Se a porta padrão `3306` já estiver ocupada no seu sistema operacional por um MySQL local nativo, utilize `3307` (como já configurado) para evitar conflitos de porta.

3. Inicie os containers em segundo plano executando:
   ```bash
   docker compose up -d
   ```
4. Para checar o status dos containers:
   ```bash
   docker ps
   ```
   Você verá dois containers ativos:
   - `rotasolidaria_mysql_dev` (com status `Up (healthy)`)
   - `rotasolidaria_cloudbeaver_dev` (DBeaver Web)

---

## 2. Acesso e Configuração Inicial do DBeaver Web

O **DBeaver em container** ([CloudBeaver](https://cloudbeaver.io/)) disponibiliza toda a experiência do DBeaver Community diretamente no navegador.

- **URL de Acesso:** [http://localhost:8978](http://localhost:8978) *(ou a porta definida em `CB_PORT`)*

### Passo 1: Assistente de Inicialização (Apenas no primeiro acesso)
Ao abrir a URL pela primeira vez, o DBeaver solicitará a configuração rápida do servidor:
1. Clique em **Next** na tela inicial de boas-vindas.
2. Em **Server Configuration**, mantenha os valores padrão e clique em **Next**.
3. Na etapa **Administrative credentials**, defina um usuário e senha para você gerenciar o painel do DBeaver (exemplo: Usuário `admin` e crie uma senha segura).
4. Clique em **Next** e depois em **Finish** para concluir o setup.
5. Faça login com as credenciais administrativas que você acabou de criar.

---

### Passo 2: Conectar o DBeaver ao MySQL

Com o painel do DBeaver aberto:
1. No canto superior esquerdo ou na barra de ferramentas, clique em **Connection** (ícone de tomada) e selecione **New Connection** (ou **Create**).
2. Selecione o driver **MySQL**.
3. Preencha os dados da conexão com a rede interna do Docker:
   - **Host:** `mysql` *(como o DBeaver e o MySQL estão na mesma rede do Docker, use o nome do serviço `mysql`, NÃO use localhost aqui)*
   - **Port:** `3306` *(porta interna da rede do container)*
   - **Database:** `meubanco_dev` *(ou o valor de `DB_NAME` no seu `.env`)*
   - **Username:** `admin` *(ou `root`)*
   - **Password:** `admin` *(ou a senha que você configurou em `DB_PASS` / `DB_ROOT_PASS`)*
4. **Propriedades do Driver (Obrigatório para MySQL 8):**
   - No topo da janela, clique na aba **Driver properties** (Propriedades do Driver).
   - Localize a propriedade **`allowPublicKeyRetrieval`** e altere o valor para **`true`**.
   - *(Recomendado)* Localize a propriedade **`useSSL`** e defina como **`false`**.
5. Clique no botão **Test Connection** para validar a comunicação.
6. Clique em **Create** (Criar). 

Pronto! A conexão aparecerá no menu lateral esquerdo (**Database Navigator**).

> ### 💡 Por que a propriedade `allowPublicKeyRetrieval=true` é necessária?
> O MySQL 8.0 utiliza por padrão o mecanismo de autenticação seguro **`caching_sha2_password`**. 
> Em conexões sem certificado SSL (comuns em ambientes de desenvolvimento local dentro do Docker), o cliente JDBC precisa solicitar a chave pública RSA ao servidor MySQL para criptografar a senha antes de transmiti-la pela rede interna.
> Por padrão de segurança do driver oficial da Oracle, essa solicitação remota de chave pública vem desabilitada (`false`). Habilitar `allowPublicKeyRetrieval=true` autoriza o driver a recuperar essa chave e autenticar com sucesso, evitando o erro `Public Key Retrieval is not allowed`.

---

## 3. Como Utilizar o DBeaver no Dia a Dia

### Navegação nas Tabelas:
- No menu esquerdo, expanda:
  `mysql` > `Databases` > `meubanco_dev` > `Tables`.
- Dê um duplo clique sobre qualquer tabela para abrir suas propriedades, colunas, tipos e índices.

### Visualização e Edição de Dados:
- Com a tabela aberta, clique na aba **Data**.
- Os dados são exibidos em formato de planilha.
- Você pode editar valores diretamente dando duplo clique na célula desejada, ou adicionar/remover registros pelos botões na barra de ferramentas.
- Clique no botão **Save** (Salvar) na barra inferior para aplicar o commit das alterações.

### Diagrama de Entidade-Relacionamento (ER Diagram):
- Dê um duplo clique no banco de dados `meubanco_dev` e selecione a aba **ER Diagram**.
- O DBeaver gera visualmente as relações entre as entidades, facilitando o entendimento das chaves primárias e estrangeiras do projeto.

### Editor de Consultas SQL:
- Clique no menu **SQL** ou no ícone de novo script para abrir o editor de consultas.
- Digite seu código SQL (o editor conta com autocomplete e syntax highlight):
  ```sql
  SELECT * FROM usuario;
  ```
- Clique no botão de **Executar** (ícone de play laranja) ou use o atalho `Ctrl + Enter`.

---

## 4. Configuração da Aplicação (Spring Boot)

Como a aplicação Spring Boot é executada na sua máquina (fora do container Docker), ela se conecta ao MySQL através da porta externa exposta no seu computador (`localhost:3307`).

No arquivo `src/main/resources/application.properties`, configure as seguintes propriedades:

```properties
spring.datasource.url=jdbc:mysql://localhost:3307/meubanco_dev?createDatabaseIfNotExist=true&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=admin
spring.datasource.password=admin
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

> **Atenção:** Se você alterar a variável `DB_PORT` no seu arquivo `.env`, certifique-se de ajustar a mesma porta na URL do Spring Boot (`localhost:PORTA`).

---

## 5. Comandos Úteis do Docker (Guia Prático)

Comandos essenciais para o gerenciamento dos containers no dia a dia de desenvolvimento:

### 🟢 Iniciar e Parar Serviços
* **Iniciar os containers em segundo plano:**
  ```bash
  docker compose up -d
  ```
* **Pausar/Desligar os containers (mantendo os dados preservados):**
  ```bash
  docker compose stop
  ```
* **Parar e remover os containers e redes locais (mantendo os dados nos volumes):**
  ```bash
  docker compose down
  ```
* **Reiniciar todos os serviços:**
  ```bash
  docker compose restart
  ```
* **Reiniciar apenas um serviço específico:**
  ```bash
  docker compose restart mysql
  docker compose restart cloudbeaver
  ```

---

### 🔍 Monitoramento e Logs
* **Verificar o status dos containers e saúde (`healthy`):**
  ```bash
  docker compose ps
  # ou
  docker ps
  ```
* **Acompanhar os logs de todos os containers em tempo real:**
  ```bash
  docker compose logs -f
  ```
* **Acompanhar logs de um serviço específico:**
  ```bash
  # Logs do banco de dados
  docker compose logs -f mysql

  # Logs do DBeaver Web
  docker compose logs -f cloudbeaver
  ```

---

### 💻 Acessar o Terminal do Container
* **Acessar o terminal bash do MySQL:**
  ```bash
  docker exec -it rotasolidaria_mysql_dev bash
  ```
* **Acessar o MySQL diretamente via linha de comando (CLI):**
  ```bash
  docker exec -it rotasolidaria_mysql_dev mysql -u admin -p meubanco_dev
  ```

---

### 🧹 Limpeza e Reset do Ambiente
* **Resetar o banco do zero (Apagar containers E dados gravados):**
  ```bash
  docker compose down -v
  ```
  > ⚠️ **Atenção:** A flag `-v` remove os volumes persistentes (`mysql_data` e `cloudbeaver_data`). Todas as tabelas, registros e preferências do DBeaver serão apagados, deixando o ambiente totalmente limpo para uma nova inicialização.

* **Forçar recriação dos containers após alterações no `.env` ou `docker-compose.yml`:**
  ```bash
  docker compose up -d --force-recreate
  ```

* **Atualizar as imagens para a versão mais recente:**
  ```bash
  docker compose pull
  docker compose up -d
  ```