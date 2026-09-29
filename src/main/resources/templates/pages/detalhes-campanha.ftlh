<#import "../layout/main.ftlh" as main>

<@main.layout title="Detalhes da Campanha" css="/css/detalhes-campanha.css" currentNav="campanhas">
  <main>
    <div class="container section detail-section">
      <a class="back-link" href="/campanhas"><span class="icon">arrow_back</span>Voltar para campanhas</a>

      <div class="detail-card">
        <div class="detail-img">
          <img src="/images/doacaodesangue.jpeg" alt="${campanha.title}">
        </div>
        <div class="detail-body">
          <div class="detail-top">
            <#if campanha.status == "OPEN">
              <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
            <#elseif campanha.status == "CLOSED">
              <span class="badge badge-closed"><span class="dot"></span>Inscrições encerradas</span>
            <#else>
              <span class="badge badge-closed"><span class="dot"></span>Campanha cancelada</span>
            </#if>
            <span class="row-vagas detail-vagas-count">${vagasRestantes} de ${campanha.slots!0} vagas disponíveis</span>
          </div>

          <h1>${campanha.title}</h1>

          <#if campanha.description??>
            <p class="detail-description">${campanha.description}</p>
          </#if>

          <div class="info-grid">
            <div class="info-box">
              <span class="icon-box"><span class="icon">schedule</span></span>
              <div>
                <div class="info-title">
                  <#if campanha.eventDate??>${campanha.eventDate}</#if>
                </div>
                <div class="info-sub">
                  <#if campanha.departureTime??>Saída ${campanha.departureTime}h · </#if>
                  <#if campanha.donationTime??>Doação ${campanha.donationTime}h</#if>
                </div>
              </div>
            </div>

            <#if campanha.donationLocation??>
              <div class="info-box">
                <span class="icon-box"><span class="icon">place</span></span>
                <div>
                  <div class="info-title">${campanha.donationLocation.name}</div>
                  <div class="info-sub">
                    ${campanha.donationLocation.street}, ${campanha.donationLocation.number}
                    <#if campanha.donationLocation.neighborhood??> — ${campanha.donationLocation.neighborhood}</#if>,
                    ${campanha.donationLocation.city} - ${campanha.donationLocation.state}
                  </div>
                </div>
              </div>
            </#if>

            <div class="info-box">
              <span class="icon-box"><span class="icon">directions_bus</span></span>
              <div>
                <div class="info-title">Transporte gratuito</div>
                <div class="info-sub">
                  <#if campanha.departureLocation??>
                    Embarque em: ${campanha.departureLocation.name}
                  <#else>
                    Embarque na sua cidade
                  </#if>
                </div>
              </div>
            </div>
          </div>

          <section class="route" aria-labelledby="route-title">
            <span class="kicker">Como chegar</span>
            <h2 id="route-title">O ônibus leva você até o hemocentro</h2>
            <ol class="route__stops">
              <li class="route__stop">
                <span class="route__dot route__dot--start"><span class="icon" aria-hidden="true">directions_bus</span></span>
                <div class="route__text">
                  <span class="route__time"><#if campanha.departureTime??>Saída ${campanha.departureTime}<#else>Horário a confirmar</#if></span>
                  <strong>Embarque</strong>
                  <#if campanha.departureLocation??>
                    <span>${campanha.departureLocation.name}<#if campanha.departureLocation.city??>, ${campanha.departureLocation.city}</#if></span>
                  <#else>
                    <span>Na sua cidade — o organizador confirma o ponto</span>
                  </#if>
                </div>
              </li>
              <li class="route__stop route__stop--end">
                <span class="route__dot route__dot--end"><span class="icon" aria-hidden="true">bloodtype</span></span>
                <div class="route__text">
                  <span class="route__time"><#if campanha.donationTime??>Doação ${campanha.donationTime}<#else>Horário a confirmar</#if></span>
                  <strong>Hemocentro</strong>
                  <#if campanha.donationLocation??>
                    <span>${campanha.donationLocation.name}<#if campanha.donationLocation.city??>, ${campanha.donationLocation.city}</#if></span>
                  </#if>
                </div>
              </li>
            </ol>
          </section>

          <div class="notice-box">
            <span class="icon">info</span>
            <p><strong>Organizado por:</strong>
              <#if campanha.organizer??>${campanha.organizer.institution!"Organizador"} (${campanha.organizer.name})<#else>Organizador Regional</#if>.
            </p>
          </div>

          <div class="checklist-title">Antes de embarcar</div>
          <ul class="checklist">
            <li><span class="icon">check_circle</span>Documento oficial com foto, original</li>
            <li><span class="icon">check_circle</span>Alimentação leve até 4 horas antes</li>
            <li><span class="icon">check_circle</span>Mínimo de 6 horas de sono</li>
            <li><span class="icon">check_circle</span>Entre 16 e 69 anos e acima de 50 kg</li>
          </ul>

          <div class="detail-actions">
            <#if minhaInscricao??>
              <a class="btn btn-primary btn-lg" href="/inscricoes/${minhaInscricao.id?c}"><span class="icon">confirmation_number</span>Ver meu bilhete</a>
            <#elseif campanha.status != "OPEN" || vagasRestantes lte 0>
              <span class="btn btn-primary btn-lg btn-disabled" aria-disabled="true"><#if vagasRestantes lte 0>Vagas esgotadas<#else>Inscrições encerradas</#if></span>
            <#else>
              <a class="btn btn-primary btn-lg" href="/campanhas/${campanha.id}/inscrever">Fazer inscrição<span class="icon">arrow_forward</span></a>
            </#if>
            <a class="btn btn-secondary btn-lg" href="/campanhas">Ver outras campanhas</a>
          </div>
        </div>
      </div>

      <p class="more-link">Tem dúvidas se você pode doar? <a href="/educativo">Confira os requisitos básicos.</a></p>
    </div>
  </main>
</@main.layout>
