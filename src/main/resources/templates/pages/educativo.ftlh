<#import "../layout/main.ftlh" as main>

<@main.layout title="Guia do Doador - Rota Solidária" css="/css/educativo.css" currentNav="educativo">
  <main>
    <section class="page-hero vh-section">
      <div class="container hero-content-center">
        <span class="kicker">Orientação ao doador</span>
        <h1>Guia do doador de sangue</h1>
        <p>Tudo o que você precisa saber antes de salvar vidas. Conheça os requisitos essenciais, entenda o processo e participe com segurança.</p>

        <div class="hero-features">
          <div class="hero-feature-item">
            <span class="icon">schedule</span>
            <span>Cerca de 40 minutos</span>
          </div>
          <div class="hero-feature-item">
            <span class="icon">favorite</span>
            <span>Salva até 4 vidas</span>
          </div>
          <div class="hero-feature-item">
            <span class="icon">verified_user</span>
            <span>100% seguro e descartável</span>
          </div>
        </div>

        <a href="#requisitos" class="btn btn-secondary hero-scroll-btn">
          <span>Ver requisitos básicos</span>
          <span class="icon" aria-hidden="true">arrow_downward</span>
        </a>
      </div>
    </section>

    <section id="requisitos" class="req-section vh-section">
      <div class="container">
        <div class="section-head text-center">
          <span class="kicker">Critérios fundamentais</span>
          <h2>Requisitos básicos para doar</h2>
          <p>Normas do Ministério da Saúde para garantir a segurança do doador e de quem recebe.</p>
        </div>

        <div class="req-grid">
          <div class="req-card">
            <span class="icon-box"><span class="icon" aria-hidden="true">calendar_month</span></span>
            <h3>Idade</h3>
            <p>Ter entre 16 e 69 anos (menores de 18 anos precisam de autorização dos responsáveis legais).</p>
          </div>
          <div class="req-card">
            <span class="icon-box"><span class="icon" aria-hidden="true">monitor_weight</span></span>
            <h3>Peso mínimo</h3>
            <p>Pesar no mínimo 50 kg para que a quantidade coletada seja segura para o seu organismo.</p>
          </div>
          <div class="req-card">
            <span class="icon-box"><span class="icon" aria-hidden="true">favorite</span></span>
            <h3>Saúde e alimentação</h3>
            <p>Estar em boas condições de saúde, descansado e bem alimentado. Evite alimentos gordurosos 4 horas antes.</p>
          </div>
          <div class="req-card">
            <span class="icon-box"><span class="icon" aria-hidden="true">badge</span></span>
            <h3>Documentação</h3>
            <p>Apresentar documento oficial original com foto recente (RG, CNH ou documento digital oficial).</p>
          </div>
        </div>

        <div class="section-foot text-center">
          <a class="foot-scroll-link" href="#processo">
            <span>Como é o processo de doação?</span>
            <span class="icon" aria-hidden="true">arrow_downward</span>
          </a>
        </div>
      </div>
    </section>

    <section id="processo" class="steps-section vh-section">
      <div class="container">
        <div class="section-head text-center">
          <span class="kicker">Etapa por etapa</span>
          <h2>Como é o processo de doação?</h2>
          <p>Um procedimento simples, acolhedor e realizado por equipes especializadas.</p>
        </div>

        <div class="steps-grid">
          <div class="step-card">
            <div class="step-num">1</div>
            <div class="step-content">
              <h3>Recepção e cadastro</h3>
              <p>Apresentação do documento com foto e cadastro inicial dos seus dados pessoais no sistema do hemocentro.</p>
            </div>
          </div>
          <div class="step-card">
            <div class="step-num">2</div>
            <div class="step-content">
              <h3>Triagem clínica</h3>
              <p>Uma entrevista rápida e confidencial com verificação de pressão, temperatura e teste de hemoglobina (anemia).</p>
            </div>
          </div>
          <div class="step-card">
            <div class="step-num">3</div>
            <div class="step-content">
              <h3>Coleta do sangue</h3>
              <p>A doação leva em média 8 a 12 minutos. Todo o material utilizado é estéril, descartável e de uso único.</p>
            </div>
          </div>
          <div class="step-card">
            <div class="step-num">4</div>
            <div class="step-content">
              <h3>Lanche e repouso</h3>
              <p>Após a doação você recebe um lanche especial e descansa por cerca de 15 minutos antes de seguir sua rotina.</p>
            </div>
          </div>
        </div>

        <div class="section-foot text-center">
          <a class="foot-scroll-link" href="#agendamento">
            <span>Pronto para doar?</span>
            <span class="icon" aria-hidden="true">arrow_downward</span>
          </a>
        </div>
      </div>
    </section>

    <section id="agendamento" class="cta-section vh-section">
      <div class="container">
        <div class="cta-panel">
          <span class="kicker kicker-soft">Ação solidária</span>
          <h2>Pronto para doar com segurança?</h2>
          <p>A Rota Solidária organiza o transporte gratuito de ida e volta saindo da sua cidade até os hemocentros da região.</p>
          <div class="cta-actions">
            <a class="btn btn-secondary btn-lg" href="/campanhas">
              <span>Encontrar campanhas na região</span>
              <span class="icon" aria-hidden="true">arrow_forward</span>
            </a>
            <a class="btn btn-ghost-white btn-lg" href="/">Voltar ao início</a>
          </div>
        </div>
      </div>
    </section>
  </main>
</@main.layout>
