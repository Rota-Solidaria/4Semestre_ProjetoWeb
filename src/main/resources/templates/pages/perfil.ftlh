<#import "../layout/main.ftlh" as main>

<@main.layout title="Meu Perfil - Rota Solidária" css="/css/perfil.css" currentNav="">
  <section class="profile-hero">
    <div class="container profile-hero-inner">
      <div class="profile-user-info">
        <div class="profile-avatar-large">
          <span>${(usuario.name?keep_before(" ")?substring(0, 1))!"U"}${(usuario.name?keep_after(" ")?substring(0, 1))!"S"}</span>
          <#if isDonor && donor?? && donor.bloodType??>
            <span class="blood-type-pill">${donor.bloodType.displayName}</span>
          </#if>
        </div>
        <div class="profile-name-area">
          <span class="kicker" style="color:#FBE3E4">Painel do Doador</span>
          <h1>${usuario.name}</h1>
          <div class="profile-meta-row">
            <span><span class="icon">mail</span>${usuario.email}</span>
            <#if usuario.phone?? && usuario.phone?has_content>
              <span><span class="icon">call</span>${usuario.phone}</span>
            </#if>
            <#if isDonor && donor?? && donor.birthDate??>
              <span><span class="icon">cake</span>${donor.birthDate}</span>
            </#if>
          </div>
        </div>
      </div>

      <div>
        <span class="profile-hero-badge">
          <span class="icon">check_circle</span>
          <#if isDonor>Doador Solidário<#else>Organizador</#if>
        </span>
      </div>
    </div>
  </section>

  <main class="container section">
    <#if sucessoMsg??>
      <div class="alert-box alert-success">
        <span class="icon">check_circle</span>
        <span>${sucessoMsg}</span>
      </div>
    </#if>

    <#if erroMsg??>
      <div class="alert-box alert-error">
        <span class="icon">error</span>
        <span>${erroMsg}</span>
      </div>
    </#if>

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

    <!-- Layout 2 Colunas -->
    <div class="profile-main-grid">

      <!-- Coluna Principal: Minhas Inscrições -->
      <div>
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
                    <span><span class="icon">schedule</span>${reg.campaign.eventDate} <#if reg.campaign.departureTime??>· Saída ${reg.campaign.departureTime}h</#if></span>
                  </#if>
                  <#if reg.campaign.donationLocation??>
                    <span><span class="icon">place</span>${reg.campaign.donationLocation.name} (${reg.campaign.donationLocation.city})</span>
                  </#if>
                  <span><span class="icon">directions_bus</span>Transporte gratuito</span>
                </div>
              </div>
              <div>
                <a class="btn btn-secondary" href="/campanhas/${reg.campaign.id}">Ver Detalhes</a>
              </div>
            </div>
          </#list>
        <#else>
          <div class="reg-empty">
            <div class="reg-empty-icon">
              <span class="icon">calendar_today</span>
            </div>
            <h3>Você ainda não possui inscrições ativas</h3>
            <p>Escolha uma campanha disponível na região para participar com transporte gratuito e garantir sua vaga.</p>
            <a class="btn btn-primary" href="/campanhas">Explorar Campanhas Disponíveis</a>
          </div>
        </#if>

        <div class="info-callout">
          <span class="icon">info</span>
          <div>
            <strong>Lembrete importante antes de cada doação</strong>
            <p>Tenha uma boa noite de sono de no mínimo 6 horas, tome um café leve ou faça alimentação não gordurosa até 4 horas antes, hidrate-se com água e lembre-se de levar seu documento original com foto.</p>
          </div>
        </div>
      </div>

      <!-- Coluna Lateral: Formulário de Edição -->
      <aside class="edit-card" id="editar">
        <h2>Editar Perfil</h2>
        <p class="subtitle">Atualize suas informações pessoais e médicas para facilitar suas inscrições.</p>

        <form method="post" action="/perfil/editar">
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
              <span>Alterar Senha de Acesso</span>
            </div>

            <div class="form-field">
              <label for="prof-senha-atual">Senha Atual</label>
              <input id="prof-senha-atual" name="senhaAtual" type="password" placeholder="Digite apenas se desejar trocar">
            </div>

            <div class="form-field">
              <label for="prof-nova-senha">Nova Senha</label>
              <input id="prof-nova-senha" name="novaSenha" type="password" placeholder="Mínimo 6 dígitos">
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
  </main>
</@main.layout>
