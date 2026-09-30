<#--
  Layout compartilhado dos e-mails (direção "Editorial caloroso").
  HTML de e-mail: layout em tabelas e estilos inline, porque Gmail/Outlook ignoram
  folhas de estilo externas, flexbox e grid. A logo é anexada inline (cid:logo) pelo EmailService.
  Uso: <#import "_layout.ftlh" as e> e <@e.layout titulo=... preheader=... motivo=...>…</@e.layout>
  tom: "vermelho" (padrão), "ambar" ou "neutro" define a cor de destaque do e-mail.
-->
<#assign tons = {
  "vermelho": {"fundo": "#FFF7F5", "circulo": "#FBE3E4", "destaque": "#B4232A", "linha": "#F0D6D3"},
  "ambar":    {"fundo": "#FFF9F0", "circulo": "#FDEBC8", "destaque": "#8A5A00", "linha": "#F1DFC0"},
  "neutro":   {"fundo": "#F7F6F5", "circulo": "#E9E6E3", "destaque": "#57514E", "linha": "#E4E0DC"}
}>
<#assign sans = "'IBM Plex Sans',Arial,Helvetica,sans-serif">
<#assign display = "Archivo,'Arial Black',Arial,Helvetica,sans-serif">

<#macro layout titulo preheader motivo tom="vermelho">
<#assign t = tons[tom]>
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="light">
  <meta name="supported-color-schemes" content="light">
  <title>${titulo} - Rota Solidária</title>
</head>
<body style="margin:0;padding:0;background-color:${t.fundo};-webkit-font-smoothing:antialiased;">
  <#-- Texto de pré-visualização exibido ao lado do assunto na caixa de entrada -->
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:${t.fundo};">${preheader}</div>

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:${t.fundo};">
    <tr>
      <td align="center" style="padding:48px 20px;">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:520px;">
          <#-- Marca -->
          <tr>
            <td style="padding:0 0 44px;font-family:${display};font-size:16px;font-weight:800;color:#1A1817;">
              <img src="cid:logo" width="28" height="28" alt="" style="display:inline-block;vertical-align:middle;border:0;width:28px;height:28px;margin-right:8px;">
              <span style="vertical-align:middle;"><span style="color:#B4232A;">Rota</span> Solidária</span>
            </td>
          </tr>
          <#-- Selo circular -->
          <tr>
            <td style="padding:0 0 28px;">
              <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="center" valign="middle" width="80" height="80" bgcolor="${t.circulo}" style="width:80px;height:80px;border-radius:40px;background-color:${t.circulo};">
                    <img src="cid:logo" width="36" height="36" alt="" style="display:block;border:0;width:36px;height:36px;margin:0 auto;">
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <#nested>
          <#-- Assinatura e rodapé -->
          <tr>
            <td style="padding:44px 0 0;font-family:${sans};font-size:16px;line-height:1.6;color:#57514E;">
              Com carinho,<br><strong style="color:#1A1817;">Equipe Rota Solidária</strong>
            </td>
          </tr>
          <tr>
            <td style="padding:36px 0 0;font-family:${sans};font-size:12px;line-height:1.6;color:#6B6461;">
              Projeto de Extensão · Angatuba e Região. ${motivo} Este é um e-mail automático, não é preciso respondê-lo.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
</#macro>

<#-- Título grande; "destaque" é a parte colorida na segunda linha -->
<#macro titulo texto destaque="">
<tr>
  <td style="padding:0 0 20px;font-family:${display};font-size:40px;line-height:1.05;font-weight:800;letter-spacing:-1px;color:#1A1817;">
    ${texto}<#if destaque?has_content><br><span style="color:${t.destaque};">${destaque}</span></#if>
  </td>
</tr>
</#macro>

<#macro paragrafo tamanho=18>
<tr>
  <td style="padding:0 0 18px;font-family:${sans};font-size:${tamanho}px;line-height:1.6;color:#3E3936;"><#nested></td>
</tr>
</#macro>

<#-- Botão "à prova de balas": funciona mesmo em clientes que ignoram padding em links -->
<#macro botao href rotulo>
<tr>
  <td style="padding:18px 0 0;">
    <table role="presentation" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td align="center" bgcolor="#1A1817" style="border-radius:999px;background-color:#1A1817;">
          <a href="${href}" target="_blank" style="display:inline-block;padding:16px 28px;font-family:${sans};font-size:16px;font-weight:600;color:#FFFFFF;text-decoration:none;border-radius:999px;">${rotulo}</a>
        </td>
      </tr>
    </table>
  </td>
</tr>
</#macro>

<#-- Seção separada por linha fina, com título -->
<#macro secao titulo>
<tr>
  <td style="padding:44px 0 0;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-top:1px solid ${t.linha};">
      <tr>
        <td style="padding:28px 0 16px;font-family:${display};font-size:20px;font-weight:600;color:#1A1817;">${titulo}</td>
      </tr>
      <#nested>
    </table>
  </td>
</tr>
</#macro>

<#-- Item de texto dentro de uma seção: frase em negrito + complemento -->
<#macro item forte>
<tr>
  <td style="padding:0 0 16px;font-family:${sans};font-size:16px;line-height:1.6;color:#57514E;"><strong style="color:#1A1817;">${forte}</strong> <#nested></td>
</tr>
</#macro>

<#-- Linha rótulo/valor para detalhes (data, local…) -->
<#macro dado rotulo valor>
<tr>
  <td style="padding:0 0 12px;font-family:${sans};font-size:16px;line-height:1.5;color:#1A1817;">
    <span style="display:inline-block;width:110px;color:#6B6461;">${rotulo}</span><strong>${valor}</strong>
  </td>
</tr>
</#macro>

<#macro link href><a href="${href}" target="_blank" style="color:#B4232A;font-weight:600;"><#nested></a></#macro>
