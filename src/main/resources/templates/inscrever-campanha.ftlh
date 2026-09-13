<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Inscrição em Campanha</title>
  <link rel="icon" href="assets/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
  <link rel="stylesheet" href="/css/inscrever-campanha.css">
</head>

<body>

  <header class="site-header">
    <div class="container header-inner">

      <a class="logo" href="/">
        <span class="logo-mark">
          <span class="logo-dot"></span>
        </span>

        <span class="logo-text">
          <span class="brand">Rota</span> Solidária
        </span>
      </a>

      <nav class="nav">
        <a href="/">Início</a>
        <a class="active" href="/campanhas">Campanhas</a>
        <a href="/educativo">Saiba Mais</a>
      </nav>

      <div class="header-actions">
        <a class="icon-btn" href="#acessibilidade" aria-label="Acessibilidade">
          <span class="icon">accessibility_new</span>
        </a>

        <a class="profile-chip" href="/login">
          <span class="avatar">RS</span>
          Perfil
        </a>
      </div>
    </div>

    <div class="mobile-nav container">
      <a href="/">Início</a>
      <a href="/campanhas">Campanhas</a>
      <a href="/educativo">Saiba Mais</a>
      <a href="/login">Perfil</a>
    </div>
  </header>


  <main>
    <div class="container section">

      <!-- Etapas -->
      <div class="step-track">
        <span class="step-pill">
          <span class="step-dot">1</span>
          Inscrição
        </span>

        <span class="step-line"></span>

        <span class="step-pill step-inactive">
          <span class="step-dot">2</span>
          Confirmação
        </span>
      </div>


      <div class="form-layout">

        <div class="form-panel">

          <span class="kicker">Inscrição</span>

          <h1>Reservar vaga</h1>

          <p>
            Confira seus dados e escolha as informações da sua participação.
          </p>


          <!-- Dados da conta -->
          <div class="account-box">

            <div class="account-header">
              <span class="icon">account_circle</span>

              <div>
                <strong>Dados da sua conta</strong>
                <span>Informações cadastradas no seu perfil</span>
              </div>
            </div>

            <div class="account-data">

              <div class="account-field">
                <span class="account-label">Nome</span>
                <strong>João da Silva</strong>
              </div>

              <div class="account-field">
                <span class="account-label">WhatsApp</span>
                <strong>(15) 99999-0000</strong>
              </div>

            </div>

          </div>


          <div class="notice-box">
            Seus dados pessoais já estão cadastrados na sua conta e serão utilizados automaticamente nesta inscrição.
          </div>


          <form method="post" action="/campanhas/1/inscrever">

            <div class="form-grid">

              <!-- Cidade -->
              <div class="field full">

                <label for="rs-emb">
                  Cidade de embarque
                </label>

                <select id="rs-emb" name="embarque" required>
                  <option value="">Selecione o local de embarque</option>
                  <option>Angatuba — Praça Matriz</option>
                  <option>Angatuba — Rodoviária</option>
                  <option>Guareí — Centro</option>
                  <option>Vou por conta própria</option>
                </select>

              </div>


              <!-- Observações -->
              <div class="field full">

                <label for="rs-obs">
                  Observações
                  <span class="hint">· opcional</span>
                </label>

                <textarea
                  id="rs-obs"
                  name="obs"
                  rows="3"
                  placeholder="Precisa de acompanhante ou tem alguma observação?"
                ></textarea>

              </div>


              <!-- LGPD -->
              <div class="lgpd-row">

                <span class="lgpd-box">
                  <input
                    type="checkbox"
                    name="lgpd"
                    required
                    aria-label="Aceitar o compartilhamento de dados"
                  >
                </span>

                <span class="lgpd-text">
                  Autorizo o envio dos meus dados ao organizador da campanha, conforme a LGPD.
                </span>

              </div>


              <!-- Ações -->
              <div class="form-actions">

                <button
                  class="btn btn-primary btn-lg"
                  type="submit"
                >
                  Confirmar inscrição
                  <span class="icon">arrow_forward</span>
                </button>

                <a
                  class="btn btn-ghost btn-lg"
                  href="/campanhas/1"
                >
                  Cancelar
                </a>

              </div>

            </div>

          </form>

        </div>


        <!-- Resumo da campanha -->
        <aside class="panel summary-card">

          <img
            src="assets/doacaodesangue.jpeg"
            alt="Doação de sangue"
          >

          <span class="badge badge-open">
            <span class="dot"></span>
            Inscrições abertas
          </span>

          <div class="summary-title">
            Campanha Mês Amarelo
          </div>

          <div class="summary-info">

            <span>
              <span class="icon">schedule</span>
              11 de Maio · 05:00h
            </span>

            <span>
              <span class="icon">place</span>
              Colsan — Posto de Coleta Sorocaba
            </span>

          </div>

          <div class="summary-note">

            <span class="icon">check_circle</span>

            <p>
              Você recebe o comprovante e o checklist de preparo por WhatsApp.
            </p>

          </div>

        </aside>

      </div>
    </div>
  </main>


  <footer class="site-footer">

    <div class="container footer-inner">

      <span class="footer-brand">
        <span class="icon">favorite</span>
        <strong>Rota Solidária</strong> · 2026
      </span>

      <span>
        Projeto de Extensão · Angatuba e Região
      </span>

    </div>

  </footer>

</body>
</html>