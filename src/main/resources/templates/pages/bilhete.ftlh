<#import "../layout/main.ftlh" as main>

<@main.layout title="Informações da Inscrição - Rota Solidária" css="/css/bilhete.css" currentNav="minhas">
  <main class="container">
    <div class="ticket-page">
      <div class="ticket-intro">
        <h1 data-gotas-origem>Informações da Inscrição</h1>
        <p>Confira os detalhes da sua participação nesta campanha de doação.</p>
      </div>

      <article class="ticket" aria-label="Informações da inscrição na campanha">
        <div class="ticket__header">
          <div>
            <span class="ticket__label">Campanha</span>
            <h2 class="ticket__title">${campanha.title}</h2>
          </div>
          <div class="ticket__code-badge">
            <span>Código:</span>
            <strong>${inscricao.code}</strong>
          </div>
        </div>

        <div class="ticket__body">
          <dl class="ticket__data">
            <div>
              <dt>Doador</dt>
              <dd>${inscricao.donor.name}</dd>
            </div>
            <div>
              <dt>Status</dt>
              <dd class="status-confirmed"><span class="icon" aria-hidden="true">check_circle</span>Confirmada</dd>
            </div>
            <div>
              <dt>Data da Doação</dt>
              <dd class="mono">${dataBr}</dd>
            </div>
            <div>
              <dt>Horário da Doação</dt>
              <dd class="mono"><#if campanha.donationTime??>${campanha.donationTimeTexto}<#else>A definir</#if></dd>
            </div>
            <#if campanha.donationLocation??>
              <div class="span-all">
                <dt>Local da Doação (Hemocentro)</dt>
                <dd>${campanha.donationLocation.name}<#if campanha.donationLocation.city??> — ${campanha.donationLocation.city}</#if></dd>
              </div>
            </#if>
            <div class="span-all">
              <dt>Transporte / Ponto de Embarque</dt>
              <dd>${inscricao.boardingPoint!"A confirmar com o organizador"}<#if horarioEmbarque??> · Embarque às ${horarioEmbarque}</#if></dd>
            </div>
          </dl>
        </div>
      </article>

      <div class="ticket-actions">
        <#if wazeUrl??>
          <a class="btn btn-primary btn-lg" href="${wazeUrl}" target="_blank" rel="noopener"><span class="icon" aria-hidden="true">navigation</span>Ir com o Waze</a>
        </#if>
        <a class="btn <#if wazeUrl??>btn-secondary<#else>btn-primary</#if> btn-lg" href="${whatsappUrl}" target="_blank" rel="noopener"><span class="icon" aria-hidden="true">send</span>Enviar no WhatsApp</a>
        <#if campanha.eventDate??>
          <a class="btn btn-secondary btn-lg" href="/inscricoes/${inscricao.id?c}/calendario.ics"><span class="icon" aria-hidden="true">event</span>Adicionar ao calendário</a>
        </#if>
        <a class="btn btn-ghost btn-lg" href="/perfil"><span class="icon" aria-hidden="true">arrow_back</span>Voltar para o perfil</a>
      </div>

    </div>
  </main>
</@main.layout>
