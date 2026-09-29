<#-- Aplica tema e preferências de acessibilidade antes da página aparecer (evita "piscar" no tema errado).
     As preferências ficam no navegador (localStorage "rs-a11y") e são editadas no painel de acessibilidade. -->
<script>
  (function () {
    var prefs = {};
    try { prefs = JSON.parse(localStorage.getItem('rs-a11y') || '{}') || {}; } catch (e) { prefs = {}; }
    var root = document.documentElement;
    var darkQuery = window.matchMedia('(prefers-color-scheme: dark)');

    function setAttr(name, value) {
      if (value) root.setAttribute(name, value); else root.removeAttribute(name);
    }

    function apply() {
      // Padrão: tema claro. O escuro só vale se a pessoa escolher "Escuro" ou "Sistema" (com o sistema no escuro)
      var dark = prefs.theme === 'dark' || (prefs.theme === 'system' && darkQuery.matches);
      root.setAttribute('data-theme', dark ? 'dark' : 'light');
      setAttr('data-text', prefs.text && prefs.text !== 'normal' ? prefs.text : null);
      setAttr('data-contrast', prefs.contrast ? 'high' : null);
      setAttr('data-motion', prefs.motion ? 'reduce' : null);
      setAttr('data-links', prefs.links ? 'underline' : null);
    }

    window.rsA11y = {
      prefs: prefs,
      apply: apply,
      save: function () {
        try { localStorage.setItem('rs-a11y', JSON.stringify(prefs)); } catch (e) { /* navegação privada */ }
      }
    };

    apply();
    if (darkQuery.addEventListener) darkQuery.addEventListener('change', apply);
  })();
</script>
