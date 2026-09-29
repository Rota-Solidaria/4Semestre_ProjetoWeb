<#import "../layout/main.ftlh" as main>

<@main.layout title="Redefinir Senha - Rota Solidária" css="/css/login.css" currentNav="entrar">
  <main class="container">
    <div class="login-wrap">
      <div class="panel login-panel">
        <span class="kicker">Recuperar acesso</span>
        <h1>Criar nova senha</h1>
        <#if tokenValido>
          <p>Escolha uma nova senha para a sua conta.</p>
          <form method="post" action="/redefinir-senha">
            <#include "../includes/csrf.ftlh">
            <input type="hidden" name="token" value="${token}">
            <div class="field">
              <label for="rs-senha">Nova senha</label>
              <input id="rs-senha" name="senha" type="password" data-password data-password-strength required minlength="${minSenha}" autocomplete="new-password" placeholder="Mínimo ${minSenha} caracteres">
            </div>
            <div class="field">
              <label for="rs-confirmar">Confirmar nova senha</label>
              <input id="rs-confirmar" name="confirmarSenha" type="password" data-password data-password-confirm="#rs-senha" required minlength="${minSenha}" autocomplete="new-password" placeholder="Repita a nova senha">
            </div>
            <button class="btn btn-primary" type="submit">Salvar nova senha</button>
          </form>
        <#else>
          <p class="login-msg-error">Este link de redefinição é inválido ou expirou.</p>
          <a class="btn btn-primary" href="/esqueci-senha">Solicitar novo link</a>
        </#if>
        <p class="login-foot"><a href="/login">Voltar para o login</a></p>
      </div>
    </div>
  </main>
</@main.layout>
