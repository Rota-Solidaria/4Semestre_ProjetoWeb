<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Campanhas Ativas</title>
  <link rel="icon" href="assets/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link
    href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap"
    rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0"
    rel="stylesheet">
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
        <a class="icon-btn" href="#acessibilidade" aria-label="Acessibilidade"><span
            class="icon">accessibility_new</span></a>
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
        <#if campanhas?? && campanhas?size gt 0>
          <#list campanhas as c>
            <a class="list-row" href="/campanhas/${c.
  id}">
              <img src="/css/assets/doacaodesangue.  
  jpeg" alt="${c.title}">
              <div>
                <div class="row-top">
                  <span class="badge badge-          
  open"><span class="dot"></span>${c.status}</span>
                  <span class="row-vagas">${c.
                    slots!0} vagas</span>
                </div>
                <h3>${c.title}</h3>
                <div class="row-meta">
                  <#if c.eventDate??>
                    <span><span class="icon">schedule</span>${c.eventDate} <#if c. donationTime??>· ${c.donationTime}h
                      </#if></span>
                  </#if>
                  <#if c.donationLocation??>
                    <span><span class="icon">place</span>${c.donationLocation.name} —
                      ${c.donationLocation.city}</span>
                  </#if>
                  <span><span class="icon">directions_bus</span>Transporte
                    gratuito</span>
                </div>
              </div>
              <span class="row-cta cta-primary" style="background:var(--brand);color:#fff">Ver
                campanha</span>
            </a>
          </#list>
          <#else>
            <p style="padding: 2rem; text-align: center;
  color: var(--text3);">Nenhuma campanha aberta no
              momento.</p>
        </#if>
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