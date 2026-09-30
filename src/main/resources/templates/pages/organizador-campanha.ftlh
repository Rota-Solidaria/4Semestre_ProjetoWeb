<#import "../layout/main.ftlh" as main>

<#-- Nova campanha / editar campanha: dados da campanha + rota do ônibus com mapa.
     campanha ausente = nova campanha. -->

<#-- Um ponto da rota. p é um PontoForm (ou {} para a parada nova do <template>);
     prefixo é o nome no formulário: partida, paradas[0], destino...
     static/js/rota-editor.js cuida do CEP, da busca do endereço, do pin e da renumeração das paradas. -->
<#macro ponto p prefixo tipo titulo sub horarioRotulo rotulo="">
  <#assign inscritos = (p.inscritos)!0>
  <section class="ponto ponto--${tipo}" data-ponto data-tipo="${tipo}" data-inscritos="${inscritos?c}">
    <div class="ponto__head">
      <span class="ponto__pin" aria-hidden="true" data-pino><#if tipo == "inicio"><span class="icon">directions_bus</span><#elseif tipo == "fim"><span class="icon">bloodtype</span><#else>${rotulo}</#if></span>
      <div class="ponto__titulo">
        <strong data-titulo>${titulo}</strong>
        <span>${sub}</span>
      </div>
      <#if tipo == "parada">
        <div class="ponto__acoes">
          <button type="button" class="icon-btn" data-acao="subir" aria-label="Mover parada para cima"><span class="icon" aria-hidden="true">arrow_upward</span></button>
          <button type="button" class="icon-btn" data-acao="descer" aria-label="Mover parada para baixo"><span class="icon" aria-hidden="true">arrow_downward</span></button>
          <button type="button" class="icon-btn" data-acao="remover" aria-label="Remover parada"<#if inscritos gt 0> disabled title="Há doadores inscritos nesta parada"</#if>><span class="icon" aria-hidden="true">delete</span></button>
        </div>
      </#if>
    </div>

    <input type="hidden" data-campo="locationId" name="${prefixo}.locationId" value="${(p.locationId?c)!""}">
    <input type="hidden" data-campo="lat" name="${prefixo}.lat" value="${(p.lat?c)!""}">
    <input type="hidden" data-campo="lng" name="${prefixo}.lng" value="${(p.lng?c)!""}">

    <#if tipo == "fim">
      <#-- Preenchido por rota-editor.js com static/data/hemocentros-sp.json (fica oculto se a lista não carregar) -->
      <div class="catalogo" data-catalogo hidden>
        <label class="campo">
          <span class="campo__rotulo">Hemocentros do estado de SP</span>
          <select data-catalogo-lista>
            <option value="">Escolha na lista…</option>
          </select>
        </label>
        <span class="catalogo__dica">Não encontrou? Digite o endereço nos campos abaixo. <span data-catalogo-fonte></span></span>
      </div>
    </#if>

    <div class="campos">
      <label class="campo campo--4">
        <span class="campo__rotulo">Nome do local</span>
        <input type="text" data-campo="nome" name="${prefixo}.nome" value="${(p.nome)!""}" maxlength="140" required
               placeholder="<#if tipo == "fim">Ex.: Hemocentro de São Paulo<#else>Ex.: Praça Matriz</#if>">
      </label>
      <label class="campo campo--2">
        <span class="campo__rotulo">${horarioRotulo}</span>
        <input type="time" data-campo="horario" name="${prefixo}.horario" value="<#if (p.horario)??>${p.horario}</#if>">
      </label>
      <label class="campo campo--2">
        <span class="campo__rotulo">CEP</span>
        <input type="text" class="mono" data-campo="cep" name="${prefixo}.cep" value="${(p.cep)!""}" inputmode="numeric" maxlength="9" placeholder="00000-000" autocomplete="off">
      </label>
      <label class="campo campo--3">
        <span class="campo__rotulo">Rua</span>
        <input type="text" data-campo="rua" name="${prefixo}.rua" value="${(p.rua)!""}" maxlength="200">
      </label>
      <label class="campo campo--1">
        <span class="campo__rotulo">Nº</span>
        <input type="text" data-campo="numero" name="${prefixo}.numero" value="${(p.numero)!""}" maxlength="10">
      </label>
      <label class="campo campo--2 campo--m6">
        <span class="campo__rotulo">Bairro</span>
        <input type="text" data-campo="bairro" name="${prefixo}.bairro" value="${(p.bairro)!""}" maxlength="80">
      </label>
      <label class="campo campo--3">
        <span class="campo__rotulo">Cidade</span>
        <input type="text" data-campo="cidade" name="${prefixo}.cidade" value="${(p.cidade)!""}" maxlength="80" required>
      </label>
      <label class="campo campo--1">
        <span class="campo__rotulo">UF</span>
        <input type="text" data-campo="uf" name="${prefixo}.uf" value="${(p.uf)!""}" maxlength="2" autocomplete="off" style="text-transform:uppercase">
      </label>
      <label class="campo">
        <span class="campo__rotulo">Ponto de referência <span class="muted">(opcional)</span></span>
        <input type="text" data-campo="referencia" name="${prefixo}.referencia" value="${(p.referencia)!""}" maxlength="200" placeholder="Ex.: em frente à igreja">
      </label>
    </div>

    <div class="ponto__rodape">
      <span class="ponto__status" data-status aria-live="polite"></span>
      <div class="ponto__botoes">
        <#if inscritos gt 0>
          <span class="ponto__inscritos"><span class="icon" aria-hidden="true">group</span>${inscritos} <#if inscritos == 1>inscrito embarca<#else>inscritos embarcam</#if> aqui</span>
        </#if>
        <button type="button" class="btn btn-secondary btn-sm" data-acao="localizar"><span class="icon" aria-hidden="true">search</span>Localizar</button>
        <button type="button" class="btn btn-secondary btn-sm" data-acao="marcar"><span class="icon" aria-hidden="true">add_location_alt</span>Marcar no mapa</button>
      </div>
    </div>
  </section>
