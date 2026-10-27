<#import "../layout/main.ftlh" as main>

<#-- Home: mapa da região com as caravanas abertas. static/js/home-mapa.js pede a localização,
     escolhe a cidade de embarque mais próxima e filtra a lista; sem JS (ou sem mapa) a lista aparece inteira.
     Sem nenhuma caravana aberta, o mapa mostra os hemocentros de SP (static/data/hemocentros-sp.json). -->
<@main.layout title="Rota Solidária · Ônibus gratuito para doar sangue" css="/css/index.css" currentNav="inicio" mapa=true scripts=["/js/home-mapa.js"]>
  <main>
    <section class="hero vh-section">
      <div class="container hero-grid">
        <div class="hero-content">
          <h1>Doe sangue, salve vidas perto de você.</h1>
          <p>Encontre a próxima coleta na sua região e garanta sua vaga com transporte gratuito em poucos minutos.</p>
          <div class="hero-actions">
            <a class="btn btn-primary" href="/campanhas">Ver campanhas <span class="icon">arrow_forward</span></a>
            <a class="btn btn-secondary" href="/educativo">Como doar sangue</a>
          </div>
        </div>

        <div class="hero-image">
          <img src="/images/doacaodesangue.jpeg" alt="Pessoa realizando doação de sangue">
        </div>
      </div>
    </section>

    <section class="section section-campaigns vh-section" id="campanhas-agenda">
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
                          <span><span class="icon">schedule</span>${c.eventDateBr}<#if c.departureTime??> · Saída ${c.departureTime}h<#elseif c.donationTime??> · ${c.donationTimeTexto}h</#if></span>
                        </#if>
                        <#if c.donationLocation??>
                          <span><span class="icon">place</span>${c.donationLocation.name}<#if c.donationLocation.city??> — ${c.donationLocation.city}</#if></span>
                        </#if>
                        <#if c.departureLocation??>
                          <span><span class="icon">directions_bus</span>Saída: ${c.departureLocation.city}</span>
                        </#if>
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
                          <span><span class="icon">schedule</span>${c.eventDateBr}<#if c.departureTime??> · Saída ${c.departureTime}h<#elseif c.donationTime??> · ${c.donationTimeTexto}h</#if></span>
                        </#if>
                        <#if c.donationLocation??>
                          <span><span class="icon">place</span>${c.donationLocation.name}<#if c.donationLocation.city??> — ${c.donationLocation.city}</#if></span>
                        </#if>
                        <#if c.departureLocation??>
                          <span><span class="icon">directions_bus</span>Saída: ${c.departureLocation.city}</span>
                        </#if>
                      </div>
                      <span class="card-cta cta-disabled">Encerrada</span>
                    </div>
                  </div>
                </#if>
              </#if>
            </#list>
          <#else>
            <h1>Encontre onde doar sangue perto de você.</h1>
          </#if>
        </div>
        <#if caravanas?has_content>
          <p>Veja no mapa as caravanas gratuitas da região até o hemocentro e reserve sua vaga em poucos cliques.</p>
        <#else>
          <p>Os hemocentros de São Paulo estão no mapa. Quando abrir uma caravana gratuita, ela aparece aqui.</p>
        </#if>
      </div>
    </section>

    <section class="section past-section vh-section" id="nossa-historia">
      <div class="container">
        <div class="home-mapa__painel<#if !caravanas?has_content> is-vazio</#if>" data-home-mapa<#if !caravanas?has_content> data-vazio</#if>>
          <div class="home-mapa__area" data-home-mapa-bloco>
            <div class="rota-mapa home-mapa__mapa" data-home-mapa-el role="region"
                 aria-label="<#if caravanas?has_content>Mapa com as cidades de onde saem as caravanas<#else>Mapa com os hemocentros do estado de São Paulo</#if>"></div>
            <#if caravanas?has_content>
              <div class="home-legenda" aria-hidden="true">
                <span class="home-legenda__pino">3</span>
                <span>Número = caravanas que embarcam na cidade</span>
              </div>
            </#if>
          </div>

          <div class="home-mapa__lado">
            <div class="home-status" data-home-status aria-live="polite">
              <#if caravanas?has_content>
                <span class="kicker" data-status-kicker>Caravanas abertas</span>
                <h2 data-status-titulo>${caravanas?size} <#if caravanas?size == 1>caravana com inscrições abertas<#else>caravanas com inscrições abertas</#if></h2>
                <p class="muted" data-status-texto>Escolha a cidade de onde você sai.</p>
              <#else>
                <span class="kicker" data-status-kicker>Nenhuma caravana aberta agora</span>
                <h2 data-status-titulo>Você ainda pode doar direto num hemocentro</h2>
                <p class="muted" data-status-texto>Toque numa gota no mapa para ver o endereço. Quando abrir uma caravana, ela aparece aqui.</p>
              </#if>
              <button type="button" class="btn btn-secondary home-status__local" data-usar-local hidden>
                <span class="icon">my_location</span>Usar minha localização
              </button>
            </div>

            <#if caravanas?has_content>
              <ul class="caravanas" data-caravanas>
                <#list caravanas as cv>
                  <#assign c = cv.campanha>
                  <li class="caravana<#if cv.lotada> is-lotada</#if>" data-caravana data-id="${c.id}"
                      <#if c.donationLocation?? && c.donationLocation.hasCoordinates()>data-destino="${c.donationLocation.name}" data-destino-lat="${c.donationLocation.latitude?c}" data-destino-lng="${c.donationLocation.longitude?c}"</#if>>
                    <a class="caravana__link" href="/campanhas/${c.id}">
                      <span class="caravana__topo">
                        <span class="caravana__quando">${c.eventDateBr!}<#if c.departureTimeTexto??> · ${c.departureTimeTexto}</#if></span>
                        <#if cv.lotada>
                          <span class="badge badge-closed"><span class="dot"></span>Lotada</span>
                        <#elseif cv.poucasVagas>
                          <span class="badge badge-few"><span class="dot"></span><#if cv.vagasRestantes == 1>Resta 1 vaga<#else>Restam ${cv.vagasRestantes} vagas</#if></span>
                        <#else>
                          <span class="badge badge-open"><span class="dot"></span>${cv.vagasRestantes} vagas</span>
                        </#if>
                      </span>
                      <strong class="caravana__titulo">${c.title}</strong>
                      <span class="caravana__trajeto">
                        <span class="icon" aria-hidden="true">directions_bus</span>
                        <span><#if c.departureLocation??>${c.departureLocation.city!c.departureLocation.name}<#else>Saída a confirmar</#if><#if c.passaPor?has_content> → ${c.passaPor}</#if><#if c.donationLocation??> → ${c.donationLocation.name}</#if></span>
                      </span>
                      <span class="caravana__perto" data-perto hidden></span>
                      <span class="caravana__cta"><#if cv.lotada>Ver detalhes<#else>Reservar vaga</#if><span class="icon" aria-hidden="true">arrow_forward</span></span>
                    </a>
                    <#list cv.embarques as e>
                      <span hidden data-embarque data-cidade="${e.cidade}" data-nome="${e.nome}" data-lat="${e.latitude?c}" data-lng="${e.longitude?c}" data-horario="${e.horario}"></span>
                    </#list>
                  </li>
                </#list>
              </ul>
              <div class="home-cidades" data-home-cidades hidden>
                <span class="home-cidades__titulo">Outra cidade</span>
                <div class="home-cidades__lista" data-cidades-lista></div>
              </div>
              <a class="home-mapa__todas" href="/campanhas">Ver todas as campanhas<span class="icon" aria-hidden="true">arrow_forward</span></a>
            <#else>
              <ul class="hemocentros-perto" data-hemocentros-perto hidden></ul>
              <a class="btn btn-secondary btn-block" href="/educativo"><span class="icon">menu_book</span>Antes de ir: guia do doador</a>
            </#if>
          </div>
        </div>
      </div>
    </section>

    <section class="home-primeira vh-section">
      <div class="container">
        <div class="home-primeira__faixa">
          <strong>Primeira vez?</strong>
          <ol class="home-primeira__passos">
            <li><span>01</span>Escolha a caravana</li>
            <li><span>02</span>Escolha onde embarcar</li>
            <li><span>03</span>Receba o bilhete no celular</li>
          </ol>
          <a class="home-primeira__link" href="/doar">Como funciona<span class="icon" aria-hidden="true">arrow_forward</span></a>
        </div>
      </div>
    </section>

    <section class="home-fim vh-section">
      <div class="container home-fim__grid">
        <div class="home-impacto">
          <span class="home-impacto__num">até 4 vidas</span>
          <span>podem ser ajudadas por uma doação de sangue.</span>
          <span class="home-impacto__fonte">Ministério da Saúde, 25/11/2023</span>
        </div>
        <a class="home-posso" href="/educativo">
          <strong>Posso doar?</strong>
          <span class="muted">16 a 69 anos, 50 kg ou mais, e 60 dias (homens) ou 90 dias (mulheres) desde a última doação. A triagem no hemocentro dá a palavra final.</span>
          <span class="home-posso__link">Ler o guia do doador<span class="icon" aria-hidden="true">arrow_forward</span></span>
        </a>
      </div>
    </section>
  </main>
</@main.layout>
