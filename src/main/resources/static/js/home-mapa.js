/* Home: mapa das caravanas abertas, ou dos hemocentros de SP quando não há caravana.
 *
 * A lista vem pronta do servidor (pages/index.ftlh): cada <li data-caravana> leva os pontos de embarque
 * em <span data-embarque data-cidade data-lat data-lng data-horario>. Este script:
 *   1. agrupa os pontos por cidade e põe um pino por cidade (o número é quantas caravanas passam ali);
 *   2. pede a localização da pessoa e escolhe a cidade de embarque mais perto (até PERTO_KM);
 *      se nenhuma estiver perto, mostra a mais próxima mesmo assim, avisando a distância;
 *   3. sem localização (negada, indisponível ou demorando), mostra todas e a pessoa escolhe a cidade.
 * Sem caravana aberta (data-vazio), o mapa mostra os hemocentros de SP e, com a localização,
 * lista os três mais próximos.
 * A localização fica só no navegador: nada é enviado ao servidor. Distâncias em linha reta. */
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
    elKicker.textContent = kicker;
    elTitulo.textContent = titulo;
    elTexto.textContent = texto;
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
    painel.querySelector('[data-home-mapa-bloco]').hidden = true;
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
    if (!('geolocation' in navigator)) { aoFalhar(); return; }
    navigator.geolocation.getCurrentPosition(function (pos) {
      voce = { lat: pos.coords.latitude, lng: pos.coords.longitude };
      botaoLocal.hidden = true;
      mostrarVoce();
      aoChegar();
    }, function () {
      aoFalhar();
    }, { enableHighAccuracy: false, timeout: 10000, maximumAge: 10 * 60 * 1000 });
  }

  function oferecerBotao(aoChegar, aoFalhar) {
    botaoLocal.hidden = false;
    botaoLocal.onclick = function () {
      botaoLocal.disabled = true;
      pedirLocalizacao(function () {
        botaoLocal.disabled = false;
        aoChegar();
      }, function () {
        botaoLocal.disabled = false;
        elTexto.textContent = 'Não conseguimos sua localização. Confira se o navegador tem permissão para usá-la.';
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
    var itens = Array.prototype.slice.call(lista.querySelectorAll('[data-caravana]'));
    var caixaCidades = painel.querySelector('[data-home-cidades]');
    var listaCidades = painel.querySelector('[data-cidades-lista]');
    var total = itens.length;

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
        // O mesmo hemocentro pode vir com nomes diferentes ("Colsan Sorocaba" e "Hemocentro de Sorocaba - Colsan"):
        // a menos de 1 km, é o mesmo pino
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

    // Hemocentros para onde vão as caravanas da cidade escolhida
    function destinosDe(cidade) {
      var ids = {};
      cidade.itens.forEach(function (li) { if (li.dataset.destinoId) { ids[li.dataset.destinoId] = true; } });
      return listaDestinos.filter(function (d) { return ids[d.id]; });
    }

    // Pinos: as cidades (com o número de caravanas) e, com uma cidade escolhida, os hemocentros dela.
    // Sem escolha, só as cidades: os hemocentros caíam por cima dos pinos de Sorocaba e Votorantim.
    // Só a cidade escolhida ganha etiqueta: com todas, o mapa da região vira uma sopa de nomes.
    function pinos() {
      return cidades.map(function (c) {
        var n = c.itens.length;
        return {
          // nome vira a dica do pino (title): explica o número
          id: c.id, lat: c.lat, lng: c.lng, tipo: 'parada',
          nome: n + plural(n, ' caravana embarca', ' caravanas embarcam') + ' em ' + c.nome,
          rotulo: String(n), meu: c === atual,
          etiqueta: c === atual ? { titulo: c.nome } : null
        };
      }).concat(atual ? destinosDe(atual) : []);
    }

    function desenharPinos() {
      if (!mapa) { return; }
      mapa.pronto.then(function () {
        mapa.definirPontos(pinos(), {
          escalonar: 80,
          aoClicar: function (id) {
            var c = cidades.filter(function (x) { return x.id === id; })[0];
            if (c) { selecionar(c); }
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
      if (!mapa || !pontos.length) { return; }
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

    // Botões das cidades; com a localização, em ordem de distância e com os km
    function desenharCidades() {
      if (cidades.length < 2) { caixaCidades.hidden = true; return; }
      var ordem = cidades.slice().sort(function (a, b) {
        if (voce) { return distancia(a) - distancia(b); }
        return b.itens.length - a.itens.length || a.nome.localeCompare(b.nome, 'pt-BR');
      });
      listaCidades.replaceChildren();
      ordem.forEach(function (c) {
        var b = document.createElement('button');
        b.type = 'button';
        b.setAttribute('aria-pressed', String(c === atual));
        b.textContent = c.nome + (voce ? ' · ' + textoKm(distancia(c)) : '');
        b.addEventListener('click', function () { selecionar(c); });
        listaCidades.appendChild(b);
      });
      caixaCidades.hidden = false;
    }

    // Mostra só as caravanas que passam pela cidade (as outras ficam escondidas, no fim da lista)
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

    function selecionar(cidade) {
      atual = cidade;
      mostrarItens(cidade.itens, cidade);
      var n = cidade.itens.length;
      var d = distancia(cidade);
      var maisPerto = voce && cidades.every(function (c) { return distancia(c) >= d; });
      if (d !== null && maisPerto && d > PERTO_KM) {
        status('A saída mais próxima de você',
          cidade.nome + ', a ' + textoKm(d),
          'Ainda não há caravana saindo perto de você. Esta é a cidade de embarque mais próxima.');
      } else if (d !== null && d <= PERTO_KM) {
        status('Perto de você', 'Saindo de ' + cidade.nome + ', a ' + textoKm(d),
          n + plural(n, ' caravana passa', ' caravanas passam') + ' por ' + cidade.nome + '.');
      } else {
        status('Saindo de ' + cidade.nome, n + plural(n, ' caravana aberta', ' caravanas abertas'),
          d !== null ? 'A ' + textoKm(d) + ' de você.' : 'Escolha outra cidade abaixo, se preferir.');
      }
      desenharPinos();
      desenharCidades();
      // Câmera: a cidade escolhida, os hemocentros dessas caravanas e você
      var alvo = [{ lat: cidade.lat, lng: cidade.lng }];
      cidade.itens.forEach(function (li) {
        if (li.dataset.destinoLat) { alvo.push({ lat: parseFloat(li.dataset.destinoLat), lng: parseFloat(li.dataset.destinoLng) }); }
      });
      if (voce && d <= 150) { alvo.push(voce); }
      enquadrar(alvo);
    }

    function mostrarTodas() {
      atual = null;
      mostrarItens(itens, null);
      status('Caravanas abertas', total + plural(total, ' caravana com inscrições abertas', ' caravanas com inscrições abertas'),
        'Escolha a cidade de onde você sai, no mapa ou abaixo.');
      desenharPinos();
      desenharCidades();
      enquadrar(cidades);
    }

    function escolherAMaisPerto() {
      if (!cidades.length) { mostrarTodas(); return; }
      var maisPerto = cidades.slice().sort(function (a, b) { return distancia(a) - distancia(b); })[0];
      selecionar(maisPerto);
    }

    mostrarTodas();
    if (!cidades.length) { return; } // nenhuma caravana com ponto no mapa: fica a lista
    elTexto.textContent = 'Procurando a saída mais perto de você…';
    pedirLocalizacao(escolherAMaisPerto, function () {
      elTexto.textContent = 'Escolha a cidade de onde você sai, no mapa ou abaixo.';
      oferecerBotao(escolherAMaisPerto, function () {});
    });
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

    pedirLocalizacao(mostrarMaisProximos, function () {
      oferecerBotao(mostrarMaisProximos, function () {});
    });
  }
})();
