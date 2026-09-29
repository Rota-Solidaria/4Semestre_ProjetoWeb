# Exports — Rota Solidária Design System v1.0

## 1. Para Figma (e editores compatíveis)

**Tokens (recomendado, 100% editável):**
1. Instale o plugin **Tokens Studio for Figma**.
2. Plugin → *Import* → *JSON* → selecione `tokens/rota-solidaria.tokens.json`.
3. *Export to Figma* → cria Variables e Text/Effect Styles nativos (cores, tipografia, espaços, raios, sombras).
   O arquivo está no formato W3C DTCG, então também funciona em Style Dictionary, Penpot e Zeroheight.

**Telas completas como camadas do Figma:**
1. Instale o plugin **html.to.design**.
2. Escolha *Import from file/code* e envie o HTML autônomo desejado de `html/`.
3. As telas entram como frames com auto layout, texto editável e cores vinculáveis aos tokens acima.
   (Para importar por URL, gere um link temporário do arquivo em `html/` e cole no plugin.)

**Logo:** `logo/*.svg` — vetor limpo, arraste direto para o Figma (Ctrl+V mantém os paths editáveis).

## 2. HTML interativo autônomo
`html/` contém três arquivos únicos, sem dependências externas (fontes, imagens e scripts embutidos).
Abra com duplo clique em qualquer navegador — funcionam offline, inclusive tema escuro, filtros e formulários.

| Arquivo | Conteúdo |
| --- | --- |
| `rota-solidaria-design-system.html` | documentação visual completa do sistema |
| `rota-solidaria-prototipo-v2.html` | protótipo interativo v2 (fluxo completo de inscrição) |
| `rota-solidaria-v3.html` | direção editorial v3 (timetable de rotas + reserva) |

## 3. Para um agente de IA
Entregue estes três arquivos como contexto — são autossuficientes e não precisam de imagens:

- `DESIGN-SYSTEM.md` — sistema completo em prosa estruturada (princípios, cor, tipografia, regras, acessibilidade).
- `design-system.json` — especificação de componentes, estados e medidas, legível por máquina.
- `tokens/rota-solidaria.tokens.json` — valores canônicos no formato W3C DTCG.

Prompt sugerido: *"Use DESIGN-SYSTEM.md como regra e design-system.json como especificação de componentes.
Todos os valores de cor, espaço e tipografia devem vir de rota-solidaria.tokens.json. Idioma pt-BR."*

## 4. Para o repositório
`tokens/rota-solidaria-tokens.css` substitui o `:root` de `css/site.css`: variáveis, tema escuro
(manual + `prefers-color-scheme`) e as classes `.rs-btn`, `.rs-card`, `.rs-status`, `.rs-input`, `.rs-alert`.
