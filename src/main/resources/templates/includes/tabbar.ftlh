<#-- Barra de navegação inferior, visível só no celular e tablet (components.css) -->
<#assign nav = currentNav!"">
<nav class="tabbar<#if ehOrganizador!false> tabbar--5</#if>" aria-label="Navegação principal">
  <a class="tabbar__item<#if nav == "inicio"> is-active</#if>" href="/"<#if nav == "inicio"> aria-current="page"</#if>>
    <span class="tabbar__icon"><span class="icon" aria-hidden="true">home</span></span>Início
  </a>
  <a class="tabbar__item<#if nav == "campanhas"> is-active</#if>" href="/campanhas"<#if nav == "campanhas"> aria-current="page"</#if>>
    <span class="tabbar__icon"><span class="icon" aria-hidden="true">calendar_month</span></span>Campanhas
  </a>
  <#if ehOrganizador!false>
    <a class="tabbar__item<#if nav == "organizador"> is-active</#if>" href="/organizador/campanhas"<#if nav == "organizador"> aria-current="page"</#if>>
      <span class="tabbar__icon"><span class="icon" aria-hidden="true">edit_calendar</span></span>Organizar
    </a>
  </#if>
  <a class="tabbar__item<#if nav == "minhas"> is-active</#if>" href="/perfil#inscricoes"<#if nav == "minhas"> aria-current="page"</#if>>
    <span class="tabbar__icon"><span class="icon" aria-hidden="true">confirmation_number</span></span>Minhas
  </a>
  <#if usuarioLogado??>
    <a class="tabbar__item<#if nav == "perfil"> is-active</#if>" href="/perfil"<#if nav == "perfil"> aria-current="page"</#if>>
      <span class="tabbar__icon"><span class="icon" aria-hidden="true">person</span></span>Perfil
    </a>
  <#else>
    <a class="tabbar__item<#if nav == "entrar"> is-active</#if>" href="/login"<#if nav == "entrar"> aria-current="page"</#if>>
      <span class="tabbar__icon"><span class="icon" aria-hidden="true">login</span></span>Entrar
    </a>
  </#if>
</nav>
