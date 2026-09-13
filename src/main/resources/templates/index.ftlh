<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Rota Solidária</title>
  <link rel="icon" href="assets/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
  <link rel="stylesheet" href="/css/index.css">
</head>

<body>
  <header class="site-header">
    <div class="container header-inner">
      <a class="logo" href="/">
        <span class="logo-mark"><span class="logo-dot"></span></span>
        <span class="logo-text"><span class="brand">Rota</span> Solidária</span>
      </a>
      <nav class="nav">
        <a class="active" href="/">Início</a>
        <a href="/campanhas">Campanhas</a>
        <a href="/educativo">Saiba Mais</a>
      </nav>
      <div class="header-actions">
        <a class="icon-btn" href="#acessibilidade" aria-label="Acessibilidade"><span class="icon">accessibility_new</span></a>
        <a class="profile-chip" href="/login"><span class="avatar">RS</span>Perfil</a>
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
    <section class="hero">
      <div class="container hero-grid">
        <div>
          <span class="kicker">Doação de sangue · Angatuba e região</span>
          <h1>Doe sangue, salve vidas perto de você.</h1>
          <p>Encontre a próxima coleta na sua região, veja se há transporte gratuito e garanta sua vaga em poucos minutos.</p>
        </div>

        <div class="hero-image">
          <img src="assets/doacaodesangue.jpeg" alt="Pessoa realizando doação de sangue">

          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-head">
          <div>
            <span class="kicker">Agenda de coleta</span>
            <h2>Próximas campanhas confirmadas</h2>
            <p>Ordenadas pela distância até Angatuba.</p>
          </div>
          <a class="btn btn-secondary" href="/campanhas">Ver todas<span class="icon">arrow_forward</span></a>
        </div>

        <div class="grid">
          <a class="card" href="/campanhas/1">
            <div class="card-img"><img src="assets/doacaodesangue.jpeg" alt=""></div>
            <div class="card-body">
              <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
              <h3>Campanha Mês Amarelo</h3>
              <div class="meta">
                <span><span class="icon">schedule</span>11 de Maio · Saída 05:00h</span>
                <span><span class="icon">place</span>Colsan — Posto de Coleta Sorocaba</span>
                <span><span class="icon">directions_bus</span>Transporte gratuito</span>
              </div>
              <span class="card-cta cta-primary">Inscrever-se</span>
            </div>
          </a>
          <div class="card is-closed">
            <div class="card-img"><img src="assets/doacaodesangue.jpeg" alt=""></div>
            <div class="card-body">
              <span class="badge badge-closed"><span class="dot"></span>Finalizada</span>
              <h3>Mutirão Solidário de Abril</h3>
              <div class="meta">
                <span><span class="icon">schedule</span>03 de Abril · Saída 05:00h</span>
                <span><span class="icon">place</span>Colsan — Posto de Coleta Sorocaba</span>
                <span><span class="icon">directions_bus</span>Transporte gratuito</span>
              </div>
              <span class="card-cta cta-disabled">Encerrada</span>
            </div>
          </div>
        </div>
      </div>
    </section>
    <section class="section past-section">
      <div class="container">
        <div class="section-head">
          <div>
            <span class="kicker">Nossa história</span>
            <h2>Excursões anteriores</h2>
            <p>Confira alguns momentos das campanhas realizadas pela Rota Solidária.</p>
          </div>
        </div>

        <div class="past-grid">
          <div class="past-card">
            <img src="assets/excursoes/foto-01.jpeg" alt="Participantes da excursão para doação de sangue">
            <div class="past-info">
              <strong>Mutirão Solidário de Abril</strong>
              <span>03 de Abril · Sorocaba</span>
            </div>
          </div>

          <div class="past-card">
            <img src="assets/excursoes/foto-02.jpg" alt="Grupo reunido durante uma campanha de doação">
            <div class="past-info">
              <strong>Campanha de Março</strong>
              <span>15 de Março · Sorocaba</span>
            </div>
          </div>

          <div class="past-card">
            <img src="assets/excursoes/foto-03.jpg" alt="Participantes durante uma excursão">
            <div class="past-info">
              <strong>Campanha de Fevereiro</strong>
              <span>20 de Fevereiro · Sorocaba</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container footer-inner">
      <span class="footer-brand"><span class="icon">favorite</span><strong>Rota Solidária</strong> · 2026</span>
      <span>Projeto de Extensão · Angatuba e Região</span>
    </div>
  </footer>
</body>

</html>