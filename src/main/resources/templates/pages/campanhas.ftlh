<#import "../layout/main.ftlh" as main>

<@main.layout title="Campanhas - Rota Solidária" css="/css/campanhas.css" currentNav="campanhas" mapa=true scripts=["/js/home-mapa.js"]>
  <main>
    <section class="campanhas-page vh-section">
      <div class="container">
        <!-- Cabeçalho compacto integrado -->
        <div class="campanhas-head">
          <div class="campanhas-head__text">
            <span class="kicker">Agenda regional</span>
            <h1>Campanhas na região</h1>
            <p>Filtre por cidade, trajeto ou hemocentro e garanta sua vaga com transporte gratuito.</p>
          </div>
          <#if ehOrganizador!false>
            <div class="campanhas-head__actions">
              <a class="btn btn-primary" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Criar campanha</a>
              <a class="btn btn-secondary" href="/organizador/campanhas">Minhas campanhas</a>
            </div>
          </#if>
        </div>

        <!-- Painel do mapa para visualização das caravanas na região -->
        <div class="campanhas-mapa-container">
          <div class="home-mapa__painel<#if !caravanas?has_content> is-vazio</#if>" data-home-mapa data-sem-localizacao<#if !caravanas?has_content> data-vazio</#if>>
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
                  <p class="muted" data-status-texto>Escolha a cidade de onde você sai ou use a busca.</p>
                <#else>
                  <span class="kicker" data-status-kicker>Nenhuma caravana aberta agora</span>
                  <h2 data-status-titulo>Você ainda pode doar direto num hemocentro</h2>
                  <p class="muted" data-status-texto>Toque numa gota no mapa para ver o endereço. Quando abrir uma caravana, ela aparece aqui.</p>
                </#if>
              </div>

              <#if caravanas?has_content>
                <!-- Campo de busca centralizado no painel lateral ao lado do mapa -->
                <div class="home-busca">
                  <label class="search-field home-busca__campo">
                    <span class="icon" aria-hidden="true">search</span>
                    <input type="search" placeholder="Buscar por cidade, trajeto ou hemocentro..." data-busca-caravanas aria-label="Buscar caravanas">
                    <button type="button" class="search-clear-btn" data-limpa-busca aria-label="Limpar busca" hidden>
                      <span class="icon" aria-hidden="true">close</span>
                    </button>
                  </label>
                </div>

                <!-- Opções de cidade movidas para CIMA das campanhas -->
                <div class="home-cidades" data-home-cidades hidden>
                  <span class="home-cidades__titulo">Cidades de embarque:</span>
                  <div class="home-cidades__lista" data-cidades-lista></div>
                </div>

                <!-- Lista de caravanas -->
                <ul class="caravanas" data-caravanas>
                  <#list caravanas as cv>
                    <#assign c = cv.campanha>
                    <#assign minha = (minhasInscricoes[c.id?c])!>
                    <li class="caravana<#if cv.lotada> is-lotada</#if>" data-caravana data-id="${c.id}"
                        <#if c.donationLocation?? && c.donationLocation.hasCoordinates()>data-destino="${c.donationLocation.name}" data-destino-lat="${c.donationLocation.latitude?c}" data-destino-lng="${c.donationLocation.longitude?c}"</#if>>
                      <a class="caravana__link" href="/campanhas/${c.id}">
                        <span class="caravana__topo">
                          <span class="caravana__quando">${c.eventDateBr!}<#if c.departureTimeTexto??> · ${c.departureTimeTexto}</#if></span>
                          <#if minha?has_content>
                            <span class="badge badge-open"><span class="icon" aria-hidden="true">confirmation_number</span>Inscrito</span>
                          <#elseif cv.lotada>
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
                        <span class="caravana__cta"><#if cv.lotada>Ver detalhes<#else>Ver campanha</#if><span class="icon" aria-hidden="true">arrow_forward</span></span>
                      </a>
                      <#list cv.embarques as e>
                        <span hidden data-embarque data-cidade="${e.cidade}" data-nome="${e.nome}" data-lat="${e.latitude?c}" data-lng="${e.longitude?c}" data-horario="${e.horario}"></span>
                      </#list>
                    </li>
                  </#list>
                </ul>

                <div class="caravanas-vazia" data-caravanas-vazia hidden>
                  <span class="icon" aria-hidden="true">search_off</span>
                  <p>Nenhuma caravana encontrada com esse termo.</p>
                </div>
              <#else>
                <ul class="hemocentros-perto" data-hemocentros-perto hidden></ul>
              </#if>
            </div>
          </div>
        </div>

      </div>
    </section>
  </main>
</@main.layout>
