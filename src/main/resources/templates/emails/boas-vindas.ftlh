<#--
  E-mail de boas-vindas, enviado quando uma conta é criada (cadastro ou Google).
  Variáveis: primeiroNome, linkPerfil, linkCampanhas
-->
<#import "_layout.ftlh" as e>
<@e.layout titulo="Boas-vindas"
           preheader="Sua conta está pronta. Veja os próximos passos para fazer sua primeira doação."
           motivo="Você recebeu este e-mail porque criou uma conta.">
  <@e.titulo texto="Boas-vindas," destaque="${primeiroNome}."/>
  <@e.paragrafo>Sua conta no Rota Solidária está pronta. Daqui para frente, a gente cuida do caminho até o hemocentro. Você só precisa chegar com vontade de ajudar.</@e.paragrafo>
  <@e.paragrafo>Uma única doação pode ajudar até <strong style="color:#1A1817;">quatro pessoas</strong>.</@e.paragrafo>
  <@e.botao href=linkPerfil rotulo="Completar meu perfil"/>
  <@e.secao titulo="Seus próximos passos">
    <@e.item forte="Conte um pouco sobre você.">Tipo sanguíneo, peso e data de nascimento deixam a inscrição mais rápida.</@e.item>
    <@e.item forte="Encontre uma caravana.">Saídas de Angatuba e região para os hemocentros. <@e.link href=linkCampanhas>Ver campanhas</@e.link></@e.item>
    <@e.item forte="Garanta seu lugar.">Escolha o ponto de embarque e receba seu bilhete.</@e.item>
  </@e.secao>
</@e.layout>
