/* Home: mapa das caravanas abertas, ou dos hemocentros de SP quando não há caravana.
 *
 * A lista vem pronta do servidor (pages/campanhas.ftlh ou pages/index.ftlh): cada <li data-caravana> leva os pontos de embarque
 * em <span data-embarque data-cidade data-lat data-lng data-horario>. Este script:
 *   1. agrupa os pontos por cidade e põe um pino por cidade (o número é quantas caravanas passam ali);
 *   2. permite filtrar por cidade nos botões ou clicando nos pinos do mapa;
 *   3. permite buscar em tempo real por nome, trajeto, cidade ou local;
 *   4. se não tiver data-sem-localizacao, pede a localização para ordenar as cidades pela distância.
 * Sem caravana aberta (data-vazio), o mapa mostra os hemocentros de SP. */
(function () {
  'use strict';

  var PERTO_KM = 30;
  var HEMOCENTROS_URL = '/data/hemocentros-sp.json';

  var painel = document.querySelector('[data-home-mapa]');
  if (!painel) { return; }

  var elMapa = painel.querySelector('[data-home-mapa-el]');
  var elKicker = painel.querySelector('[data-status-kicker]');
  var elTitulo = painel.querySelector('[data-status-titulo]');
  var elTexto = painel.querySelector('[data-status-texto]');
  var botaoLocal = painel.querySelector('[data-usar-local]');
  var vazio = painel.hasAttribute('data-vazio');
  var semLocalizacao = painel.hasAttribute('data-sem-localizacao') || !botaoLocal;

  var voce = null; // { lat, lng } quando a pessoa deixa usar a localização

  /* ---------- Utilitários ---------- */

  function km(a, b) {
    var r = 6371;
    var dLat = (b.lat - a.lat) * Math.PI / 180;
    var dLng = (b.lng - a.lng) * Math.PI / 180;
    var h = Math.sin(dLat / 2) * Math.sin(dLat / 2)
      + Math.cos(a.lat * Math.PI / 180) * Math.cos(b.lat * Math.PI / 180) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return 2 * r * Math.asin(Math.sqrt(h));
  }

  function textoKm(d) {
    return d < 1 ? 'menos de 1 km' : Math.round(d) + ' km';
  }

  function normalizar(texto) {
    return (texto || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().trim();
  }

  function status(kicker, titulo, texto) {
    if (elKicker) { elKicker.textContent = kicker; }
    if (elTitulo) { elTitulo.textContent = titulo; }
    if (elTexto) { elTexto.textContent = texto; }
  }

  function plural(n, um, varios) {
    return n === 1 ? um : varios;
  }

  /* ---------- Mapa ---------- */

  var mapa = null;
  if (window.RotaMapa && window.maplibregl) {
    try {
      mapa = window.RotaMapa.criar(elMapa, { hemocentros: vazio });
    } catch (e) { // sem WebGL: fica só a lista
      mapa = null;
    }
  }
  if (!mapa) {
    var blocoMapa = painel.querySelector('[data-home-mapa-bloco]');
    if (blocoMapa) { blocoMapa.hidden = true; }
    painel.classList.add('is-sem-mapa');
  }

  var marcadorVoce = null;
  function mostrarVoce() {
    if (!mapa || !voce) { return; }
    if (!marcadorVoce) {
      var el = document.createElement('div');
      el.className = 'home-voce';
      el.title = 'Você está aqui';
      el.setAttribute('aria-label', 'Você está aqui');
      marcadorVoce = new window.maplibregl.Marker({ element: el, anchor: 'center' });
    }
    mapa.pronto.then(function () { marcadorVoce.setLngLat([voce.lng, voce.lat]).addTo(mapa.map); });
  }

  /* ---------- Localização ---------- */

  function pedirLocalizacao(aoChegar, aoFalhar) {
    if (semLocalizacao || !('geolocation' in navigator)) { aoFalhar(); return; }
    navigator.geolocation.getCurrentPosition(function (pos) {
      voce = { lat: pos.coords.latitude, lng: pos.coords.longitude };
      if (botaoLocal) { botaoLocal.hidden = true; }
      mostrarVoce();
      aoChegar();
    }, function () {
      aoFalhar();
    }, { enableHighAccuracy: false, timeout: 10000, maximumAge: 10 * 60 * 1000 });
  }

  function oferecerBotao(aoChegar, aoFalhar) {
    if (semLocalizacao || !botaoLocal) { return; }
    botaoLocal.hidden = false;
    botaoLocal.onclick = function () {
      botaoLocal.disabled = true;
      pedirLocalizacao(function () {
        botaoLocal.disabled = false;
        aoChegar();
      }, function () {
        botaoLocal.disabled = false;
        if (elTexto) { elTexto.textContent = 'Não conseguimos sua localização. Confira se o navegador tem permissão para usá-la.'; }
        aoFalhar();
      });
    };
  }

  if (vazio) {
    iniciarHemocentros();
  } else {
    iniciarCaravanas();
  }

  /* ========== Com caravanas abertas ========== */

  function iniciarCaravanas() {
    var lista = painel.querySelector('[data-caravanas]');
    if (!lista) { return; }
    var itens = Array.prototype.slice.call(lista.querySelectorAll('[data-caravana]'));
    var caixaCidades = painel.querySelector('[data-home-cidades]');
    var listaCidades = painel.querySelector('[data-cidades-lista]');
    var inputBusca = painel.querySelector('[data-busca-caravanas]');
    var btnLimpaBusca = painel.querySelector('[data-limpa-busca]');
    var avisoVazio = painel.querySelector('[data-caravanas-vazia]');
    var total = itens.length;
    var termoBusca = '';

    // Cidades de embarque: um pino por cidade, com as caravanas que passam por ela
    var porChave = {};
    var destinos = {};
    itens.forEach(function (li) {
      li.querySelectorAll('[data-embarque]').forEach(function (e) {
        var lat = parseFloat(e.dataset.lat);
        var lng = parseFloat(e.dataset.lng);
        if (isNaN(lat) || isNaN(lng)) { return; }
        var chave = normalizar(e.dataset.cidade);
        var cidade = porChave[chave];
        if (!cidade) {
          cidade = porChave[chave] = { id: 'cidade-' + chave, nome: e.dataset.cidade, lat: lat, lng: lng, itens: [], pontos: {} };
        }
        if (cidade.itens.indexOf(li) < 0) { cidade.itens.push(li); }
        // Primeiro ponto da caravana nesta cidade (o horário em que o ônibus passa)
        if (!cidade.pontos[li.dataset.id]) {
          cidade.pontos[li.dataset.id] = { nome: e.dataset.nome, horario: e.dataset.horario };
        }
      });
      if (li.dataset.destinoLat) {
        var local = { lat: parseFloat(li.dataset.destinoLat), lng: parseFloat(li.dataset.destinoLng) };
        var igual = Object.keys(destinos).filter(function (id) { return km(destinos[id], local) < 1; })[0];
        if (igual) {
          li.dataset.destinoId = igual;
        } else {
          var id = 'destino-' + normalizar(li.dataset.destino);
          destinos[id] = {
            id: id, nome: li.dataset.destino, tipo: 'fim', lat: local.lat, lng: local.lng,
            etiqueta: { linha: 'Hemocentro', titulo: li.dataset.destino }
          };
          li.dataset.destinoId = id;
        }
      }
    });
    var cidades = Object.keys(porChave).map(function (k) { return porChave[k]; });
    var listaDestinos = Object.keys(destinos).map(function (k) { return destinos[k]; });
    var atual = null;

    function distancia(cidade) {
      return voce ? km(voce, cidade) : null;
    }

    function destinosDe(cidade) {
      var ids = {};
      cidade.itens.forEach(function (li) { if (li.dataset.destinoId) { ids[li.dataset.destinoId] = true; } });
      return listaDestinos.filter(function (d) { return ids[d.id]; });
    }

    function destinosDeItens(listaItens) {
      var ids = {};
      listaItens.forEach(function (li) { if (li.dataset.destinoId) { ids[li.dataset.destinoId] = true; } });
      return listaDestinos.filter(function (d) { return ids[d.id]; });
    }

    function pinos(itensAtivos) {
      var ativos = itensAtivos || (atual ? atual.itens : itens);
      var cidadesAtivas = cidades.filter(function (c) {
        return c.itens.some(function (li) { return ativos.indexOf(li) >= 0; });
      });
      return cidadesAtivas.map(function (c) {
        var n = c.itens.filter(function (li) { return ativos.indexOf(li) >= 0; }).length;
        return {
          id: c.id, lat: c.lat, lng: c.lng, tipo: 'parada',
          nome: n + plural(n, ' caravana embarca', ' caravanas embarcam') + ' em ' + c.nome,
          rotulo: String(n), meu: c === atual,
          etiqueta: c === atual ? { titulo: c.nome } : null
        };
      }).concat(atual ? destinosDe(atual) : destinosDeItens(ativos));
    }

    function desenharPinos(itensAtivos) {
      if (!mapa) { return; }
      mapa.pronto.then(function () {
        mapa.definirPontos(pinos(itensAtivos), {
          escalonar: 80,
          aoClicar: function (id) {
            var c = cidades.filter(function (x) { return x.id === id; })[0];
            if (c) {
              if (atual === c) {
                mostrarTodas();
              } else {
                selecionar(c);
              }
            }
          },
          aoPassarMouse: function (id, ligado) {
            var c = cidades.filter(function (x) { return x.id === id; })[0];
            if (!c) { return; }
            c.itens.forEach(function (li) { li.classList.toggle('is-destacada', ligado); });
          }
        });
      });
    }

    function enquadrar(pontos) {
      if (!mapa || !pontos || !pontos.length) { return; }
      mapa.pronto.then(function () { mapa.enquadrar(pontos, true); });
    }

    // Lista ↔ mapa: passar o mouse num cartão faz o pino da cidade dele saltar
    itens.forEach(function (li) {
      ['mouseenter', 'focusin'].forEach(function (ev) {
        li.addEventListener(ev, function () {
          if (!mapa) { return; }
          var c = atual && atual.itens.indexOf(li) >= 0 ? atual
            : cidades.filter(function (x) { return x.itens.indexOf(li) >= 0; })[0];
          if (c) { mapa.destacar(c.id, true); }
        });
      });
      ['mouseleave', 'focusout'].forEach(function (ev) {
        li.addEventListener(ev, function () {
          if (mapa) { cidades.forEach(function (c) { mapa.destacar(c.id, false); }); }
        });
      });
    });

    // Botões das cidades (agora posicionados acima da lista)
    function desenharCidades() {
      if (!caixaCidades || !listaCidades) { return; }
      if (cidades.length < 2) { caixaCidades.hidden = true; return; }
      var ordem = cidades.slice().sort(function (a, b) {
        if (voce) { return distancia(a) - distancia(b); }
        return b.itens.length - a.itens.length || a.nome.localeCompare(b.nome, 'pt-BR');
      });
      listaCidades.replaceChildren();

      // Botão "Todas"
      var bTodas = document.createElement('button');
      bTodas.type = 'button';
      bTodas.setAttribute('aria-pressed', String(atual === null));
      bTodas.textContent = 'Todas (' + total + ')';
      bTodas.addEventListener('click', function () {
        mostrarTodas();
      });
      listaCidades.appendChild(bTodas);

      ordem.forEach(function (c) {
        var b = document.createElement('button');
        b.type = 'button';
        b.setAttribute('aria-pressed', String(c === atual));
        b.textContent = c.nome + (voce ? ' · ' + textoKm(distancia(c)) : ' (' + c.itens.length + ')');
        b.addEventListener('click', function () {
          if (atual === c) {
            mostrarTodas();
          } else {
            selecionar(c);
          }
        });
        listaCidades.appendChild(b);
      });
      caixaCidades.hidden = false;
    }

    // Mostra as caravanas visíveis e oculta as demais
    function mostrarItens(visiveis, cidade) {
      itens.forEach(function (li) {
        var ver = visiveis.indexOf(li) >= 0;
        li.hidden = !ver;
        var perto = li.querySelector('[data-perto]');
        var ponto = cidade && cidade.pontos[li.dataset.id];
        if (ver && ponto) {
          perto.textContent = 'Embarque: ' + ponto.nome + (ponto.horario ? ' às ' + ponto.horario : '');
          perto.hidden = false;
        } else {
          perto.hidden = true;
        }
      });
      visiveis.concat(itens.filter(function (li) { return visiveis.indexOf(li) < 0; }))
        .forEach(function (li) { lista.appendChild(li); });
    }

    function filtrarEAtualizar() {
      var termo = normalizar(termoBusca);
      var visiveis = itens.filter(function (li) {
        if (atual && atual.itens.indexOf(li) < 0) {
          return false;
        }
        if (termo) {
          var texto = normalizar(li.textContent);
          return texto.indexOf(termo) >= 0;
        }
        return true;
      });

      mostrarItens(visiveis, atual);

      if (avisoVazio) {
        avisoVazio.hidden = visiveis.length > 0;
      }

      if (termo) {
        status('Resultado da busca',
          visiveis.length + plural(visiveis.length, ' caravana encontrada', ' caravanas encontradas'),
          atual ? 'Na cidade de ' + atual.nome + ' para "' + termoBusca + '".' : 'Filtrando por "' + termoBusca + '".');
      } else if (atual) {
        var n = visiveis.length;
        var d = distancia(atual);
        if (d !== null && d <= PERTO_KM) {
          status('Perto de você', 'Saindo de ' + atual.nome + ', a ' + textoKm(d),
            n + plural(n, ' caravana passa', ' caravanas passam') + ' por ' + atual.nome + '.');
        } else {
          status('Saindo de ' + atual.nome,
            n + plural(n, ' caravana aberta', ' caravanas abertas'),
            'Escolha outra cidade acima ou use a busca.');
        }
      } else {
        status('Caravanas abertas',
          total + plural(total, ' caravana com inscrições abertas', ' caravanas com inscrições abertas'),
          'Escolha a cidade de onde você sai acima ou use a busca.');
      }

      desenharPinos(visiveis);
    }

    function selecionar(cidade) {
      atual = cidade;
      filtrarEAtualizar();
      desenharCidades();
      var alvo = [{ lat: cidade.lat, lng: cidade.lng }];
      cidade.itens.forEach(function (li) {
        if (li.dataset.destinoLat) { alvo.push({ lat: parseFloat(li.dataset.destinoLat), lng: parseFloat(li.dataset.destinoLng) }); }
      });
      if (voce && distancia(cidade) <= 150) { alvo.push(voce); }
      enquadrar(alvo);
    }

    function mostrarTodas() {
      atual = null;
      filtrarEAtualizar();
      desenharCidades();
      enquadrar(cidades);
    }

    function escolherAMaisPerto() {
      if (!cidades.length) { mostrarTodas(); return; }
      var maisPerto = cidades.slice().sort(function (a, b) { return distancia(a) - distancia(b); })[0];
      selecionar(maisPerto);
    }

    // Eventos do input de busca
    if (inputBusca) {
      inputBusca.addEventListener('input', function () {
        termoBusca = inputBusca.value.trim();
        if (btnLimpaBusca) {
          btnLimpaBusca.hidden = !termoBusca;
        }
        filtrarEAtualizar();
      });
    }

    if (btnLimpaBusca) {
      btnLimpaBusca.addEventListener('click', function () {
        if (inputBusca) {
          inputBusca.value = '';
          inputBusca.focus();
        }
        termoBusca = '';
        btnLimpaBusca.hidden = true;
        filtrarEAtualizar();
      });
    }

    // Inicialização
    mostrarTodas();
    if (!cidades.length) { return; }

    if (!semLocalizacao) {
      if (elTexto) { elTexto.textContent = 'Procurando a saída mais perto de você…'; }
      pedirLocalizacao(escolherAMaisPerto, function () {
        if (elTexto) { elTexto.textContent = 'Escolha a cidade de onde você sai acima ou use a busca.'; }
        oferecerBotao(escolherAMaisPerto, function () {});
      });
    } else {
      if (elTexto) { elTexto.textContent = 'Escolha a cidade de onde você sai acima ou use a busca.'; }
    }
  }

  /* ========== Sem caravana aberta: hemocentros de SP ========== */

  function iniciarHemocentros() {
    var lista = painel.querySelector('[data-hemocentros-perto]');
    var hemocentros = null;

    var carregar = fetch(HEMOCENTROS_URL)
      .then(function (r) { if (!r.ok) { throw new Error(r.status); } return r.json(); })
      .then(function (dados) { hemocentros = dados.hemocentros || []; })
      .catch(function () { hemocentros = []; });

    function mostrarMaisProximos() {
      carregar.then(function () {
        if (!voce || !hemocentros.length) { return; }
        var proximos = hemocentros.map(function (h) {
          return { h: h, d: km(voce, { lat: h.lat, lng: h.lng }) };
        }).sort(function (a, b) { return a.d - b.d; }).slice(0, 3);

        status('Nenhuma caravana aberta agora', 'Hemocentros perto de você',
          'Você pode doar direto num deles. Quando abrir uma caravana, ela aparece aqui.');
        lista.replaceChildren();
        proximos.forEach(function (p) {
          var li = document.createElement('li');
          var b = document.createElement('button');
          b.type = 'button';
          var nome = document.createElement('strong');
          nome.textContent = p.h.nome;
          var onde = document.createElement('span');
          onde.textContent = (p.h.rua ? p.h.rua + (p.h.numero ? ', ' + p.h.numero : '') + ' · ' : '') + p.h.cidade + ' · ' + textoKm(p.d);
          b.appendChild(nome);
          b.appendChild(onde);
          b.addEventListener('click', function () {
            if (mapa) { mapa.enquadrar([{ lat: p.h.lat, lng: p.h.lng }], true); }
          });
          li.appendChild(b);
          lista.appendChild(li);
        });
        lista.hidden = false;
        if (mapa) {
          mapa.pronto.then(function () {
            mapa.enquadrar(proximos.map(function (p) { return { lat: p.h.lat, lng: p.h.lng }; }).concat([voce]), true);
          });
        }
      });
    }

    if (!semLocalizacao) {
      pedirLocalizacao(mostrarMaisProximos, function () {
        oferecerBotao(mostrarMaisProximos, function () {});
      });
    }
  }
})();
