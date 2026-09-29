<#import "../layout/main.ftlh" as main>

<@main.layout title="Login - Rota Solidária" css="/css/login.css" currentNav="entrar">
  <main class="container">
    <div class="login-wrap">
      <div class="panel login-panel">
        <span class="kicker">Acesso</span>
        <h1>Entrar</h1>
        <p>Acesse seu perfil para acompanhar suas inscrições.</p>
        <form method="post" action="/login">
          <#include "../includes/csrf.ftlh">
          <div class="field">
            <label for="rs-email">E-mail</label>
            <input id="rs-email" name="email" type="email" required autocomplete="email" placeholder="seu@email.com">
          </div>
          <div class="field">
            <div class="field-label-row">
              <label for="rs-senha">Senha</label>
              <a class="field-link" href="/esqueci-senha">Esqueci minha senha</a>
            </div>
            <input id="rs-senha" name="senha" type="password" data-password required autocomplete="current-password" placeholder="••••••••">
          </div>
          <button class="btn btn-primary" type="submit">Entrar</button>
        </form>
        <p class="login-foot">Ainda não possui cadastro? <a href="/cadastro">Criar conta</a></p>
      </div>
    </div>
  </main>
</@main.layout>
