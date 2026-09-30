<#--
  E-mail de boas-vindas, enviado quando uma conta é criada (cadastro ou Google).
  HTML de e-mail: layout em tabelas e estilos inline, porque Gmail/Outlook ignoram
  folhas de estilo externas, flexbox e grid. A logo é anexada inline (cid:logo) pelo EmailService.
  Variáveis: primeiroNome, linkPerfil, linkCampanhas
-->
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="light">
  <meta name="supported-color-schemes" content="light">
  <title>Boas-vindas - Rota Solidária</title>
</head>
<body style="margin:0;padding:0;background-color:#FAF9F8;-webkit-font-smoothing:antialiased;">
  <#-- Texto de pré-visualização exibido ao lado do assunto na caixa de entrada -->
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:#FAF9F8;">
    Sua conta está pronta. Veja os próximos passos para fazer sua primeira doação.
  </div>

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#FAF9F8;">
    <tr>
      <td align="center" style="padding:32px 16px;">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:560px;">

          <#-- Marca -->
          <tr>
            <td style="padding:0 4px 20px;">
              <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td style="vertical-align:middle;padding-right:10px;">
                    <img src="cid:logo" width="40" height="40" alt="" style="display:block;border:0;width:40px;height:40px;">
                  </td>
                  <td style="vertical-align:middle;font-family:Archivo,'Arial Black',Arial,Helvetica,sans-serif;font-size:20px;font-weight:800;letter-spacing:-0.4px;color:#1A1817;">
                    <span style="color:#B4232A;">Rota</span> Solidária
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <#-- Cartão principal -->
          <tr>
            <td style="background-color:#FFFFFF;border:1px solid #E4E0DC;border-radius:20px;padding:36px 32px;">
              <p style="margin:0 0 12px;font-family:'IBM Plex Mono','Courier New',monospace;font-size:12px;font-weight:500;letter-spacing:1.4px;text-transform:uppercase;color:#B4232A;">
                Boas-vindas
              </p>
              <h1 style="margin:0 0 16px;font-family:Archivo,'Arial Black',Arial,Helvetica,sans-serif;font-size:28px;line-height:1.15;font-weight:800;letter-spacing:-0.5px;color:#1A1817;">
                Olá, ${primeiroNome}! 👋
              </h1>
              <p style="margin:0 0 26px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:16px;line-height:1.6;color:#57514E;">
                Sua conta no Rota Solidária está pronta. Obrigado por querer doar: cada bolsa de sangue pode ajudar até quatro pessoas.
              </p>

              <#-- Próximos passos -->
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom:28px;">
                <tr>
                  <td style="vertical-align:top;padding:0 0 14px;width:40px;">
                    <div style="width:28px;height:28px;border-radius:14px;background-color:#FBE3E4;color:#8F1821;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;line-height:28px;text-align:center;">1</div>
                  </td>
                  <td style="vertical-align:top;padding:0 0 14px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:15px;line-height:1.5;color:#57514E;">
                    <strong style="color:#1A1817;">Complete seu perfil</strong><br>Tipo sanguíneo, peso e data de nascimento agilizam suas inscrições.
                  </td>
                </tr>
                <tr>
                  <td style="vertical-align:top;padding:0 0 14px;width:40px;">
                    <div style="width:28px;height:28px;border-radius:14px;background-color:#FBE3E4;color:#8F1821;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;line-height:28px;text-align:center;">2</div>
                  </td>
                  <td style="vertical-align:top;padding:0 0 14px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:15px;line-height:1.5;color:#57514E;">
                    <strong style="color:#1A1817;">Veja as campanhas perto de você</strong><br>Caravanas saindo de Angatuba e região para os hemocentros.
                  </td>
                </tr>
                <tr>
                  <td style="vertical-align:top;padding:0;width:40px;">
                    <div style="width:28px;height:28px;border-radius:14px;background-color:#FBE3E4;color:#8F1821;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;line-height:28px;text-align:center;">3</div>
                  </td>
                  <td style="vertical-align:top;padding:0;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:15px;line-height:1.5;color:#57514E;">
                    <strong style="color:#1A1817;">Inscreva-se e garanta o transporte</strong><br>Escolha o ponto de embarque e receba seu bilhete.
                  </td>
                </tr>
              </table>

              <#-- Botão "à prova de balas": funciona mesmo em clientes que ignoram padding em links -->
              <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="center" bgcolor="#B4232A" style="border-radius:12px;background-color:#B4232A;">
                    <a href="${linkPerfil}" target="_blank" style="display:inline-block;padding:16px 32px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:16px;font-weight:600;line-height:1;color:#FFFFFF;text-decoration:none;border-radius:12px;">
                      Completar meu perfil
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:20px 0 0;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:14px;line-height:1.5;color:#8A827E;">
                Prefere começar pelas campanhas? <a href="${linkCampanhas}" target="_blank" style="color:#B4232A;font-weight:600;text-decoration:underline;">Ver campanhas</a>
              </p>
            </td>
          </tr>

          <#-- Rodapé -->
          <tr>
            <td align="center" style="padding:24px 16px 0;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:13px;line-height:1.6;color:#8A827E;">
              <strong style="color:#57514E;">Rota Solidária</strong> · Projeto de Extensão · Angatuba e Região<br>
              Este é um e-mail automático, não é preciso respondê-lo.
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
