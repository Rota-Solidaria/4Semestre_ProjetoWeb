<#import "../layout/main.ftlh" as main>

<@main.layout title="Bilhete de embarque - Rota Solidária" css="/css/bilhete.css" currentNav="minhas">
  <main class="container">
    <div class="ticket-page">
      <div class="ticket-intro">
        <span class="ticket-status" data-gotas-origem><span class="icon" aria-hidden="true">check_circle</span>Inscrição confirmada</span>
        <#if encontro>
          <h1>Sua presença está confirmada</h1>
          <p>Mostre este bilhete no hemocentro. Ele também fica salvo em Minhas inscrições.</p>
        <#elseif !vaiDeOnibus>
          <h1>Sua inscrição está confirmada</h1>
          <p>Mostre este bilhete no hemocentro. Ele também fica salvo em Minhas inscrições.</p>
        <#else>
          <h1>Sua vaga no ônibus está garantida</h1>
          <p>Mostre este bilhete no embarque. Ele também fica salvo em Minhas inscrições.</p>
        </#if>
      </div>

      <article class="ticket" aria-label="Bilhete de embarque">
        <div class="ticket__main">
          <span class="ticket__overline">${campanha.title}</span>

          <#if encontro>
            <div class="ticket__route ticket__route--encontro">
              <div class="ticket__stop">
                <span class="ticket__label">Encontro no hemocentro</span>
                <strong><#if campanha.donationLocation?? && campanha.donationLocation.city??>${campanha.donationLocation.city}<#else>Hemocentro</#if></strong>
              </div>
              <span class="icon ticket__route-icon" aria-hidden="true">bloodtype</span>
            </div>
          <#else>
            <div class="ticket__route">
              <div class="ticket__stop">
                <span class="ticket__label">Embarque</span>
                <strong>${origem}</strong>
              </div>
              <div class="ticket__path" aria-hidden="true">
                <span class="line"></span><span class="icon">directions_bus</span><span class="line"></span>
              </div>
              <div class="ticket__stop ticket__stop--end">
                <span class="ticket__label">Doação</span>
                <strong><#if campanha.donationLocation?? && campanha.donationLocation.city??>${campanha.donationLocation.city}<#else>Hemocentro</#if></strong>
              </div>
            </div>
          </#if>

          <dl class="ticket__data">
            <div><dt>Data</dt><dd class="mono">${dataBr}</dd></div>
            <#if horarioEmbarque??>
              <div><dt>Embarque</dt><dd class="mono">${horarioEmbarque}</dd></div>
            </#if>
            <div><dt><#if encontro>Horário<#else>Doação</#if></dt><dd class="mono"><#if campanha.donationTime??>${campanha.donationTime}<#else>A definir</#if></dd></div>
            <#if !encontro>
              <div class="span-all"><dt>Ponto de embarque</dt><dd>${inscricao.boardingPoint!"A confirmar com o organizador"}</dd></div>
            </#if>
            <#if campanha.donationLocation??>
              <div class="span-all"><dt>Hemocentro</dt><dd>${campanha.donationLocation.name}</dd></div>
            </#if>
            <div class="span-all"><dt>Doador</dt><dd>${inscricao.donor.name}</dd></div>
          </dl>
        </div>

        <div class="ticket__stub">
          <span class="ticket__label">Código da vaga</span>
          <strong class="ticket__code">${inscricao.code}</strong>
          <span class="ticket__stub-note"><span class="icon" aria-hidden="true">verified</span>Vaga confirmada</span>
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
      </div>

      <div class="prep-box">
        <div class="prep-head"><span class="icon" aria-hidden="true">checklist</span>Preparo para o dia</div>
        <ul>
          <li>Documento oficial com foto, original</li>
          <li>Alimentação leve até 4 horas antes</li>
          <li>Mínimo de 6 horas de sono e boa hidratação</li>
        </ul>
      </div>

      <p class="ticket-note">O organizador da campanha entrará em contato com você pelo WhatsApp informado em até 48 horas.</p>

      <div class="ticket-links">
        <a href="/perfil#inscricoes">Ver minhas inscrições</a>
        <a href="/campanhas/${campanha.id?c}">Detalhes da campanha</a>
        <a href="/educativo">Guia do doador</a>
      </div>
    </div>
  </main>
</@main.layout>
