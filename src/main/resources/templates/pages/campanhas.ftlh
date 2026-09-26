<#import "../layout/main.ftlh" as main>

<@main.layout title="Campanhas - Rota Solidária" css="/css/campanhas.css" currentNav="campanhas">
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
            <a class="list-row" href="/campanhas/${c.id}">
              <img src="/images/doacaodesangue.jpeg" alt="${c.title}">
              <div>
                <div class="row-top">
                  <span class="badge badge-open"><span class="dot"></span>${c.status}</span>
                  <span class="row-vagas">${c.slots!0} vagas</span>
                </div>
                <h3>${c.title}</h3>
                <div class="row-meta">
                  <#if c.eventDate??>
                    <span><span class="icon">schedule</span>${c.eventDate} <#if c.donationTime??>· ${c.donationTime}h</#if></span>
                  </#if>
                  <#if c.donationLocation??>
                    <span><span class="icon">place</span>${c.donationLocation.name} — ${c.donationLocation.city}</span>
                  </#if>
                  <span><span class="icon">directions_bus</span>Transporte gratuito</span>
                </div>
              </div>
              <span class="row-cta cta-primary">Ver campanha</span>
            </a>
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
