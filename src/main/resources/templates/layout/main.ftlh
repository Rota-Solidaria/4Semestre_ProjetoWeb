<#-- mapa=true carrega o MapLibre (mapas vetoriais do OpenFreeMap/OpenStreetMap, gratuito) e o estilo dos mapas de rota;
     scripts lista arquivos JS da página, carregados no fim do <body>. -->
<#macro layout 
  title="Rota Solidária · Caravanas gratuitas para doação de sangue" 
  description="Conectamos doadores a hemocentros através de transporte gratuito. Encontre caravanas na sua região, reserve sua vaga e ajude a salvar vidas."
  ogImage="/images/og-share.png"
  css="/css/index.css" 
  currentNav="" 
  mapa=false 
  scripts=[]>
<!doctype html>
<html lang="pt-BR"<#if celebrar??> data-celebrar</#if>>

<head>
  <#include "../includes/theme-init.ftlh">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${title}</title>

  <#assign fullOgImage = ogImage?starts_with("http")?then(ogImage, (appBaseUrl!"") + ogImage)>
  <#assign pageUrl = (currentUrl?has_content)?then(currentUrl, (appBaseUrl!""))>

  <!-- Metadados de SEO padrão -->
  <meta name="description" content="${description}">
  <meta name="keywords" content="doação de sangue, caravana de doadores, hemocentro, transporte gratuito doação de sangue, rota solidária, salvar vidas, doar sangue sp">
  <meta name="author" content="Rota Solidária">
  <meta name="theme-color" content="#BA2D32">
  <meta name="robots" content="index, follow">

  <#if pageUrl?has_content>
    <link rel="canonical" href="${pageUrl}">
  </#if>

  <!-- Open Graph / WhatsApp / Facebook / LinkedIn -->
  <meta property="og:site_name" content="Rota Solidária">
  <meta property="og:type" content="website">
  <meta property="og:title" content="${title}">
  <meta property="og:description" content="${description}">
  <#if pageUrl?has_content>
    <meta property="og:url" content="${pageUrl}">
  </#if>
  <meta property="og:image" content="${fullOgImage}">
  <meta property="og:image:secure_url" content="${fullOgImage}">
  <meta property="og:image:type" content="image/png">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:alt" content="Rota Solidária - Caravanas gratuitas para doação de sangue">
  <meta property="og:locale" content="pt_BR">

  <!-- Twitter Cards -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${title}">
  <meta name="twitter:description" content="${description}">
  <meta name="twitter:image" content="${fullOgImage}">
  <meta name="twitter:image:alt" content="Rota Solidária - Caravanas gratuitas para doação de sangue">

  <link rel="icon" href="/images/favicon.ico">
  <link rel="apple-touch-icon" href="/images/logo.png">
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
  <#-- Depois de uma inscrição ou de salvar a campanha: gotas comemorando (static/js/gotas.js) -->
  <#if celebrar??>
    <script src="/js/gotas.js"></script>
  </#if>
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
