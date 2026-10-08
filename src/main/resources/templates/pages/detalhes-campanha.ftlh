<#import "../layout/main.ftlh" as main>

<#-- Atributos do ponto usados pelo mapa (static/js/rota-mapa.js); ?c evita a vírgula decimal do pt-BR -->
<#macro pontoMapa tipo local="" rotulo="" meu=false horario="">
  <#if local?has_content && local.hasCoordinates()> data-lat="${local.latitude?c}" data-lng="${local.longitude?c}" data-nome="${local.name}" data-tipo="${tipo}" data-rotulo="${rotulo}"<#if horario?has_content> data-horario="${horario}"</#if><#if meu> data-meu="true"</#if></#if>
</#macro>

<#-- O doador logado embarca neste local? (meuEmbarqueId vem do CampaignController) -->
<#function ehMeuEmbarque local>
  <#return meuEmbarqueId?? && local?has_content && local.id?? && local.id == meuEmbarqueId>
</#function>

<#macro seloVoce texto="Você embarca aqui">
  <span class="route__voce">${texto}</span>
</#macro>

<@main.layout title="Detalhes da Campanha" css="/css/detalhes-campanha.css" currentNav="campanhas" mapa=true>
  <main>
    <div class="container section detail-section">
      <a class="back-link" href="/campanhas"><span class="icon">arrow_back</span>Voltar para campanhas</a>

      <div class="detail-card">
        <div class="detail-img">
          <img src="${campanha.imageUrl!"/images/doacaodesangue.jpeg"}" alt="${campanha.title}">
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
          <p class="detail-org">Organizado por <#if campanha.organizer??><#if campanha.organizer.institution?has_content && campanha.organizer.name?has_content>${campanha.organizer.institution} (${campanha.organizer.name})<#else>${campanha.organizer.institution!campanha.organizer.name!"Organizador"}</#if><#else>Organizador Regional</#if></p>

          <#if campanha.description??>
            <p class="detail-description">${campanha.description}</p>
          </#if>

          <div class="campaign-itinerary-card">
            <div class="itinerary-summary">
              <div class="itinerary-item">
                <span class="itinerary-label">Data e horários</span>
                <div class="info-title">
                  <#if campanha.eventDate??>${campanha.eventDateBr}</#if>
                </div>
                <div class="info-sub">
                  <#if campanha.departureTime??>Saída ${campanha.departureTime}h · </#if>
                  <#if campanha.donationTime??>Doação ${campanha.donationTimeTexto}h</#if>
                </div>
              </div>

              <#if campanha.donationLocation??>
                <div class="itinerary-item">
                  <span class="itinerary-label">Local da doação</span>
                  <div class="info-title">${campanha.donationLocation.name}</div>
                  <#-- Rua, número e bairro são opcionais no cadastro da rota -->
                  <#assign dl = campanha.donationLocation>
                  <#assign endereco = []>
                  <#if dl.street??><#assign endereco += [dl.street + (dl.number??)?then(", " + dl.number!"", "")]></#if>
                  <#if dl.neighborhood??><#assign endereco += [dl.neighborhood]></#if>
                  <#if dl.city??><#assign endereco += [dl.city + (dl.state??)?then(" - " + dl.state!"", "")]></#if>
                  <div class="info-sub">${endereco?join(" — ")}</div>
                </div>
              </#if>

              <div class="itinerary-item">
                <span class="itinerary-label">Embarque</span>
                <div class="info-title">
                  <#if campanha.departureLocation??>
                    ${campanha.departureLocation.name}
                  <#else>
                    Cidade de partida
                  </#if>
                </div>
                <div class="info-sub">Ponto inicial da viagem</div>
              </div>
            </div>

            <section class="route" aria-labelledby="route-title">
              <h2 id="route-title">Rota do transporte</h2>
              <#if meuEmbarqueNome??>
                <p class="route__meu"><span>Seu embarque: <strong>${meuEmbarqueNome}</strong><#if meuEmbarqueHorario??> às <strong class="mono">${meuEmbarqueHorario}</strong></#if></span></p>
              </#if>
              <ol class="route__stops<#if campanha.stops?has_content> route__stops--multi</#if>">
                <#assign meu = ehMeuEmbarque(campanha.departureLocation!)>
                <li class="route__stop<#if meu> route__stop--meu</#if>"<@pontoMapa local=campanha.departureLocation! tipo="inicio" meu=meu horario=(campanha.departureTime?string)!""/>>
                  <span class="route__dot route__dot--start"><span class="icon" aria-hidden="true">directions_bus</span></span>
                  <div class="route__text">
                    <span class="route__time"><#if campanha.departureTime??>${campanha.departureTime}<#else>A confirmar</#if></span>
                    <strong>${(campanha.departureLocation.city)!((campanha.departureLocation.name)!"Partida")}</strong>
                    <#if campanha.departureLocation?? && campanha.departureLocation.name != (campanha.departureLocation.city!"")>
                      <span>${campanha.departureLocation.name}</span>
                    </#if>
                    <#if meu><@seloVoce/></#if>
                  </div>
                </li>
                <#list campanha.stops as parada>
                  <#assign meu = ehMeuEmbarque(parada.location)>
                  <li class="route__stop route__stop--mid<#if meu> route__stop--meu</#if>"<@pontoMapa local=parada.location tipo="parada" rotulo=parada?counter meu=meu horario=(parada.stopTimeTexto)!""/>>
                    <span class="route__dot route__dot--stop" aria-hidden="true">${parada?counter}</span>
                    <div class="route__text">
                      <span class="route__time"><#if parada.stopTime??>${parada.stopTimeTexto}<#else>A confirmar</#if></span>
                      <strong>${(parada.location.city)!(parada.location.name)}</strong>
                      <#if parada.location.name != (parada.location.city!"")>
                        <span>${parada.location.name}</span>
                      </#if>
                      <#if meu><@seloVoce/></#if>
                    </div>
                  </li>
                </#list>
                <li class="route__stop route__stop--end"<@pontoMapa local=campanha.donationLocation! tipo="fim" meu=false horario=(campanha.donationTimeTexto)!""/>>
                  <span class="route__dot route__dot--end"><span class="icon" aria-hidden="true">bloodtype</span></span>
                  <div class="route__text">
                    <span class="route__time"><#if campanha.donationTime??>${campanha.donationTimeTexto}<#else>A confirmar</#if></span>
                    <strong>${(campanha.donationLocation.city)!((campanha.donationLocation.name)!"Hemocentro")}</strong>
                    <#if campanha.donationLocation?? && campanha.donationLocation.name != (campanha.donationLocation.city!"")>
                      <span>${campanha.donationLocation.name}</span>
                    </#if>
                  </div>
                </li>
              </ol>
              <#if campanha.algumHorarioEstimado>
                <p class="route__nota">Horários com ≈ são estimados pela rota; confirme com o organizador.</p>
              </#if>
              <div class="route__map" data-rota-mapa-bloco>
                <div class="rota-mapa" data-rota-mapa=".route__stop[data-lat]" role="region" aria-label="Mapa com o trajeto do ônibus e os hemocentros de SP"></div>
                <div class="route__legenda">
                  <ul class="route__simbolos" aria-label="Legenda do mapa">
                    <li><span class="simbolo simbolo--partida" aria-hidden="true"></span>Partida</li>
                    <#if campanha.stops?has_content><li><span class="simbolo simbolo--parada" aria-hidden="true"></span>Parada</li></#if>
                    <#if meuEmbarqueNome??><li><span class="simbolo simbolo--meu" aria-hidden="true"></span>Seu embarque</li></#if>
                    <li><span class="simbolo simbolo--hemocentro" aria-hidden="true"></span>Hemocentro da campanha</li>
                    <li><span class="simbolo simbolo--outros" aria-hidden="true"></span>Outros hemocentros</li>
                    <#if meuEmbarqueNome?? && !(campanha.departureLocation?? && meuEmbarqueId?? && campanha.departureLocation.id == meuEmbarqueId)><li><span class="simbolo simbolo--antes" aria-hidden="true"></span>Antes do seu embarque</li></#if>
                  </ul>
                </div>
              </div>
            </section>
          </div>

          <div class="detail-actions">
            <#if minhaInscricao??>
              <a class="btn btn-primary btn-lg" href="/inscricoes/${minhaInscricao.id?c}">Ver inscrição</a>
            <#elseif campanha.status != "OPEN" || vagasRestantes lte 0>
              <span class="btn btn-primary btn-lg btn-disabled" aria-disabled="true"><#if vagasRestantes lte 0>Vagas esgotadas<#else>Inscrições encerradas</#if></span>
            <#else>
              <a class="btn btn-primary btn-lg" href="/campanhas/${campanha.id}/inscrever">Fazer inscrição</a>
            </#if>
          </div>
        </div>
      </div>

      <p class="more-link">Tem dúvidas se você pode doar? <a href="/educativo">Confira os requisitos básicos.</a></p>
    </div>
  </main>
</@main.layout>
