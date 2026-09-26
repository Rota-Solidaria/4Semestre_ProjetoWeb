<#import "../layout/main.ftlh" as main>

<@main.layout title="Login - Rota Solidária" css="/css/login.css" currentNav="">
  <main class="container">
    <div class="login-wrap">
      <div class="panel login-panel">
        <span class="kicker">Acesso</span>
        <h1>Entrar</h1>
        <p>Acesse seu perfil para acompanhar suas inscrições.</p>
        <#if erro??>
          <p class="login-msg-error">${erro}</p>
        </#if>
        <#if aviso??>
          <p class="login-msg-warn">${aviso}</p>
        </#if>
        <form method="post" action="/login">
          <div class="field">
            <label for="rs-email">E-mail</label>
            <input id="rs-email" name="email" type="email" required placeholder="seu@email.com">
          </div>
          <div class="field">
            <label for="rs-senha">Senha</label>
            <input id="rs-senha" name="senha" type="password" required placeholder="••••••••">
          </div>
          <button class="btn btn-primary" type="submit">Entrar</button>
        </form>
        <p class="login-foot">Ainda não possui cadastro? <a href="/campanhas/1/inscrever">Continuar sem cadastro</a></p>
      </div>
    </div>
  </main>
</@main.layout>
