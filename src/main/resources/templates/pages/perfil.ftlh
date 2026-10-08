<#import "../layout/main.ftlh" as main>

<@main.layout title="<#if ehOrganizador!false>Perfil do Hemocentro<#else>Meu Perfil</#if> - Rota Solidária" css="/css/perfil.css" currentNav="perfil">
  <section class="profile-hero">
    <div class="container profile-hero-inner">
      <div class="profile-user-info">
        <div class="profile-avatar-large">
          <span>${(usuario.initials)!"US"}</span>
          <#if !ehOrganizador!false && isDonor && donor?? && donor.bloodType??>
            <#if donor.bloodType.name() != "UNKNOWN">
              <span class="blood-type-pill">${donor.bloodType.displayName}</span>
            <#else>
              <span class="blood-type-pill" title="Tipo sanguíneo não informado">?</span>
            </#if>
          </#if>
        </div>
        <div class="profile-name-area">
          <span class="kicker" style="color:#FBE3E4"><#if ehOrganizador!false>Hemocentro<#else>Painel do Doador</#if></span>
          <h1>${usuario.name}</h1>
          <div class="profile-meta-row">
            <span><span class="icon">mail</span>${usuario.email}</span>
            <#if usuario.phone?? && usuario.phone?has_content>
              <span><span class="icon">call</span>${usuario.phone}</span>
            </#if>
            <#if ehOrganizador!false && (organizer.institution)?has_content>
              <span><span class="icon">domain</span>${organizer.institution}</span>
            <#elseif !ehOrganizador!false && isDonor && donor?? && donor.birthDate??>
              <span><span class="icon">cake</span>${donor.birthDateBr}</span>
            </#if>
          </div>
        </div>
      </div>

      <#if !ehOrganizador!false && isDonor>
        <section class="donor-card" aria-label="Carteirinha do doador">
          <div class="donor-card__top">
            <div>
              <span class="donor-card__label">Carteirinha do doador</span>
              <strong class="donor-card__name">${usuario.name}</strong>
            </div>
            <div class="donor-card__type">
              <span class="donor-card__label">Tipo</span>
              <strong><#if donor?? && donor.bloodType?? && donor.bloodType.name() != "UNKNOWN">${donor.bloodType.displayName}<#else>?</#if></strong>
            </div>
          </div>
          <dl class="donor-card__stats">
            <div><dt>Doações</dt><dd>${totalDoacoes!0}</dd></div>
            <div><dt>Peso</dt><dd><#if donor?? && donor.weight??>${donor.weight} kg<#else>—</#if></dd></div>
          </dl>
          <#if !(donor?? && donor.bloodType??)>
            <a class="donor-card__hint" href="#editar">Informe seu tipo sanguíneo</a>
          <#elseif donor.bloodType.name() == "UNKNOWN">
            <span class="donor-card__hint" style="text-decoration:none;cursor:default">Tipo a definir na triagem</span>
          </#if>
        </section>
      </#if>
    </div>
  </section>

  <main class="container section">
    <#if !ehOrganizador!false && !isDonor>
      <!-- Indicadores / Estatísticas do Perfil -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon green">
            <span class="icon">volunteer_activism</span>
          </div>
          <div class="stat-info">
            <div class="stat-value"><#if inscricoes??>${inscricoes?size * 4}<#else>0</#if></div>
            <div class="stat-label">Vidas que você pode salvar</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon">
            <span class="icon">event_available</span>
          </div>
          <div class="stat-info">
            <div class="stat-value"><#if inscricoes??>${inscricoes?size}<#else>0</#if></div>
            <div class="stat-label">Campanhas inscritas</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon blue">
            <span class="icon">bloodtype</span>
          </div>
          <div class="stat-info">
            <div class="stat-value"><#if isDonor && donor?? && donor.bloodType??>${donor.bloodType.displayName}<#else>Não definido</#if></div>
            <div class="stat-label">Tipo Sanguíneo</div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon green">
            <span class="icon">verified</span>
          </div>
          <div class="stat-info">
            <div class="stat-value">Apto para doar</div>
            <div class="stat-label">Status de prontidão</div>
          </div>
        </div>
      </div>
    </#if>

    <#if ehOrganizador!false>
      <!-- Visualização do Hemocentro: Apenas informações do usuário -->
      <div class="profile-single-column">
        <aside class="edit-card" id="editar">
          <h2>Informações do Usuário</h2>
          <p class="subtitle">Atualize suas informações de contato e acesso.</p>

          <form method="post" action="/perfil/editar">
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

            <div style="margin-top:22px">
              <button class="btn btn-primary btn-block" type="submit">
                <span class="icon">save</span>
                Salvar Alterações
              </button>
            </div>
          </form>
        </aside>
      </div>
    <#else>
    <!-- Layout 2 Colunas -->
    <div class="profile-main-grid">

      <!-- Coluna Principal: Minhas Inscrições -->
      <div id="inscricoes">
        <div class="section-title-wrap">
          <h2>Minhas Inscrições em Campanhas</h2>
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

      <!-- Coluna Lateral: Formulário de Edição -->
      <aside class="edit-card" id="editar">
        <h2>Editar Perfil</h2>
        <p class="subtitle">Atualize suas informações pessoais e médicas para facilitar suas inscrições.</p>

        <form method="post" action="/perfil/editar">
          <#include "../includes/csrf.ftlh">
          <div class="form-field">
            <label for="prof-name">Nome Completo</label>
            <input id="prof-name" name="name" type="text" required value="${usuario.name}">
          </div>

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
                <input id="prof-weight" name="weight" type="number" step="0.5" min="45" max="250" placeholder="ex: 70" value="<#if donor?? && donor.weight??>${donor.weight}</#if>">
              </div>
            </div>

            <div class="form-field">
              <label for="prof-birth">Data de Nascimento</label>
              <input id="prof-birth" name="birthDate" type="date" value="<#if donor?? && donor.birthDate??>${donor.birthDate}</#if>">
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

          <div style="margin-top:22px">
            <button class="btn btn-primary btn-block" type="submit">
              <span class="icon">save</span>
              Salvar Alterações
            </button>
          </div>
        </form>
      </aside>

    </div>
    </#if>
  </main>
</@main.layout>
