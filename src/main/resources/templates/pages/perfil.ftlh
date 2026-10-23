<#import "../layout/main.ftlh" as main>

<#assign pageTitle = (ehOrganizador!false)?then("Perfil do Hemocentro", "Meu Perfil") + " - Rota Solidária">
<@main.layout title=pageTitle css="/css/perfil.css" currentNav="perfil">
  <section class="profile-hero">
    <div class="container profile-hero-inner">
      <div class="profile-avatar-large">
        <span>${(usuario.initials)!"US"}</span>
        <#if !ehOrganizador!false && isDonor && donor?? && donor.bloodType??>
          <#if donor.bloodType.name() != "UNKNOWN">
            <span class="blood-type-pill" title="Tipo sanguíneo: ${donor.bloodType.displayName}">${donor.bloodType.displayName}</span>
          <#else>
            <span class="blood-type-pill" title="Tipo sanguíneo a definir na triagem">?</span>
          </#if>
        </#if>
      </div>

      <div class="profile-name-row">
        <h1>${usuario.name}</h1>
        <#if !ehOrganizador!false && isDonor && donor?? && donor.bloodType?? && donor.bloodType.name() != "UNKNOWN">
          <span class="profile-tag-blood">${donor.bloodType.displayName}</span>
        <#elseif !ehOrganizador!false && isDonor>
          <span class="profile-tag-blood unconfirmed">Tipo a definir</span>
        </#if>
      </div>

      <div class="profile-meta-row">
        <span><span class="icon">mail</span>${usuario.email}</span>
        <#if usuario.phone?? && usuario.phone?has_content>
          <span><span class="icon">call</span>${usuario.phone}</span>
        </#if>
        <#if ehOrganizador!false && (organizer.institution)?has_content>
          <span><span class="icon">domain</span>${organizer.institution}</span>
        <#elseif !ehOrganizador!false && isDonor>
          <span><span class="icon">volunteer_activism</span>${totalDoacoes!0} <#if (totalDoacoes!0) == 1>doação<#else>doações</#if></span>
          <#if (donor.birthDateBr)?has_content && donor.birthDateBr != "">
            <span><span class="icon">cake</span>${donor.birthDateBr}</span>
          </#if>
        </#if>
      </div>

      <div class="profile-hero-actions">
        <button type="button" class="btn-hero-edit" id="btn-open-edit-modal">
          <span class="icon">edit</span>
          <span>Editar Perfil</span>
        </button>
      </div>
    </div>
  </section>

  <main class="container section profile-main-section">
    <div class="profile-content-wrap">
      <div class="section-title-wrap">
        <h2>Minhas Inscrições</h2>
        <a class="btn btn-secondary btn-sm" href="/campanhas">Ver todas as coletas</a>
      </div>

      <#if inscricoes?? && inscricoes?size gt 0>
        <#list inscricoes as reg>
          <div class="reg-card">
            <div class="reg-card-main">
              <span class="badge <#if reg.status == 'CONFIRMED'>badge-open<#else>badge-few</#if>">
                <span class="dot"></span>
                <#if reg.status == 'CONFIRMED'>Inscrição Confirmada<#elseif reg.status == 'PENDING'>Aguardando Triagem<#else>${reg.status}</#if>
              </span>
              <h3>${reg.campaign.title}</h3>
              <div class="reg-meta">
                <#if reg.campaign.eventDate??>
                  <span><span class="icon">schedule</span><#if reg.campaign.eventDate??>${reg.campaign.eventDateBr}</#if> <#if reg.campaign.departureTime??>· Saída ${reg.campaign.departureTime}h</#if></span>
                </#if>
                <#if reg.campaign.donationLocation??>
                  <span><span class="icon">place</span>${reg.campaign.donationLocation.name} (${reg.campaign.donationLocation.city})</span>
                </#if>
                <#if reg.boardingLocation??>
                  <span><span class="icon">directions_bus</span>Embarque: ${reg.boardingLocation.name}</span>
                <#elseif reg.boardingPoint?has_content>
                  <span><span class="icon">directions_bus</span>Embarque: ${reg.boardingPoint}</span>
                </#if>
              </div>
            </div>
            <div class="reg-card-actions">
              <#if reg.status != "CANCELLED">
                <a class="btn btn-primary" href="/inscricoes/${reg.id?c}"><span class="icon" aria-hidden="true">assignment</span>Ver inscrição</a>
              </#if>
              <a class="btn btn-secondary" href="/campanhas/${reg.campaign.id}">Detalhes</a>
            </div>
          </div>
        </#list>
      <#else>
        <div class="reg-empty">
          <div class="reg-empty-art" aria-hidden="true">
            <span class="reg-empty-drop"></span>
            <span class="icon">directions_bus</span>
          </div>
          <div class="reg-empty-text">
            <h3>Você ainda não tem inscrições</h3>
            <p>Escolha uma campanha perto de você e garanta sua vaga no transporte.</p>
            <div class="reg-empty-actions">
              <a class="btn btn-primary" href="/campanhas">Ver campanhas<span class="icon" aria-hidden="true">arrow_forward</span></a>
              <a class="btn btn-ghost" href="/educativo">Como funciona a doação</a>
            </div>
          </div>
        </div>
      </#if>
    </div>
  </main>

  <!-- Modal de Edição de Perfil -->
  <dialog id="modal-editar" class="profile-modal">
    <div class="profile-modal-content">
      <div class="profile-modal-header">
        <div>
          <h2>Editar Perfil</h2>
          <p class="subtitle"><#if ehOrganizador!false>Atualize suas informações de contato e acesso.<#else>Atualize suas informações pessoais e médicas.</#if></p>
        </div>
        <button type="button" class="modal-close-btn" id="btn-close-edit-modal" aria-label="Fechar">
          <span class="icon">close</span>
        </button>
      </div>

      <form method="post" action="/perfil/editar" class="profile-modal-form">
        <#include "../includes/csrf.ftlh">
        <div class="form-field">
          <label for="prof-name">Nome Completo</label>
          <input id="prof-name" name="name" type="text" required value="${usuario.name}">
        </div>

        <#if organizer??>
          <div class="form-field">
            <label for="prof-institution">Instituição / Hemocentro</label>
            <input id="prof-institution" name="institution" type="text" value="${(organizer.institution)!""}" placeholder="ex: Fundação Pró-Sangue">
          </div>
        </#if>

        <div class="form-field">
          <label for="prof-email">E-mail Cadastrado</label>
          <input id="prof-email" type="email" readonly value="${usuario.email}">
          <span class="field-hint">O e-mail é a sua chave de acesso e não pode ser alterado.</span>
        </div>

        <div class="form-field">
          <label for="prof-phone">WhatsApp / Telefone</label>
          <input id="prof-phone" name="phone" type="text" placeholder="(15) 99999-9999" value="${usuario.phone!""}">
        </div>

        <#if isDonor>
          <div class="form-row-2">
            <div class="form-field">
              <label for="prof-blood">Tipo Sanguíneo</label>
              <select id="prof-blood" name="bloodType">
                <option value="">Selecione...</option>
                <#list bloodTypes as bt>
                  <option value="${bt.name()}" <#if donor?? && donor.bloodType?? && donor.bloodType == bt>selected</#if>>${bt.displayName}</option>
                </#list>
              </select>
            </div>

            <div class="form-field">
              <label for="prof-weight">Peso (kg)</label>
              <input id="prof-weight" name="weight" type="number" step="0.5" min="45" max="250" placeholder="ex: 70" value="<#if (donor.weight)??>${donor.weight}</#if>">
            </div>
          </div>

          <div class="form-field">
            <label for="prof-birth">Data de Nascimento</label>
            <input id="prof-birth" name="birthDate" type="date" value="<#if (donor.birthDate)??>${donor.birthDate}</#if>">
          </div>
        </#if>

        <div class="password-section">
          <div class="password-toggle-title">
            <span class="icon">lock</span>
            <span><#if temSenha>Alterar Senha de Acesso<#else>Definir Senha de Acesso</#if></span>
          </div>

          <#if temSenha>
          <div class="form-field">
            <label for="prof-senha-atual">Senha Atual</label>
            <input id="prof-senha-atual" name="senhaAtual" type="password" data-password autocomplete="current-password" placeholder="Digite apenas se desejar trocar">
          </div>
          <#else>
          <p class="password-hint">Você entra com o Google. Defina uma senha para entrar também com e-mail e senha.</p>
          </#if>

          <div class="form-field">
            <label for="prof-nova-senha">Nova Senha</label>
            <input id="prof-nova-senha" name="novaSenha" type="password" data-password data-password-strength autocomplete="new-password" placeholder="Mínimo 8 caracteres">
          </div>
        </div>

        <div class="modal-form-actions">
          <button type="button" class="btn btn-secondary" id="btn-cancel-edit-modal">Cancelar</button>
          <button class="btn btn-primary" type="submit">
            <span class="icon">save</span>
            Salvar Alterações
          </button>
        </div>
      </form>
    </div>
  </dialog>

  <script>
    document.addEventListener('DOMContentLoaded', function () {
      const modal = document.getElementById('modal-editar');
      const openBtn = document.getElementById('btn-open-edit-modal');
      const closeBtn = document.getElementById('btn-close-edit-modal');
      const cancelBtn = document.getElementById('btn-cancel-edit-modal');

      if (openBtn && modal) {
        openBtn.addEventListener('click', function () {
          modal.showModal();
        });
      }

      function closeModal() {
        if (modal) modal.close();
      }

      if (closeBtn) closeBtn.addEventListener('click', closeModal);
      if (cancelBtn) cancelBtn.addEventListener('click', closeModal);

      if (modal) {
        modal.addEventListener('click', function (e) {
          const rect = modal.getBoundingClientRect();
          const isInDialog = (rect.top <= e.clientY && e.clientY <= rect.top + rect.height
            && rect.left <= e.clientX && e.clientX <= rect.left + rect.width);
          if (!isInDialog) {
            closeModal();
          }
        });

        if (window.location.hash === '#editar') {
          modal.showModal();
        }
      }
    });
  </script>
</@main.layout>
