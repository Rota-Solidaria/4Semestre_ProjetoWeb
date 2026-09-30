<#import "../layout/main.ftlh" as main>

<@main.layout title="Campanhas - Rota Solidária" css="/css/campanhas.css" currentNav="campanhas">
  <main>
    <section class="page-hero">
      <div class="container">
        <span class="kicker">Agenda regional</span>
        <h1>Campanhas na região</h1>
        <p>Filtre por cidade, distância e transporte disponível para encontrar a coleta mais próxima de você.</p>
        <#if ehOrganizador!false>
          <div class="hero-organizador">
            <a class="hero-organizador__botao" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Criar campanha</a>
            <a class="hero-organizador__link" href="/organizador/campanhas">Ver minhas campanhas</a>
          </div>
        </#if>
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
            <#-- Já inscrito: selo com o código, como a pessoa chega e dois atalhos (bilhete e campanha).
                 O cartão deixa de ser um link só, porque um link não pode conter outros links. -->
            <#assign minha = (minhasInscricoes[c.id?c])!>
            <#if minha?has_content>
              <div class="list-row list-row--inscrito">
            <#else>
              <a class="list-row" href="/campanhas/${c.id?c}">
            </#if>
              <img src="${c.imageUrl!"/images/doacaodesangue.jpeg"}" alt="${c.title}">
              <div>
                <div class="row-top">
                  <#if minha?has_content>
                    <span class="badge badge-inscrito"><span class="icon" aria-hidden="true">confirmation_number</span>Você está inscrito</span>
                    <span class="row-vagas">${minha.code}</span>
                  <#else>
                    <#if c.status == "OPEN">
                      <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
                    <#elseif c.status == "CLOSED">
                      <span class="badge badge-closed"><span class="dot"></span>Encerrada</span>
                    <#else>
                      <span class="badge badge-closed"><span class="dot"></span>Cancelada</span>
                    </#if>
                    <span class="row-vagas">${c.slots!0} vagas</span>
                  </#if>
                </div>
                <h3>${c.title}</h3>
                <div class="row-meta">
                  <#if c.eventDate??>
                    <span><span class="icon">schedule</span>${c.eventDateBr} <#if c.donationTime??>· ${c.donationTime}h</#if></span>
                  </#if>
                  <#if c.donationLocation??>
                    <span><span class="icon">place</span>${c.donationLocation.name} — ${c.donationLocation.city}</span>
                  </#if>
                  <#if minha?has_content>
                    <span class="row-meta__meu"><span class="icon"><#if c.meeting>pin_drop<#else>directions_bus</#if></span>${minhasChegadas[c.id?c]}</span>
                  <#elseif c.meeting>
                    <span><span class="icon">pin_drop</span>Encontro no local</span>
                  <#else>
                    <span><span class="icon">directions_bus</span>Transporte gratuito</span>
                  </#if>
                </div>
              </div>
            <#if minha?has_content>
                <div class="row-ctas">
                  <a class="row-cta cta-primary" href="/inscricoes/${minha.id?c}"><span class="icon" aria-hidden="true">confirmation_number</span>Ver meu bilhete</a>
                  <a class="row-cta cta-secondary" href="/campanhas/${c.id?c}">Ver campanha</a>
                </div>
              </div>
            <#else>
                <span class="row-cta cta-primary">Ver campanha</span>
              </a>
            </#if>
          </#list>
        <#else>
          <p class="empty-list-msg">Nenhuma campanha aberta no momento.</p>
        </#if>
      </div>

      <div class="pagination">
        <span class="page-btn current">1</span>
        <span class="page-btn">2</span>
      </div>
    </div>
  </main>
</@main.layout>
