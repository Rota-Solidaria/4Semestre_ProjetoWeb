<#import "../layout/main.ftlh" as main>

<@main.layout title="Rota Solidária" css="/css/index.css" currentNav="inicio">
  <main>
    <section class="hero">
      <div class="container hero-grid">
        <div>
          <span class="kicker">Doação de sangue · Angatuba e região</span>
          <h1>Doe sangue, salve vidas perto de você.</h1>
          <p>Encontre a próxima coleta na sua região, veja se há transporte gratuito e garanta sua vaga em poucos minutos.</p>
        </div>

        <div class="hero-image">
          <img src="/images/doacaodesangue.jpeg" alt="Pessoa realizando doação de sangue">

          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-head">
          <div>
            <span class="kicker">Agenda de coleta</span>
            <h2>Próximas campanhas confirmadas</h2>
            <p>Ordenadas pela distância até Angatuba.</p>
          </div>
          <a class="btn btn-secondary" href="/campanhas">Ver todas<span class="icon">arrow_forward</span></a>
        </div>

        <div class="grid">
          <#if campanhas?? && campanhas?size gt 0>
            <#list campanhas as c>
              <#if c?index lt 6>
                <#if c.status == "OPEN">
                  <a class="card" href="/campanhas/${c.id}">
                    <div class="card-img"><img src="${c.imageUrl!'/images/doacaodesangue.jpeg'}" alt="${c.title}"></div>
                    <div class="card-body">
                      <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
                      <h3>${c.title}</h3>
                      <div class="meta">
                        <#if c.eventDate??>
                          <span><span class="icon">schedule</span>${c.eventDate}<#if c.departureTime??> · Saída ${c.departureTime}h<#elseif c.donationTime??> · ${c.donationTime}h</#if></span>
                        </#if>
                        <#if c.donationLocation??>
                          <span><span class="icon">place</span>${c.donationLocation.name}<#if c.donationLocation.city??> — ${c.donationLocation.city}</#if></span>
                        </#if>
                        <span><span class="icon">directions_bus</span>Transporte gratuito</span>
                      </div>
                      <span class="card-cta cta-primary">Inscrever-se</span>
                    </div>
                  </a>
                <#else>
                  <div class="card is-closed">
                    <div class="card-img"><img src="${c.imageUrl!'/images/doacaodesangue.jpeg'}" alt="${c.title}"></div>
                    <div class="card-body">
                      <span class="badge badge-closed"><span class="dot"></span>Finalizada</span>
                      <h3>${c.title}</h3>
                      <div class="meta">
                        <#if c.eventDate??>
                          <span><span class="icon">schedule</span>${c.eventDate}<#if c.departureTime??> · Saída ${c.departureTime}h<#elseif c.donationTime??> · ${c.donationTime}h</#if></span>
                        </#if>
                        <#if c.donationLocation??>
                          <span><span class="icon">place</span>${c.donationLocation.name}<#if c.donationLocation.city??> — ${c.donationLocation.city}</#if></span>
                        </#if>
                        <span><span class="icon">directions_bus</span>Transporte gratuito</span>
                      </div>
                      <span class="card-cta cta-disabled">Encerrada</span>
                    </div>
                  </div>
                </#if>
              </#if>
            </#list>
          <#else>
            <p style="grid-column: 1 / -1; padding: 2rem; text-align: center; color: var(--text3);">Nenhuma campanha aberta no momento.</p>
          </#if>
        </div>
      </div>
    </section>
    <section class="section past-section">
      <div class="container">
        <div class="section-head">
          <div>
            <span class="kicker">Nossa história</span>
            <h2>Excursões anteriores</h2>
            <p>Confira alguns momentos das campanhas realizadas pela Rota Solidária.</p>
          </div>
        </div>

        <div class="past-grid">
          <div class="past-card">
            <img src="/images/excursoes/foto-01.jpeg" alt="Participantes da excursão para doação de sangue">
            <div class="past-info">
              <strong>Mutirão Solidário de Abril</strong>
              <span>03 de Abril · Sorocaba</span>
            </div>
          </div>

          <div class="past-card">
            <img src="/images/excursoes/foto-02.jpg" alt="Grupo reunido durante uma campanha de doação">
            <div class="past-info">
              <strong>Campanha de Março</strong>
              <span>15 de Março · Sorocaba</span>
            </div>
          </div>

          <div class="past-card">
            <img src="/images/excursoes/foto-03.jpg" alt="Participantes durante uma excursão">
            <div class="past-info">
              <strong>Campanha de Fevereiro</strong>
              <span>20 de Fevereiro · Sorocaba</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>
</@main.layout>
