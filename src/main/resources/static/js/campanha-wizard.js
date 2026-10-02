/* Assistente "Nova campanha / Editar campanha" em 5 passos (templates/pages/organizador-campanha.ftlh).
 *   1 Campanha · 2 Partida · 3 Paradas (opcional) · 4 Hemocentro · 5 Revisar e publicar
 * É um formulário só: cada passo é uma seção mostrada por vez, e o servidor recebe tudo ao publicar.
 * - "Continuar" confere os campos do passo antes de avançar; ao publicar, confere todos.
 * - Numa campanha nova, o rascunho fica guardado neste navegador até publicar.
 * - O mapa (rota-editor.js) aparece do passo 2 em diante e destaca o ponto do passo.
 * - No modo Encontro (sem ônibus) os passos 2 e 3 somem: 1 Campanha · 4 Hemocentro · 5 Revisar. */
(function () {
  'use strict';

  var wizard = document.getElementById('wizard');
  var form = document.getElementById('rota-form');
  if (!wizard || !form) { return; }

  var TOTAL = 5; // número do último passo (Revisar)
  var NOMES = ['Campanha', 'Partida', 'Paradas', 'Hemocentro', 'Revisar'];
  // Rótulo do botão de avançar, pelo passo de destino
  var ACOES = ['Voltar à campanha', 'Definir a partida', 'Adicionar paradas', 'Escolher o hemocentro', 'Revisar campanha'];
  var novo = wizard.dataset.novo === 'true';
  var CHAVE_RASCUNHO = 'rs-rascunho-nova-campanha';

  var secoes = Array.prototype.slice.call(form.querySelectorAll('[data-passo]'));
  var botaoVoltar = form.querySelector('[data-wizard="voltar"]');
  var botaoAvancar = form.querySelector('[data-wizard="avancar"]');
  var botaoPublicar = form.querySelector('[data-wizard="publicar"]');
  var textoProximo = form.querySelector('[data-wizard-proximo]');
  var info = form.querySelector('[data-wizard-info]');
  var itensPasso = Array.prototype.slice.call(wizard.querySelectorAll('[data-ir]'));
  var barra = form.querySelector('[data-progresso]');
  var textoProgresso = form.querySelector('[data-progresso-texto]');
  var revisao = document.getElementById('revisao');

  var atual = parseInt(wizard.dataset.passoInicial, 10) || 1;
  var alcancado = novo ? atual : TOTAL; // editando, todos os passos ficam liberados

  /* ---------- Rota obrigatória em 5 passos ---------- */

  function encontro() {
    return false;
  }

  /** Todas as campanhas têm rota de transporte em 5 passos. */
  function ativos() {
    return [1, 2, 3, 4, 5];
  }

  /** Passo vizinho ao passo n (dir = 1 adiante, -1 atrás), ou o próprio n na ponta. */
  function vizinho(n, dir) {
    var lista = ativos();
    var i = lista.indexOf(n);
    if (i < 0) { return n; }
    return lista[Math.max(0, Math.min(lista.length - 1, i + dir))];
  }

  // Validação é feita por passo (os campos dos passos escondidos não podem receber foco)
  form.noValidate = true;

  function semAnimacao() {
    return window.RotaMapa ? RotaMapa.semAnimacao() : false;
  }

  function secao(n) {
    return secoes[n - 1];
  }

  function paradas() {
    return Array.prototype.slice.call(form.querySelectorAll('#paradas [data-ponto]'));
  }

  function editor() {
    return window.RotaEditor;
  }

  /* ---------- Navegação ---------- */

  function irPara(n, opcoes) {
    opcoes = opcoes || {};
    n = Math.max(1, Math.min(TOTAL, n));
    var lista = ativos();
    if (lista.indexOf(n) < 0) { n = lista.filter(function (a) { return a > n; })[0] || TOTAL; }
    var anterior = atual;
    atual = n;
    alcancado = Math.max(alcancado, n);

    secoes.forEach(function (s, i) {
      var visivel = i + 1 === n;
      s.hidden = !visivel;
      s.classList.remove('wizard-passo--entra-frente', 'wizard-passo--entra-tras');
      if (visivel && anterior !== n && !semAnimacao()) {
        void s.offsetWidth;
        s.classList.add(n > anterior ? 'wizard-passo--entra-frente' : 'wizard-passo--entra-tras');
      }
    });
    wizard.dataset.passo = String(n);

    itensPasso.forEach(function (item) {
      var p = parseInt(item.dataset.ir, 10);
      item.classList.toggle('is-atual', p === n);
      item.classList.toggle('is-feito', p < n || (p !== n && p <= alcancado && passoCompleto(p)));
      item.disabled = p > alcancado || lista.indexOf(p) < 0;
      if (p === n) { item.setAttribute('aria-current', 'step'); } else { item.removeAttribute('aria-current'); }
    });

    barra.style.width = ((lista.indexOf(n) + 1) / lista.length * 100) + '%';
    textoProgresso.textContent = (lista.indexOf(n) + 1) + ' de ' + lista.length;

    botaoVoltar.hidden = n === 1;
    botaoAvancar.hidden = n === TOTAL;
    botaoPublicar.hidden = n !== TOTAL;
    textoProximo.textContent = rotuloAvancar(n);

    if (n === TOTAL) { montarRevisao(); }
    ajustarMapa(n);

    if (!opcoes.semRolar) {
      var alvo = window.matchMedia('(max-width: 960px)').matches && n > 1 ? form.querySelector('.wizard-folha') : wizard;
      // Só rola se o topo do passo saiu da tela: rolar a cada "Continuar" cansa e dá a sensação de salto
      var topo = alvo.getBoundingClientRect().top;
      if (topo < 0 || topo > window.innerHeight * 0.4) {
        alvo.scrollIntoView({ behavior: semAnimacao() ? 'auto' : 'smooth', block: 'start' });
      }
    }
    if (opcoes.focar !== false && anterior !== n) {
      var titulo = secao(n).querySelector('h1');
      titulo.setAttribute('tabindex', '-1');
      titulo.focus({ preventScroll: true });
    }
    if (!opcoes.inicial) { salvarRascunho(); }
  }

  function rotuloAvancar(n) {
    if (n >= TOTAL) { return ''; }
    if (n === 3) { return paradas().length ? ACOES[3] : 'Continuar sem paradas'; }
    return ACOES[vizinho(n, 1) - 1];
  }

  /** O mapa aparece do passo 2 em diante; ao entrar num passo de ponto, o pino dele salta. */
  function ajustarMapa(n) {
    var ed = editor();
    if (!ed || n === 1) { return; }
    requestAnimationFrame(function () {
      ed.mapa.map.resize();
      ed.atualizar(true);
      var bloco = n === 2 ? form.querySelector('[data-ponto][data-tipo="inicio"]')
        : n === 4 ? form.querySelector('[data-ponto][data-tipo="fim"]') : null;
      if (bloco && bloco._id) {
        setTimeout(function () {
          ed.mapa.destacar(bloco._id, true);
          setTimeout(function () { ed.mapa.destacar(bloco._id, false); }, 1400);
        }, 700);
      }
    });
  }

  /** Mostra ou esconde os passos de ônibus (2 e 3) e reescreve os textos que dependem do modo. */
  function aplicarModo() {
    var direto = encontro();
    var lista = ativos();

    [2, 3].forEach(function (n) {
      var s = secao(n);
      s.toggleAttribute('data-inativo', direto);
      // Campos desabilitados não são validados nem enviados: o servidor recebe só o que vale no modo
      Array.prototype.forEach.call(s.querySelectorAll('input, select, textarea'), function (c) { c.disabled = direto; });
    });
    itensPasso.forEach(function (item) {
      var p = parseInt(item.dataset.ir, 10);
      var ativo = lista.indexOf(p) >= 0;
      var li = item.closest('li');
      if (li && (p === 2 || p === 3)) { li.hidden = !ativo; }
      item.querySelector('.wizard-passos__num').textContent = String(lista.indexOf(p) + 1 || p);
    });
    secoes.forEach(function (s, i) {
      var k = s.querySelector('[data-kicker]');
      if (k && lista.indexOf(i + 1) >= 0) { k.textContent = 'Passo ' + (lista.indexOf(i + 1) + 1) + ' de ' + lista.length; }
    });

    var titulo = secao(4).querySelector('h1');
    titulo.textContent = direto ? titulo.dataset.tituloEncontro : titulo.dataset.tituloBus;
    var rotuloVagas = form.querySelector('[data-rotulo-vagas]');
    if (rotuloVagas) { rotuloVagas.textContent = direto ? 'Vagas' : 'Vagas no ônibus'; }
    var dicaRota = form.querySelector('.previa-doador__dica');
    if (dicaRota) {
      dicaRota.textContent = direto ? 'Os doadores vão direto ao hemocentro, sem ônibus.'
        : 'A rota aparece aqui quando você montar a partida e o hemocentro.';
    }
    var rota = form.querySelector('.previa-doador__rota');
    if (rota) { rota.hidden = direto; }
  }

  form.addEventListener('change', function (e) {
    if (!e.target.matches || !e.target.matches('input[name="modo"]')) { return; }
    aplicarModo();
    // Se o passo atual sumiu (ex.: estava na partida), irPara leva ao próximo passo que existe
    irPara(atual, { semRolar: true, focar: false, inicial: true });
    atualizarPrevia();
  });

  /* ---------- Validação por passo ---------- */

  function camposDo(n) {
    return Array.prototype.slice.call(secao(n).querySelectorAll('input, select, textarea'))
      .filter(function (c) { return c.name && c.type !== 'hidden'; });
  }

  function passoCompleto(n) {
    return camposDo(n).every(function (c) { return c.checkValidity(); });
  }

  /** Mostra o primeiro campo com problema do passo n. */
  function validar(n) {
    var invalido = camposDo(n).filter(function (c) { return !c.checkValidity(); })[0];
    if (!invalido) { return true; }
    if (atual !== n) { irPara(n, { focar: false }); }
    invalido.reportValidity();
    invalido.focus();
    return false;
  }

  botaoAvancar.addEventListener('click', function () {
    if (validar(atual)) { irPara(vizinho(atual, 1)); }
  });
  botaoVoltar.addEventListener('click', function () { irPara(vizinho(atual, -1)); });
  itensPasso.forEach(function (item) {
    item.addEventListener('click', function () {
      var p = parseInt(item.dataset.ir, 10);
      if (p > atual && !validar(atual)) { return; }
      irPara(p);
    });
  });

  form.addEventListener('submit', function (e) {
    var lista = ativos();
    for (var i = 0; i < lista.length - 1; i++) {
      if (!validar(lista[i])) {
        e.preventDefault();
        return;
      }
    }
    limparRascunho();
  });

  // Enter num campo não publica sem querer: no passo 1 ele avança
  form.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && e.target.matches('input') && atual === 1) {
      e.preventDefault();
      botaoAvancar.click();
    }
  });

  // O rótulo "Continuar sem paradas" muda quando uma parada entra ou sai
  new MutationObserver(function () { textoProximo.textContent = rotuloAvancar(atual); })
    .observe(document.getElementById('paradas'), { childList: true });

  /* ---------- Passo 5: revisão ---------- */

  function valor(el, nome) {
    var c = el.querySelector('[name="' + nome + '"], [data-campo="' + nome + '"]');
    return c ? c.value.trim() : '';
  }

  function dataBr(iso) {
    var p = iso.split('-');
    return p.length === 3 ? p[2] + '/' + p[1] + '/' + p[0] : iso;
  }

  function el(tag, classe, texto) {
    var e = document.createElement(tag);
    if (classe) { e.className = classe; }
    if (texto != null) { e.textContent = texto; }
    return e;
  }

  function linkEditar(passo, rotulo) {
    var b = el('button', 'revisao__editar', rotulo || 'Editar');
    b.type = 'button';
    b.addEventListener('click', function () { irPara(passo); });
    return b;
  }

  function montarRevisao() {
    revisao.textContent = '';

    // Campanha
    var cartao = el('div', 'revisao__cartao');
    var img = form.querySelector('[name="imagemUrl"]:checked');
    var link = valor(form, 'imagemLink');
    if (link || img) {
      var foto = el('img', 'revisao__foto');
      foto.src = link || img.value;
      foto.alt = '';
      cartao.appendChild(foto);
    }
    var textos = el('div', 'revisao__textos');
    textos.appendChild(el('strong', 'revisao__titulo', valor(form, 'titulo') || 'Sem título'));
    var data = valor(form, 'data');
    var vagas = valor(form, 'vagas');
    textos.appendChild(el('span', null, [data ? dataBr(data) : 'Sem data', vagas ? vagas + ' vagas no transporte' : null,
      novo ? 'inscrições abrem ao publicar' : null].filter(Boolean).join(' · ')));
    cartao.appendChild(textos);
    cartao.appendChild(linkEditar(1));
    revisao.appendChild(cartao);

    // Rota
    var rota = el('div', 'revisao__cartao revisao__cartao--rota');
    var topo = el('div', 'revisao__topo');
    topo.appendChild(el('strong', 'revisao__titulo', 'Rota do transporte'));
    rota.appendChild(topo);
    var lista = el('ol', 'revisao__rota');
    var fim = form.querySelector('[data-ponto][data-tipo="fim"]');
    var pontos = [form.querySelector('[data-ponto][data-tipo="inicio"]')].concat(paradas(), [fim]);
    pontos.forEach(function (bloco, i) {
      var tipo = bloco.dataset.tipo;
      var li = el('li', 'revisao__ponto revisao__ponto--' + tipo);
      var hora = valor(bloco, 'horario');
      li.appendChild(el('span', 'revisao__hora mono', hora ? (valor(bloco, 'horarioEstimado') === 'true' ? '≈ ' : '') + hora : '--:--'));
      li.appendChild(el('span', 'revisao__marca', tipo === 'parada' ? String(i) : null));
      var nome = el('span', 'revisao__nome');
      nome.appendChild(el('strong', null, valor(bloco, 'nome') || 'Sem nome'));
      var cidade = valor(bloco, 'cidade');
      if (cidade) { nome.appendChild(document.createTextNode(' · ' + cidade)); }
      li.appendChild(nome);
      li.appendChild(linkEditar(tipo === 'inicio' ? 2 : tipo === 'fim' ? 4 : 3));
      lista.appendChild(li);
    });
    rota.appendChild(lista);
    revisao.appendChild(rota);

    // Conferência
    var semMapa = pontos.filter(function (b) { return !valor(b, 'lat'); }).length;
    var horarios = pontos.map(function (b) { return valor(b, 'horario'); }).filter(Boolean);
    var emOrdem = horarios.every(function (h, i) { return i === 0 || h > horarios[i - 1]; });
    var destino = pontos[pontos.length - 1];
    var itens = direto ? [
      { ok: semMapa === 0, texto: semMapa === 0 ? 'O local está no mapa' : 'O local ainda não está no mapa', passo: 4 },
      { ok: !!valor(destino, 'nome') && !!valor(destino, 'cidade'), texto: valor(destino, 'nome') ? 'Hemocentro definido' : 'Falta escolher o hemocentro', passo: 4 }
    ] : [
      { ok: emOrdem, texto: emOrdem ? 'Horários seguem a ordem da rota' : 'Há um horário fora da ordem da rota', passo: 3 },
      { ok: semMapa === 0, texto: semMapa === 0 ? 'Todos os pontos estão no mapa'
        : semMapa + (semMapa === 1 ? ' ponto ainda não está no mapa' : ' pontos ainda não estão no mapa'), passo: 2 },
      { ok: !!valor(destino, 'nome') && !!valor(destino, 'cidade'), texto: valor(destino, 'nome') ? 'Hemocentro definido' : 'Falta escolher o hemocentro', passo: 4 }
    ];
    var todosOk = itens.every(function (i) { return i.ok; });
    var conferencia = el('ul', 'revisao__conferencia' + (todosOk ? '' : ' revisao__conferencia--aviso'));
    conferencia.setAttribute('aria-label', 'Conferência');
    itens.forEach(function (item) {
      var li = el('li', item.ok ? 'is-ok' : 'is-aviso');
      var icone = el('span', 'icon', item.ok ? 'check_circle' : 'error');
      icone.setAttribute('aria-hidden', 'true');
      li.appendChild(icone);
      li.appendChild(el('span', null, item.texto));
      if (!item.ok) { li.appendChild(linkEditar(item.passo, 'Corrigir')); }
      conferencia.appendChild(li);
    });
    revisao.appendChild(conferencia);
  }

  /* ---------- Passo 1: prévia "como o doador vai ver" ---------- */

  var previa = {};
  Array.prototype.forEach.call(form.querySelectorAll('[data-previa]'), function (e) { previa[e.dataset.previa] = e; });

  function atualizarPrevia() {
    if (!previa.titulo) { return; }
    previa.titulo.textContent = valor(form, 'titulo') || 'Título da campanha';
    var data = valor(form, 'data');
    previa.data.textContent = data ? dataBr(data) : 'Data a definir';
    previa.vagas.textContent = valor(form, 'vagas') || '0';
    var descricao = valor(form, 'descricao');
    previa.descricao.textContent = descricao.length > 140 ? descricao.slice(0, 137) + '…' : descricao;
    previa.descricao.hidden = !descricao;
    var link = valor(form, 'imagemLink');
    var escolhida = form.querySelector('[name="imagemUrl"]:checked');
    var foto = /^https?:\/\//i.test(link) ? link : escolhida ? escolhida.value : '';
    if (foto && previa.foto.getAttribute('src') !== foto) { previa.foto.src = foto; }
    var status = form.querySelector('[name="status"]');
    if (status) {
      var aberta = status.value === 'OPEN';
      previa.situacao.className = 'badge ' + (aberta ? 'badge-open' : 'badge-closed');
      previa.situacao.lastChild.textContent = status.options[status.selectedIndex].text;
    }
  }

  secao(1).addEventListener('input', atualizarPrevia);
  secao(1).addEventListener('change', atualizarPrevia);
  // Link de imagem quebrado: volta para a foto escolhida
  if (previa.foto) {
    previa.foto.addEventListener('error', function () {
      var escolhida = form.querySelector('[name="imagemUrl"]:checked');
      if (escolhida && previa.foto.getAttribute('src') !== escolhida.value) { previa.foto.src = escolhida.value; }
    });
  }

  /* ---------- Rascunho (só campanha nova, neste navegador) ---------- */

  var timerRascunho = null;
  var restaurando = false;

  function lerRascunho() {
    try { return JSON.parse(localStorage.getItem(CHAVE_RASCUNHO) || 'null'); } catch (e) { return null; }
  }

  function limparRascunho() {
    try { localStorage.removeItem(CHAVE_RASCUNHO); } catch (e) { /* navegação privada */ }
  }

  function salvarRascunho() {
    if (!novo || restaurando) { return; }
    clearTimeout(timerRascunho);
    timerRascunho = setTimeout(function () {
      var campos = {};
      Array.prototype.forEach.call(form.elements, function (c) {
        if (!c.name || c.name === '_csrf' || c.type === 'submit' || c.type === 'button') { return; }
        if (c.type === 'radio') { if (c.checked) { campos[c.name] = c.value; } return; }
        campos[c.name] = c.value;
      });
      try {
        localStorage.setItem(CHAVE_RASCUNHO, JSON.stringify({ campos: campos, paradas: paradas().length, passo: atual }));
        info.textContent = 'Rascunho guardado neste navegador';
      } catch (e) { /* sem espaço ou navegação privada: segue sem rascunho */ }
    }, 600);
  }

  function restaurar(rascunho) {
    restaurando = true;
    var adicionar = document.getElementById('add-parada');
    for (var i = paradas().length; i < rascunho.paradas; i++) { adicionar.click(); }
    Object.keys(rascunho.campos).forEach(function (nome) {
      var campos = form.querySelectorAll('[name="' + nome.replace(/"/g, '') + '"]');
      Array.prototype.forEach.call(campos, function (c) {
        if (c.type === 'radio') { c.checked = c.value === rascunho.campos[nome]; } else { c.value = rascunho.campos[nome]; }
      });
    });
    restaurando = false;
    aplicarModo();
    atualizarPrevia();
    if (editor()) { editor().atualizar(true); }
    irPara(Math.min(rascunho.passo || 1, TOTAL));
  }

  function oferecerRascunho() {
    var aviso = document.getElementById('wizard-rascunho');
    var rascunho = lerRascunho();
    if (!novo || !aviso || !rascunho || atual !== 1 || !rascunho.campos) { return; }
    var titulo = rascunho.campos.titulo;
    aviso.querySelector('[data-rascunho-titulo]').textContent = titulo ? ' (“' + titulo + '”)' : '';
    aviso.hidden = false;
    aviso.querySelector('[data-rascunho="restaurar"]').addEventListener('click', function () {
      aviso.hidden = true;
      restaurar(rascunho);
    });
    aviso.querySelector('[data-rascunho="descartar"]').addEventListener('click', function () {
      aviso.hidden = true;
      limparRascunho();
    });
  }

  form.addEventListener('input', salvarRascunho);
  form.addEventListener('change', salvarRascunho);

  /* ---------- Batimento antes do passo 5 ----------
   * O SVG é redesenhado na largura real (viewBox em pixels, escala 1:1): assim o pulso tracejado corre
   * linear pela linha, sem a distorção que o SVG esticado causava no tracejado. */
  function ajustarEcg() {
    Array.prototype.forEach.call(wizard.querySelectorAll('[data-ecg]'), function (svg) {
      var largura = Math.round(svg.clientWidth);
      if (largura < 60) { return; } // escondido (celular) ou sem espaço
      var s = Math.round(largura * 0.62); // início do pico, 44 px de largura
      var d = 'M0 12 H' + s + ' L' + (s + 6) + ' 12 L' + (s + 12) + ' 3 L' + (s + 22) + ' 21 L' + (s + 31) + ' 7 L' + (s + 38) + ' 12 H' + largura;
      svg.setAttribute('viewBox', '0 0 ' + largura + ' 24');
      var pulso = null;
      Array.prototype.forEach.call(svg.querySelectorAll('path'), function (caminho) {
        caminho.setAttribute('d', d);
        if (caminho.classList.contains('wizard-passos__ecg-pulso')) { pulso = caminho; }
      });
      if (pulso) { pulso.style.setProperty('--ecg-len', Math.ceil(pulso.getTotalLength() + 2)); }
    });
  }
  var timerEcg = null;
  window.addEventListener('resize', function () {
    if (timerEcg) { cancelAnimationFrame(timerEcg); }
    timerEcg = requestAnimationFrame(ajustarEcg);
  });
  ajustarEcg();

  aplicarModo();
  atualizarPrevia();
  irPara(atual, { semRolar: true, focar: false, inicial: true });
  oferecerRascunho();
})();
