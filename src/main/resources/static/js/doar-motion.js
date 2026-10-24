/* Movimento da landing /doar (direção M1, "Rota viva"). O hero anima só com CSS; este script cuida do resto:
 *   - blocos com [data-anima] ganham .visivel quando aparecem na tela (uma vez só);
 *   - "até 4 vidas": o número conta de 1 a 4 junto com as gotas batendo;
 *   - chamada final: gotas saem do botão (static/js/gotas.js);
 *   - a seta do botão principal para de empurrar quando a pessoa rola a página.
 * Com "Reduzir movimento" (painel ou sistema) não faz nada: a página já está no estado final. */
(function () {
  'use strict';

  var raiz = document.documentElement;
  var semAnimacao = raiz.getAttribute('data-motion') === 'reduce'
    || (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  if (semAnimacao || !('IntersectionObserver' in window)) { return; }

  // Só agora os blocos começam escondidos (sem JS, tudo aparece normalmente)
  raiz.classList.add('motion-pronto');

  function contarVidas(bloco) {
    var contador = bloco.querySelector('[data-contador]');
    if (!contador) { return; }
    contador.textContent = '1';
    [2, 3, 4].forEach(function (n, i) {
      setTimeout(function () { contador.textContent = String(n); }, 1530 + i * 230);
    });
  }

  function estourarGotas(bloco) {
    var botao = bloco.querySelector('[data-gotas-do]');
    if (!botao || !window.RotaGotas) { return; }
    setTimeout(function () {
      var r = botao.getBoundingClientRect();
      window.RotaGotas.estourar(r.left + r.width / 2, r.top + r.height / 2, { quantidade: 22 });
    }, 950);
  }

  function aoAparecer(entradas, obs) {
    entradas.forEach(function (e) {
      if (!e.isIntersecting) { return; }
      var bloco = e.target;
      obs.unobserve(bloco);
      bloco.classList.add('visivel');
      if (bloco.hasAttribute('data-anima-vidas')) { contarVidas(bloco); }
      if (bloco.hasAttribute('data-anima-gotas')) { estourarGotas(bloco); }
    });
  }

  // Cada bloco pode pedir quanto dele precisa estar na tela para começar (data-anima-limiar; padrão 25%).
  // O celular do mobile usa 60%: a animação só roda quando ele está de fato à vista.
  var observadores = {};
  document.querySelectorAll('[data-anima]').forEach(function (bloco) {
    var limiar = parseFloat(bloco.getAttribute('data-anima-limiar')) || 0.25;
    if (!observadores[limiar]) {
      observadores[limiar] = new IntersectionObserver(aoAparecer, { threshold: limiar });
    }
    observadores[limiar].observe(bloco);
  });

  // A seta do botão principal é o único movimento contínuo: para quando a pessoa começa a rolar
  function aoRolar() {
    if (window.scrollY > 80) {
      raiz.classList.add('doar-rolou');
      window.removeEventListener('scroll', aoRolar);
    }
  }
  window.addEventListener('scroll', aoRolar, { passive: true });
  aoRolar();
})();
