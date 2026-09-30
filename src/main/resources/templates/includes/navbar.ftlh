<nav class="nav">
  <a <#if (currentNav!"") == "inicio">class="active" </#if>href="/">Início</a>
  <a <#if (currentNav!"") == "campanhas">class="active" </#if>href="/campanhas">Campanhas</a>
  <a <#if (currentNav!"") == "educativo">class="active" </#if>href="/educativo">Saiba Mais</a>
  <#if ehOrganizador!false>
    <a <#if (currentNav!"") == "organizador">class="active" </#if>href="/organizador/campanhas">Organizar</a>
  </#if>
  <#if usuarioLogado??>
    <a <#if (currentNav!"") == "minhas">class="active" </#if>href="/perfil#inscricoes">Minhas inscrições</a>
  </#if>
</nav>
