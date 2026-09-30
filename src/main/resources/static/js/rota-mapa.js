/* Mapa da rota do ônibus (partida → paradas → hemocentro) e dos hemocentros de SP.
 * Tudo gratuito e sem chave:
 *   - MapLibre GL (biblioteca de mapas) com os dados vetoriais do OpenFreeMap (OpenStreetMap);
 *   - cores próprias: "papel quente" no tema claro e "noite" no tema escuro (troca junto com o site);
 *   - traçado pelas ruas do OSRM (servidor público); se ele falhar, liga os pontos em linha reta.
 *
 * Animações (todas desligadas com "Reduzir movimento" do painel de acessibilidade ou do sistema):
 *   - o pino "cai" no mapa e quica ao ganhar coordenada, com uma onda no chão;
 *   - ao arrastar, o pino é "levantado" e pousa com um quique; ao mudar de endereço, ele desliza;
 *   - a rota se desenha da partida ao hemocentro;
 *   - o hemocentro da campanha pulsa como um coração; o ponto de embarque do doador tem um anel;
 *   - lista ↔ mapa: passar o mouse (ou o foco) num ponto da lista faz o pino saltar, e vice-versa;
 *   - depois de salvar, gotas saem do hemocentro (static/js/gotas.js, quando a página tem data-celebrar).
 *
 * Uso automático: <div data-rota-mapa=".seletor-dos-pontos"></div>; cada ponto tem data-lat, data-lng,
 * data-nome, data-tipo ("inicio", "parada" ou "fim") e, opcionais, data-rotulo, data-horario e data-meu.
 * O editor do organizador (rota-editor.js) usa RotaMapa.criar(el, opcoes). */
