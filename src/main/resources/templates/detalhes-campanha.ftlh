<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Detalhes da Campanha</title>
  <link rel="icon" href="assets/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link
    href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap"
    rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0"
    rel="stylesheet">
  <link rel="stylesheet" href="/css/detalhes-campanha.css">
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
    <div class="container section" style="padding-top:0">
      <a class="back-link" href="/campanhas"><span class="icon">arrow_back</span>Voltar para campanhas</a>

      <div class="detail-card">
        <div class="detail-img">
          <img src="/css/assets/doacaodesangue.jpeg" alt="${campanha.title}">
        </div>
        <div class="detail-body">
          <div class="detail-top">
            <span class="badge badge-open"><span class="dot"></span>${campanha.status}</span>
            <span class="row-vagas" style="font-weight:600; color:var(--text2);">${campanha.slots!0}
              vagas disponíveis</span>
          </div>

          <h1>${campanha.title}</h1>

          <#if campanha.description??>
            <p style="color:var(--text2); line-height:1.6; margin-bottom:1.5rem;">${campanha.
              description}</p>
          </#if>

          <div class="info-grid">
            <div class="info-box">
              <span class="icon-box"><span class="icon">schedule</span></span>
              <div>
                <div class="info-title">
                  <#if campanha.eventDate??>${campanha.eventDate}</#if>
                </div>
                <div class="info-sub">
                  <#if campanha.departureTime??>Saída
                    ${campanha.departureTime}h · </#if>
                  <#if campanha.donationTime??>Doação
                    ${campanha.donationTime}h</#if>
                </div>
              </div>
            </div>

            <#if campanha.donationLocation??>
              <div class="info-box">
                <span class="icon-box"><span class="icon">place</span></span>
                <div>
                  <div class="info-title">${campanha.
                    donationLocation.name}</div>
                  <div class="info-sub">
                    ${campanha.donationLocation.
                    street}, ${campanha.donationLocation.number}
                    <#if campanha.donationLocation. neighborhood??> — ${campanha.donationLocation.
                      neighborhood}</#if>,
                    ${campanha.donationLocation.city} -
                    ${campanha.donationLocation.state}
                  </div>
                </div>
              </div>
            </#if>

            <div class="info-box">
              <span class="icon-box"><span class="icon">directions_bus</span></span>
              <div>
                <div class="info-title">Transporte
                  gratuito</div>
                <div class="info-sub">
                  <#if campanha.departureLocation??>
                    Embarque em: ${campanha.
                    departureLocation.name}
                    <#else>
                      Embarque na sua cidade
                  </#if>
                </div>
              </div>
            </div>
          </div>

          <div class="notice-box">
            <span class="icon">info</span>
            <p><strong>Organizado por:</strong>
              <#if campanha.organizer??>${campanha.organizer.
                institution!"Organizador"} (${campanha.organizer.
                name})<#else>Organizador Regional</#if>.
            </p>
          </div>

          <div class="checklist-title">Antes de
            embarcar</div>
          <ul class="checklist">
            <li><span class="icon">check_circle</span>Documento oficial com
              foto, original</li>
            <li><span class="icon">check_circle</span>Alimentação leve até 4
              horas antes</li>
            <li><span class="icon">check_circle</span>Mínimo de 6 horas de
              sono</li>
            <li><span class="icon">check_circle</span>Entre 16 e 69 anos e
              acima de 50 kg</li>
          </ul>

          <div class="detail-actions">
            <a class="btn btn-primary btn-lg" href="/campanhas/${campanha.id}/inscrever">Fazer
              inscrição<span class="icon">arrow_forward</span></a>
            <a class="btn btn-secondary btn-lg" href="/campanhas">Ver outras campanhas</a>
          </div>
        </div>
      </div>

      <p class="more-link">Tem dúvidas se você pode doar? <a href="/educativo">Confira os requisitos básicos.</a></p>
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