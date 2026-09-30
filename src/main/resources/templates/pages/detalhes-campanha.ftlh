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
  <span class="route__voce"><span class="icon" aria-hidden="true">person_pin_circle</span>${texto}</span>
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

          <#if campanha.description??>
            <p class="detail-description">${campanha.description}</p>
          </#if>

          <div class="info-grid">
            <div class="info-box">
              <span class="icon-box"><span class="icon">schedule</span></span>
              <div>
                <div class="info-title">
                  <#if campanha.eventDate??>${campanha.eventDateBr}</#if>
                </div>
                <div class="info-sub">
                  <#if campanha.departureTime??>Saída ${campanha.departureTime}h · </#if>
                  <#if campanha.donationTime??>Doação ${campanha.donationTimeTexto}h</#if>
                </div>
              </div>
            </div>

            <#if campanha.donationLocation??>
              <div class="info-box">
                <span class="icon-box"><span class="icon">place</span></span>
                <div>
                  <div class="info-title">${campanha.donationLocation.name}</div>
                  <#-- Rua, número e bairro são opcionais no cadastro da rota -->
                  <#assign dl = campanha.donationLocation>
                  <#assign endereco = []>
                  <#if dl.street??><#assign endereco += [dl.street + (dl.number??)?then(", " + dl.number!"", "")]></#if>
                  <#if dl.neighborhood??><#assign endereco += [dl.neighborhood]></#if>
                  <#if dl.city??><#assign endereco += [dl.city + (dl.state??)?then(" - " + dl.state!"", "")]></#if>
                  <div class="info-sub">${endereco?join(" — ")}</div>
                </div>
              </div>
            </#if>

            <div class="info-box">
              <#if campanha.meeting>
                <span class="icon-box"><span class="icon">directions_car</span></span>
                <div>
                  <div class="info-title">Encontro no local</div>
                  <div class="info-sub">Sem transporte: você vai por conta própria</div>
                </div>
              <#else>
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
              </#if>
            </div>
          </div>

          <section class="route" aria-labelledby="route-title">
            <span class="kicker">Como chegar</span>
            <h2 id="route-title"><#if campanha.meeting>Encontro no hemocentro<#else>O ônibus leva você até o hemocentro</#if></h2>
            <#if meuEmbarqueNome??>
              <p class="route__meu"><span class="icon" aria-hidden="true">confirmation_number</span><span>Seu embarque: <strong>${meuEmbarqueNome}</strong><#if meuEmbarqueHorario??> às <strong class="mono">${meuEmbarqueHorario}</strong></#if></span></p>
            <#elseif vouDireto??>
              <p class="route__meu"><span class="icon" aria-hidden="true">directions_car</span><span>Você vai por conta própria<#if campanha.donationTime??>: encontro no hemocentro às <strong class="mono">${campanha.donationTimeTexto}</strong></#if></span></p>
            </#if>
            <ol class="route__stops<#if campanha.stops?has_content> route__stops--multi</#if>">
              <#if !campanha.meeting>
              <#assign meu = ehMeuEmbarque(campanha.departureLocation!)>
              <li class="route__stop<#if meu> route__stop--meu</#if>"<@pontoMapa local=campanha.departureLocation! tipo="inicio" meu=meu horario=(campanha.departureTime?string)!""/>>
                <span class="route__dot route__dot--start"><span class="icon" aria-hidden="true">directions_bus</span></span>
                <div class="route__text">
                  <span class="route__time"><#if campanha.departureTime??>Saída ${campanha.departureTime}<#else>Horário a confirmar</#if></span>
                  <strong>Partida</strong>
                  <#if campanha.departureLocation??>
                    <span>${campanha.departureLocation.name}<#if campanha.departureLocation.city??>, ${campanha.departureLocation.city}</#if></span>
                  <#else>
                    <span>Na sua cidade — o organizador confirma o ponto</span>
                  </#if>
                  <#if meu><@seloVoce/></#if>
                </div>
              </li>
              <#list campanha.stops as parada>
                <#assign meu = ehMeuEmbarque(parada.location)>
                <li class="route__stop route__stop--mid<#if meu> route__stop--meu</#if>"<@pontoMapa local=parada.location tipo="parada" rotulo=parada?counter meu=meu horario=(parada.stopTimeTexto)!""/>>
                  <span class="route__dot route__dot--stop" aria-hidden="true">${parada?counter}</span>
                  <div class="route__text">
                    <span class="route__time"><#if parada.stopTime??>${parada.stopTimeTexto}<#else>Horário a confirmar</#if></span>
                    <strong>Parada ${parada?counter}</strong>
                    <span>${parada.location.name}<#if parada.location.city??>, ${parada.location.city}</#if></span>
                    <#if meu><@seloVoce/></#if>
                  </div>
                </li>
              </#list>
              </#if>
              <li class="route__stop route__stop--end<#if vouDireto??> route__stop--meu</#if>"<@pontoMapa local=campanha.donationLocation! tipo="fim" meu=vouDireto?? horario=(campanha.donationTimeTexto)!""/>>
                <span class="route__dot route__dot--end"><span class="icon" aria-hidden="true">bloodtype</span></span>
                <div class="route__text">
                  <span class="route__time"><#if campanha.donationTime??>Doação ${campanha.donationTimeTexto}<#else>Horário a confirmar</#if></span>
                  <strong>Hemocentro</strong>
                  <#if campanha.donationLocation??>
                    <span>${campanha.donationLocation.name}<#if campanha.donationLocation.city??>, ${campanha.donationLocation.city}</#if></span>
                  </#if>
                  <#if vouDireto??><@seloVoce texto="Você vai direto"/></#if>
                </div>
              </li>
            </ol>
            <#if campanha.algumHorarioEstimado>
              <p class="route__nota"><span class="icon" aria-hidden="true">schedule</span>Horários com ≈ são estimados pela rota; confirme com o organizador.</p>
            </#if>
            <div class="route__map" data-rota-mapa-bloco>
              <div class="rota-mapa" data-rota-mapa=".route__stop[data-lat]" data-rota-resumo="#rota-resumo" role="region" aria-label="Mapa com o trajeto do ônibus e os hemocentros de SP"></div>
              <div class="route__legenda">
                <span class="rota-mapa-legenda" id="rota-resumo" aria-live="polite"></span>
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

          <div class="notice-box">
            <span class="icon">info</span>
            <p><strong>Organizado por:</strong>
              <#if campanha.organizer??>${campanha.organizer.institution!"Organizador"} (${campanha.organizer.name})<#else>Organizador Regional</#if>.
            </p>
          </div>

          <div class="checklist-title"><#if campanha.meeting>Antes de ir<#else>Antes de embarcar</#if></div>
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