(function () {
  'use strict';

  var OSRM_URL = 'https://router.project-osrm.org/route/v1/driving/';
  var HEMOCENTROS_URL = '/data/hemocentros-sp.json';
  var ESTADO_SP = [[-53.11, -25.31], [-44.16, -19.78]];
  var NOME = ['coalesce', ['get', 'name:pt'], ['get', 'name']];
  var FONTE = { normal: ['Noto Sans Regular'], negrito: ['Noto Sans Bold'], italico: ['Noto Sans Italic'] };
  var CAMADAS_HC = ['hc-ponto', 'hc-grupo'];

  var TEXTOS = {
    'NavigationControl.ZoomIn': 'Aproximar',
    'NavigationControl.ZoomOut': 'Afastar',
    'AttributionControl.ToggleAttribution': 'Créditos do mapa',
    'CooperativeGesturesHandler.WindowsHelpText': 'Use Ctrl + rolagem para aproximar o mapa',
    'CooperativeGesturesHandler.MacHelpText': 'Use ⌘ + rolagem para aproximar o mapa',
    'CooperativeGesturesHandler.MobileHelpText': 'Use dois dedos para mover o mapa'
  };

  /* ---------- Paletas: A · Papel quente (claro) e B · Noite (escuro) ---------- */

  var PALETAS = {
    claro: {
      fundo: '#F4F0EB', residencial: '#ECE5DD', verde: '#DFE6D6', mata: '#D6E0CB', agua: '#CFDDE4', rio: '#BFD1DA',
      predio: '#E6DED5', limite: '#CFC9C3',
      viaLocal: '#FBF9F6', viaSec: '#FFFFFF', viaSecBorda: '#E8E1D9', viaPri: '#FFFFFF', viaPriBorda: '#E2D9CF',
      rotulo: '#6F6763', rotuloForte: '#3F3A37', rotuloAgua: '#5E7A88', halo: 'rgba(244,240,235,0.92)',
      rota: '#B4232A', rotaBorda: '#FFFFFF', rotaAntes: 'rgba(180,35,42,0.42)', rotaBrilho: 'rgba(180,35,42,0)',
      hcFundo: '#FFFFFF', hcBorda: '#B4232A', grupoFundo: '#FBE3E4', grupoBorda: '#B4232A', grupoTexto: '#8F1821',
      gota: '#B4232A'
    },
    escuro: {
      fundo: '#181615', residencial: '#221F1D', verde: '#1A221B', mata: '#1B241C', agua: '#12232C', rio: '#16303B',
      predio: '#23201E', limite: '#46423F',
      viaLocal: '#262321', viaSec: '#2E2A27', viaSecBorda: '#1E1C1A', viaPri: '#3A3431', viaPriBorda: '#221F1D',
      rotulo: '#9C948F', rotuloForte: '#D8D2CE', rotuloAgua: '#7FA0B0', halo: 'rgba(24,22,21,0.92)',
      rota: '#F2969B', rotaBorda: '#1A1918', rotaAntes: 'rgba(242,150,155,0.5)', rotaBrilho: 'rgba(192,51,58,0.45)',
      hcFundo: '#C0333A', hcBorda: 'rgba(242,150,155,0.45)', grupoFundo: '#2A1416', grupoBorda: '#F2969B', grupoTexto: '#F2969B',
      gota: '#FFFFFF'
    }
  };

  function nomeDoTema() {
    return document.documentElement.getAttribute('data-theme') === 'dark' ? 'escuro' : 'claro';
  }

  function semAnimacao() {
    return document.documentElement.getAttribute('data-motion') === 'reduce'
      || (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  }

  function largura(pares) {
    return ['interpolate', ['exponential', 1.4], ['zoom']].concat(pares);
  }

  function classe(lista) {
    return ['match', ['get', 'class'], lista, true, false];
  }

  var LINHA_REDONDA = { 'line-cap': 'round', 'line-join': 'round' };

  /* Camadas do mapa, de baixo para cima. paint(p) recebe a paleta, para trocar o tema sem recarregar. */
  var CAMADAS = [
    { id: 'fundo', type: 'background', paint: function (p) { return { 'background-color': p.fundo }; } },
    { id: 'residencial', type: 'fill', 'source-layer': 'landuse',
      filter: classe(['residential', 'suburb', 'neighbourhood', 'commercial', 'industrial', 'retail']),
      paint: function (p) { return { 'fill-color': p.residencial, 'fill-opacity': ['interpolate', ['linear'], ['zoom'], 6, 0.5, 11, 1] }; } },
    { id: 'mata', type: 'fill', 'source-layer': 'landcover', filter: classe(['wood', 'forest']),
      paint: function (p) { return { 'fill-color': p.mata, 'fill-opacity': 0.85 }; } },
    { id: 'verde', type: 'fill', 'source-layer': 'landcover', filter: classe(['grass', 'wetland']),
      paint: function (p) { return { 'fill-color': p.verde, 'fill-opacity': 0.7 }; } },
    { id: 'parque', type: 'fill', 'source-layer': 'park',
      paint: function (p) { return { 'fill-color': p.verde, 'fill-opacity': 0.8 }; } },
    { id: 'agua', type: 'fill', 'source-layer': 'water', paint: function (p) { return { 'fill-color': p.agua }; } },
    { id: 'rio', type: 'line', 'source-layer': 'waterway', layout: LINHA_REDONDA,
      paint: function (p) { return { 'line-color': p.rio, 'line-width': largura([6, 0.4, 14, 3]) }; } },
    { id: 'predio', type: 'fill', 'source-layer': 'building', minzoom: 14,
      paint: function (p) { return { 'fill-color': p.predio }; } },
    { id: 'limite', type: 'line', 'source-layer': 'boundary',
      filter: ['all', ['==', ['get', 'admin_level'], 4], ['!=', ['get', 'maritime'], 1]],
      paint: function (p) { return { 'line-color': p.limite, 'line-width': 1, 'line-dasharray': [3, 2] }; } },
    { id: 'via-local', type: 'line', 'source-layer': 'transportation', minzoom: 11, layout: LINHA_REDONDA,
      filter: classe(['minor', 'service', 'tertiary']),
      paint: function (p) { return { 'line-color': p.viaLocal, 'line-width': largura([11, 0.5, 16, 7]) }; } },
    { id: 'via-sec-borda', type: 'line', 'source-layer': 'transportation', minzoom: 7, layout: LINHA_REDONDA,
      filter: classe(['primary', 'secondary']),
      paint: function (p) { return { 'line-color': p.viaSecBorda, 'line-width': largura([7, 1, 10, 3, 16, 13]) }; } },
    { id: 'via-sec', type: 'line', 'source-layer': 'transportation', minzoom: 7, layout: LINHA_REDONDA,
      filter: classe(['primary', 'secondary']),
      paint: function (p) { return { 'line-color': p.viaSec, 'line-width': largura([7, 0.5, 10, 2, 16, 10]) }; } },
    { id: 'via-pri-borda', type: 'line', 'source-layer': 'transportation', layout: LINHA_REDONDA,
      filter: classe(['motorway', 'trunk']),
      paint: function (p) { return { 'line-color': p.viaPriBorda, 'line-width': largura([5, 1.2, 10, 4.5, 16, 16]) }; } },
    { id: 'via-pri', type: 'line', 'source-layer': 'transportation', layout: LINHA_REDONDA,
      filter: classe(['motorway', 'trunk']),
      paint: function (p) { return { 'line-color': p.viaPri, 'line-width': largura([5, 0.6, 10, 3, 16, 12]) }; } },

    // Rota do ônibus: por cima das ruas, por baixo dos nomes
    { id: 'rota-brilho', type: 'line', source: 'rota-trecho', layout: LINHA_REDONDA,
      paint: function (p) { return { 'line-color': p.rotaBrilho, 'line-width': 18, 'line-blur': 12 }; } },
    { id: 'rota-borda', type: 'line', source: 'rota-borda', layout: LINHA_REDONDA,
      paint: function (p) { return { 'line-color': p.rotaBorda, 'line-width': largura([5, 8, 12, 13]) }; } },
    { id: 'rota-antes', type: 'line', source: 'rota-antes', layout: LINHA_REDONDA,
      paint: function (p) { return { 'line-color': p.rotaAntes, 'line-width': largura([5, 4, 12, 6]), 'line-dasharray': [0.1, 2] }; } },
    { id: 'rota-trecho', type: 'line', source: 'rota-trecho', layout: LINHA_REDONDA,
      paint: function (p) { return { 'line-color': p.rota, 'line-width': largura([5, 4.5, 12, 7.5]) }; } },

    { id: 'rotulo-agua', type: 'symbol', 'source-layer': 'water_name',
      layout: { 'text-field': NOME, 'text-font': FONTE.italico, 'text-size': 12 },
      paint: function (p) { return { 'text-color': p.rotuloAgua, 'text-halo-color': p.halo, 'text-halo-width': 1.2 }; } },
    { id: 'rotulo-via', type: 'symbol', 'source-layer': 'transportation_name', minzoom: 13,
      layout: { 'symbol-placement': 'line', 'text-field': NOME, 'text-font': FONTE.normal, 'text-size': 11 },
      paint: function (p) { return { 'text-color': p.rotulo, 'text-halo-color': p.halo, 'text-halo-width': 1.4 }; } },
    { id: 'rotulo-bairro', type: 'symbol', 'source-layer': 'place', minzoom: 12, filter: classe(['suburb', 'neighbourhood']),
      layout: { 'text-field': NOME, 'text-font': FONTE.normal, 'text-size': 11, 'text-transform': 'uppercase', 'text-letter-spacing': 0.08 },
      paint: function (p) { return { 'text-color': p.rotulo, 'text-halo-color': p.halo, 'text-halo-width': 1.4 }; } },
    { id: 'rotulo-vila', type: 'symbol', 'source-layer': 'place', minzoom: 10, filter: classe(['village']),
      layout: { 'text-field': NOME, 'text-font': FONTE.normal, 'text-size': 11 },
      paint: function (p) { return { 'text-color': p.rotulo, 'text-halo-color': p.halo, 'text-halo-width': 1.4 }; } },
    { id: 'rotulo-cidade', type: 'symbol', 'source-layer': 'place', minzoom: 6, filter: classe(['town']),
      layout: { 'text-field': NOME, 'text-font': FONTE.normal, 'text-size': ['interpolate', ['linear'], ['zoom'], 6, 10, 12, 14] },
      paint: function (p) { return { 'text-color': p.rotulo, 'text-halo-color': p.halo, 'text-halo-width': 1.4 }; } },
    { id: 'rotulo-capital', type: 'symbol', 'source-layer': 'place', filter: classe(['city']),
      layout: { 'text-field': NOME, 'text-font': FONTE.negrito, 'text-size': ['interpolate', ['linear'], ['zoom'], 4, 11, 10, 16] },
      paint: function (p) { return { 'text-color': p.rotuloForte, 'text-halo-color': p.halo, 'text-halo-width': 1.6 }; } },

    // Outros hemocentros de SP (lista em cache); agrupados quando o mapa está afastado
    { id: 'hc-grupo', type: 'circle', source: 'hemocentros', filter: ['has', 'point_count'],
      paint: function (p) {
        return { 'circle-color': p.grupoFundo, 'circle-stroke-color': p.grupoBorda, 'circle-stroke-width': 2,
          'circle-radius': ['step', ['get', 'point_count'], 15, 5, 19] };
      } },
    { id: 'hc-grupo-num', type: 'symbol', source: 'hemocentros', filter: ['has', 'point_count'],
      layout: { 'text-field': ['get', 'point_count_abbreviated'], 'text-font': FONTE.negrito, 'text-size': 13, 'text-allow-overlap': true },
      paint: function (p) { return { 'text-color': p.grupoTexto }; } },
    { id: 'hc-ponto', type: 'circle', source: 'hemocentros', filter: ['!', ['has', 'point_count']],
      paint: function (p) {
        return { 'circle-color': p.hcFundo, 'circle-stroke-color': p.hcBorda,
          'circle-stroke-width': ['interpolate', ['linear'], ['zoom'], 6, 2, 12, 3],
          'circle-radius': ['interpolate', ['linear'], ['zoom'], 6, 7, 12, 11] };
      } },
    { id: 'hc-gota', type: 'symbol', source: 'hemocentros', filter: ['!', ['has', 'point_count']],
      layout: { 'icon-image': 'gota', 'icon-size': ['interpolate', ['linear'], ['zoom'], 6, 0.42, 12, 0.62], 'icon-allow-overlap': true },
      paint: function () { return {}; } }
  ];

  // Opacidade dos hemocentros: começa invisível e aparece com uma transição
  var OPACIDADE_HC = {
    'hc-grupo': ['circle-opacity', 'circle-stroke-opacity'],
    'hc-grupo-num': ['text-opacity'],
    'hc-ponto': ['circle-opacity', 'circle-stroke-opacity'],
    'hc-gota': ['icon-opacity']
  };

  function geojsonVazio() {
    return { type: 'FeatureCollection', features: [] };
  }

  function estilo(p) {
    return {
      version: 8,
      glyphs: 'https://tiles.openfreemap.org/fonts/{fontstack}/{range}.pbf',
      sources: {
        omt: { type: 'vector', url: 'https://tiles.openfreemap.org/planet' },
        'rota-borda': { type: 'geojson', data: geojsonVazio() },
        'rota-antes': { type: 'geojson', data: geojsonVazio() },
        'rota-trecho': { type: 'geojson', data: geojsonVazio() },
        hemocentros: { type: 'geojson', data: geojsonVazio(), cluster: true, clusterRadius: 42, clusterMaxZoom: 10 }
      },
      layers: CAMADAS.map(function (c) {
        var camada = { id: c.id, type: c.type, paint: c.paint(p) };
        if (c.type !== 'background') { camada.source = c.source || 'omt'; }
        ['source-layer', 'filter', 'minzoom', 'layout'].forEach(function (k) { if (c[k] !== undefined) { camada[k] = c[k]; } });
        (OPACIDADE_HC[c.id] || []).forEach(function (prop) {
          camada.paint[prop] = 0;
          camada.paint[prop + '-transition'] = { duration: 700, delay: 0 };
        });
        return camada;
      })
    };
  }

  /* Ícone da gota desenhado num canvas (o mapa precisa de uma imagem para os símbolos) */
  function imagemGota(cor) {
    var tam = 48;
    var canvas = document.createElement('canvas');
    canvas.width = tam;
    canvas.height = tam;
    var ctx = canvas.getContext('2d');
    ctx.fillStyle = cor;
    ctx.beginPath();
    ctx.moveTo(24, 6);
    ctx.bezierCurveTo(15, 18, 10, 25, 10, 31);
    ctx.bezierCurveTo(10, 38.7, 16.3, 45, 24, 45);
    ctx.bezierCurveTo(31.7, 45, 38, 38.7, 38, 31);
    ctx.bezierCurveTo(38, 25, 33, 18, 24, 6);
    ctx.fill();
    return ctx.getImageData(0, 0, tam, tam);
  }

  /* ---------- Geometria da rota ---------- */

  function distancia(a, b) {
    var dx = (b[0] - a[0]) * Math.cos((a[1] + b[1]) * Math.PI / 360);
    var dy = b[1] - a[1];
    return Math.sqrt(dx * dx + dy * dy);
  }

  function medir(linha) {
    var acumulado = [0];
    for (var i = 1; i < linha.length; i++) { acumulado.push(acumulado[i - 1] + distancia(linha[i - 1], linha[i])); }
    return acumulado;
  }

  function pontoEm(linha, medidas, d) {
    if (d <= 0) { return linha[0]; }
    for (var i = 1; i < linha.length; i++) {
      if (medidas[i] >= d) {
        var t = (d - medidas[i - 1]) / ((medidas[i] - medidas[i - 1]) || 1);
        return [linha[i - 1][0] + (linha[i][0] - linha[i - 1][0]) * t, linha[i - 1][1] + (linha[i][1] - linha[i - 1][1]) * t];
      }
    }
    return linha[linha.length - 1];
  }

  /** Pedaço da linha entre as distâncias d0 e d1. */
  function cortar(linha, medidas, d0, d1) {
    if (d1 <= d0) { return []; }
    var trecho = [pontoEm(linha, medidas, d0)];
    for (var i = 0; i < linha.length; i++) {
      if (medidas[i] > d0 && medidas[i] < d1) { trecho.push(linha[i]); }
    }
    trecho.push(pontoEm(linha, medidas, d1));
    return trecho;
  }

  function linhaGeojson(coords) {
    return coords.length < 2 ? geojsonVazio()
      : { type: 'Feature', properties: {}, geometry: { type: 'LineString', coordinates: coords } };
  }

  /** Distância ao longo da linha até o vértice mais próximo do ponto. */
  function progressoNaLinha(linha, medidas, ponto) {
    var melhor = 0, menor = Infinity;
    for (var i = 0; i < linha.length; i++) {
      var d = distancia(linha[i], [ponto.lng, ponto.lat]);
      if (d < menor) { menor = d; melhor = i; }
    }
    return medidas[melhor];
  }

  /** Traçado pelas ruas no OSRM. Resolve com { coords, distanciaKm, duracaoMin, trechosMin, pelasRuas }
   *  (trechosMin: minutos de cada trecho entre pontos consecutivos). */
  function tracar(pontos) {
    if (pontos.length < 2) { return Promise.resolve(null); }
    var retas = pontos.map(function (p) { return [p.lng, p.lat]; });
    var coords = retas.map(function (c) { return c[0] + ',' + c[1]; }).join(';');
    return fetch(OSRM_URL + coords + '?overview=full&geometries=geojson')
      .then(function (r) { if (!r.ok) { throw new Error('OSRM ' + r.status); } return r.json(); })
      .then(function (dados) {
        var rota = dados.routes && dados.routes[0];
        if (dados.code !== 'Ok' || !rota) { throw new Error('OSRM sem rota'); }
        return {
          coords: rota.geometry.coordinates, distanciaKm: rota.distance / 1000, duracaoMin: rota.duration / 60,
          trechosMin: (rota.legs || []).map(function (l) { return l.duration / 60; }), pelasRuas: true
        };
      })
      .catch(function () { return { coords: retas, pelasRuas: false }; });
  }

  /** "≈ 190 km · 2 h 40 min de viagem" */
  function resumo(resultado) {
    if (!resultado || !resultado.pelasRuas) { return ''; }
    var h = Math.floor(resultado.duracaoMin / 60);
    var min = Math.round(resultado.duracaoMin % 60);
    var tempo = h > 0 ? h + ' h' + (min ? ' ' + min + ' min' : '') : min + ' min';
    return '≈ ' + Math.round(resultado.distanciaKm) + ' km · ' + tempo + ' de viagem';
  }

  function normalizar(texto) {
    return (texto || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\s+/g, ' ').trim().toLowerCase();
  }

  function suave(t) {
    return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }

  /* ---------- Pinos (HTML, animados por CSS em rota-mapa.css) ---------- */

  var SVG_ONIBUS = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="3" width="14" height="15" rx="3"></rect><path d="M5 11h14M8 21v-3M16 21v-3"></path></svg>';
  var SVG_GOTA = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2.5c-3.8 4.8-6.5 8.3-6.5 11.7a6.5 6.5 0 0 0 13 0c0-3.4-2.7-6.9-6.5-11.7z"></path></svg>';

  function elementoPino(ponto) {
    var el = document.createElement('div');
    el.className = 'rp rp--' + (ponto.tipo || 'parada');
    el.innerHTML = '<span class="rp__onda"></span>'
      + (ponto.tipo === 'fim' ? '<span class="rp__sombra"></span>' : '')
      + '<span class="rp__halo"></span>'
      + '<div class="rp__corpo"><div class="rp__batida">'
      + (ponto.tipo === 'inicio' ? '<span class="rp__disco">' + SVG_ONIBUS + '</span>'
        : ponto.tipo === 'fim' ? '<span class="rp__gota"><span class="rp__gota-icone">' + SVG_GOTA + '</span></span>'
          : '<span class="rp__disco"><span class="rp__num"></span></span>')
      + '</div></div>';
    preencherPino(el, ponto);
    return el;
  }

  function preencherPino(el, ponto) {
    var num = el.querySelector('.rp__num');
    if (num) { num.textContent = ponto.rotulo || ''; }
    el.classList.toggle('rp--meu', !!ponto.meu);
    el.title = ponto.nome || '';
    var etiqueta = el.querySelector('.rp__etiqueta');
    if (!ponto.etiqueta) {
      if (etiqueta) { etiqueta.remove(); }
      return;
    }
    if (!etiqueta) {
      etiqueta = document.createElement('div');
      el.appendChild(etiqueta);
    }
    etiqueta.className = 'rp__etiqueta' + (ponto.tipo === 'fim' ? ' rp__etiqueta--cartao' : '');
    etiqueta.textContent = '';
    if (ponto.etiqueta.linha) {
      var linha = document.createElement('span');
      linha.className = 'rp__etiqueta-linha';
      linha.textContent = ponto.etiqueta.linha;
      etiqueta.appendChild(linha);
    }
    var titulo = document.createElement('strong');
    titulo.textContent = ponto.etiqueta.titulo;
    etiqueta.appendChild(titulo);
  }

  function animarClasse(el, nome, duracaoMs) {
    if (semAnimacao()) { return; }
    el.classList.remove(nome);
    void el.offsetWidth; // reinicia a animação
    el.classList.add(nome);
    clearTimeout(el['_t_' + nome]);
    el['_t_' + nome] = setTimeout(function () { el.classList.remove(nome); }, duracaoMs);
  }

  /* ---------- Controle "Hemocentros de SP" (mostrar/ocultar) ---------- */

  function ControleHemocentros(mapa) {
    this.mapa = mapa;
  }

  ControleHemocentros.prototype.onAdd = function () {
    var self = this;
    this.el = document.createElement('div');
    this.el.className = 'maplibregl-ctrl rm-ctrl';
    var botao = document.createElement('button');
    botao.type = 'button';
    botao.className = 'rm-ctrl__hemocentros';
    botao.setAttribute('aria-pressed', 'true');
    botao.innerHTML = '<span class="rm-ctrl__gota">' + SVG_GOTA + '</span><span>Hemocentros de SP</span>';
    botao.addEventListener('click', function () {
      var ligado = botao.getAttribute('aria-pressed') !== 'true';
      botao.setAttribute('aria-pressed', String(ligado));
      self.mapa.mostrarHemocentros(ligado);
    });
    this.el.appendChild(botao);
    return this.el;
  };

  ControleHemocentros.prototype.onRemove = function () {
    this.el.remove();
  };

  /* ---------- O mapa ---------- */

  function Mapa(el, opcoes) {
    var self = this;
    this.el = el;
    this.opcoes = opcoes || {};
    this.marcadores = {};
    this.paleta = PALETAS[nomeDoTema()];

    el.classList.add('rota-mapa--carregando');
    this.map = new maplibregl.Map({
      container: el,
      style: estilo(this.paleta),
      bounds: ESTADO_SP,
      fitBoundsOptions: { padding: 24 },
      attributionControl: this.opcoes.compacto ? false : { compact: true },
      cooperativeGestures: false, // a rolagem do mouse aproxima o mapa direto, sem Ctrl/⌘
      interactive: !this.opcoes.compacto, // compacto: só mostra (canhoto do bilhete de divulgação)
      dragRotate: false,
      pitchWithRotate: false,
      touchPitch: false,
      maxPitch: 0,
      locale: TEXTOS
    });
    this.map.touchZoomRotate.disableRotation();
    this.map.keyboard.disableRotation();
    if (!this.opcoes.compacto) {
      this.map.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-left');
    } else {
      // Mapa compacto: créditos no alto, para não ficarem sob o cartão do hemocentro
      this.map.addControl(new maplibregl.AttributionControl({ compact: true }), 'top-right');
    }
    if (this.opcoes.hemocentros !== false) {
      this.map.addControl(new ControleHemocentros(this), 'top-right');
    }

    this.map.on('styleimagemissing', function (e) {
      if (e.id === 'gota' && !self.map.hasImage('gota')) {
        self.map.addImage('gota', imagemGota(self.paleta.gota), { pixelRatio: 2 });
      }
    });

    this.pronto = new Promise(function (ok) {
      self.map.on('load', function () {
        el.classList.remove('rota-mapa--carregando');
        if (self.opcoes.compacto) {
          // Créditos recolhidos no mapa pequeno (abrem no "i")
          var creditos = el.querySelector('.maplibregl-ctrl-attrib');
          if (creditos) { creditos.classList.remove('maplibregl-compact-show'); creditos.removeAttribute('open'); }
        }
        ok();
      });
    });

    if (this.opcoes.hemocentros !== false) {
      this.pronto.then(function () { self._carregarHemocentros(); });
    }

    // O site trocou de tema: repinta o mapa sem recarregar
    new MutationObserver(function () {
      var nova = PALETAS[nomeDoTema()];
      if (nova !== self.paleta) { self._aplicarPaleta(nova); }
    }).observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
  }

  Mapa.prototype._aplicarPaleta = function (p) {
    var map = this.map;
    this.paleta = p;
    this.pronto.then(function () {
      CAMADAS.forEach(function (c) {
        var pintura = c.paint(p);
        Object.keys(pintura).forEach(function (prop) { map.setPaintProperty(c.id, prop, pintura[prop]); });
      });
      if (map.hasImage('gota')) { map.updateImage('gota', imagemGota(p.gota)); }
    });
  };

  /* Pinos da rota: cria os novos (caindo), move os que mudaram (deslizando) e remove os que saíram. */
  Mapa.prototype.definirPontos = function (pontos, opts) {
    var self = this;
    opts = opts || {};
    this._optsPontos = opts;
    var vistos = {};
    pontos.forEach(function (ponto, i) {
      vistos[ponto.id] = true;
      var atual = self.marcadores[ponto.id];
      if (atual) {
        self._atualizarMarcador(atual, ponto);
      } else {
        self._criarMarcador(ponto, (opts.escalonar || 0) * i);
      }
    });
    Object.keys(this.marcadores).forEach(function (id) {
      if (!vistos[id]) { self._removerMarcador(id); }
    });
  };

  /** Adiciona um pino só (usado na página da campanha, quando o ônibus "passa" pelo ponto). */
  Mapa.prototype.adicionarPonto = function (ponto) {
    if (!this.marcadores[ponto.id]) { this._criarMarcador(ponto, 0); }
  };

  Mapa.prototype._criarMarcador = function (ponto, atraso) {
    var opts = this._optsPontos || {};
    var el = elementoPino(ponto);
    var marcador = new maplibregl.Marker({ element: el, anchor: 'center', draggable: !!opts.editavel })
      .setLngLat([ponto.lng, ponto.lat])
      .addTo(this.map);
    var registro = { marcador: marcador, el: el, ponto: ponto };
    this.marcadores[ponto.id] = registro;

    if (!semAnimacao()) {
      el.style.setProperty('--atraso', atraso + 'ms');
      el.classList.add('rp--entrando');
      setTimeout(function () { el.classList.remove('rp--entrando'); }, atraso + 1200);
    }

    el.addEventListener('click', function () {
      if (opts.aoClicar) { opts.aoClicar(registro.ponto.id); }
    });
    el.addEventListener('mouseenter', function () {
      el.classList.add('rp--destacado');
      if (opts.aoPassarMouse) { opts.aoPassarMouse(registro.ponto.id, true); }
    });
    el.addEventListener('mouseleave', function () {
      el.classList.remove('rp--destacado');
      if (opts.aoPassarMouse) { opts.aoPassarMouse(registro.ponto.id, false); }
    });
    if (ponto.tipo === 'fim') { this._celebrar(el, atraso); }
    if (opts.editavel) {
      marcador.on('dragstart', function () { el.classList.add('rp--levantado'); });
      marcador.on('dragend', function () {
        el.classList.remove('rp--levantado');
        animarClasse(el, 'rp--pousando', 700);
        var pos = marcador.getLngLat();
        registro.ponto = Object.assign({}, registro.ponto, { lat: pos.lat, lng: pos.lng });
        if (opts.aoArrastar) { opts.aoArrastar(registro.ponto.id, pos); }
      });
    }
  };

  /** Destaca o pino de um ponto (a pessoa passou o mouse ou o foco nele na lista). */
  Mapa.prototype.destacar = function (id, ligado) {
    var registro = this.marcadores[id];
    if (!registro) { return; }
    registro.el.classList.toggle('rp--destacado', !!ligado);
    if (ligado) { animarClasse(registro.el, 'rp--saltando', 520); }
  };

  /** Depois de salvar (data-celebrar na página), gotas saem do hemocentro assim que ele pousa. */
  Mapa.prototype._celebrar = function (el, atraso) {
    var raiz = document.documentElement;
    if (!raiz.hasAttribute('data-celebrar') || raiz.dataset.celebrado || !window.RotaGotas) { return; }
    raiz.dataset.celebrado = 'true';
    setTimeout(function () {
      var r = el.querySelector('.rp__corpo').getBoundingClientRect();
      var visivel = r.bottom > 0 && r.top < window.innerHeight && r.right > 0 && r.left < window.innerWidth;
      // Mapa fora da tela (a página voltou ao topo): as gotas saem do aviso de "salvo"
      if (!visivel) { r = (document.querySelector('.toast') || document.body).getBoundingClientRect(); }
      window.RotaGotas.estourar(r.left + r.width / 2, Math.max(40, r.top + Math.min(r.height, 80) / 2));
    }, (atraso || 0) + (semAnimacao() ? 0 : 650));
  };

  Mapa.prototype._atualizarMarcador = function (registro, ponto) {
    var antes = registro.ponto;
    registro.ponto = ponto;
    if (antes.rotulo !== ponto.rotulo) { animarClasse(registro.el, 'rp--renumerado', 500); }
    preencherPino(registro.el, ponto);
    if (Math.abs(antes.lat - ponto.lat) > 1e-7 || Math.abs(antes.lng - ponto.lng) > 1e-7) {
      this._deslizar(registro, [ponto.lng, ponto.lat]);
    }
  };

  /** O pino desliza até o novo endereço, levantado, e pousa com um quique. */
  Mapa.prototype._deslizar = function (registro, para) {
    var marcador = registro.marcador;
    var el = registro.el;
    cancelAnimationFrame(registro.quadro);
    var atual = marcador.getLngLat();
    var de = [atual.lng, atual.lat];
    if (semAnimacao()) { marcador.setLngLat(para); return; }
    var inicio = performance.now();
    var duracao = 700;
    el.classList.add('rp--voando');
    (function passo(agora) {
      var t = Math.min(1, (agora - inicio) / duracao);
      var e = suave(t);
      marcador.setLngLat([de[0] + (para[0] - de[0]) * e, de[1] + (para[1] - de[1]) * e]);
      if (t < 1) {
        registro.quadro = requestAnimationFrame(passo);
      } else {
        el.classList.remove('rp--voando');
        animarClasse(el, 'rp--pousando', 700);
      }
    })(inicio);
  };

  Mapa.prototype._removerMarcador = function (id) {
    var registro = this.marcadores[id];
    delete this.marcadores[id];
    cancelAnimationFrame(registro.quadro);
    if (semAnimacao()) { registro.marcador.remove(); return; }
    registro.el.classList.add('rp--saindo');
    setTimeout(function () { registro.marcador.remove(); }, 320);
  };

  /** Enquadra os pontos com um movimento suave de câmera. */
  Mapa.prototype.enquadrar = function (pontos, animar) {
    var map = this.map;
    var duracao = animar && !semAnimacao() ? 1100 : 0;
    if (!pontos.length) { return; }
    if (pontos.length === 1) {
      map.easeTo({ center: [pontos[0].lng, pontos[0].lat], zoom: 13, duration: duracao });
      return;
    }
    var limites = new maplibregl.LngLatBounds();
    pontos.forEach(function (p) { limites.extend([p.lng, p.lat]); });
    var margem = this.opcoes.compacto ? { top: 64, bottom: 78, left: 46, right: 46 } : { top: 80, bottom: 100, left: 100, right: 130 };
    map.fitBounds(limites, { padding: margem, maxZoom: 13, duration: duracao });
  };

  /**
   * Busca e desenha a rota. opts: divisao (índice do ponto onde começa o trecho do doador),
   * duracao (ms da animação), aoPassar(i) (a linha chegou ao ponto i).
   * Resolve com o traçado, ou null se outro pedido o substituiu.
   */
  Mapa.prototype.desenharRota = function (pontos, opts) {
    var self = this;
    opts = opts || {};
    var pedido = (this._pedidoRota || 0) + 1;
    this._pedidoRota = pedido;
    return Promise.all([this.pronto, tracar(pontos)]).then(function (r) {
      var resultado = r[1];
      if (self._pedidoRota !== pedido) { return null; }
      self._pararRota();
      if (!resultado) {
        self._atualizarRota(null, 0);
        return resultado;
      }
      var linha = resultado.coords;
      var medidas = medir(linha);
      var marcos = pontos.map(function (p) { return progressoNaLinha(linha, medidas, p); });
      self._rota = {
        linha: linha, medidas: medidas, total: medidas[medidas.length - 1],
        corte: opts.divisao != null ? marcos[opts.divisao] : 0
      };
      self._animarRota(opts.duracao == null ? 1400 : opts.duracao, marcos, opts.aoPassar);
      return resultado;
    });
  };

  Mapa.prototype._atualizarRota = function (rota, d) {
    var map = this.map;
    if (!rota) {
      ['rota-borda', 'rota-antes', 'rota-trecho'].forEach(function (id) { map.getSource(id).setData(geojsonVazio()); });
      return;
    }
    map.getSource('rota-borda').setData(linhaGeojson(cortar(rota.linha, rota.medidas, 0, d)));
    map.getSource('rota-antes').setData(linhaGeojson(cortar(rota.linha, rota.medidas, 0, Math.min(d, rota.corte))));
    map.getSource('rota-trecho').setData(linhaGeojson(cortar(rota.linha, rota.medidas, rota.corte, d)));
  };

  /** A linha "se desenha" da partida ao hemocentro. */
  Mapa.prototype._animarRota = function (duracao, marcos, aoPassar) {
    var self = this;
    var rota = this._rota;
    var passou = marcos.map(function () { return false; });
    function avisar(d) {
      marcos.forEach(function (m, i) {
        if (!passou[i] && m <= d + 1e-9) {
          passou[i] = true;
          if (aoPassar) { aoPassar(i); }
        }
      });
    }
    if (semAnimacao() || duracao <= 0) {
      this._atualizarRota(rota, rota.total);
      avisar(rota.total);
      return Promise.resolve();
    }
    return new Promise(function (ok) {
      var inicio = performance.now();
      (function passo(agora) {
        if (self._rota !== rota) { ok(); return; }
        var t = Math.min(1, (agora - inicio) / duracao);
        var d = suave(t) * rota.total;
        self._atualizarRota(rota, d);
        avisar(d);
        if (t < 1) {
          self._quadroRota = requestAnimationFrame(passo);
        } else {
          ok();
        }
      })(inicio);
    });
  };

  Mapa.prototype._pararRota = function () {
    cancelAnimationFrame(this._quadroRota);
    this._rota = null;
  };

  /* ---------- Hemocentros de SP ---------- */

  Mapa.prototype._carregarHemocentros = function () {
    var self = this;
    fetch(HEMOCENTROS_URL)
      .then(function (r) { if (!r.ok) { throw new Error(r.status); } return r.json(); })
      .then(function (dados) {
        self._hemocentros = dados.hemocentros || [];
        self._atualizarHemocentros();
        self._interacoesHemocentros();
        // Aparecem suavemente depois que o mapa se ajeita
        setTimeout(function () { self.mostrarHemocentros(true); }, semAnimacao() ? 0 : 500);
      })
      .catch(function () { /* sem a lista, o mapa mostra só a rota */ });
  };

  /** Esconde da camada "outros" o hemocentro que já é o destino da rota. */
  Mapa.prototype.destacarHemocentro = function (lng, lat, nome) {
    this._destino = lng == null ? null : { coords: [lng, lat], nome: normalizar(nome) };
    this._atualizarHemocentros();
  };

  Mapa.prototype._atualizarHemocentros = function () {
    var self = this;
    if (!this._hemocentros) { return; }
    var destino = this._destino;
    var features = [];
    this._hemocentros.forEach(function (h, i) {
      // É o mesmo lugar do destino (mesmo nome, ou a menos de ~800 m): não repete a gota
      if (destino && (distancia(destino.coords, [h.lng, h.lat]) < 0.008 || (destino.nome && normalizar(h.nome) === destino.nome))) { return; }
      features.push({ type: 'Feature', properties: { indice: i }, geometry: { type: 'Point', coordinates: [h.lng, h.lat] } });
    });
    this.pronto.then(function () { self.map.getSource('hemocentros').setData({ type: 'FeatureCollection', features: features }); });
  };

  Mapa.prototype.mostrarHemocentros = function (ligado) {
    var self = this;
    var map = this.map;
    this._hcLigado = ligado;
    this.pronto.then(function () {
      Object.keys(OPACIDADE_HC).forEach(function (id) {
        if (ligado) { map.setLayoutProperty(id, 'visibility', 'visible'); }
        OPACIDADE_HC[id].forEach(function (prop) { map.setPaintProperty(id, prop, ligado ? 1 : 0); });
      });
      if (!ligado) {
        if (self._popup) { self._popup.remove(); }
        // Depois do esmaecer, tira do mapa (para não receber cliques invisíveis)
        setTimeout(function () {
          if (self._hcLigado) { return; }
          Object.keys(OPACIDADE_HC).forEach(function (id) { map.setLayoutProperty(id, 'visibility', 'none'); });
        }, 750);
      }
    });
  };

  Mapa.prototype._sobreHemocentro = function (ponto) {
    var map = this.map;
    return CAMADAS_HC.every(function (id) { return map.getLayer(id); })
      && map.queryRenderedFeatures(ponto, { layers: CAMADAS_HC }).length > 0;
  };

  Mapa.prototype._interacoesHemocentros = function () {
    var self = this;
    var map = this.map;
    var popup = new maplibregl.Popup({ closeButton: false, closeOnClick: false, offset: 14, className: 'rm-popup', maxWidth: '260px' });
    this._popup = popup;
    var fixo = false;

    function conteudo(h, comBotao) {
      var caixa = document.createElement('div');
      caixa.className = 'rm-popup__conteudo';
      var linha = document.createElement('span');
      linha.className = 'rm-popup__linha';
      linha.textContent = 'Hemocentro · ' + h.cidade;
      var nome = document.createElement('strong');
      nome.textContent = h.nome;
      caixa.appendChild(linha);
      caixa.appendChild(nome);
      if (h.rua) {
        var endereco = document.createElement('span');
        endereco.textContent = h.rua + (h.numero ? ', ' + h.numero : '');
        caixa.appendChild(endereco);
      }
      if (comBotao && self.opcoes.aoEscolherHemocentro) {
        var botao = document.createElement('button');
        botao.type = 'button';
        botao.className = 'rm-popup__botao';
        botao.textContent = 'Usar como hemocentro da rota';
        botao.addEventListener('click', function () {
          popup.remove();
          fixo = false;
          self.opcoes.aoEscolherHemocentro(h);
        });
        caixa.appendChild(botao);
      }
      return caixa;
    }

    function hemocentroDo(e) {
      var f = e.features && e.features[0];
      return f && self._hemocentros[f.properties.indice];
    }

    map.on('mouseenter', 'hc-ponto', function (e) {
      map.getCanvas().style.cursor = 'pointer';
      var h = hemocentroDo(e);
      if (h && !fixo) { popup.setLngLat([h.lng, h.lat]).setDOMContent(conteudo(h, false)).addTo(map); }
    });
    map.on('mouseleave', 'hc-ponto', function () {
      map.getCanvas().style.cursor = self._cursor || '';
      if (!fixo) { popup.remove(); }
    });
    map.on('click', 'hc-ponto', function (e) {
      var h = hemocentroDo(e);
      if (!h) { return; }
      fixo = true;
      popup.setLngLat([h.lng, h.lat]).setDOMContent(conteudo(h, true)).addTo(map);
    });
    // Clique fora de um hemocentro fecha o balão
    map.on('click', function (e) {
      if (!self._sobreHemocentro(e.point)) {
        fixo = false;
        popup.remove();
      }
    });

    map.on('mouseenter', 'hc-grupo', function () { map.getCanvas().style.cursor = 'pointer'; });
    map.on('mouseleave', 'hc-grupo', function () { map.getCanvas().style.cursor = self._cursor || ''; });
    map.on('click', 'hc-grupo', function (e) {
      var f = e.features && e.features[0];
      if (!f) { return; }
      map.getSource('hemocentros').getClusterExpansionZoom(f.properties.cluster_id).then(function (zoom) {
        map.easeTo({ center: f.geometry.coordinates, zoom: zoom + 0.5, duration: semAnimacao() ? 0 : 700 });
      });
    });
  };

  /* ---------- Clique no mapa (marcar um ponto) ---------- */

  Mapa.prototype.aoClicar = function (fn) {
    var self = this;
    this.map.on('click', function (e) {
      if (self._sobreHemocentro(e.point)) { return; } // o clique foi num hemocentro ou grupo
      fn(e.lngLat);
    });
  };

  Mapa.prototype.definirCursor = function (cursor) {
    this._cursor = cursor || '';
    this.map.getCanvas().style.cursor = this._cursor;
    this.el.classList.toggle('rota-mapa--marcando', !!cursor);
  };

  /* ---------- Página da campanha: sequência de abertura ---------- */

  function lerPontos(seletor, semEtiquetas) {
    var pontos = [];
    document.querySelectorAll(seletor).forEach(function (el) {
      var lat = parseFloat(el.dataset.lat);
      var lng = parseFloat(el.dataset.lng);
      if (isNaN(lat) || isNaN(lng)) { return; }
      el.dataset.pontoId = 'p' + pontos.length;
      var ponto = {
        id: 'p' + pontos.length, lat: lat, lng: lng, nome: el.dataset.nome, tipo: el.dataset.tipo,
        rotulo: el.dataset.rotulo, meu: el.dataset.meu === 'true'
      };
      var horario = el.dataset.horario;
      if (semEtiquetas) {
        // mapa compacto: só os pinos
      } else if (ponto.tipo === 'fim') {
        ponto.etiqueta = { linha: (ponto.meu ? 'Você vai direto' : 'Hemocentro') + (horario ? ' · ' + horario : ''), titulo: ponto.nome };
      } else if (ponto.meu) {
        ponto.etiqueta = { titulo: 'Seu embarque' + (horario ? ' · ' + horario : '') };
      }
      pontos.push(ponto);
    });
    return pontos;
  }

  function iniciarMapasDaPagina() {
    document.querySelectorAll('[data-rota-mapa]').forEach(function (el) {
      if (!el.getClientRects().length) { return; } // escondido nesta tela (ex.: canhoto do bilhete no celular)
      var compacto = el.hasAttribute('data-rota-compacto');
      var pontos = lerPontos(el.dataset.rotaMapa, compacto);
      if (pontos.length < 2 || !window.maplibregl) {
        (el.closest('[data-rota-mapa-bloco]') || el).hidden = true;
        return;
      }
      var mapa;
      try {
        mapa = new Mapa(el, { hemocentros: !compacto, compacto: compacto });
      } catch (e) { // sem WebGL (aparelho antigo ou navegador restrito): esconde o mapa e segue com o resto da página
        (el.closest('[data-rota-mapa-bloco]') || el).hidden = true;
        return;
      }
      var fim = pontos.filter(function (p) { return p.tipo === 'fim'; })[0];
      if (fim) { mapa.destacarHemocentro(fim.lng, fim.lat, fim.nome); }
      var divisao = null;
      pontos.forEach(function (p, i) { if (p.meu && p.tipo !== 'fim') { divisao = i; } });
      var legenda = el.dataset.rotaResumo && document.querySelector(el.dataset.rotaResumo);

      // Linha do tempo ↔ mapa: o item e o pino se destacam juntos
      var itens = {};
      document.querySelectorAll(el.dataset.rotaMapa).forEach(function (item) {
        if (!item.dataset.pontoId) { return; }
        itens[item.dataset.pontoId] = item;
        ['mouseenter', 'focusin'].forEach(function (ev) {
          item.addEventListener(ev, function () { mapa.destacar(item.dataset.pontoId, true); });
        });
        ['mouseleave', 'focusout'].forEach(function (ev) {
          item.addEventListener(ev, function () { mapa.destacar(item.dataset.pontoId, false); });
        });
      });

      mapa.pronto.then(function () {
        mapa.definirPontos([], {
          aoPassarMouse: function (id, ligado) {
            if (itens[id]) { itens[id].classList.toggle('is-destacado', ligado); }
          }
        });
        mapa.enquadrar(pontos, true);
        // A câmera chega e a linha se desenha, deixando os pinos pelo trajeto
        setTimeout(function () {
          mapa.desenharRota(pontos, {
            divisao: divisao,
            duracao: 2400,
            aoPassar: function (i) { mapa.adicionarPonto(pontos[i]); }
          }).then(function (resultado) {
            pontos.forEach(function (p) { mapa.adicionarPonto(p); });
            if (legenda && resultado) {
              legenda.textContent = resultado.pelasRuas ? resumo(resultado) : 'Traçado aproximado entre os pontos';
            }
          });
        }, semAnimacao() ? 0 : 900);
      });
    });
  }

  window.RotaMapa = {
    criar: function (el, opcoes) { return new Mapa(el, opcoes); },
    resumo: resumo,
    semAnimacao: semAnimacao
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', iniciarMapasDaPagina);
  } else {
    iniciarMapasDaPagina();
  }
})();
