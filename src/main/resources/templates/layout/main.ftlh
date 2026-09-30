<#-- mapa=true carrega o MapLibre (mapas vetoriais do OpenFreeMap/OpenStreetMap, gratuito) e o estilo dos mapas de rota;
     scripts lista arquivos JS da página, carregados no fim do <body>. -->
<#macro layout title="Rota Solidária" css="/css/index.css" currentNav="" mapa=false scripts=[]>
<!doctype html>
<html lang="pt-BR">

<head>
  <#include "../includes/theme-init.ftlh">
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
  <link rel="stylesheet" href="/css/header.css">
  <link rel="stylesheet" href="/css/toast.css">
  <#if mapa>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/maplibre-gl@5.24.0/dist/maplibre-gl.css">
  </#if>
  <link rel="stylesheet" href="${css}">
  <link rel="stylesheet" href="/css/components.css">
  <#if mapa>
    <link rel="stylesheet" href="/css/rota-mapa.css">
  </#if>
  <link rel="stylesheet" href="/css/theme.css">
</head>

<body>
  <#include "../includes/header.ftlh">

  <#nested>

  <#include "../includes/a11y-panel.ftlh">
  <#include "../includes/toast.ftlh">
  <#include "../includes/footer.ftlh">
  <#include "../includes/tabbar.ftlh">
  <#include "../includes/scripts.ftlh">
  <#if mapa>
    <script src="https://cdn.jsdelivr.net/npm/maplibre-gl@5.24.0/dist/maplibre-gl.js"></script>
    <script src="/js/rota-mapa.js"></script>
  </#if>
  <#list scripts as script>
    <script src="${script}"></script>
  </#list>
</body>

</html>
</#macro>