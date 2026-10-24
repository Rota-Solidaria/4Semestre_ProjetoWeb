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
            <p>Filtre por cidade, distância ou hemocentro e garanta sua vaga com transporte gratuito.</p>
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
                        <span class="caravana__cta"><#if cv.lotada>Ver detalhes<#else>Ver campanha</#if><span class="icon" aria-hidden="true">arrow_forward</span></span>
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
              <#else>
                <ul class="hemocentros-perto" data-hemocentros-perto hidden></ul>
              </#if>
            </div>
          </div>
        </div>

        <!-- Título da lista completa -->
        <div class="campanhas-lista-head" id="todas-campanhas">
          <span class="kicker">Catálogo</span>
          <h2>Todas as campanhas da região</h2>
        </div>

        <!-- Barra de busca no padrão do projeto -->
        <form method="get" action="/campanhas#todas-campanhas" class="filter-panel" role="search">
          <label class="search-field">
            <span class="icon" aria-hidden="true">search</span>
            <input type="search" name="q" value="${busca!}" placeholder="Buscar por cidade, local ou organizador" aria-label="Buscar campanhas">
            <#if busca?has_content>
              <a href="/campanhas#todas-campanhas" class="search-clear-btn" aria-label="Limpar busca">
                <span class="icon" aria-hidden="true">close</span>
              </a>
            </#if>
          </label>
          <#if (limite?? && limite != 6)>
            <input type="hidden" name="limite" value="${limite}">
          </#if>
        </form>

        <#if busca?has_content>
          <div class="search-feedback-bar">
            <span>Exibindo resultados para "<strong>${busca}</strong>"</span>
            <a href="/campanhas#todas-campanhas" class="clear-search-link"><span class="icon" aria-hidden="true">close</span> Limpar filtro</a>
          </div>
        </#if>

        <!-- Lista de Campanhas -->
        <div class="list">
          <#if campanhas?? && campanhas?size gt 0>
            <#list campanhas as c>
              <#assign minha = (minhasInscricoes[c.id?c])!>
              <#if minha?has_content>
                <div class="list-row list-row--inscrito">
              <#else>
                <a class="list-row" href="/campanhas/${c.id?c}">
              </#if>
                <img src="${c.imageUrl!"/images/doacaodesangue.jpeg"}" alt="${c.title}">
                <div>
                  <div class="row-top">
                    <#if minha?has_content>
                      <span class="badge badge-inscrito"><span class="icon" aria-hidden="true">confirmation_number</span>Você está inscrito</span>
                      <span class="row-vagas">${minha.code}</span>
                    <#else>
                      <#if c.status == "OPEN">
                        <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
                      <#elseif c.status == "CLOSED">
                        <span class="badge badge-closed"><span class="dot"></span>Encerrada</span>
                      <#else>
                        <span class="badge badge-closed"><span class="dot"></span>Cancelada</span>
                      </#if>
                      <span class="row-vagas">${c.slots!0} vagas</span>
                    </#if>
                  </div>
                  <h3>${c.title}</h3>
                  <div class="row-meta">
                    <#if c.eventDate??>
                      <span><span class="icon">schedule</span>${c.eventDateBr} <#if c.donationTime??>· ${c.donationTimeTexto}h</#if></span>
                    </#if>
                    <#if c.donationLocation??>
                      <span><span class="icon">place</span>${c.donationLocation.name} — ${c.donationLocation.city}</span>
                    </#if>
                    <#if minha?has_content>
                      <span class="row-meta__meu"><span class="icon">directions_bus</span>${minhasChegadas[c.id?c]}</span>
                    <#elseif c.departureLocation??>
                      <span><span class="icon">directions_bus</span>Saída: ${c.departureLocation.city}</span>
                    </#if>
                  </div>
                </div>
              <#if minha?has_content>
                  <div class="row-ctas">
                    <a class="row-cta cta-primary" href="/inscricoes/${minha.id?c}"><span class="icon" aria-hidden="true">assignment</span>Ver inscrição</a>
                    <a class="row-cta cta-secondary" href="/campanhas/${c.id?c}">Ver campanha</a>
                  </div>
                </div>
              <#else>
                  <span class="row-cta cta-primary">Ver campanha</span>
                </a>
              </#if>
            </#list>
          <#else>
            <div class="empty-list-card">
              <span class="icon empty-icon">event_busy</span>
              <p class="empty-list-msg">Nenhuma campanha encontrada<#if busca?has_content> para "${busca}"</#if>.</p>
              <#if busca?has_content>
                <a class="btn btn-secondary" href="/campanhas#todas-campanhas">Ver todas as campanhas</a>
              </#if>
            </div>
          </#if>
        </div>

        <#if (totalPaginas!0) gt 1>
          <nav class="pagination" aria-label="Paginação das campanhas">
            <#if temAnterior!false>
              <a class="page-btn" href="/campanhas?pagina=${paginaAtual - 1}<#if busca?has_content>&q=${busca?url}</#if><#if (limite?? && limite != 6)>&limite=${limite}</#if>#todas-campanhas" aria-label="Página anterior">
                <span class="icon" aria-hidden="true">chevron_left</span>
              </a>
            </#if>

            <#if totalPaginas lte 7>
              <#list 1..totalPaginas as p>
                <#if p == paginaAtual>
                  <span class="page-btn current" aria-current="page">${p}</span>
                <#else>
                  <a class="page-btn" href="/campanhas?pagina=${p}<#if busca?has_content>&q=${busca?url}</#if><#if (limite?? && limite != 6)>&limite=${limite}</#if>#todas-campanhas" aria-label="Página ${p}">${p}</a>
                </#if>
              </#list>
            <#else>
              <#if paginaAtual == 1>
                <span class="page-btn current" aria-current="page">1</span>
              <#else>
                <a class="page-btn" href="/campanhas?pagina=1<#if busca?has_content>&q=${busca?url}</#if><#if (limite?? && limite != 6)>&limite=${limite}</#if>#todas-campanhas" aria-label="Página 1">1</a>
              </#if>

              <#if paginaAtual gt 3>
                <span class="page-ellipsis" aria-hidden="true">…</span>
              </#if>

              <#assign pInicio = (paginaAtual - 1)>
              <#if pInicio lt 2><#assign pInicio = 2></#if>
              <#assign pFim = (paginaAtual + 1)>
              <#if pFim gt (totalPaginas - 1)><#assign pFim = (totalPaginas - 1)></#if>

              <#if pInicio lte pFim>
                <#list pInicio..pFim as p>
                  <#if p == paginaAtual>
                    <span class="page-btn current" aria-current="page">${p}</span>
                  <#else>
                    <a class="page-btn" href="/campanhas?pagina=${p}<#if busca?has_content>&q=${busca?url}</#if><#if (limite?? && limite != 6)>&limite=${limite}</#if>#todas-campanhas" aria-label="Página ${p}">${p}</a>
                  </#if>
                </#list>
              </#if>

              <#if paginaAtual lt (totalPaginas - 2)>
                <span class="page-ellipsis" aria-hidden="true">…</span>
              </#if>

              <#if paginaAtual == totalPaginas>
                <span class="page-btn current" aria-current="page">${totalPaginas}</span>
              <#else>
                <a class="page-btn" href="/campanhas?pagina=${totalPaginas}<#if busca?has_content>&q=${busca?url}</#if><#if (limite?? && limite != 6)>&limite=${limite}</#if>#todas-campanhas" aria-label="Página ${totalPaginas}">${totalPaginas}</a>
              </#if>
            </#if>

            <#if temProxima!false>
              <a class="page-btn" href="/campanhas?pagina=${paginaAtual + 1}<#if busca?has_content>&q=${busca?url}</#if><#if (limite?? && limite != 6)>&limite=${limite}</#if>#todas-campanhas" aria-label="Próxima página">
                <span class="icon" aria-hidden="true">chevron_right</span>
              </a>
            </#if>
          </nav>
        <#elseif (totalElementos!0) gt 0>
          <nav class="pagination" aria-label="Paginação das campanhas">
            <span class="page-btn current" aria-current="page">1</span>
          </nav>
        </#if>
      </div>
    </section>
  </main>
</@main.layout>
