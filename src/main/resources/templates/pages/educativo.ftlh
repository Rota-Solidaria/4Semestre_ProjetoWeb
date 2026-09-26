<#import "../layout/main.ftlh" as main>

<@main.layout title="Guia do Doador" css="/css/educativo.css" currentNav="educativo">
  <main>
    <section class="page-hero">
      <div class="container">
        <span class="kicker">Orientação ao doador</span>
        <h1>Guia do doador</h1>
        <p>Tudo o que você precisa saber antes de salvar vidas. Conheça os requisitos, entenda o processo e tire suas dúvidas.</p>
      </div>
    </section>

    <div class="container section">
      <section>
        <h2>Requisitos básicos</h2>
        <div class="req-grid">
          <div class="req-card">
            <span class="icon-box"><span class="icon">calendar_month</span></span>
            <h3>Idade</h3>
            <p>Ter entre 16 e 69 anos.</p>
          </div>
          <div class="req-card">
            <span class="icon-box"><span class="icon">event_seat</span></span>
            <h3>Peso</h3>
            <p>Pesar no mínimo 50 kg.</p>
          </div>
          <div class="req-card">
            <span class="icon-box"><span class="icon">favorite</span></span>
            <h3>Saúde e alimentação</h3>
            <p>Estar bem de saúde, descansado e não estar em jejum. Evite alimentos gordurosos 4 horas antes.</p>
          </div>
          <div class="req-card">
            <span class="icon-box"><span class="icon">person</span></span>
            <h3>Documentação</h3>
            <p>Apresentar documento de identidade original com foto recente.</p>
          </div>
        </div>
      </section>

      <section class="section">
        <h2>Como é o processo de doação?</h2>
        <div class="steps">
          <div class="step">
            <div class="step-num">1</div>
            <div>
              <h3>Recepção e cadastro</h3>
              <p>Você apresenta seu documento de identidade com foto e seus dados são registrados.</p>
            </div>
          </div>
          <div class="step">
            <div class="step-num">2</div>
            <div>
              <h3>Triagem clínica</h3>
              <p>Uma entrevista rápida e confidencial avalia se a doação é segura para você.</p>
            </div>
          </div>
          <div class="step">
            <div class="step-num">3</div>
            <div>
              <h3>Coleta do sangue</h3>
              <p>A doação é rápida e segura. O material utilizado é descartável e de uso único.</p>
            </div>
          </div>
          <div class="step">
            <div class="step-num">4</div>
            <div>
              <h3>Lanche e repouso</h3>
              <p>Após a doação, faça um lanche e permaneça no local por cerca de 15 minutos.</p>
            </div>
          </div>
        </div>
      </section>

      <div class="cta-panel">
        <h2>Pronto para doar com segurança?</h2>
        <p>Encontre uma campanha na região e agende sua participação.</p>
        <a class="btn btn-secondary btn-lg" href="/campanhas">Encontrar campanhas</a>
      </div>
    </div>
  </main>
</@main.layout>
