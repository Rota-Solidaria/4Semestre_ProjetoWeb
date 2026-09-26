<#import "../layout/main.ftlh" as main>

<@main.layout title="Rota Solidária" css="/css/index.css" currentNav="inicio">
  <main>
    <section class="hero">
      <div class="container hero-grid">
        <div>
          <span class="kicker">Doação de sangue · Angatuba e região</span>
          <h1>Doe sangue, salve vidas perto de você.</h1>
          <p>Encontre a próxima coleta na sua região, veja se há transporte gratuito e garanta sua vaga em poucos minutos.</p>
        </div>

        <div class="hero-image">
          <img src="/images/doacaodesangue.jpeg" alt="Pessoa realizando doação de sangue">

          </div>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-head">
          <div>
            <span class="kicker">Agenda de coleta</span>
            <h2>Próximas campanhas confirmadas</h2>
            <p>Ordenadas pela distância até Angatuba.</p>
          </div>
          <a class="btn btn-secondary" href="/campanhas">Ver todas<span class="icon">arrow_forward</span></a>
        </div>

        <div class="grid">
          <a class="card" href="/campanhas/1">
            <div class="card-img"><img src="/images/doacaodesangue.jpeg" alt=""></div>
            <div class="card-body">
              <span class="badge badge-open"><span class="dot"></span>Inscrições abertas</span>
              <h3>Campanha Mês Amarelo</h3>
              <div class="meta">
                <span><span class="icon">schedule</span>11 de Maio · Saída 05:00h</span>
                <span><span class="icon">place</span>Colsan — Posto de Coleta Sorocaba</span>
                <span><span class="icon">directions_bus</span>Transporte gratuito</span>
              </div>
              <span class="card-cta cta-primary">Inscrever-se</span>
            </div>
          </a>
          <div class="card is-closed">
            <div class="card-img"><img src="/images/doacaodesangue.jpeg" alt=""></div>
            <div class="card-body">
              <span class="badge badge-closed"><span class="dot"></span>Finalizada</span>
              <h3>Mutirão Solidário de Abril</h3>
              <div class="meta">
                <span><span class="icon">schedule</span>03 de Abril · Saída 05:00h</span>
                <span><span class="icon">place</span>Colsan — Posto de Coleta Sorocaba</span>
                <span><span class="icon">directions_bus</span>Transporte gratuito</span>
              </div>
              <span class="card-cta cta-disabled">Encerrada</span>
            </div>
          </div>
        </div>
      </div>
    </section>
    <section class="section past-section">
      <div class="container">
        <div class="section-head">
          <div>
            <span class="kicker">Nossa história</span>
            <h2>Excursões anteriores</h2>
            <p>Confira alguns momentos das campanhas realizadas pela Rota Solidária.</p>
          </div>
        </div>

        <div class="past-grid">
          <div class="past-card">
            <img src="/images/excursoes/foto-01.jpeg" alt="Participantes da excursão para doação de sangue">
            <div class="past-info">
              <strong>Mutirão Solidário de Abril</strong>
              <span>03 de Abril · Sorocaba</span>
            </div>
          </div>

          <div class="past-card">
            <img src="/images/excursoes/foto-02.jpg" alt="Grupo reunido durante uma campanha de doação">
            <div class="past-info">
              <strong>Campanha de Março</strong>
              <span>15 de Março · Sorocaba</span>
            </div>
          </div>

          <div class="past-card">
            <img src="/images/excursoes/foto-03.jpg" alt="Participantes durante uma excursão">
            <div class="past-info">
              <strong>Campanha de Fevereiro</strong>
              <span>20 de Fevereiro · Sorocaba</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>
</@main.layout>
