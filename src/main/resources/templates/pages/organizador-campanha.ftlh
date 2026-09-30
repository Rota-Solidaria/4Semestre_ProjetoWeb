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

    <#-- Endereço primeiro (como num app de transporte): o CEP preenche o resto e põe o pino no mapa -->
    <div class="campos">
      <label class="campo campo--2">
        <span class="campo__rotulo campo__rotulo--linha">CEP <a class="campo__ajuda" href="https://buscacepinter.correios.com.br/app/endereco/index.php" target="_blank" rel="noopener">Não sei o CEP</a></span>
        <span class="campo__cep">
          <input type="text" class="mono" data-campo="cep" name="${prefixo}.cep" value="${(p.cep)!""}" inputmode="numeric" maxlength="9" placeholder="00000-000" autocomplete="postal-code">
          <#-- depois do campo no HTML (o clique no rótulo "CEP" vai para o campo), à esquerda na tela -->
          <button type="button" class="campo__lupa" data-acao="buscar-cep" aria-label="Buscar endereço pelo CEP"><span class="icon" aria-hidden="true">search</span></button>
        </span>
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
      <label class="campo campo--4">
        <span class="campo__rotulo">Nome do local</span>
        <input type="text" data-campo="nome" name="${prefixo}.nome" value="${(p.nome)!""}" maxlength="140" required
               placeholder="<#if tipo == "fim">Ex.: Hemocentro de São Paulo<#else>Ex.: Praça Matriz</#if>">
      </label>
      <label class="campo campo--2">
        <span class="campo__rotulo">${horarioRotulo}</span>
        <input type="time" data-campo="horario" name="${prefixo}.horario" value="<#if (p.horario)??>${p.horario}</#if>">
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

<#-- Assistente em 5 passos (static/js/campanha-wizard.js). No computador: passos no topo, mapa à direita;
     no celular: mapa fixo em cima e o passo num painel que sobe por cima dele.
     É um formulário só: o servidor recebe tudo junto ao publicar e valida como antes. -->
<#assign passoInicial = (novo && !(form.titulo?has_content))?then(1, 5)>
<#assign passos = ["Campanha", "Partida", "Paradas", "Hemocentro", "Revisar e publicar"]>

