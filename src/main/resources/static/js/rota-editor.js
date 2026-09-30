/* Editor da rota do ônibus (templates/pages/organizador-rota.ftlh).
 * Fluxo de cada ponto, como num app de transporte:
 *   1. CEP com 8 dígitos → ViaCEP preenche rua, bairro, cidade e UF (grátis, sem chave);
 *   2. endereço completo → Nominatim/OpenStreetMap acha a coordenada e coloca o pin (grátis, 1 busca por segundo);
 *   3. opcional: arrastar o pin, ou "Marcar no mapa" e clicar no lugar exato; o endereço do lugar
 *      escolhido é preenchido sozinho (Nominatim, busca inversa).
 * O hemocentro pode vir da lista de SP (no seletor ou clicando na gota do mapa).
 * As paradas podem ser adicionadas, reordenadas e removidas; os nomes paradas[i].* são renumerados.
 * As animações dos pinos (cair, deslizar, pousar, sumir) ficam em rota-mapa.js / rota-mapa.css. */
(function () {
  'use strict';

  var form = document.getElementById('rota-form');
  var mapaEl = document.getElementById('editor-mapa');
  if (!form || !mapaEl || !window.RotaMapa) { return; }

  var listaParadas = document.getElementById('paradas');
  var tplParada = document.getElementById('tpl-parada');
  var mapaBloco = document.getElementById('editor-mapa-bloco');
  var dica = document.getElementById('editor-dica');
  var resumo = document.getElementById('editor-resumo');
  var dicaPadrao = dica.textContent;

  var mapa = RotaMapa.criar(mapaEl, {
    hemocentros: true,
    aoEscolherHemocentro: function (h) { usarHemocentro(h); }
  });
  var marcando = null; // ponto esperando um clique no mapa
  var sequencia = 0;   // id fixo de cada ponto no mapa, para o pino deslizar em vez de ser recriado

  /* ---------- Acesso aos campos de um ponto ---------- */

  function blocos() {
    return Array.prototype.slice.call(form.querySelectorAll('[data-ponto]'));
  }

  function campo(bloco, nome) {
    return bloco.querySelector('[data-campo="' + nome + '"]');
  }

  function valor(bloco, nome) {
    return campo(bloco, nome).value.trim();
  }

  function coordenada(bloco) {
    var lat = parseFloat(valor(bloco, 'lat'));
    var lng = parseFloat(valor(bloco, 'lng'));
    return isNaN(lat) || isNaN(lng) ? null : { lat: lat, lng: lng };
  }

  function status(bloco, texto, estado) {
    var el = bloco.querySelector('[data-status]');
    var icones = { ok: 'check_circle', aviso: 'info', erro: 'error', buscando: 'progress_activity' };
    el.dataset.estado = estado || '';
    el.innerHTML = '';
    if (!texto) { return; }
    if (icones[estado]) {
      var i = document.createElement('span');
      i.className = 'icon';
      i.setAttribute('aria-hidden', 'true');
      i.textContent = icones[estado];
      el.appendChild(i);
    }
    el.appendChild(document.createTextNode(texto));
  }

  function definirCoordenada(bloco, lat, lng) {
    campo(bloco, 'lat').value = lat.toFixed(7);
    campo(bloco, 'lng').value = lng.toFixed(7);
  }

  /* ---------- Marcadores e linha da rota ---------- */

  function blocoPorId(id) {
    return blocos().filter(function (b) { return b._id === id; })[0];
  }

  function pontoDoBloco(bloco, indice) {
    var c = coordenada(bloco);
    if (!c) { return null; }
    return {
      id: bloco._id, lat: c.lat, lng: c.lng,
      nome: valor(bloco, 'nome') || 'Ponto sem nome',
      tipo: bloco.dataset.tipo,
      rotulo: bloco.dataset.tipo === 'parada' ? String(indice) : ''
    };
  }

  var linhaTimer = null;
  var primeiraVez = true;

  /** Atualiza os pinos a partir do formulário e redesenha a linha (com um pequeno atraso para não sobrecarregar o OSRM). */
  function atualizarMapa(enquadrar) {
    var pontos = [];
    var numParada = 0;
    var destino = null;
    blocos().forEach(function (bloco) {
      // Passos que o modo Encontro esconde (partida e paradas) não entram no mapa
      if (bloco.closest('[data-inativo]')) { return; }
      if (bloco.dataset.tipo === 'parada') { numParada++; }
      var ponto = pontoDoBloco(bloco, numParada);
      if (!ponto) { return; }
      pontos.push(ponto);
      if (ponto.tipo === 'fim') { destino = ponto; }
    });

    mapa.definirPontos(pontos, {
      editavel: true,
      escalonar: primeiraVez ? 160 : 0, // ao abrir, os pinos caem um de cada vez
      aoArrastar: function (id, pos) {
        var bloco = blocoPorId(id);
        if (!bloco) { return; }
        definirCoordenada(bloco, pos.lat, pos.lng);
        atualizarMapa(false);
        enderecoPeloPino(bloco, pos.lat, pos.lng);
      },
      aoClicar: function (id) {
        var bloco = blocoPorId(id);
        if (bloco && !marcando) { ativar(bloco, true); }
      },
      // Mouse no pino: destaca o ponto na lista
      aoPassarMouse: function (id, ligado) {
        var bloco = blocoPorId(id);
        if (bloco) { bloco.classList.toggle('is-destacado', ligado); }
      }
    });
    mapa.destacarHemocentro(destino ? destino.lng : null, destino ? destino.lat : null, destino ? destino.nome : null);
    if (enquadrar) { mapa.enquadrar(pontos, true); }

    var duracao = primeiraVez ? 1800 : 900;
    primeiraVez = false;
    clearTimeout(linhaTimer);
    linhaTimer = setTimeout(function () {
      mapa.desenharRota(pontos, { duracao: duracao }).then(function (resultado) {
        if (resultado === null && pontos.length >= 2) { return; } // resposta antiga, descartada
        resumo.textContent = !resultado ? ''
          : resultado.pelasRuas ? RotaMapa.resumo(resultado) : 'Traçado aproximado (serviço de rotas indisponível)';
      });
    }, 500);
  }

  /* ---------- Busca do CEP (ViaCEP) ---------- */

  function mascaraCep(input) {
    var d = input.value.replace(/\D/g, '').slice(0, 8);
    input.value = d.length > 5 ? d.slice(0, 5) + '-' + d.slice(5) : d;
    return d;
  }

  function lupa(bloco, buscando) {
    var botao = bloco.querySelector('[data-acao="buscar-cep"]');
    if (!botao) { return; }
    botao.classList.toggle('is-buscando', buscando);
    botao.querySelector('.icon').textContent = buscando ? 'progress_activity' : 'search';
  }

  /** forcar = a pessoa clicou na lupa ou apertou Enter: busca mesmo que o CEP não tenha mudado. */
  function buscarCep(bloco, forcar) {
    var cep = mascaraCep(campo(bloco, 'cep'));
    if (cep.length !== 8) {
      if (forcar) { status(bloco, 'Digite os 8 números do CEP.', 'aviso'); }
      return;
    }
    if (!forcar && bloco._ultimoCep === cep) { return; }
    bloco._ultimoCep = cep;
    status(bloco, 'Buscando o CEP…', 'buscando');
    lupa(bloco, true);
    fetch('https://viacep.com.br/ws/' + cep + '/json/')
      .then(function (r) { return r.json(); })
      .then(function (d) {
        lupa(bloco, false);
        if (d.erro) {
          status(bloco, 'CEP não encontrado. Preencha o endereço à mão.', 'erro');
          return;
        }
        if (d.logradouro) { campo(bloco, 'rua').value = d.logradouro; }
        if (d.bairro) { campo(bloco, 'bairro').value = d.bairro; }
        campo(bloco, 'cidade').value = d.localidade || '';
        campo(bloco, 'uf').value = d.uf || '';
        if (nomeAutomatico(bloco) && d.logradouro) { definirNomeAutomatico(bloco, d.logradouro); }
        status(bloco, 'Endereço preenchido pelo CEP', 'ok');
        if (d.logradouro && !valor(bloco, 'numero')) {
          campo(bloco, 'numero').focus();
        }
        localizar(bloco);
      })
      .catch(function () {
        lupa(bloco, false);
        bloco._ultimoCep = null;
        status(bloco, 'Não foi possível consultar o CEP agora. Preencha o endereço à mão.', 'erro');
      });
  }

  /* ---------- Endereço → coordenada (Nominatim, no máximo 1 busca por segundo) ---------- */

  var NOMINATIM = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&countrycodes=br&accept-language=pt-BR&';
  var NOMINATIM_REVERSO = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&zoom=18&addressdetails=1&accept-language=pt-BR&';
  var fila = Promise.resolve();
  var ultimaBusca = 0;

  /** Uma busca no Nominatim por vez, com 1,1 s entre elas (política de uso gratuito). */
  function nominatim(params, base) {
    var busca = fila.then(function () {
      var espera = Math.max(0, ultimaBusca + 1100 - Date.now());
      return new Promise(function (ok) { setTimeout(ok, espera); });
    }).then(function () {
      ultimaBusca = Date.now();
      var qs = Object.keys(params).map(function (k) { return k + '=' + encodeURIComponent(params[k]); }).join('&');
      return fetch((base || NOMINATIM) + qs).then(function (r) { return r.ok ? r.json() : []; });
    }).catch(function () { return []; });
    fila = busca;
    return busca;
  }

  /** Tenta do mais preciso para o menos preciso: rua e número, depois o nome do local, depois só a cidade. */
  function tentativas(bloco) {
    var rua = valor(bloco, 'rua'), numero = valor(bloco, 'numero'), nome = valor(bloco, 'nome');
    var cidade = valor(bloco, 'cidade'), uf = valor(bloco, 'uf').toUpperCase();
    var lista = [];
    if (rua && cidade) {
      lista.push({ params: { street: (numero ? numero + ' ' : '') + rua, city: cidade, state: uf, country: 'Brasil' }, precisao: 'rua' });
    }
    if (nome && cidade && nome !== rua) {
      lista.push({ params: { q: [nome, cidade, uf].filter(Boolean).join(', ') }, precisao: 'local' });
    }
    if (cidade) {
      lista.push({ params: { city: cidade, state: uf, country: 'Brasil' }, precisao: 'cidade' });
    }
    return lista;
  }

  function localizar(bloco) {
    var lista = tentativas(bloco);
    if (!lista.length) {
      status(bloco, 'Informe ao menos a cidade para localizar o ponto.', 'aviso');
      return;
    }
    var pedido = (bloco._pedido || 0) + 1;
    bloco._pedido = pedido;
    status(bloco, 'Procurando no mapa…', 'buscando');

    (function tentar(i) {
      if (i >= lista.length) {
        status(bloco, 'Não encontramos o endereço — use “Marcar no mapa”.', 'erro');
        return;
      }
      nominatim(lista[i].params).then(function (resultados) {
        if (bloco._pedido !== pedido) { return; } // o endereço mudou enquanto buscava
        if (!resultados.length) { tentar(i + 1); return; }
        definirCoordenada(bloco, parseFloat(resultados[0].lat), parseFloat(resultados[0].lon));
        if (lista[i].precisao === 'cidade') {
          status(bloco, 'Localização aproximada (centro da cidade). Arraste o pin para o ponto exato.', 'aviso');
        } else {
          status(bloco, 'Localizado no mapa. Confira o pin e arraste se precisar.', 'ok');
        }
        atualizarMapa(true);
      });
    })(0);
  }

  /** O nome do local ainda é o que o sistema preencheu (vazio ou igual ao último automático)? Então pode trocar. */
  function nomeAutomatico(bloco) {
    var nome = valor(bloco, 'nome');
    return !nome || nome === bloco._nomeAuto;
  }

  function definirNomeAutomatico(bloco, nome) {
    campo(bloco, 'nome').value = nome;
    bloco._nomeAuto = nome;
  }

  /** O pino foi posto à mão (arrastado ou clicado no mapa): preenche o endereço daquele lugar. */
  function enderecoPeloPino(bloco, lat, lng) {
    var pedido = (bloco._pedido || 0) + 1;
    bloco._pedido = pedido; // cancela uma busca pelo endereço digitado que ainda estava na fila
    status(bloco, 'Buscando o endereço deste ponto…', 'buscando');
    nominatim({ lat: lat.toFixed(7), lon: lng.toFixed(7) }, NOMINATIM_REVERSO).then(function (r) {
      if (bloco._pedido !== pedido) { return; } // o pino mudou de novo enquanto buscava
      var a = r && r.address;
      if (!a) {
        status(bloco, 'Posição marcada. Não achamos o endereço aqui — preencha à mão.', 'aviso');
        return;
      }
      var rua = a.road || a.pedestrian || a.footway || a.square || '';
      var cidade = a.city || a.town || a.village || a.municipality || '';
      var uf = (a['ISO3166-2-lvl4'] || '').replace(/^BR-/, '');
      var cep = (a.postcode || '').replace(/\D/g, '');
      campo(bloco, 'rua').value = rua;
      campo(bloco, 'numero').value = a.house_number || '';
      campo(bloco, 'bairro').value = a.suburb || a.neighbourhood || a.quarter || a.city_district || '';
      if (cidade) { campo(bloco, 'cidade').value = cidade; }
      if (uf) { campo(bloco, 'uf').value = uf; }
      campo(bloco, 'cep').value = cep.length === 8 ? cep.slice(0, 5) + '-' + cep.slice(5) : '';
      bloco._ultimoCep = cep;
      if (nomeAutomatico(bloco)) {
        definirNomeAutomatico(bloco, rua ? rua + (a.house_number ? ', ' + a.house_number : '') : cidade);
      }
      // Um hemocentro escolhido da lista deixa de valer quando o pino vai para outro lugar
      if (bloco.dataset.tipo === 'fim' && selectHemocentros) { selectHemocentros.value = ''; }
      status(bloco, !rua ? 'Não há rua neste ponto: confira o endereço ou ajuste o pino.'
        : a.house_number ? 'Endereço preenchido pelo pino.' : 'Endereço preenchido pelo pino — confira o número.',
      rua ? 'ok' : 'aviso');
      atualizarMapa(false);
    });
  }

  /* ---------- Marcar o ponto clicando no mapa ---------- */

  function ativar(bloco, rolar) {
    blocos().forEach(function (b) { b.classList.toggle('is-ativo', b === bloco); });
    if (rolar) { bloco.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }
  }

  function iniciarMarcacao(bloco) {
    marcando = bloco;
    ativar(bloco, false);
    mapaBloco.classList.add('is-marcando');
    mapa.definirCursor('crosshair');
    dica.textContent = 'Clique no mapa onde fica “' + (valor(bloco, 'nome') || 'este ponto') + '”. Esc cancela.';
    if (window.matchMedia('(max-width: 960px)').matches) {
      mapaBloco.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  function encerrarMarcacao() {
    marcando = null;
    mapaBloco.classList.remove('is-marcando');
    mapa.definirCursor('');
    dica.textContent = dicaPadrao;
  }

  mapa.aoClicar(function (lngLat) {
    if (!marcando) { return; }
    var bloco = marcando;
    definirCoordenada(bloco, lngLat.lat, lngLat.lng);
    encerrarMarcacao();
    atualizarMapa(false);
    enderecoPeloPino(bloco, lngLat.lat, lngLat.lng);
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && marcando) { encerrarMarcacao(); }
  });

  /* ---------- Paradas: adicionar, mover, remover ---------- */

  function renumerar() {
    var paradas = listaParadas.querySelectorAll('[data-ponto]');
    paradas.forEach(function (bloco, i) {
      bloco.querySelectorAll('[name]').forEach(function (input) {
        input.name = input.name.replace(/^paradas\[\d+\]/, 'paradas[' + i + ']');
      });
      bloco.querySelector('[data-titulo]').textContent = 'Parada ' + (i + 1);
      bloco.querySelector('[data-pino]').textContent = String(i + 1);
      bloco.querySelector('[data-acao="subir"]').disabled = i === 0;
      bloco.querySelector('[data-acao="descer"]').disabled = i === paradas.length - 1;
    });
  }

  document.getElementById('add-parada').addEventListener('click', function () {
    var bloco = tplParada.content.firstElementChild.cloneNode(true);
    listaParadas.appendChild(bloco);
    prepararBloco(bloco);
    renumerar();
    campo(bloco, 'nome').focus();
  });

  form.addEventListener('click', function (e) {
    var botao = e.target.closest('[data-acao]');
    if (!botao || botao.disabled) { return; }
    var bloco = botao.closest('[data-ponto]');
    switch (botao.dataset.acao) {
      case 'localizar':
        localizar(bloco);
        break;
      case 'buscar-cep':
        buscarCep(bloco, true);
        break;
      case 'marcar':
        iniciarMarcacao(bloco);
        break;
      case 'subir':
        if (bloco.previousElementSibling) { listaParadas.insertBefore(bloco, bloco.previousElementSibling); }
        renumerar();
        atualizarMapa(false);
        botao.focus();
        break;
      case 'descer':
        if (bloco.nextElementSibling) { listaParadas.insertBefore(bloco.nextElementSibling, bloco); }
        renumerar();
        atualizarMapa(false);
        botao.focus();
        break;
      case 'remover':
        if (marcando === bloco) { encerrarMarcacao(); }
        bloco.remove(); // o pino some do mapa com uma animação
        bloco = null;
        renumerar();
        atualizarMapa(false);
        break;
    }
  });

  /* ---------- Eventos de cada ponto ---------- */

  function prepararBloco(bloco) {
    bloco._id = 'ponto-' + (++sequencia);
    var cep = campo(bloco, 'cep');
    cep.addEventListener('input', function () { buscarCep(bloco); });

    // Mudou o endereço: procura de novo (o pin acompanha, como num app de transporte)
    ['rua', 'numero', 'cidade', 'uf'].forEach(function (nome) {
      campo(bloco, nome).addEventListener('change', function () { localizar(bloco); });
    });
    campo(bloco, 'nome').addEventListener('change', function () {
      if (!coordenada(bloco)) { localizar(bloco); } else { atualizarMapa(false); }
    });

    bloco.addEventListener('focusin', function () { ativar(bloco, false); mapa.destacar(bloco._id, true); });
    bloco.addEventListener('focusout', function (e) {
      if (!bloco.contains(e.relatedTarget)) { mapa.destacar(bloco._id, false); }
    });
    // Mouse no ponto da lista: o pino salta no mapa
    bloco.addEventListener('mouseenter', function () { mapa.destacar(bloco._id, true); });
    bloco.addEventListener('mouseleave', function () {
      if (!bloco.contains(document.activeElement)) { mapa.destacar(bloco._id, false); }
    });

    // Enter num campo do ponto não envia o formulário; só confirma o campo
    bloco.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' && e.target.matches('input')) {
        e.preventDefault();
        if (e.target.dataset.campo === 'cep') {
          buscarCep(bloco, true);
        } else {
          e.target.dispatchEvent(new Event('change', { bubbles: true }));
        }
      }
    });

    if (coordenada(bloco)) {
      status(bloco, 'No mapa', 'ok');
    } else if (valor(bloco, 'cidade')) {
      status(bloco, 'Ainda não está no mapa — clique em Localizar ou marque no mapa.', 'aviso');
    }
  }

  /* ---------- Lista pronta de hemocentros de SP (cache em /data/hemocentros-sp.json) ---------- */

  var listaHemocentros = [];
  var selectHemocentros = null;

  /** Preenche o bloco do hemocentro com um item da lista (vindo do seletor ou da gota clicada no mapa). */
  function usarHemocentro(h) {
    var bloco = form.querySelector('[data-ponto][data-tipo="fim"]');
    if (!bloco || !h) { return; }
    ['nome', 'rua', 'numero', 'bairro', 'cidade', 'uf'].forEach(function (c) { campo(bloco, c).value = h[c] || ''; });
    campo(bloco, 'cep').value = h.cep || '';
    bloco._ultimoCep = (h.cep || '').replace(/\D/g, '');
    bloco._pedido = (bloco._pedido || 0) + 1; // descarta uma busca de endereço em andamento
    definirCoordenada(bloco, h.lat, h.lng);
    if (selectHemocentros) {
      // A gota do mapa vem de outra cópia da lista: compara pelo nome e cidade
      var indice = listaHemocentros.findIndex(function (x) { return x.nome === h.nome && x.cidade === h.cidade; });
      selectHemocentros.value = indice >= 0 ? String(indice) : '';
    }
    status(bloco, 'Hemocentro da lista, já no mapa. Confira o horário da doação.', 'ok');
    ativar(bloco, true);
    atualizarMapa(true);
    campo(bloco, 'horario').focus({ preventScroll: true });
  }

  function carregarHemocentros() {
    var bloco = form.querySelector('[data-ponto][data-tipo="fim"]');
    var caixa = bloco && bloco.querySelector('[data-catalogo]');
    if (!caixa) { return; }
    var select = caixa.querySelector('[data-catalogo-lista]');

    fetch('/data/hemocentros-sp.json')
      .then(function (r) { if (!r.ok) { throw new Error(r.status); } return r.json(); })
      .then(function (dados) {
        var lista = dados.hemocentros || [];
        listaHemocentros = lista;
        selectHemocentros = select;
        var grupos = {};
        lista.forEach(function (h, i) {
          if (!grupos[h.cidade]) {
            grupos[h.cidade] = document.createElement('optgroup');
            grupos[h.cidade].label = h.cidade;
            select.appendChild(grupos[h.cidade]);
          }
          var opcao = document.createElement('option');
          opcao.value = String(i);
          opcao.textContent = h.nome + (h.rua ? ' — ' + h.rua + (h.numero ? ', ' + h.numero : '') : '');
          grupos[h.cidade].appendChild(opcao);
          // Campanha já salva com um hemocentro da lista: deixa selecionado
          if (h.nome === valor(bloco, 'nome') && h.cidade === valor(bloco, 'cidade')) { select.value = String(i); }
        });
        caixa.querySelector('[data-catalogo-fonte]').textContent = dados.atribuicao || '';
        caixa.hidden = false;

        select.addEventListener('change', function () {
          usarHemocentro(lista[parseInt(select.value, 10)]);
        });

        // Digitou outro endereço: a escolha da lista deixa de valer
        bloco.addEventListener('input', function (e) {
          if (e.target !== select && e.target.dataset.campo && e.target.dataset.campo !== 'horario') { select.value = ''; }
        });
      })
      .catch(function () { /* sem a lista, o organizador digita o endereço normalmente */ });
  }

  blocos().forEach(prepararBloco);
  renumerar();
  atualizarMapa(true);
  carregarHemocentros();

  // Usado pelo assistente de passos (campanha-wizard.js)
  window.RotaEditor = {
    mapa: mapa,
    atualizar: function (enquadrar) { atualizarMapa(enquadrar); }
  };
})();
