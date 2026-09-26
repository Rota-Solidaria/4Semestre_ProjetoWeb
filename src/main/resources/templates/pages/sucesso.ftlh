<#import "../layout/main.ftlh" as main>

<@main.layout title="Inscrição Confirmada" css="/css/sucesso.css" currentNav="">
  <main class="container">
    <div class="success-wrap">
      <div class="panel success-panel">
        <span class="success-icon"><span class="icon">check_circle</span></span>
        <h1>Inscrição confirmada!</h1>
        <p>Muito obrigado por se inscrever. Sua atitude salva vidas.</p>

        <div class="summary-box">
          <div class="row"><span>Campanha</span><strong>Campanha Mês Amarelo</strong></div>
          <div class="divider"></div>
          <div class="row"><span>Data e saída</span><strong>11 de Maio · 05:00h</strong></div>
          <div class="divider"></div>
          <div class="row"><span>Local</span><strong>Colsan — Posto de Coleta Sorocaba</strong></div>
        </div>

        <div class="warn-box">
          <div class="warn-head"><span class="icon">error</span>Preparo para o dia</div>
          <ul>
            <li>· Documento com foto original</li>
            <li>· Alimentação leve até 4 horas antes</li>
            <li>· 6 horas de sono e boa hidratação</li>
          </ul>
        </div>

        <p class="success-contact-note">O organizador da campanha entrará em contato com você pelo WhatsApp informado em até 48 horas.</p>

        <div class="success-actions">
          <a class="btn btn-primary btn-lg" href="/"><span class="icon">home</span>Voltar para o início</a>
          <a class="btn btn-secondary btn-lg" href="/educativo">Preparo para doação</a>
        </div>
      </div>
    </div>
  </main>
</@main.layout>
