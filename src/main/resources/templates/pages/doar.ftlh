<#import "../layout/main.ftlh" as main>

<#-- Landing para quem nunca doou (direção A, "A gente leva você"): começa pela dor (o hemocentro é longe),
     responde as objeções e leva ao mapa da home, que acha a caravana mais perto.
     Fatos de saúde só de fonte oficial e datada (ver docs/video/prompt-video.md).
     Movimento (direção M1, "Rota viva"): o hero anima só com CSS; os blocos com data-anima entram ao aparecer
     na tela (static/js/doar-motion.js). Sem JS ou com "Reduzir movimento", tudo aparece direto no estado final. -->
<@main.layout 
  title="Doe sangue sem se preocupar com o transporte · Rota Solidária" 
  description="O hemocentro fica longe? O ônibus leva você. Encontre uma caravana gratuita que sai da sua cidade, reserve sua vaga em poucos cliques e ajude a salvar vidas."
  css="/css/doar.css" 
  currentNav="inicio" 
  scripts=["/js/gotas.js", "/js/doar-motion.js"]>
  <main class="doar">

    <section class="doar-hero vh-section">
      <div class="container doar-hero__grid">
        <div class="doar-hero__texto">
          <h1><span class="doar-pal" style="--i:0">O</span> <span class="doar-pal" style="--i:1">hemocentro</span> <span class="doar-pal" style="--i:2">fica</span> <span class="doar-pal doar-longe" style="--i:3">longe</span><span class="doar-pal" style="--i:3">?</span> <span class="doar-pal" style="--i:5">O</span> <span class="doar-pal" style="--i:6">ônibus</span> <span class="doar-leva"><span class="doar-pal" style="--i:7">leva</span> <span class="doar-pal" style="--i:8">você.</span></span></h1>
          <p class="doar-hero__sub">Escolha uma caravana gratuita que sai da sua cidade, reserve a vaga em poucos cliques e receba o bilhete de embarque no celular.</p>
          <div class="doar-hero__acoes">
            <a class="btn btn-primary btn-lg" href="/campanhas">Ver caravanas perto de mim<span class="icon doar-seta" aria-hidden="true">arrow_forward</span></a>
            <a class="btn btn-ghost btn-lg" href="#como">Como funciona</a>
          </div>
          <#if caravanasAbertas gt 0>
            <span class="doar-prova"><span class="doar-prova__ponto" aria-hidden="true"></span><strong>${caravanasAbertas}</strong> <#if caravanasAbertas == 1>caravana com inscrições abertas agora<#else>caravanas com inscrições abertas agora</#if></span>
          </#if>
        </div>

        <#-- iPhone com a tela "Como chegar" em HTML (no desktop fica lado a lado no hero; no mobile ganha sua própria seção abaixo) -->
        <div class="doar-hero__visual doar-hero__visual--desktop">
          <div class="iphone" role="img" aria-label="Celular com a tela Como chegar do Rota Solidária: o ônibus sai da Praça da Matriz de Angatuba às 06:30, para na Rodoviária de Itapetininga e chega ao Colsan Sorocaba para a doação às 08:30">
            <span class="iphone__btn iphone__btn--acao"></span><span class="iphone__btn iphone__btn--vol1"></span><span class="iphone__btn iphone__btn--vol2"></span><span class="iphone__btn iphone__btn--lado"></span>
            <div class="iphone__bezel">
              <div class="iphone__tela" aria-hidden="true">
                <span class="iphone__ilha"></span>
                <div class="iphone__status">
                  <span>9:41</span>
                  <span class="iphone__icones">
                    <svg width="16" height="12" viewBox="0 0 16 12"><path d="M8 2.6c2.3 0 4.4.9 6 2.4l1.2-1.3A10.3 10.3 0 0 0 8 .8 10.3 10.3 0 0 0 .8 3.7L2 5c1.6-1.5 3.7-2.4 6-2.4Zm0 3.6c1.3 0 2.5.5 3.4 1.3l1.2-1.3A6.7 6.7 0 0 0 8 4.4 6.7 6.7 0 0 0 3.4 6.2l1.2 1.3c.9-.8 2.1-1.3 3.4-1.3Zm0 3.5c-.4 0-.8.2-1.1.5L8 11.4l1.1-1.2c-.3-.3-.7-.5-1.1-.5Z"></path></svg>
                    <svg width="27" height="13" viewBox="0 0 27 13"><rect x=".5" y=".5" width="23" height="12" rx="3.8" fill="none" stroke="currentColor" opacity=".4"></rect><rect x="2" y="2" width="18" height="9" rx="2.4"></rect><path d="M25 4.5v4a2 2 0 0 0 0-4Z" opacity=".45"></path></svg>
                  </span>
                </div>
                <div class="iphone__notif">
                  <span class="iphone__notif-app"><span class="icon">mail</span></span>
                  <span class="iphone__notif-txt"><span class="iphone__notif-linha"><span>E-mail · Rota Solidária</span><span>agora</span></span><b>Lembrete: falta menos de um dia</b><span>Embarque ≈ 07:15 · Rodoviária de Itapetininga</span></span>
                </div>
                <div class="app-topo"><i></i><span><b>Rota</b> Solidária</span></div>
                <div class="app-corpo">
                  <span class="app-kicker">Como chegar</span>
                  <div class="app-titulo">O ônibus leva você até o hemocentro</div>
                  <div class="rota">
                    <svg class="rota__linha" viewBox="0 0 4 240" preserveAspectRatio="none">
                      <path class="rota__fundo" d="M2 0V240" pathLength="1"></path>
                      <path class="rota__traco" d="M2 0V240" pathLength="1"></path>
                    </svg>
                    <div class="rota__parada">
                      <span class="rota__pino rota__pino--saida"><span class="icon">directions_bus</span></span>
                      <span class="rota__txt"><span class="rota__hora">Saída 06:30</span><strong>Partida</strong><span>Praça da Matriz, Angatuba</span></span>
                    </div>
                    <div class="rota__parada">
                      <span class="rota__pino rota__pino--parada">1</span>
                      <span class="rota__txt"><span class="rota__hora">≈ 07:15</span><strong>Parada 1</strong><span>Rodoviária de Itapetininga</span></span>
                    </div>
                    <div class="rota__parada">
                      <span class="rota__pino rota__pino--hemo"><span class="icon">bloodtype</span></span>
                      <span class="rota__txt"><span class="rota__hora">Doação 08:30</span><strong>Hemocentro</strong><span>Colsan Sorocaba</span></span>
                    </div>
                    <span class="rota__bus"><span class="icon">directions_bus</span></span>
                  </div>
                </div>
                <div class="app-carimbo"><strong><span class="icon">check</span>VAGA GARANTIDA</strong><span>CÓDIGO RS-00002</span></div>
                <span class="iphone__indicador"></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <#-- No mobile: o celular vira uma seção de 100vh própria e focada na animação da rota -->
    <section class="doar-cel-sec vh-section" data-anima data-anima-limiar="0.3">
      <div class="container doar-cel-sec__container">
        <div class="doar-hero__visual doar-hero__visual--mobile">
          <div class="iphone" role="img" aria-label="Celular com a tela Como chegar do Rota Solidária: o ônibus sai da Praça da Matriz de Angatuba às 06:30, para na Rodoviária de Itapetininga e chega ao Colsan Sorocaba para a doação às 08:30">
            <span class="iphone__btn iphone__btn--acao"></span><span class="iphone__btn iphone__btn--vol1"></span><span class="iphone__btn iphone__btn--vol2"></span><span class="iphone__btn iphone__btn--lado"></span>
            <div class="iphone__bezel">
              <div class="iphone__tela" aria-hidden="true">
                <span class="iphone__ilha"></span>
                <div class="iphone__status">
                  <span>9:41</span>
                  <span class="iphone__icones">
                    <svg width="18" height="12" viewBox="0 0 18 12"><rect x="0" y="8" width="3" height="4" rx="1"></rect><rect x="5" y="5.5" width="3" height="6.5" rx="1"></rect><rect x="10" y="3" width="3" height="9" rx="1"></rect><rect x="15" y="0" width="3" height="12" rx="1"></rect></svg>
                    <svg width="16" height="12" viewBox="0 0 16 12"><path d="M8 2.6c2.3 0 4.4.9 6 2.4l1.2-1.3A10.3 10.3 0 0 0 8 .8 10.3 10.3 0 0 0 .8 3.7L2 5c1.6-1.5 3.7-2.4 6-2.4Zm0 3.6c1.3 0 2.5.5 3.4 1.3l1.2-1.3A6.7 6.7 0 0 0 8 4.4 6.7 6.7 0 0 0 3.4 6.2l1.2 1.3c.9-.8 2.1-1.3 3.4-1.3Zm0 3.5c-.4 0-.8.2-1.1.5L8 11.4l1.1-1.2c-.3-.3-.7-.5-1.1-.5Z"></path></svg>
                    <svg width="27" height="13" viewBox="0 0 27 13"><rect x=".5" y=".5" width="23" height="12" rx="3.8" fill="none" stroke="currentColor" opacity=".4"></rect><rect x="2" y="2" width="18" height="9" rx="2.4"></rect><path d="M25 4.5v4a2 2 0 0 0 0-4Z" opacity=".45"></path></svg>
                  </span>
                </div>
                <div class="iphone__notif">
                  <span class="iphone__notif-app"><span class="icon">mail</span></span>
                  <span class="iphone__notif-txt"><span class="iphone__notif-linha"><span>E-mail · Rota Solidária</span><span>agora</span></span><b>Lembrete: falta menos de um dia</b><span>Embarque ≈ 07:15 · Rodoviária de Itapetininga</span></span>
                </div>
                <div class="app-topo"><i></i><span><b>Rota</b> Solidária</span></div>
                <div class="app-corpo">
                  <span class="app-kicker">Como chegar</span>
                  <div class="app-titulo">O ônibus leva você até o hemocentro</div>
                  <div class="rota">
                    <svg class="rota__linha" viewBox="0 0 4 240" preserveAspectRatio="none">
                      <path class="rota__fundo" d="M2 0V240" pathLength="1"></path>
                      <path class="rota__traco" d="M2 0V240" pathLength="1"></path>
                    </svg>
                    <div class="rota__parada">
                      <span class="rota__pino rota__pino--saida"><span class="icon">directions_bus</span></span>
                      <span class="rota__txt"><span class="rota__hora">Saída 06:30</span><strong>Partida</strong><span>Praça da Matriz, Angatuba</span></span>
                    </div>
                    <div class="rota__parada">
                      <span class="rota__pino rota__pino--parada">1</span>
                      <span class="rota__txt"><span class="rota__hora">≈ 07:15</span><strong>Parada 1</strong><span>Rodoviária de Itapetininga</span></span>
                    </div>
                    <div class="rota__parada">
                      <span class="rota__pino rota__pino--hemo"><span class="icon">bloodtype</span></span>
                      <span class="rota__txt"><span class="rota__hora">Doação 08:30</span><strong>Hemocentro</strong><span>Colsan Sorocaba</span></span>
                    </div>
                    <span class="rota__bus"><span class="icon">directions_bus</span></span>
                  </div>
                </div>
                <div class="app-carimbo"><strong><span class="icon">check</span>VAGA GARANTIDA</strong><span>CÓDIGO RS-00002</span></div>
                <span class="iphone__indicador"></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="doar-dor vh-section" data-anima>
      <div class="container">
        <div class="doar-cabeca doar-cabeca--centro">
          <span class="kicker doar-entra">Por que tanta gente não doa</span>
          <h2 class="doar-entra" style="--i:1">Vontade não falta. Falta chegar até lá.</h2>
        </div>
        <div class="doar-dor__grid">
          <div class="doar-dor__card" style="--i:0">
            <span class="doar-dor__icone" aria-hidden="true"><span class="icon">location_on</span></span>
            <s class="doar-objecao">"O hemocentro é em outra cidade."</s>
            <span class="doar-resposta"><strong>A caravana sai da sua cidade.</strong><span>Pontos de embarque conhecidos, como a praça ou a rodoviária, com horário marcado.</span></span>
          </div>
          <div class="doar-dor__card" style="--i:1">
            <span class="doar-dor__icone" aria-hidden="true"><span class="icon">directions_bus</span></span>
            <s class="doar-objecao">"Não tenho carro nem carona."</s>
            <span class="doar-resposta"><strong>O ônibus é gratuito.</strong><span>Você não paga passagem nem nada para doar. Só reserva a vaga.</span></span>
          </div>
          <div class="doar-dor__card" style="--i:2">
            <span class="doar-dor__icone" aria-hidden="true"><span class="icon">fact_check</span></span>
            <s class="doar-objecao">"Nem sei se eu posso doar."</s>
            <span class="doar-resposta"><strong>Confira em 30 segundos.</strong><span>Os requisitos básicos estão logo abaixo. A palavra final é da triagem no hemocentro.</span></span>
          </div>
        </div>
      </div>
    </section>

    <section class="doar-como vh-section" id="como" data-anima>
      <div class="container">
        <div class="doar-cabeca doar-cabeca--centro">
          <span class="kicker doar-entra">Como funciona</span>
          <h2 class="doar-entra" style="--i:1">Três passos até a sua vaga no ônibus</h2>
        </div>
        <ol class="doar-passos">
          <li class="doar-entra" style="--i:0">
            <div class="doar-passos__tela"><img src="/images/doar/passo-1-caravanas.jpg" width="585" height="1266" loading="lazy" alt="Lista de caravanas abertas no app, com data e vagas"></div>
            <div class="doar-passos__info">
              <span class="doar-passos__num">01</span>
              <strong>Escolha a caravana</strong>
              <span>Veja data, horário de saída e quantas vagas ainda restam.</span>
            </div>
          </li>
          <li class="doar-entra" style="--i:1">
            <div class="doar-passos__tela"><img src="/images/doar/passo-2-embarque.jpg" width="585" height="1266" loading="lazy" alt="Escolha do ponto de embarque no app"></div>
            <div class="doar-passos__info">
              <span class="doar-passos__num">02</span>
              <strong>Escolha onde embarcar</strong>
              <span>O ônibus passa por mais de um ponto. Você pega o mais perto de casa.</span>
            </div>
          </li>
          <li class="doar-entra" style="--i:2">
            <div class="doar-passos__tela">
              <img src="/images/doar/passo-3-bilhete.jpg" width="585" height="1266" loading="lazy" alt="Bilhete de embarque com o código da vaga">
              <span class="doar-mini-carimbo" aria-hidden="true">VAGA GARANTIDA<small>RS-00002</small></span>
            </div>
            <div class="doar-passos__info">
              <span class="doar-passos__num">03</span>
              <strong>Receba o bilhete</strong>
              <span>Mande para o WhatsApp, salve na agenda e receba lembrete por e-mail.</span>
            </div>
          </li>
        </ol>
        <div class="doar-como__acao">
          <a class="btn btn-primary btn-lg doar-entra" style="--i:3" href="/campanhas">Quero reservar minha vaga<span class="icon doar-seta" aria-hidden="true">arrow_forward</span></a>
        </div>
      </div>
    </section>

    <section class="doar-posso vh-section" id="posso" data-anima>
      <div class="container doar-posso__grid">
        <div class="doar-posso__texto doar-entra">
          <span class="kicker">Posso doar?</span>
          <h2>Confira o básico antes de reservar</h2>
          <p class="muted">Reservar a vaga no ônibus não garante a doação: quem decide é a triagem clínica no hemocentro, no dia.</p>
          <a class="doar-link" href="/educativo">Ver o guia completo do doador<span class="icon" aria-hidden="true">arrow_forward</span></a>
        </div>
        <ul class="doar-requisitos">
          <li class="doar-entra" style="--i:1"><span class="icon" aria-hidden="true">check_circle</span><span><strong>16 a 69 anos</strong>Menores de 18 com autorização; de 60 a 69, só quem já doou antes</span></li>
          <li class="doar-entra" style="--i:2"><span class="icon" aria-hidden="true">check_circle</span><span><strong>50 kg ou mais</strong>Peso mínimo para doar</span></li>
          <li class="doar-entra" style="--i:3"><span class="icon" aria-hidden="true">check_circle</span><span><strong>Dormiu 6 horas</strong>E está alimentado</span></li>
          <li class="doar-entra" style="--i:4"><span class="icon" aria-hidden="true">check_circle</span><span><strong>60 ou 90 dias</strong>Desde a última doação (homens / mulheres)</span></li>
        </ul>
      </div>
    </section>

    <section class="doar-todos vh-section-sm" data-anima>
      <div class="container doar-todos__grid">
        <img class="doar-entra" src="/images/doar/acessibilidade.jpg" width="1200" height="750" loading="lazy" alt="Painel de acessibilidade do Rota Solidária com o texto ampliado">
        <div class="doar-todos__texto doar-entra" style="--i:1">
          <span class="kicker">Feito para todo mundo</span>
          <h2>Letra grande, alto contraste e modo escuro em um toque</h2>
          <p class="muted">Pensado para quem tem 16 ou 69 anos e para internet lenta. Funciona no celular, sem instalar nada.</p>
          <span class="doar-todos__origem">Projeto de extensão do curso de Tecnologia em Sistemas para Internet · IFSP Itapetininga.</span>
        </div>
      </div>
    </section>

    <section class="doar-duvidas vh-section" id="duvidas">
      <div class="container doar-duvidas__caixa">
        <div class="doar-cabeca doar-cabeca--centro">
          <span class="kicker">Tire suas dúvidas</span>
          <h2>Dúvidas de quem vai pela primeira vez</h2>
        </div>
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

    <section class="doar-final-sec vh-section-sm" data-anima data-anima-gotas>
      <div class="container">
        <div class="doar-final">
          <div>
            <h2 class="doar-entra">Tem um ônibus saindo perto de você.</h2>
            <p class="doar-entra" style="--i:1">Veja a data, escolha o ponto de embarque e garanta a vaga.</p>
          </div>
          <div class="doar-final__acao doar-entra" style="--i:2">
            <a class="btn btn-primary btn-lg" href="/campanhas" data-gotas-do>Ver caravanas perto de mim<span class="icon doar-seta" aria-hidden="true">arrow_forward</span></a>
            <span>Gratuito · reserva em poucos cliques</span>
          </div>
        </div>
      </div>
    </section>

  </main>
</@main.layout>
