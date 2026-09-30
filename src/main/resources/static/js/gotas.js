/* Estouro de gotas de sangue: comemora uma inscrição confirmada ou uma campanha salva.
 * Carregado só quando a página tem data-celebrar (flash "celebrar" do controller).
 *   - Com [data-gotas-origem] na página, as gotas saem desse elemento (ex.: o selo do bilhete);
 *   - no editor da campanha, rota-mapa.js chama RotaGotas.estourar() quando a gota do hemocentro pousa.
 * Nada acontece com "Reduzir movimento" ligado. */
(function () {
  'use strict';

  var CORES = ['#B4232A', '#D4454C', '#8F1821', '#E0636A', '#F2969B'];
  var GOTA = 'M12 2.5c-3.8 4.8-6.5 8.3-6.5 11.7a6.5 6.5 0 0 0 13 0c0-3.4-2.7-6.9-6.5-11.7z';

  function semAnimacao() {
    return document.documentElement.getAttribute('data-motion') === 'reduce'
      || (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  }

  function aleatorio(min, max) {
    return min + Math.random() * (max - min);
  }

  function criarGota(tamanho, cor) {
    var ns = 'http://www.w3.org/2000/svg';
    var svg = document.createElementNS(ns, 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('width', tamanho);
    svg.setAttribute('height', tamanho);
    svg.setAttribute('aria-hidden', 'true');
    var caminho = document.createElementNS(ns, 'path');
    caminho.setAttribute('d', GOTA);
    caminho.setAttribute('fill', cor);
    svg.appendChild(caminho);
    svg.style.cssText = 'position:fixed;left:0;top:0;pointer-events:none;z-index:9999;will-change:transform,opacity;'
      + 'filter:drop-shadow(0 2px 2px rgba(143,24,33,.25))';
    return svg;
  }

  /** Um anel que se abre no ponto de origem, antes das gotas. */
  function anel(x, y) {
    var el = document.createElement('span');
    el.style.cssText = 'position:fixed;left:' + (x - 20) + 'px;top:' + (y - 20) + 'px;width:40px;height:40px;'
      + 'border-radius:50%;border:3px solid #B4232A;pointer-events:none;z-index:9998;box-sizing:border-box';
    document.body.appendChild(el);
    el.animate([
      { transform: 'scale(.3)', opacity: 0.9 },
      { transform: 'scale(2.8)', opacity: 0 }
    ], { duration: 650, easing: 'cubic-bezier(.2,.7,.3,1)' }).onfinish = function () { el.remove(); };
  }

  /**
   * Solta as gotas a partir de (x, y) na tela: sobem em leque, giram e caem com a gravidade.
   * opts.quantidade (padrão 26).
   */
  function estourar(x, y, opts) {
    if (semAnimacao() || !document.body.animate) { return; }
    opts = opts || {};
    var quantidade = opts.quantidade || 26;
    anel(x, y);
    for (var i = 0; i < quantidade; i++) {
      (function (i) {
        var tamanho = aleatorio(9, 20);
        var gota = criarGota(tamanho, CORES[i % CORES.length]);
        document.body.appendChild(gota);

        // Leque para cima (entre -160° e -20°), com velocidade e giro aleatórios
        var angulo = aleatorio(-160, -20) * Math.PI / 180;
        var velocidade = aleatorio(260, 520);          // px/s
        var vx = Math.cos(angulo) * velocidade;
        var vy = Math.sin(angulo) * velocidade;
        var gravidade = 980;                            // px/s²
        var duracao = aleatorio(1.1, 1.6);              // s
        var giro = aleatorio(-220, 220);
        var quadros = [];
        var passos = 14;
        for (var p = 0; p <= passos; p++) {
          var t = duracao * p / passos;
          var dx = vx * t;
          var dy = vy * t + gravidade * t * t / 2;
          var escala = p === 0 ? 0.2 : p === 1 ? 1.15 : 1;
          quadros.push({
            transform: 'translate(' + (x - tamanho / 2 + dx) + 'px,' + (y - tamanho / 2 + dy) + 'px) rotate(' + (giro * p / passos) + 'deg) scale(' + escala + ')',
            opacity: p < passos * 0.65 ? 1 : 1 - (p - passos * 0.65) / (passos * 0.35)
          });
        }
        gota.animate(quadros, { duration: duracao * 1000, delay: i * 12, easing: 'linear', fill: 'both' })
          .onfinish = function () { gota.remove(); };
      })(i);
    }
  }

  window.RotaGotas = { estourar: estourar };

  function automatico() {
    var raiz = document.documentElement;
    if (!raiz.hasAttribute('data-celebrar')) { return; }
    var origem = document.querySelector('[data-gotas-origem]');
    if (!origem) { return; } // sem origem na página: quem chama é o mapa (editor da campanha)
    raiz.dataset.celebrado = 'true';
    setTimeout(function () {
      var r = origem.getBoundingClientRect();
      estourar(r.left + r.width / 2, r.top + r.height / 2);
    }, 350);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', automatico);
  } else {
    automatico();
  }
})();
