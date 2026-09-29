<#-- Painel de acessibilidade: aberto pelo botão do header (.a11y-toggle). No desktop é um menu suspenso;
     no celular sobe da parte de baixo da tela. Comportamento em includes/scripts.ftlh. -->
<div class="a11y-backdrop" data-a11y-close hidden></div>
<section class="a11y-panel" id="a11y-panel" role="dialog" aria-labelledby="a11y-title" hidden>
  <span class="a11y-panel__handle" aria-hidden="true"></span>
  <div class="a11y-panel__head">
    <h2 id="a11y-title">Acessibilidade</h2>
    <button type="button" class="a11y-close" aria-label="Fechar" data-a11y-close><span class="icon" aria-hidden="true">close</span></button>
  </div>

  <fieldset class="a11y-group">
    <legend>Tamanho do texto</legend>
    <div class="segmented" data-pref="text">
      <button type="button" class="size-a" data-value="normal" aria-label="Texto normal">A</button>
      <button type="button" class="size-a-plus" data-value="large" aria-label="Texto grande">A+</button>
      <button type="button" class="size-a-plus-plus" data-value="xlarge" aria-label="Texto muito grande">A++</button>
    </div>
  </fieldset>

  <fieldset class="a11y-group">
    <legend>Tema</legend>
    <div class="segmented" data-pref="theme">
      <button type="button" data-value="light"><span class="icon" aria-hidden="true">light_mode</span>Claro</button>
      <button type="button" data-value="dark"><span class="icon" aria-hidden="true">dark_mode</span>Escuro</button>
      <button type="button" data-value="system"><span class="icon" aria-hidden="true">contrast</span>Sistema</button>
    </div>
  </fieldset>

  <div class="a11y-switches">
    <div class="a11y-switch-row">
      <span><strong id="a11y-contrast-label">Alto contraste</strong><small>Textos e bordas mais fortes</small></span>
      <button type="button" class="switch" role="switch" aria-checked="false" aria-labelledby="a11y-contrast-label" data-pref="contrast"><span class="switch__thumb"></span></button>
    </div>
    <div class="a11y-switch-row">
      <span><strong id="a11y-motion-label">Reduzir movimento</strong><small>Desliga animações e transições</small></span>
      <button type="button" class="switch" role="switch" aria-checked="false" aria-labelledby="a11y-motion-label" data-pref="motion"><span class="switch__thumb"></span></button>
    </div>
    <div class="a11y-switch-row">
      <span><strong id="a11y-links-label">Destacar links</strong><small>Sublinha os links da página</small></span>
      <button type="button" class="switch" role="switch" aria-checked="false" aria-labelledby="a11y-links-label" data-pref="links"><span class="switch__thumb"></span></button>
    </div>
  </div>

  <button type="button" class="btn btn-primary a11y-done" data-a11y-close>Pronto</button>
</section>
