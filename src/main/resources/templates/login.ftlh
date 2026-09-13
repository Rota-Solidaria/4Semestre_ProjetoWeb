<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Login - Rota Solidária</title>
  <link rel="icon" href="assets/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
  <link rel="stylesheet" href="/css/login.css">
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

  <main class="container">
    <div class="login-wrap">
      <div class="panel login-panel">
        <span class="kicker">Acesso</span>
        <h1>Entrar</h1>
        <p>Acesse seu perfil para acompanhar suas inscrições.</p>
        <#if erro??>
          <p style="color:var(--err-text);margin-bottom:14px">${erro}</p>
        </#if>
        <#if aviso??>
          <p style="color:var(--warn-text);margin-bottom:14px">${aviso}</p>
        </#if>
        <form method="post" action="/login">
          <div class="field">
            <label for="rs-email">E-mail</label>
            <input id="rs-email" name="email" type="email" required placeholder="seu@email.com">
          </div>
          <div class="field">
            <label for="rs-senha">Senha</label>
            <input id="rs-senha" name="senha" type="password" required placeholder="••••••••">
          </div>
          <button class="btn btn-primary" type="submit">Entrar</button>
        </form>
        <p class="login-foot">Ainda não possui cadastro? <a href="/campanhas/1/inscrever">Continuar sem cadastro</a></p>
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