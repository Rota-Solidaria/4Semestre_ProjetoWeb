<#--
  Toast "Pulso": aviso temporário no rodapé da tela.
  Recebe o atributo "toast" (com.rotasolidaria.controllers.Toast) do controller ou de um flash attribute.
  A linha de pulso na base é o cronômetro: quando termina de ser desenhada, o toast some (includes/scripts.ftlh).
-->
<div class="toast-region" aria-live="polite">
  <#if toast??>
    <div class="toast toast--${toast.type}" role="${(toast.type == "error")?then("alert", "status")}" data-toast style="--toast-duration: ${toast.duration?c}ms">
      <div class="toast__body">
        <span class="toast__drop" aria-hidden="true"><span class="icon">${toast.icon}</span></span>
        <div class="toast__text">
          <p class="toast__title">${toast.title}</p>
          <#if toast.message??><p class="toast__message">${toast.message}</p></#if>
        </div>
        <#if toast.actionUrl??>
          <a class="toast__action" href="${toast.actionUrl}">${toast.actionLabel}</a>
        </#if>
        <button type="button" class="toast__close" aria-label="Fechar aviso" data-toast-close>
          <span class="icon" aria-hidden="true">close</span>
        </button>
      </div>
      <div class="toast__pulse" aria-hidden="true">
        <svg class="toast__pulse-track" width="100%" height="14" viewBox="0 0 440 14" preserveAspectRatio="none" fill="none"><path d="M0 9 H296 L301 9 L305 2 L310 13 L314 6 L317 9 H440" vector-effect="non-scaling-stroke"/></svg>
        <svg class="toast__pulse-fill" width="100%" height="14" viewBox="0 0 440 14" preserveAspectRatio="none" fill="none"><path d="M0 9 H296 L301 9 L305 2 L310 13 L314 6 L317 9 H440" vector-effect="non-scaling-stroke"/></svg>
      </div>
    </div>
  </#if>
</div>