<@main.layout title="${novo?then('Nova campanha', 'Editar campanha')} - Rota Solidária" css="/css/organizador.css" currentNav="organizador" mapa=true scripts=["/js/rota-editor.js", "/js/campanha-wizard.js"]>
  <main class="container wizard" id="wizard" data-passo-inicial="${passoInicial}" data-novo="${novo?c}">
    <div class="wizard-topo">
      <a class="back-link" href="/organizador/campanhas"><span class="icon" aria-hidden="true">arrow_back</span>Minhas campanhas</a>
      <span class="wizard-topo__titulo"><#if novo>Nova campanha<#else>${campanha.title}</#if></span>
    </div>

    <#-- Computador: passos numerados -->
    <nav class="wizard-passos" aria-label="Passos da campanha">
      <ol>
        <#list passos as nome>
          <li>
            <#if nome?counter == 4>
              <#-- Linha antes do passo 5: um batimento cardíaco (o pulso corre até "Revisar e publicar") -->
              <#-- O campanha-wizard.js redesenha o traçado na largura real (viewBox em pixels), para o pulso correr linear -->
              <svg class="wizard-passos__ecg" viewBox="0 0 100 24" preserveAspectRatio="none" aria-hidden="true" data-ecg>
                <path class="wizard-passos__ecg-base" d="M0 12 H58 L62 12 L65 3 L70 21 L74 7 L77 12 H100"></path>
                <path class="wizard-passos__ecg-pulso" d="M0 12 H58 L62 12 L65 3 L70 21 L74 7 L77 12 H100"></path>
              </svg>
            </#if>
            <button type="button" class="wizard-passos__item" data-ir="${nome?counter}">
              <span class="wizard-passos__num" aria-hidden="true">${nome?counter}</span>
              <span class="wizard-passos__nome">${nome}<#if nome == "Paradas"> <span class="muted">(opcional)</span></#if></span>
            </button>
          </li>
        </#list>
      </ol>
    </nav>

    <div class="wizard-rascunho" id="wizard-rascunho" hidden>
      <span class="icon" aria-hidden="true">history</span>
      <span>Você começou uma campanha antes<strong data-rascunho-titulo></strong>. Quer continuar de onde parou?</span>
      <button type="button" class="btn btn-primary btn-sm" data-rascunho="restaurar">Continuar</button>
      <button type="button" class="btn btn-ghost btn-sm" data-rascunho="descartar">Descartar</button>
    </div>

    <form class="campanha-form" id="rota-form" method="post" action="<#if novo>/organizador/campanhas/nova<#else>/organizador/campanhas/${campanha.id?c}/editar</#if>">
      <#include "../includes/csrf.ftlh">

      <div class="wizard-corpo">
        <div class="wizard-folha">
          <#-- Celular: barra de progresso no topo do painel -->
          <div class="wizard-progresso" aria-hidden="true">
            <span class="wizard-progresso__alca"></span>
            <div class="wizard-progresso__linha"><span class="wizard-progresso__barra"><span data-progresso></span></span><span class="wizard-progresso__texto" data-progresso-texto></span></div>
          </div>

          <section class="wizard-passo" data-passo="1" aria-labelledby="passo-1-titulo">
            <span class="kicker" data-kicker>Passo 1 de 5</span>
            <h1 id="passo-1-titulo">Sobre a campanha</h1>
            <p class="wizard-passo__sub">O que os doadores vão ver na lista de campanhas.</p>
            <div class="passo1">
          <div class="form-card">
            <#assign modoAtual = (form.modo!"BUS")?string>
            <#-- Modo da campanha: muda o assistente inteiro (Encontro esconde Partida e Paradas), por isso vem primeiro
                 e cada opção mostra o trajeto e quantos passos terá -->
            <fieldset class="modo" aria-describedby="modo-sub">
              <legend class="modo__titulo">Como os doadores chegam ao hemocentro?</legend>
              <p class="modo__sub" id="modo-sub">Isso define o que você preenche nos próximos passos.</p>
              <div class="modo__opcoes">
                <label class="modo__opcao">
                  <input type="radio" name="modo" value="BUS"<#if modoAtual == "BUS"> checked</#if><#if form.inscritos gt 0> disabled</#if>>
                  <span class="modo__check" aria-hidden="true"><span class="icon">check</span></span>
                  <span class="modo__trajeto modo__trajeto--onibus" aria-hidden="true">
                    <span class="modo__ponto"></span><span class="modo__linha"></span>
                    <span class="modo__parada">1</span><span class="modo__linha"></span>
                    <span class="modo__onibus"><span class="icon">directions_bus</span></span><span class="modo__linha"></span>
                    <span class="modo__gota"></span>
                  </span>
                  <span class="modo__texto">
                    <strong>Ônibus com rota</strong>
                    <span>Você leva os doadores: define a partida, as paradas e o hemocentro.</span>
                  </span>
                  <span class="modo__passos">5 passos · com mapa da rota</span>
                </label>
                <label class="modo__opcao">
                  <input type="radio" name="modo" value="MEETING"<#if modoAtual == "MEETING"> checked</#if><#if form.inscritos gt 0> disabled</#if>>
                  <span class="modo__check" aria-hidden="true"><span class="icon">check</span></span>
                  <span class="modo__trajeto modo__trajeto--encontro" aria-hidden="true">
                    <span class="modo__lado">
                      <span class="modo__chega"><span class="modo__pessoa"></span><span class="modo__linha" style="width:30px"></span></span>
                      <span class="modo__chega"><span class="modo__pessoa"></span><span class="modo__linha" style="width:48px"></span></span>
                    </span>
                    <span class="modo__gota modo__gota--grande"></span>
                    <span class="modo__lado modo__lado--dir">
                      <span class="modo__chega"><span class="modo__linha" style="width:42px"></span><span class="modo__pessoa"></span></span>
                      <span class="modo__chega"><span class="modo__linha" style="width:24px"></span><span class="modo__pessoa"></span></span>
                    </span>
                  </span>
                  <span class="modo__texto">
                    <strong>Encontro no local</strong>
                    <span>Sem transporte: cada doador vai por conta própria até o hemocentro.</span>
                  </span>
                  <span class="modo__passos">3 passos · só o hemocentro</span>
                </label>
              </div>
              <#if form.inscritos gt 0>
                <input type="hidden" name="modo" value="${modoAtual}">
                <span class="campo__dica"><span class="icon" aria-hidden="true">lock</span>Já há doadores inscritos: não dá para mudar entre ônibus e encontro.</span>
              </#if>
            </fieldset>

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
                <span class="campo__rotulo" data-rotulo-vagas>Vagas no ônibus</span>
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
          </div>
              <aside class="previa-doador" aria-label="Prévia: como o doador vai ver">
                <span class="previa-doador__rotulo">Como o doador vai ver</span>
                <article class="previa-doador__cartao">
                  <img class="previa-doador__foto" data-previa="foto" src="${(form.imagemLink?has_content)?then(form.imagemLink!"", form.imagemUrl!"/images/doacaodesangue.jpeg")}" alt="">
                  <div class="previa-doador__corpo">
                    <span class="badge badge-open" data-previa="situacao"><span class="dot"></span>Inscrições abertas</span>
                    <strong class="previa-doador__titulo" data-previa="titulo">${form.titulo!"Título da campanha"}</strong>
                    <span class="previa-doador__meta"><span class="icon" aria-hidden="true">calendar_month</span><span data-previa="data">Data a definir</span> · <span data-previa="vagas">${(form.vagas!40)?c}</span> vagas</span>
                    <p class="previa-doador__descricao" data-previa="descricao"></p>
                    <div class="previa-doador__rota" aria-hidden="true"><span class="previa-doador__ponto"></span><span class="previa-doador__linha"></span><span class="previa-doador__gota"></span></div>
                    <span class="previa-doador__dica">A rota aparece aqui quando você montar a partida e o hemocentro.</span>
                  </div>
                </article>
              </aside>
            </div>
          </section>

          <section class="wizard-passo" data-passo="2" aria-labelledby="passo-2-titulo" hidden>
            <span class="kicker" data-kicker>Passo 2 de 5</span>
            <h1 id="passo-2-titulo">De onde o ônibus sai?</h1>
            <p class="wizard-passo__sub">Comece pelo CEP: o endereço é preenchido e o ponto aparece no mapa.</p>
            <@ponto p=form.partida prefixo="partida" tipo="inicio" titulo="Partida" sub="Onde o ônibus sai" horarioRotulo="Saída às"/>
          </section>

          <section class="wizard-passo" data-passo="3" aria-labelledby="passo-3-titulo" hidden>
            <span class="kicker" data-kicker>Passo 3 de 5</span>
            <h1 id="passo-3-titulo">O ônibus para em mais algum lugar?</h1>
            <p class="wizard-passo__sub">Adicione onde ele pega mais doadores, na ordem do caminho. Se ele vai direto, é só continuar.</p>
            <div class="paradas" id="paradas"><#list form.paradas as parada><@ponto p=parada prefixo="paradas[${parada?index}]" tipo="parada" titulo="Parada ${parada?counter}" sub="O ônibus passa e pega mais doadores" horarioRotulo="Passa às" rotulo="${parada?counter}"/></#list></div>
            <button type="button" class="add-parada" id="add-parada"><span class="icon" aria-hidden="true">add</span>Adicionar parada</button>
          </section>

          <section class="wizard-passo" data-passo="4" aria-labelledby="passo-4-titulo" hidden>
            <span class="kicker" data-kicker>Passo 4 de 5</span>
            <h1 id="passo-4-titulo" data-titulo-bus="Onde acontece a doação?" data-titulo-encontro="Onde as pessoas vão se encontrar?">Onde acontece a doação?</h1>
            <p class="wizard-passo__sub">Escolha um hemocentro de SP na lista (ou clicando na gota do mapa), ou digite o endereço.</p>
            <@ponto p=form.destino prefixo="destino" tipo="fim" titulo="Hemocentro" sub="Onde acontece a doação" horarioRotulo="Doação às"/>
          </section>

          <section class="wizard-passo" data-passo="5" aria-labelledby="passo-5-titulo" hidden>
            <span class="kicker" data-kicker>Passo 5 de 5</span>
            <h1 id="passo-5-titulo"><#if novo>Tudo certo para publicar?<#else>Revise e salve</#if></h1>
            <p class="wizard-passo__sub"><#if novo>Confira antes de abrir as inscrições.<#else>Toque em “Editar” para mudar qualquer parte.</#if></p>
            <div class="revisao" id="revisao" aria-live="polite"></div>
          </section>
        </div>

        <aside class="rota-editor__mapa" id="editor-mapa-bloco" aria-label="Mapa da rota">
          <div class="rota-mapa" id="editor-mapa"></div>
          <span class="rota-mapa-legenda" id="editor-resumo" aria-live="polite"></span>
          <p class="rota-editor__dica"><span class="icon" aria-hidden="true">touch_app</span><span id="editor-dica">Arraste um pino para ajustar a posição, ou use “Marcar no mapa” e clique no lugar.</span></p>
        </aside>
      </div>

      <div class="campanha-form__salvar wizard-rodape">
        <button type="button" class="btn btn-secondary" data-wizard="voltar"><span class="icon" aria-hidden="true">arrow_back</span>Voltar</button>
        <span class="wizard-rodape__info" data-wizard-info><#if !novo><a href="/campanhas/${campanha.id?c}">Ver página da campanha</a></#if></span>
        <button type="button" class="btn btn-primary" data-wizard="avancar"><span data-wizard-proximo>Continuar</span><span class="icon" aria-hidden="true">arrow_forward</span></button>
        <button type="submit" class="btn btn-primary wizard-rodape__publicar" data-wizard="publicar" hidden><span class="icon" aria-hidden="true"><#if novo>bloodtype<#else>check</#if></span><#if novo>Publicar campanha<#else>Salvar alterações</#if></button>
      </div>
    </form>

    <template id="tpl-parada"><@ponto p={} prefixo="paradas[0]" tipo="parada" titulo="Parada" sub="O ônibus passa e pega mais doadores" horarioRotulo="Passa às"/></template>
  </main>
</@main.layout>
