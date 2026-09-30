<#import "../layout/main.ftlh" as main>

<@main.layout title="Criar Conta - Rota Solidária" css="/css/login.css" currentNav="entrar">
  <main class="container">
    <div class="login-wrap">
      <div class="panel login-panel">
        <span class="kicker">Cadastro</span>
        <h1>Criar conta</h1>
        <p>Cadastre-se para se inscrever nas caravanas de doação.</p>
        <form method="post" action="/cadastro">
          <#include "../includes/csrf.ftlh">
          <div class="field">
            <label for="rs-nome">Nome completo</label>
            <input id="rs-nome" name="name" type="text" required maxlength="120" autocomplete="name" value="${name!""}" placeholder="Seu nome">
          </div>
          <div class="field">
            <label for="rs-email">E-mail</label>
            <input id="rs-email" name="email" type="email" required maxlength="160" autocomplete="email" value="${email!""}" placeholder="seu@email.com">
          </div>
          <div class="field">
            <label for="rs-telefone">Telefone / WhatsApp <span class="field-optional">(opcional)</span></label>
            <input id="rs-telefone" name="phone" type="tel" maxlength="20" autocomplete="tel" value="${phone!""}" placeholder="(15) 99999-9999">
          </div>
          <div class="field">
            <label for="rs-senha">Senha</label>
            <input id="rs-senha" name="senha" type="password" data-password data-password-strength required minlength="${minSenha}" autocomplete="new-password" placeholder="Mínimo ${minSenha} caracteres">
          </div>
          <div class="field">
            <label for="rs-confirmar">Confirmar senha</label>
            <input id="rs-confirmar" name="confirmarSenha" type="password" data-password data-password-confirm="#rs-senha" required minlength="${minSenha}" autocomplete="new-password" placeholder="Repita a senha">
          </div>
          <button class="btn btn-primary" type="submit">Criar conta</button>
        </form>
        <#assign googleLabel = "Cadastrar com Google">
        <#include "../includes/google-login.ftlh">
        <p class="login-foot">Já possui conta? <a href="/login">Entrar</a></p>
      </div>
    </div>
  </main>
</@main.layout>
