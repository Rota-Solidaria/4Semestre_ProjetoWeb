<#--
  E-mail de redefinição de senha.
  HTML de e-mail: layout em tabelas e estilos inline, porque Gmail/Outlook ignoram
  folhas de estilo externas, flexbox e grid. A logo é anexada inline (cid:logo) pelo EmailService.
  Variáveis: primeiroNome, link, validadeMinutos
-->
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="light">
  <meta name="supported-color-schemes" content="light">
  <title>Redefinição de senha - Rota Solidária</title>
</head>
<body style="margin:0;padding:0;background-color:#FAF9F8;-webkit-font-smoothing:antialiased;">
  <#-- Texto de pré-visualização exibido ao lado do assunto na caixa de entrada -->
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:#FAF9F8;">
    Crie uma nova senha para sua conta. O link vale por ${validadeMinutos} minutos.
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
                Recuperar acesso
              </p>
              <h1 style="margin:0 0 16px;font-family:Archivo,'Arial Black',Arial,Helvetica,sans-serif;font-size:28px;line-height:1.15;font-weight:800;letter-spacing:-0.5px;color:#1A1817;">
                Crie uma nova senha
              </h1>
              <p style="margin:0 0 14px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:16px;line-height:1.6;color:#57514E;">
                Olá, <strong style="color:#1A1817;">${primeiroNome}</strong>!
              </p>
              <p style="margin:0 0 28px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:16px;line-height:1.6;color:#57514E;">
                Recebemos um pedido para redefinir a senha da sua conta no Rota Solidária. Clique no botão abaixo para escolher uma nova senha.
              </p>

              <#-- Botão "à prova de balas": funciona mesmo em clientes que ignoram padding em links -->
              <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="center" bgcolor="#B4232A" style="border-radius:12px;background-color:#B4232A;">
                    <a href="${link}" target="_blank" style="display:inline-block;padding:16px 32px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:16px;font-weight:600;line-height:1;color:#FFFFFF;text-decoration:none;border-radius:12px;">
                      Criar nova senha
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:20px 0 0;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:14px;line-height:1.5;color:#8A827E;">
                O link vale por <strong style="color:#57514E;">${validadeMinutos} minutos</strong> e só pode ser usado uma vez.
              </p>

              <#-- Aviso de segurança -->
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:28px;">
                <tr>
                  <td style="background-color:#FDF0DC;border:1px solid #F2DBB4;border-radius:12px;padding:14px 16px;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:14px;line-height:1.5;color:#7A4400;">
                    <strong>Não foi você?</strong> Pode ignorar este e-mail: sua senha continua a mesma e ninguém consegue alterá-la sem este link.
                  </td>
                </tr>
              </table>

              <#-- Link alternativo -->
              <p style="margin:28px 0 6px;padding-top:22px;border-top:1px solid #E4E0DC;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:13px;line-height:1.5;color:#8A827E;">
                Se o botão não funcionar, copie e cole este endereço no navegador:
              </p>
              <p style="margin:0;font-family:'IBM Plex Sans',Arial,Helvetica,sans-serif;font-size:13px;line-height:1.5;word-break:break-all;">
                <a href="${link}" target="_blank" style="color:#B4232A;text-decoration:underline;">${link}</a>
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
