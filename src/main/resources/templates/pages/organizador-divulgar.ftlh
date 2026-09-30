<#import "../layout/main.ftlh" as main>

<#-- Bilhete da campanha para divulgar (depois de publicar, ou pelo botão "Divulgar" em Minhas campanhas).
     Computador: o bilhete à esquerda (com o mapa no canhoto) e o painel "Divulgue" com a imagem pronta.
     Celular: o próprio bilhete é a imagem que vai para as redes.
     A imagem (story, post ou cartaz) é desenhada no navegador por static/js/divulgar.js. -->

<#macro pontoMapa tipo local="" rotulo="">
  <#if local?has_content && local.hasCoordinates()><li data-lat="${local.latitude?c}" data-lng="${local.longitude?c}" data-nome="${local.name}" data-tipo="${tipo}" data-rotulo="${rotulo}"></li></#if>
</#macro>

<#assign partida = campanha.departureLocation!>
<#assign destino = campanha.donationLocation!>
<#assign cidadePartida = (partida?has_content)?then(partida.city!partida.name!"", "Sua cidade")>
<#assign cidadeDestino = (destino?has_content)?then(destino.city!destino.name!"", "Hemocentro")>

<@main.layout title="Divulgar campanha - Rota Solidária" css="/css/organizador.css" currentNav="organizador" mapa=true scripts=["https://cdnjs.cloudflare.com/ajax/libs/qrcode-generator/1.4.4/qrcode.min.js", "/js/divulgar.js"]>
  <main class="container divulgar" id="divulgar"
        data-link="${linkPublico}"
        data-titulo="${campanha.title}"
        data-partida="${cidadePartida}"
        data-destino="${cidadeDestino}"
        data-hemocentro="${(destino.name)!""}"
        data-data="${campanha.eventDateBr!""}"
        data-saida="<#if campanha.departureTime??>${campanha.departureTime}</#if>"
        data-doacao="${campanha.donationTimeTexto!""}"
        data-vagas="${(campanha.slots!0)?c}"
        data-paradas="${paradasTexto}">

    <div class="divulgar-topo">
      <#if campanha.status == "OPEN">
        <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
      <#else>
        <span class="badge badge-closed"><span class="dot"></span>Inscrições encerradas</span>
      </#if>
      <h1><#if celebrar??>Campanha publicada!<#else>Divulgue a campanha</#if></h1>
      <p>Este é o bilhete da caravana. <span class="divulgar-so-computador">Ao lado, ele já virou uma imagem pronta para as redes.</span><span class="divulgar-so-celular">A imagem abaixo é o que vai para as redes.</span></p>
    </div>

    <div class="divulgar-grade">
      <section class="divulgar-bilhete" aria-label="Bilhete da campanha">
        <article class="bilhete">
          <div class="bilhete__principal">
            <span class="bilhete__sobre">${campanha.title}</span>
            <div class="bilhete__rota">
              <div><span class="bilhete__rotulo">Saída</span><strong>${cidadePartida}</strong></div>
              <div class="bilhete__caminho" aria-hidden="true"><span></span><span class="icon">directions_bus</span><span></span></div>
              <div class="bilhete__fim"><span class="bilhete__rotulo">Doação</span><strong>${cidadeDestino}</strong></div>
            </div>
            <dl class="bilhete__dados">
              <div><dt>Data</dt><dd>${campanha.eventDateBr!"A definir"}</dd></div>
              <div><dt>Saída</dt><dd><#if campanha.departureTime??>${campanha.departureTime}<#else>—</#if></dd></div>
              <div><dt>Doação</dt><dd>${campanha.donationTimeTexto!"—"}</dd></div>
              <div><dt>Vagas</dt><dd>${(campanha.slots!0)?c}</dd></div>
            </dl>
            <#if campanha.stops?has_content>
              <#-- Duas paradas na mesma cidade: mostra também o nome do local para diferenciar -->
              <#assign cidadesParadas = []>
              <#list campanha.stops as p><#assign cidadesParadas = cidadesParadas + [p.location.city!p.location.name]></#list>
              <#function cidadeRepetida cidade><#local n = 0><#list cidadesParadas as c><#if c == cidade><#local n = n + 1></#if></#list><#return (n > 1)></#function>
              <div class="bilhete__paradas"><span class="icon" aria-hidden="true">location_on</span><span>Paradas:
                <#list campanha.stops as parada><#assign cidade = parada.location.city!parada.location.name><strong>${cidade}<#if cidadeRepetida(cidade) && parada.location.name != cidade> (${parada.location.name})</#if><#if parada.stopTime??> ${parada.stopTimeTexto}</#if></strong><#sep> · </#sep></#list></span></div>
            </#if>
          </div>
          <div class="bilhete__canhoto">
            <div class="rota-mapa rota-mapa--compacta" data-rota-mapa=".divulgar-pontos li" data-rota-compacto role="img" aria-label="Mapa da rota até o hemocentro"></div>
            <div class="bilhete__hemocentro">
              <span>Hemocentro<#if campanha.donationTime??> · ${campanha.donationTimeTexto}</#if></span>
              <strong>${(destino.name)!"A definir"}</strong>
            </div>
          </div>
        </article>
        <ul class="divulgar-pontos" hidden>
          <@pontoMapa local=partida tipo="inicio"/>
          <#list campanha.stops as parada><@pontoMapa local=parada.location tipo="parada" rotulo=parada?counter/></#list>
          <@pontoMapa local=destino tipo="fim"/>
        </ul>
        <nav class="divulgar-links" aria-label="Próximos passos">
          <a href="/campanhas/${campanha.id?c}">Ver página da campanha</a>
          <a href="/organizador/campanhas/${campanha.id?c}/editar">Editar campanha</a>
          <a href="/organizador/campanhas">Minhas campanhas</a>
        </nav>
      </section>

      <aside class="divulgar-painel" aria-labelledby="divulgar-titulo">
        <div class="divulgar-painel__topo">
          <h2 id="divulgar-titulo">Divulgue</h2>
          <div class="divulgar-formatos" role="group" aria-label="Formato da imagem">
            <button type="button" data-formato="story" aria-pressed="true">Story</button>
            <button type="button" data-formato="post" aria-pressed="false">Post</button>
            <button type="button" data-formato="cartaz" aria-pressed="false">Cartaz</button>
          </div>
        </div>

        <figure class="divulgar-previa" data-formato-atual="story">
          <img id="divulgar-imagem" alt="Imagem da campanha para compartilhar: ${campanha.title}, saída de ${cidadePartida} até ${cidadeDestino}">
          <#-- Por cima da gota desenhada na imagem: a mesma gota, batendo como um coração -->
          <span class="divulgar-previa__gota" data-previa-gota aria-hidden="true"><span class="divulgar-previa__batida"><svg viewBox="0 0 24 24"><path d="M12 2.5c-3.8 4.8-6.5 8.3-6.5 11.7a6.5 6.5 0 0 0 13 0c0-3.4-2.7-6.9-6.5-11.7z"></path></svg></span></span>
          <span class="divulgar-previa__carregando" data-previa-carregando>Montando a imagem…</span>
        </figure>

        <div class="divulgar-acoes">
          <button type="button" class="btn btn-primary btn-lg divulgar-acoes__principal" data-acao="compartilhar"><span class="icon" aria-hidden="true">ios_share</span>Compartilhar imagem</button>
          <div class="divulgar-acoes__grade">
            <a class="btn divulgar-acoes__whatsapp" data-acao="whatsapp" href="#" target="_blank" rel="noopener">WhatsApp</a>
            <button type="button" class="btn btn-secondary" data-acao="baixar"><span class="icon" aria-hidden="true">download</span>Baixar</button>
            <button type="button" class="btn divulgar-acoes__copiar" data-acao="copiar"><span class="icon" aria-hidden="true">content_copy</span><span data-copiar-texto>Copiar link</span></button>
          </div>
          <span class="divulgar-acoes__mais">Também em <a data-acao="facebook" href="#" target="_blank" rel="noopener">Facebook</a> e <a data-acao="x" href="#" target="_blank" rel="noopener">X</a></span>
          <span class="divulgar-acoes__aviso" data-aviso aria-live="polite"></span>
        </div>

        <nav class="divulgar-links divulgar-so-celular" aria-label="Próximos passos">
          <a href="/campanhas/${campanha.id?c}">Ver página</a>
          <a href="/organizador/campanhas/${campanha.id?c}/editar">Editar</a>
          <a href="/organizador/campanhas">Minhas campanhas</a>
        </nav>
      </aside>
    </div>
  </main>
</@main.layout>
