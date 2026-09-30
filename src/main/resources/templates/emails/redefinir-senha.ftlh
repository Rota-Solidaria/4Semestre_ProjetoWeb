<#--
  E-mail de redefinição de senha.
  Variáveis: primeiroNome, link, validadeMinutos
-->
<#import "_layout.ftlh" as e>
<@e.layout titulo="Redefinição de senha"
           preheader="Crie uma nova senha para sua conta. O link vale por ${validadeMinutos} minutos."
           motivo="Você recebeu este e-mail porque alguém pediu para redefinir a senha desta conta.">
  <@e.titulo texto="Vamos criar" destaque="uma nova senha."/>
  <@e.paragrafo>Olá, ${primeiroNome}. Recebemos um pedido para redefinir a senha da sua conta no Rota Solidária. É só tocar no botão abaixo e escolher uma nova.</@e.paragrafo>
  <@e.paragrafo tamanho=16>O link vale por <strong style="color:#1A1817;">${validadeMinutos} minutos</strong> e só pode ser usado uma vez.</@e.paragrafo>
  <@e.botao href=link rotulo="Criar nova senha"/>
  <@e.secao titulo="Não foi você?">
    <@e.item forte="Pode ficar tranquilo.">Ignore este e-mail: sua senha continua a mesma e ninguém consegue alterá-la sem este link.</@e.item>
    <@e.item forte="O botão não funcionou?">Copie e cole este endereço no navegador:<br><@e.link href=link>${link}</@e.link></@e.item>
  </@e.secao>
</@e.layout>
