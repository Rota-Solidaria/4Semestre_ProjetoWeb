<#macro layout title="Rota Solidária" css="/css/index.css" currentNav="">
<!doctype html>
<html lang="pt-BR">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${title}</title>
  <link rel="icon" href="/images/favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link
    href="https://fonts.googleapis.com/css2?family=Archivo:wght@700;800&family=IBM+Plex+Mono:wght@500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap"
    rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0"
    rel="stylesheet">
  <link rel="stylesheet" href="${css}">
</head>

<body>
  <#include "../includes/header.ftlh">

  <#nested>

  <#include "../includes/footer.ftlh">
  <#include "../includes/scripts.ftlh">
</body>

</html>
</#macro>