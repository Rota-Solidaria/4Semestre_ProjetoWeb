<#import "../layout/main.ftlh" as main>

<@main.layout title="Inscrição em Campanha" css="/css/inscrever-campanha.css" currentNav="campanhas">
  <main>
    <div class="container section">

      <!-- Etapas -->
      <div class="step-track">
        <span class="step-pill">
          <span class="step-dot">1</span>
          Inscrição
        </span>

        <span class="step-line"></span>

        <span class="step-pill step-inactive">
          <span class="step-dot">2</span>
          Confirmação
        </span>
      </div>


      <div class="form-layout">

        <div class="form-panel">

          <span class="kicker">Inscrição</span>

          <h1>Reservar vaga</h1>

          <p>
            Confira seus dados e escolha as informações da sua participação.
          </p>


          <!-- Dados da conta -->
          <div class="account-box">

            <div class="account-header">
              <span class="icon">account_circle</span>

              <div>
                <strong>Dados da sua conta</strong>
                <span>Informações cadastradas no seu perfil</span>
              </div>
            </div>

            <div class="account-data">

              <div class="account-field">
                <span class="account-label">Nome</span>
                <strong>${usuario.name}</strong>
              </div>

              <div class="account-field">
                <span class="account-label">WhatsApp</span>
                <strong><#if usuario.phone?? && usuario.phone?has_content>${usuario.phone}<#else><a href="/perfil#editar">Adicionar no perfil</a></#if></strong>
              </div>

            </div>

          </div>


          <div class="notice-box">
            Seus dados pessoais já estão cadastrados na sua conta e serão utilizados automaticamente nesta inscrição.
          </div>


          <form method="post" action="/campanhas/${campanha.id}/inscrever">
            <#include "../includes/csrf.ftlh">

            <div class="form-grid">

              <!-- Cidade -->
              <div class="field full">

                <label for="rs-emb">
                  Local de embarque
                </label>

                <select id="rs-emb" name="embarque" required>
                  <option value="">Selecione o local de embarque</option>
                  <#list opcoesEmbarque as opcao>
                    <option>${opcao}</option>
                  </#list>
                </select>

              </div>


              <!-- Observações -->
              <div class="field full">

                <label for="rs-obs">
                  Observações
                  <span class="hint">· opcional</span>
                </label>

                <textarea
                  id="rs-obs"
                  name="observacoes"
                  rows="3"
                  placeholder="Precisa de acompanhante ou tem alguma observação?"
                ></textarea>

              </div>


              <!-- LGPD -->
              <div class="lgpd-row">

                <span class="lgpd-box">
                  <input
                    type="checkbox"
                    name="lgpd"
                    required
                    aria-label="Aceitar o compartilhamento de dados"
                  >
                </span>

                <span class="lgpd-text">
                  Autorizo o envio dos meus dados ao organizador da campanha, conforme a LGPD.
                </span>

              </div>


              <!-- Ações -->
              <div class="form-actions">

                <button
                  class="btn btn-primary btn-lg"
                  type="submit"
                  <#if vagasRestantes lte 0>disabled</#if>
                >
                  Confirmar inscrição
                  <span class="icon">arrow_forward</span>
                </button>

                <a
                  class="btn btn-ghost btn-lg"
                  href="/campanhas/${campanha.id}"
                >
                  Cancelar
                </a>

              </div>

            </div>

          </form>

        </div>


        <!-- Resumo da campanha -->
        <aside class="panel summary-card">

          <img
            src="/images/doacaodesangue.jpeg"
            alt="Doação de sangue"
          >

          <#if vagasRestantes gt 0>
            <span class="badge badge-open">
              <span class="dot"></span>
              ${vagasRestantes} <#if vagasRestantes == 1>vaga restante<#else>vagas restantes</#if>
            </span>
          <#else>
            <span class="badge badge-closed">
              <span class="dot"></span>
              Vagas esgotadas
            </span>
          </#if>

          <div class="summary-title">
            ${campanha.title}
          </div>

          <div class="summary-info">

            <span>
              <span class="icon">schedule</span>
              ${dataBr!"Data a definir"}<#if campanha.departureTime??> · Saída ${campanha.departureTime}</#if><#if campanha.donationTime??> · Doação ${campanha.donationTime}</#if>
            </span>

            <#if campanha.donationLocation??>
              <span>
                <span class="icon">place</span>
                ${campanha.donationLocation.name}<#if campanha.donationLocation.city??> — ${campanha.donationLocation.city}</#if>
              </span>
            </#if>

          </div>

          <div class="summary-note">

            <span class="icon">confirmation_number</span>

            <p>
              Ao confirmar, você recebe na hora o seu bilhete de embarque com o código da vaga.
            </p>

          </div>

        </aside>

      </div>
    </div>
  </main>
</@main.layout>
