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
            <span class="badge badge-open"><span class="dot"></span>${campanha.status}</span>
            <span class="row-vagas detail-vagas-count">${campanha.slots!0} vagas disponíveis</span>
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
            <a class="btn btn-primary btn-lg" href="/campanhas/${campanha.id}/inscrever">Fazer inscrição<span class="icon">arrow_forward</span></a>
            <a class="btn btn-secondary btn-lg" href="/campanhas">Ver outras campanhas</a>
          </div>
        </div>
      </div>

      <p class="more-link">Tem dúvidas se você pode doar? <a href="/educativo">Confira os requisitos básicos.</a></p>
    </div>
  </main>
</@main.layout>
