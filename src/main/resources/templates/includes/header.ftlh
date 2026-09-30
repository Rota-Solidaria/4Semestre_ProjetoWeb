<header class="site-header">
  <div class="container header-inner">
    <a class="logo" href="/">
      <span class="logo-mark"><span class="logo-dot"></span></span>
      <span class="logo-text"><span class="brand">Rota</span> Solidária</span>
    </a>
    <#include "navbar.ftlh">
    <div class="header-actions">
      <button type="button" class="icon-btn a11y-toggle" aria-label="Acessibilidade" aria-expanded="false" aria-controls="a11y-panel" data-a11y-toggle><span
          class="icon" aria-hidden="true">accessibility_new</span></button>
      <#if ehOrganizador!false>
        <a class="header-cta" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Nova campanha</a>
      </#if>
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
            <#if ehOrganizador!false>
              <a class="dropdown-item" href="/organizador/campanhas">
                <span class="icon">route</span>Minhas campanhas
              </a>
            </#if>
            <div class="dropdown-divider"></div>
            <form class="logout-form" method="post" action="/logout">
              <#include "csrf.ftlh">
              <button type="submit" class="dropdown-item dropdown-danger">
                <span class="icon">logout</span>Sair do perfil
              </button>
            </form>
          </div>
        </div>
      <#else>
        <a class="profile-chip profile-chip--login" href="/login"><span class="icon" aria-hidden="true">login</span>Entrar</a>
      </#if>
    </div>
  </div>
</header>