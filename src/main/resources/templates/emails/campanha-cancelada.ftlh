<#--
  Aviso de campanha cancelada, enviado a cada inscrito (CampanhaEmailService).
  Variáveis: primeiroNome, titulo, data, local, linkCampanhas
-->
<#import "_layout.ftlh" as e>
<@e.layout titulo="Campanha cancelada"
           preheader="A campanha ${titulo} de ${data} foi cancelada."
           motivo="Você recebeu este e-mail porque estava inscrito nesta campanha."
           tom="neutro">
  <@e.titulo texto="Olá, ${primeiroNome}." destaque="Uma mudança de planos."/>
  <@e.paragrafo>A campanha em que você se inscreveu foi <strong style="color:#1A1817;">cancelada pelo organizador</strong>. Sentimos muito pelo transtorno. Sua inscrição não vale mais para essa data.</@e.paragrafo>
  <@e.secao titulo="Campanha cancelada">
    <@e.dado rotulo="Campanha" valor=titulo/>
    <@e.dado rotulo="Data" valor=data/>
    <@e.dado rotulo="Local" valor=local/>
  </@e.secao>
  <@e.paragrafo>Outras caravanas continuam precisando de você.</@e.paragrafo>
  <@e.botao href=linkCampanhas rotulo="Ver outras campanhas"/>
</@e.layout>
