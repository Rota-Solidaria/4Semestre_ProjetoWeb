<#import "../layout/main.ftlh" as main>

<#-- Landing para quem nunca doou (direção A, "A gente leva você"): começa pela dor (o hemocentro é longe),
     responde as objeções e leva ao mapa da home, que acha a caravana mais perto.
     Fatos de saúde só de fonte oficial e datada (ver docs/video/prompt-video.md). -->
<@main.layout title="Doe sangue sem se preocupar com o transporte · Rota Solidária" css="/css/doar.css">
  <main>

    <section class="doar-hero">
      <div class="container doar-hero__grid">
        <div class="doar-hero__texto">
          <span class="kicker">Doação de sangue · Angatuba, Itapetininga e região</span>
          <h1>O hemocentro fica longe? O ônibus leva você.</h1>
          <p class="doar-hero__sub">Escolha uma caravana gratuita que sai da sua cidade, reserve a vaga em poucos cliques e receba o bilhete de embarque no celular.</p>
          <div class="doar-hero__acoes">
            <a class="btn btn-primary btn-lg" href="/#mapa">Ver caravanas perto de mim<span class="icon" aria-hidden="true">arrow_forward</span></a>
            <a class="btn btn-ghost btn-lg" href="#como">Como funciona</a>
          </div>
          <span class="doar-gatilho"><span class="icon" aria-hidden="true">verified</span>Transporte gratuito · reserva em poucos cliques · lembrete por e-mail</span>
          <#if caravanasAbertas gt 0>
            <span class="doar-prova"><span class="doar-prova__ponto" aria-hidden="true"></span><strong>${caravanasAbertas}</strong> <#if caravanasAbertas == 1>caravana com inscrições abertas agora<#else>caravanas com inscrições abertas agora</#if></span>
          </#if>
        </div>
        <div class="doar-hero__visual">
          <div class="doar-celular">
            <img src="/images/doar/rota.jpg" width="585" height="1266" fetchpriority="high"
                 alt="Tela do app com a rota do ônibus: saída da Praça da Matriz de Angatuba às 06:30, parada em Itapetininga e chegada ao hemocentro">
          </div>
          <div class="doar-hero__selo">
            <span class="icon" aria-hidden="true">directions_bus</span>
            <span><strong>Saída 06:30</strong>Praça da Matriz, Angatuba</span>
          </div>
        </div>
      </div>
    </section>

    <section class="doar-dor">
      <div class="container">
        <div class="doar-cabeca">
          <span class="kicker">Por que tanta gente não doa</span>
          <h2>Vontade não falta. Falta chegar até lá.</h2>
        </div>
        <div class="doar-dor__grid">
          <div class="doar-dor__card">
            <s>"O hemocentro é em outra cidade."</s>
            <strong>A caravana sai da sua cidade.</strong>
            <span>Pontos de embarque conhecidos, como a praça ou a rodoviária, com horário marcado.</span>
          </div>
          <div class="doar-dor__card">
            <s>"Não tenho carro nem carona."</s>
            <strong>O ônibus é gratuito.</strong>
            <span>Você não paga passagem nem nada para doar. Só reserva a vaga.</span>
          </div>
          <div class="doar-dor__card">
            <s>"Nem sei se eu posso doar."</s>
            <strong>Confira em 30 segundos.</strong>
            <span>Os requisitos básicos estão logo abaixo. A palavra final é da triagem no hemocentro.</span>
          </div>
        </div>
      </div>
    </section>

    <section class="doar-como" id="como">
      <div class="container">
        <div class="doar-cabeca">
          <span class="kicker">Como funciona</span>
          <h2>Três passos até a sua vaga no ônibus</h2>
        </div>
        <ol class="doar-passos">
          <li>
            <div class="doar-passos__tela"><img src="/images/doar/passo-1-caravanas.jpg" width="585" height="1266" loading="lazy" alt="Lista de caravanas abertas no app, com data e vagas"></div>
            <span class="doar-passos__num">01</span>
            <strong>Escolha a caravana</strong>
            <span>Veja data, horário de saída e quantas vagas ainda restam.</span>
          </li>
          <li>
            <div class="doar-passos__tela"><img src="/images/doar/passo-2-embarque.jpg" width="585" height="1266" loading="lazy" alt="Escolha do ponto de embarque no app"></div>
            <span class="doar-passos__num">02</span>
            <strong>Escolha onde embarcar</strong>
            <span>O ônibus passa por mais de um ponto. Você pega o mais perto de casa.</span>
          </li>
          <li>
            <div class="doar-passos__tela"><img src="/images/doar/passo-3-bilhete.jpg" width="585" height="1266" loading="lazy" alt="Bilhete de embarque com o código da vaga"></div>
            <span class="doar-passos__num">03</span>
            <strong>Receba o bilhete</strong>
            <span>Mande para o WhatsApp, salve na agenda e receba lembrete por e-mail.</span>
          </li>
        </ol>
        <a class="btn btn-primary btn-lg" href="/#mapa">Quero reservar minha vaga<span class="icon" aria-hidden="true">arrow_forward</span></a>
      </div>
    </section>

    <section class="doar-impacto-sec">
      <div class="container">
        <div class="doar-impacto">
          <span class="doar-impacto__num">até 4 vidas</span>
          <span class="doar-impacto__texto">podem ser ajudadas por uma única doação de sangue.</span>
          <span class="doar-impacto__fonte">Fonte: Ministério da Saúde, 25/11/2023</span>
        </div>
      </div>
    </section>

    <section class="doar-posso" id="posso">
      <div class="container doar-posso__grid">
        <div class="doar-posso__texto">
          <span class="kicker">Posso doar?</span>
          <h2>Confira o básico antes de reservar</h2>
          <p class="muted">Reservar a vaga no ônibus não garante a doação: quem decide é a triagem clínica no hemocentro, no dia.</p>
          <a class="doar-link" href="/educativo">Ver o guia completo do doador<span class="icon" aria-hidden="true">arrow_forward</span></a>
        </div>
        <ul class="doar-requisitos">
          <li><span class="icon" aria-hidden="true">check_circle</span><span><strong>16 a 69 anos</strong>Menores de 18 com autorização; de 60 a 69, só quem já doou antes</span></li>
          <li><span class="icon" aria-hidden="true">check_circle</span><span><strong>50 kg ou mais</strong>Peso mínimo para doar</span></li>
          <li><span class="icon" aria-hidden="true">check_circle</span><span><strong>Dormiu 6 horas</strong>E está alimentado</span></li>
          <li><span class="icon" aria-hidden="true">check_circle</span><span><strong>60 ou 90 dias</strong>Desde a última doação (homens / mulheres)</span></li>
        </ul>
      </div>
    </section>

    <section class="doar-todos">
      <div class="container doar-todos__grid">
        <img src="/images/doar/acessibilidade.jpg" width="1200" height="750" loading="lazy" alt="Painel de acessibilidade do Rota Solidária com o texto ampliado">
        <div class="doar-todos__texto">
          <span class="kicker">Feito para todo mundo</span>
          <h2>Letra grande, alto contraste e modo escuro em um toque</h2>
          <p class="muted">Pensado para quem tem 16 ou 69 anos e para internet lenta. Funciona no celular, sem instalar nada.</p>
          <span class="doar-todos__origem">Projeto de extensão do curso de Tecnologia em Sistemas para Internet · IFSP Itapetininga.</span>
        </div>
      </div>
    </section>

    <section class="doar-duvidas" id="duvidas">
      <div class="container doar-duvidas__caixa">
        <h2>Dúvidas de quem vai pela primeira vez</h2>
        <div class="doar-faq">
          <details open>
            <summary>É gratuito mesmo?<span class="icon" aria-hidden="true">expand_more</span></summary>
            <p>Sim. O transporte é gratuito e você não paga nada para doar.</p>
          </details>
          <details>
            <summary>Reservar a vaga garante que eu vou doar?<span class="icon" aria-hidden="true">expand_more</span></summary>
            <p>Não. A vaga é no ônibus. Quem confirma se você pode doar é a triagem clínica no hemocentro.</p>
          </details>
          <details>
            <summary>Preciso criar conta?<span class="icon" aria-hidden="true">expand_more</span></summary>
            <p>Sim, um cadastro rápido com nome e e-mail, ou entrando com a sua conta Google.</p>
          </details>
          <details>
            <summary>Como sei onde e quando embarcar?<span class="icon" aria-hidden="true">expand_more</span></summary>
            <p>Está no seu bilhete: ponto de embarque, horário e código da vaga. O organizador fala com você pelo WhatsApp em até 48 horas.</p>
          </details>
          <details>
            <summary>Posso ir por conta própria?<span class="icon" aria-hidden="true">expand_more</span></summary>
            <p>Pode. Na inscrição, escolha "Vou por conta própria" e encontre o grupo no hemocentro no horário da doação.</p>
          </details>
        </div>
      </div>
    </section>

    <section class="doar-final-sec">
      <div class="container">
        <div class="doar-final">
          <div>
            <h2>Tem um ônibus saindo perto de você.</h2>
            <p>Veja a data, escolha o ponto de embarque e garanta a vaga.</p>
          </div>
          <div class="doar-final__acao">
            <a class="btn btn-primary btn-lg" href="/#mapa">Ver caravanas perto de mim<span class="icon" aria-hidden="true">arrow_forward</span></a>
            <span>Gratuito · reserva em poucos cliques</span>
          </div>
        </div>
      </div>
    </section>

  </main>
</@main.layout>
