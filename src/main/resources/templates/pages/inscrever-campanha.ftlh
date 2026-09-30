<#import "../layout/main.ftlh" as main>

<#-- Inscrição em campanha: formulário à esquerda, resumo fixo com o botão de confirmar à direita
     (no celular o resumo vem depois do formulário). -->
<@main.layout title="Inscrição em Campanha - Rota Solidária" css="/css/inscrever-campanha.css" currentNav="campanhas">
  <main class="container signup-page">
    <div class="signup-top">
      <a class="back-link" href="/campanhas/${campanha.id?c}"><span class="icon" aria-hidden="true">arrow_back</span>Voltar para a campanha</a>
      <ol class="signup-steps" aria-label="Etapas da inscrição">
        <li class="is-current" aria-current="step"><span class="signup-steps__num">1</span>Inscrição</li>
        <li class="signup-steps__line" aria-hidden="true"></li>
        <li><span class="signup-steps__num">2</span>Bilhete</li>
      </ol>
    </div>

    <div class="signup-grid">
      <form class="signup-form" id="inscricao-form" method="post" action="/campanhas/${campanha.id?c}/inscrever">
        <#include "../includes/csrf.ftlh">

        <div class="signup-intro">
          <span class="kicker">Inscrição</span>
          <h1>Reservar sua vaga</h1>
          <p>Confira seus dados, escolha onde embarcar e pronto: o bilhete sai na hora.</p>
        </div>

        <section class="signup-section" aria-labelledby="sec-dados">
          <h2 id="sec-dados"><span class="signup-num" aria-hidden="true">1</span>Seus dados</h2>
          <div class="account-row">
            <span class="account-avatar" aria-hidden="true">${(usuario.name?keep_before(" ")?substring(0, 1))!"U"}${(usuario.name?keep_after(" ")?substring(0, 1))!""}</span>
            <div class="account-info">
              <strong>${usuario.name}</strong>
              <#if usuario.phone?? && usuario.phone?has_content>
                <span>WhatsApp ${usuario.phone}</span>
              <#else>
                <span class="account-missing">Adicione seu WhatsApp para o organizador falar com você</span>
              </#if>
            </div>
            <a href="/perfil#editar">Alterar no perfil</a>
          </div>
        </section>

        <fieldset class="signup-section">
          <legend><span class="signup-num" aria-hidden="true">2</span>Onde você vai embarcar?</legend>
          <div class="boarding-options">
            <#list opcoesEmbarque as opcao>
              <label class="boarding-card">
                <input type="radio" name="embarque" value="${opcao}" required<#if opcao?is_first> checked</#if>>
                <span class="boarding-card__text">
                  <strong>${opcao}</strong>
                  <#if opcao == transporteProprio>
                    <span><#if campanha.donationTime??>Encontro no hemocentro às <span class="mono">${campanha.donationTime}</span><#else>Encontro direto no hemocentro</#if></span>
                  <#else>
                    <span><#if campanha.departureTime??>Ônibus sai às <span class="mono">${campanha.departureTime}</span> · gratuito<#else>Transporte gratuito · horário a confirmar</#if></span>
                  </#if>
                </span>
                <span class="icon boarding-card__icon" aria-hidden="true"><#if opcao == transporteProprio>directions_car<#else>directions_bus</#if></span>
              </label>
            </#list>
          </div>
        </fieldset>

        <section class="signup-section">
          <h2><span class="signup-num" aria-hidden="true">3</span><span class="signup-heading"><label for="rs-obs">Algo que o organizador precise saber?</label><span class="signup-optional">opcional</span></span></h2>
          <textarea id="rs-obs" name="observacoes" rows="3" maxlength="500" placeholder="Ex.: vou com acompanhante, preciso de assento na frente…"></textarea>
        </section>

        <label class="consent">
          <input type="checkbox" name="lgpd" required>
          <span>Autorizo o envio do meu nome e WhatsApp ao organizador da campanha, conforme a LGPD.</span>
        </label>
      </form>

      <aside class="summary" aria-label="Resumo da campanha">
        <img class="summary__img" src="${campanha.imageUrl!"/images/doacaodesangue.jpeg"}" alt="">
        <div class="summary__body">
          <div class="summary__slots">
            <#if vagasRestantes gt 0>
              <span class="badge badge-open"><span class="dot"></span>${vagasRestantes} <#if vagasRestantes == 1>vaga restante<#else>vagas restantes</#if></span>
            <#else>
              <span class="badge badge-closed"><span class="dot"></span>Vagas esgotadas</span>
            </#if>
            <span class="mono muted">de ${campanha.slots!0}</span>
          </div>

          <h2 class="summary__title">${campanha.title}</h2>
          <#if dataExtenso??>
            <span class="summary__date"><span class="icon" aria-hidden="true">calendar_month</span>${dataExtenso}</span>
          </#if>

          <ol class="summary__route">
            <li>
              <span class="summary__dot" aria-hidden="true"></span>
              <span class="summary__stop">
                <span class="mono"><#if campanha.departureTime??>${campanha.departureTime} · </#if>Embarque</span>
                <span><#if campanha.departureLocation??>${campanha.departureLocation.name}<#if campanha.departureLocation.city??>, ${campanha.departureLocation.city}</#if><#else>Na sua cidade</#if></span>
              </span>
            </li>
            <li>
              <span class="summary__dot summary__dot--end" aria-hidden="true"></span>
              <span class="summary__stop">
                <span class="mono"><#if campanha.donationTime??>${campanha.donationTime} · </#if>Doação</span>
                <#if campanha.donationLocation??>
                  <span>${campanha.donationLocation.name}<#if campanha.donationLocation.city??>, ${campanha.donationLocation.city}</#if></span>
                </#if>
              </span>
            </li>
          </ol>

          <div class="summary__divider"></div>
          <button class="btn btn-primary btn-lg summary__cta" type="submit" form="inscricao-form"<#if vagasRestantes lte 0> disabled</#if>>
            Confirmar inscrição<span class="icon" aria-hidden="true">arrow_forward</span>
          </button>
          <span class="summary__note"><span class="icon" aria-hidden="true">confirmation_number</span>Você recebe o bilhete de embarque na hora.</span>
        </div>
      </aside>
    </div>
  </main>
</@main.layout>
