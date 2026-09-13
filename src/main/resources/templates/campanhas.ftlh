<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Campanhas Ativas</title>
  <link rel="icon" href="assets/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
  <link rel="stylesheet" href="/css/campanhas.css">
</head>

<body>
  <header class="site-header">
    <div class="container header-inner">
      <a class="logo" href="/">
        <span class="logo-mark"><span class="logo-dot"></span></span>
        <span class="logo-text"><span class="brand">Rota</span> Solidária</span>
      </a>
      <nav class="nav">
        <a href="/">Início</a>
        <a class="active" href="/campanhas">Campanhas</a>
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
    <section class="page-hero">
      <div class="container">
        <span class="kicker">Agenda regional</span>
        <h1>Campanhas na região</h1>
        <p>Filtre por cidade, distância e transporte disponível para encontrar a coleta mais próxima de você.</p>
      </div>
    </section>

    <div class="container section">
      <div class="filter-panel">
        <label class="search-field">
          <span class="icon">search</span>
          <input placeholder="Buscar por cidade, local ou organizador" aria-label="Buscar">
        </label>
      </div>

      <div class="list">
        <a class="list-row" href="/campanhas/1">
          <img src="assets/doacaodesangue.jpeg" alt="">
          <div>
            <div class="row-top">
              <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
              <span class="row-vagas">12 vagas</span>
            </div>
            <h3>Campanha Mês Amarelo</h3>
            <div class="row-meta">
              <span><span class="icon">schedule</span>11 de Maio · Saída 05:00h</span>
              <span><span class="icon">place</span>Colsan — Posto de Coleta Sorocaba</span>
              <span><span class="icon">directions_bus</span>Transporte gratuito</span>
            </div>
          </div>
          <span class="row-cta cta-primary" style="background:var(--brand);color:#fff">Ver campanha</span>
        </a>

        <div class="list-row is-closed">
          <img src="assets/doacaodesangue.jpeg" alt="">
          <div>
            <div class="row-top">
              <span class="badge badge-closed"><span class="dot"></span>Finalizada</span>
              <span class="row-vagas">0 vagas</span>
            </div>
            <h3>Mutirão Solidário de Abril</h3>
            <div class="row-meta">
              <span><span class="icon">schedule</span>03 de Abril · Saída 05:00h</span>
              <span><span class="icon">place</span>Colsan — Posto de Coleta Sorocaba</span>
              <span><span class="icon">directions_bus</span>Transporte gratuito</span>
            </div>
          </div>
          <span class="row-cta" style="background:var(--surface2);color:var(--text3)">Encerrada</span>
        </div>
      </div>

      <div class="pagination">
        <span class="page-btn current">1</span>
        <span class="page-btn">2</span>
      </div>
    </div>
  </main>

  <footer class="site-footer">
    <div class="container footer-inner">
      <span class="footer-brand"><span class="icon">favorite</span><strong>Rota Solidária</strong> · 2026</span>
      <span>Projeto de Extensão · Angatuba e Região</span>
    </div>
  </footer>
</body>

</html>