</#macro>

<#assign novo = !(campanha??)>
<#assign statusRotulos = {"OPEN": "Inscrições abertas", "CLOSED": "Inscrições encerradas", "CANCELLED": "Cancelada"}>

<@main.layout title="${novo?then('Nova campanha', 'Editar campanha')} - Rota Solidária" css="/css/organizador.css" mapa=true scripts=["/js/rota-editor.js"]>
  <main class="container">
    <a class="back-link" href="/organizador/campanhas"><span class="icon" aria-hidden="true">arrow_back</span>Minhas campanhas</a>
    <div class="org-head">
      <span class="kicker">Área do organizador</span>
      <h1><#if novo>Nova campanha<#else>${campanha.title}</#if></h1>
      <p>Preencha os dados da campanha e monte a rota do ônibus até o hemocentro.</p>
    </div>

    <form class="campanha-form" id="rota-form" method="post" action="<#if novo>/organizador/campanhas/nova<#else>/organizador/campanhas/${campanha.id?c}/editar</#if>">
      <#include "../includes/csrf.ftlh">

      <section class="form-card" aria-labelledby="sec-dados">
        <h2 id="sec-dados"><span class="form-card__num" aria-hidden="true">1</span>Dados da campanha</h2>
        <div class="campos">
          <label class="campo">
            <span class="campo__rotulo">Título</span>
            <input type="text" name="titulo" value="${form.titulo!""}" maxlength="140" required placeholder="Ex.: Caravana Solidária de Outubro">
          </label>
          <label class="campo">
            <span class="campo__rotulo">Descrição <span class="muted">(opcional)</span></span>
            <textarea name="descricao" rows="3" maxlength="2000" placeholder="Conte para os doadores o objetivo da campanha.">${form.descricao!""}</textarea>
          </label>
          <label class="campo campo--2">
            <span class="campo__rotulo">Data</span>
            <input type="date" name="data" value="<#if form.data??>${form.data}</#if>" required<#if novo> min="${.now?string('yyyy-MM-dd')}"</#if>>
          </label>
          <label class="campo campo--2">
            <span class="campo__rotulo">Vagas no ônibus</span>
            <input type="number" name="vagas" value="<#if form.vagas??>${form.vagas?c}</#if>" min="${(form.inscritos gt 0)?then(form.inscritos?c, '1')}" max="999" required>
            <#if form.inscritos gt 0><span class="campo__dica">${form.inscritos} <#if form.inscritos == 1>doador inscrito<#else>doadores inscritos</#if></span></#if>
          </label>
          <#if novo>
            <div class="campo campo--2">
              <span class="campo__rotulo">Situação</span>
              <span class="campo__fixo"><span class="dot" aria-hidden="true"></span>Inscrições abertas</span>
            </div>
          <#else>
            <label class="campo campo--2">
              <span class="campo__rotulo">Situação</span>
              <select name="status">
                <#list statusOpcoes as st>
                  <option value="${st}"<#if form.status?? && form.status?string == st?string> selected</#if>>${statusRotulos[st?string]}</option>
                </#list>
              </select>
            </label>
          </#if>
        </div>

        <fieldset class="imagens">
          <legend class="campo__rotulo">Imagem da campanha</legend>
          <div class="imagens__grade">
            <#list imagens as img>
              <label class="imagem-opcao">
                <input type="radio" name="imagemUrl" value="${img}"<#if (form.imagemUrl!"") == img> checked</#if>>
                <img src="${img}" alt="Foto ${img?counter}">
              </label>
            </#list>
          </div>
          <label class="campo">
            <span class="campo__rotulo">Ou o link de outra imagem <span class="muted">(opcional, substitui a foto escolhida)</span></span>
            <input type="url" name="imagemLink" value="${form.imagemLink!""}" maxlength="255" placeholder="https://…">
          </label>
        </fieldset>
      </section>

      <div class="rota-head">
        <h2><span class="form-card__num" aria-hidden="true">2</span>Rota do ônibus</h2>
        <p>Digite o CEP e o número: o endereço é preenchido e o ponto aparece no mapa. Se precisar, arraste o pin para o lugar exato.</p>
      </div>

      <div class="rota-editor">
        <div class="rota-form">
          <@ponto p=form.partida prefixo="partida" tipo="inicio" titulo="Partida" sub="Onde o ônibus sai" horarioRotulo="Saída às"/>

          <div class="paradas" id="paradas"><#list form.paradas as parada><@ponto p=parada prefixo="paradas[${parada?index}]" tipo="parada" titulo="Parada ${parada?counter}" sub="O ônibus passa e pega mais doadores" horarioRotulo="Passa às" rotulo="${parada?counter}"/></#list></div>

          <button type="button" class="add-parada" id="add-parada"><span class="icon" aria-hidden="true">add</span>Adicionar parada</button>

          <@ponto p=form.destino prefixo="destino" tipo="fim" titulo="Hemocentro" sub="Onde acontece a doação" horarioRotulo="Doação às"/>
        </div>

        <aside class="rota-editor__mapa" id="editor-mapa-bloco" aria-label="Mapa da rota">
          <div class="rota-mapa" id="editor-mapa"></div>
          <span class="rota-mapa-legenda" id="editor-resumo" aria-live="polite"></span>
          <p class="rota-editor__dica"><span class="icon" aria-hidden="true">touch_app</span><span id="editor-dica">Arraste um pin para ajustar a posição, ou use “Marcar no mapa” e clique no lugar.</span></p>
        </aside>
      </div>

      <div class="campanha-form__salvar">
        <#if !novo><a class="btn btn-ghost" href="/campanhas/${campanha.id?c}">Ver página da campanha</a></#if>
        <a class="btn btn-secondary" href="/organizador/campanhas">Cancelar</a>
        <button type="submit" class="btn btn-primary"><span class="icon" aria-hidden="true">check</span><#if novo>Criar campanha<#else>Salvar alterações</#if></button>
      </div>
    </form>

    <template id="tpl-parada"><@ponto p={} prefixo="paradas[0]" tipo="parada" titulo="Parada" sub="O ônibus passa e pega mais doadores" horarioRotulo="Passa às"/></template>
  </main>
</@main.layout>
