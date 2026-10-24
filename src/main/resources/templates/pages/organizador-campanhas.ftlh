<#import "../layout/main.ftlh" as main>

<#-- Área do organizador: campanhas dele, com atalho para editar a rota do ônibus e CRUD completo -->
<@main.layout title="Minhas campanhas - Rota Solidária" css="/css/organizador.css" currentNav="organizador">
  <main class="container">
    <div class="org-head">
      <span class="kicker">Área do organizador</span>
      <h1>Minhas campanhas</h1>
      <p>Crie, acompanhe, encerre, reabra, cancele ou exclua suas campanhas e rotas de transporte.</p>
      <div class="org-head__acoes">
        <a class="btn btn-primary" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Nova campanha</a>
      </div>
    </div>

    <#if campanhas?has_content>
      <ul class="org-list">
        <#list campanhas as c>
          <li class="org-card">
            <div class="org-card__info">
              <div class="org-card__top">
                <#if c.statusEfetivo == "OPEN">
                  <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
                <#elseif c.statusEfetivo == "CLOSED">
                  <span class="badge badge-closed"><span class="dot"></span>Inscrições encerradas</span>
                <#else>
                  <span class="badge badge-closed"><span class="dot"></span>Cancelada</span>
                </#if>
              </div>
              <h2>${c.title}</h2>
              <div class="org-card__meta">
                <span><span class="icon" aria-hidden="true">calendar_month</span><#if c.eventDate??>${c.eventDateBr}<#else>Data a definir</#if></span>
                <span><span class="icon" aria-hidden="true">route</span>
                  <#if c.departureLocation??>${c.departureLocation.city!c.departureLocation.name}<#else>Partida a definir</#if>
                  → <#if c.stops?has_content>${c.stops?size} <#if c.stops?size == 1>parada<#else>paradas</#if> → </#if>
                  ${(c.donationLocation.city)!"Hemocentro"}
                </span>
                <span><span class="icon" aria-hidden="true">group</span>${c.slots!0} vagas</span>
              </div>
            </div>
            <div class="org-card__actions">
              <a class="btn btn-primary org-act-edit" href="/organizador/campanhas/${c.id?c}/editar" title="Editar dados e paradas da rota">
                <span class="icon" aria-hidden="true">edit</span>Editar
              </a>
              <a class="btn btn-secondary org-act-view" href="/campanhas/${c.id?c}" title="Visualizar página pública da campanha">
                <span class="icon" aria-hidden="true">visibility</span>Ver página
              </a>
              <a class="btn btn-secondary org-act-share" href="/organizador/campanhas/${c.id?c}/divulgar" title="Divulgar nas redes e WhatsApp">
                <span class="icon" aria-hidden="true">share</span>Divulgar
              </a>

              <#if c.status == "OPEN">
                <form method="post" action="/organizador/campanhas/${c.id?c}/status" class="org-act-status">
                  <#include "../includes/csrf.ftlh">
                  <input type="hidden" name="status" value="CLOSED">
                  <button type="submit" class="btn btn-secondary" title="Encerrar inscrições para novos doadores">
                    <span class="icon" aria-hidden="true">lock</span>Encerrar
                  </button>
                </form>
              <#elseif c.status == "CLOSED">
                <#if !c.dataPassada>
                  <form method="post" action="/organizador/campanhas/${c.id?c}/status" class="org-act-status">
                    <#include "../includes/csrf.ftlh">
                    <input type="hidden" name="status" value="OPEN">
                    <button type="submit" class="btn btn-secondary" title="Reabrir inscrições da campanha">
                      <span class="icon" aria-hidden="true">lock_open</span>Reabrir
                    </button>
                  </form>
                </#if>
              </#if>

              <#if c.status != "CANCELLED">
                <form method="post" action="/organizador/campanhas/${c.id?c}/status" class="org-act-cancel" onsubmit="return confirm('Tem certeza que deseja cancelar esta campanha? Os doadores inscritos serão notificados por e-mail.');">
                  <#include "../includes/csrf.ftlh">
                  <input type="hidden" name="status" value="CANCELLED">
                  <button type="submit" class="btn btn-outline-danger" title="Cancelar caravana">
                    <span class="icon" aria-hidden="true">cancel</span>Cancelar
                  </button>
                </form>
              <#elseif !c.dataPassada>
                <form method="post" action="/organizador/campanhas/${c.id?c}/status" class="org-act-cancel">
                  <#include "../includes/csrf.ftlh">
                  <input type="hidden" name="status" value="OPEN">
                  <button type="submit" class="btn btn-secondary" title="Reativar campanha cancelada">
                    <span class="icon" aria-hidden="true">replay</span>Reativar
                  </button>
                </form>
              </#if>

              <form method="post" action="/organizador/campanhas/${c.id?c}/excluir" class="org-act-delete" onsubmit="return confirm('Tem certeza que deseja excluir esta campanha definitivamente? Esta ação não pode ser desfeita.');">
                <#include "../includes/csrf.ftlh">
                <button type="submit" class="btn btn-danger" title="Excluir campanha permanentemente">
                  <span class="icon" aria-hidden="true">delete</span>Excluir
                </button>
              </form>
            </div>
          </li>
        </#list>
      </ul>
    <#else>
      <div class="panel org-empty">
        <p>Você ainda não tem campanhas cadastradas.</p>
        <a class="btn btn-primary" href="/organizador/campanhas/nova"><span class="icon" aria-hidden="true">add</span>Criar a primeira campanha</a>
      </div>
    </#if>
  </main>
</@main.layout>
