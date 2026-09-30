<#--
  Lembrete enviado 24h antes da campanha (LembreteCampanhaService).
  Variáveis: primeiroNome, titulo, data, hora, rotuloLocal, local, codigo, linkBilhete
-->
<#import "_layout.ftlh" as e>
<@e.layout titulo="Lembrete de campanha"
           preheader="Sua doação é em ${data} às ${hora}. Veja os detalhes."
           motivo="Você recebeu este e-mail porque está inscrito nesta campanha."
           tom="ambar">
  <@e.titulo texto="Falta pouco," destaque="${primeiroNome}."/>
  <@e.paragrafo>Sua doação na campanha <strong style="color:#1A1817;">${titulo}</strong> é amanhã. Obrigado por separar esse tempo para alguém que você talvez nunca conheça.</@e.paragrafo>
  <@e.secao titulo="Onde e quando">
    <@e.dado rotulo="Data" valor=data/>
    <@e.dado rotulo="Horário" valor=hora/>
    <@e.dado rotulo=rotuloLocal valor=local/>
    <@e.dado rotulo="Bilhete" valor=codigo/>
  </@e.secao>
  <@e.botao href=linkBilhete rotulo="Ver meu bilhete"/>
  <@e.secao titulo="Antes de ir">
    <@e.item forte="Leve um documento oficial com foto.">Ele é pedido na triagem do hemocentro.</@e.item>
    <@e.item forte="Durma bem e alimente-se.">Evite comidas gordurosas nas horas anteriores.</@e.item>
    <@e.item forte="Beba bastante água.">Hoje e amanhã cedo.</@e.item>
  </@e.secao>
</@e.layout>
