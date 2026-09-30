<#import "../layout/main.ftlh" as main>

<#-- Área do organizador: campanhas dele, com atalho para editar a rota do ônibus -->
<@main.layout title="Minhas campanhas - Rota Solidária" css="/css/organizador.css" currentNav="organizador">
  <main class="container">
    <div class="org-head">
      <span class="kicker">Área do organizador</span>
      <h1>Minhas campanhas</h1>
      <p>Crie campanhas e defina por onde o ônibus passa: partida, paradas e hemocentro.</p>
      <div class="org-head__acoes">
        <a class="btn btn-primary" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Nova campanha</a>
      </div>
    </div>

    <#if campanhas?has_content>
      <ul class="org-list">
        <#list campanhas as c>
          <li class="org-card">
            <div class="org-card__info">
              <div class="org-card__top">
                <#if c.status == "OPEN">
                  <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
                <#elseif c.status == "CLOSED">
                  <span class="badge badge-closed"><span class="dot"></span>Inscrições encerradas</span>
                <#else>
                  <span class="badge badge-closed"><span class="dot"></span>Cancelada</span>
                </#if>
              </div>
              <h2>${c.title}</h2>
              <div class="org-card__meta">
                <span><span class="icon" aria-hidden="true">calendar_month</span><#if c.eventDate??>${c.eventDateBr}<#else>Data a definir</#if></span>
                <span><span class="icon" aria-hidden="true">route</span>
                  <#if c.departureLocation??>${c.departureLocation.city!c.departureLocation.name}<#else>Partida a definir</#if>
                  → <#if c.stops?has_content>${c.stops?size} <#if c.stops?size == 1>parada<#else>paradas</#if> → </#if>
                  ${(c.donationLocation.city)!"Hemocentro"}
                </span>
              </div>
            </div>
            <div class="org-card__actions">
              <a class="btn btn-secondary" href="/campanhas/${c.id?c}">Ver página</a>
              <a class="btn btn-secondary" href="/organizador/campanhas/${c.id?c}/divulgar"><span class="icon" aria-hidden="true">share</span>Divulgar</a>
              <a class="btn btn-primary" href="/organizador/campanhas/${c.id?c}/editar"><span class="icon" aria-hidden="true">edit</span>Editar</a>
            </div>
          </li>
        </#list>
      </ul>
    <#else>
      <div class="panel org-empty">
        <p>Você ainda não tem campanhas cadastradas.</p>
        <a class="btn btn-primary" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Criar a primeira campanha</a>
      </div>
    </#if>
  </main>
</@main.layout>
