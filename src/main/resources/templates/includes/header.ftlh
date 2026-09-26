<header class="site-header">
  <div class="container header-inner">
    <a class="logo" href="/">
      <span class="logo-mark"><span class="logo-dot"></span></span>
      <span class="logo-text"><span class="brand">Rota</span> Solidária</span>
    </a>
    <#include "navbar.ftlh">
    <div class="header-actions">
      <a class="icon-btn" href="#acessibilidade" aria-label="Acessibilidade"><span
          class="icon">accessibility_new</span></a>
      <#if usuarioLogado??>
        <div class="user-dropdown-wrapper" id="userDropdownWrapper">
          <button type="button" class="profile-chip dropdown-toggle" id="userMenuBtn" aria-haspopup="true" aria-expanded="false">
            <span class="avatar">${(usuarioLogado.name?keep_before(" ")?substring(0, 1))!"U"}${(usuarioLogado.name?keep_after(" ")?substring(0, 1))!"S"}</span>
            <span>${usuarioLogado.name?keep_before(" ")}</span>
            <span class="icon dropdown-caret">expand_more</span>
          </button>
          <div class="user-dropdown-menu" id="userMenuDropdown">
            <div class="dropdown-header-info">
              <strong>${usuarioLogado.name}</strong>
              <span class="dropdown-email">${usuarioLogado.email}</span>
            </div>
            <div class="dropdown-divider"></div>
            <a class="dropdown-item" href="/perfil">
              <span class="icon">person</span>Meu Perfil
            </a>
            <a class="dropdown-item" href="/perfil#editar">
              <span class="icon">edit</span>Editar Perfil
            </a>
            <div class="dropdown-divider"></div>
            <a class="dropdown-item dropdown-danger" href="/logout">
              <span class="icon">logout</span>Sair do perfil
            </a>
          </div>
        </div>
      <#else>
        <a class="profile-chip" href="/login"><span class="avatar">RS</span>Perfil</a>
      </#if>
    </div>
  </div>
  <div class="mobile-nav container">
    <a href="/">Início</a>
    <a href="/campanhas">Campanhas</a>
    <a href="/educativo">Saiba Mais</a>
    <#if usuarioLogado??>
      <a href="/perfil">Meu Perfil (${usuarioLogado.name?keep_before(" ")})</a>
      <a href="/perfil#editar">Editar Perfil</a>
      <a href="/logout" class="mobile-logout">Sair do perfil</a>
    <#else>
      <a href="/login">Perfil</a>
    </#if>
  </div>
</header>