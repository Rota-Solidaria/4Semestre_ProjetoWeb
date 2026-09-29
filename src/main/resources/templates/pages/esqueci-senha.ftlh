<#import "../layout/main.ftlh" as main>

<@main.layout title="Esqueci Minha Senha - Rota Solidária" css="/css/login.css" currentNav="">
  <main class="container">
    <div class="login-wrap">
      <div class="panel login-panel">
        <span class="kicker">Recuperar acesso</span>
        <h1>Esqueci minha senha</h1>
        <#if enviado??>
          <p>Se o e-mail informado estiver cadastrado, você receberá em instantes um link para criar uma nova senha. Verifique também a caixa de spam.</p>
        <#else>
          <p>Informe o e-mail da sua conta e enviaremos um link para você criar uma nova senha.</p>
          <form method="post" action="/esqueci-senha">
            <#include "../includes/csrf.ftlh">
            <div class="field">
              <label for="rs-email">E-mail</label>
              <input id="rs-email" name="email" type="email" required autocomplete="email" placeholder="seu@email.com">
            </div>
            <button class="btn btn-primary" type="submit">Enviar link</button>
          </form>
        </#if>
        <p class="login-foot"><a href="/login">Voltar para o login</a></p>
      </div>
    </div>
  </main>
</@main.layout>
