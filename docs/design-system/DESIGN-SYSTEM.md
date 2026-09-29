# Rota Solidária — Design System v1.0

> Arquivo de referência legível por agentes de IA e por pessoas.
> Fonte de verdade das cores/medidas: `rota-solidaria.tokens.json` (formato W3C DTCG).
> Implementação pronta para o repositório: `rota-solidaria-tokens.css`.
> Especificação de componentes em JSON: `design-system.json`.

## 1. Contexto do produto
Plataforma do projeto de extensão **Rota Solidária**: organiza campanhas de doação de sangue e o
transporte gratuito das cidades da região (Angatuba, Guareí, Itapetininga, Sorocaba) até os hemocentros.
Idioma: **pt-BR**. Público: doadores de 16 a 69 anos, incluindo idosos e usuários em conexões lentas.
Repositório de origem: `andrwza/Rota-Solidaria`.

## 2. Princípios
1. **Urgência antes de institucionalidade** — estoque crítico e próxima coleta aparecem acima da dobra.
2. **Informação que decide a doação** — toda campanha exibe data, distância, vagas e transporte.
3. **Nunca só cor** — status é sempre ponto colorido + texto.
4. **Atrito mínimo** — reservar vaga não exige cadastro: nome, WhatsApp e consentimento LGPD.
5. **Acessível por padrão** — alvos ≥ 44px, contraste AA, foco visível, movimento reduzido respeitado.

## 3. Marca
Símbolo: gota de sangue fundida a um marcador de localização (a rota até a campanha).
Arquivos editáveis: `logo-rota-solidaria.svg`, `logo-mark.svg`, `logo-mono-white.svg`.

| Regra | Valor |
| --- | --- |
| Área de respiro | 0,4× a altura do símbolo em todos os lados |
| Tamanho mínimo | símbolo 24px · lockup 132px de largura |
| Sobre fundo escuro/foto | versão monocromática branca |
| Favicon / app icon | somente o símbolo, centralizado |

**Não faça:** distorcer, inclinar ou espelhar; aplicar o vermelho sobre fundo escuro ou saturado;
trocar a tipografia do wordmark; adicionar sombra, contorno ou gradiente.

## 4. Cor
### Vermelho Vida (primária)
`50 #FDF3F3` · `100 #FBE3E4` · `200 #F5C2C4` · `300 #EC9498` · `400 #DE5F65` · `500 #C4323A` ·
**`600 #B4232A` (base)** · `700 #8F1821` (hover) · `800 #6D141B` (pressionado) · `#F2969B` (texto no tema escuro).

### Neutros quentes
`00 #FFFFFF` · `25 #FAF9F8` · `50 #F3F1EF` · `100 #E4E0DC` · `200 #CFC9C3` · `400 #8A827E` · `600 #57514E` · `900 #1A1817` · `950 #121110`.

### Semânticas
| Papel | Base | Suave | Texto |
| --- | --- | --- | --- |
| Sucesso (inscrições abertas) | #0E7A4F | #E3F4EB | #0B5E3C |
| Atenção (últimas vagas, jejum) | #A65C00 | #FDF0DC | #7A4400 |
| Informação (LGPD, avisos) | #1E5FA8 | #E6EEF9 | #154A85 |
| Erro (validação) | #8F1821 | #FBE3E4 | — |

### Regras de aplicação
- Máximo **dois fundos por tela**: neutro 25 e branco. Vermelho apenas em blocos de destaque, nunca em grandes áreas.
- Um único **botão primário** visível por bloco de decisão.
- Fundos suaves (50/100) para avisos e ícones; **nunca para texto**.
- Neutro 400 só em texto ≥ 16px (3.7:1).

## 5. Modo escuro
Não é inversão: neutros quentes escuros, elevação por **luminosidade de superfície** (não por sombra),
vermelho clareado para texto e ícones. Segue `prefers-color-scheme` com override manual persistido.

| Papel | Valor |
| --- | --- |
| bg | #121110 |
| surface | #1A1918 |
| elevated | #232120 |
| border / border-strong | #322F2D / #46423F |
| text / text-muted | #F6F4F2 / #B7B0AC |
| primary fill / primary text | #C0333A / #F2969B |

Regras: nunca preto puro nem branco puro em texto longo; sombra só em overlays; fotografia com `brightness(.9)`.

## 6. Tipografia
| Papel | Fonte | Especificação |
| --- | --- | --- |
| display | Archivo 800 | 62px / 1.02 / -3,5% |
| h1 | Archivo 800 | 44px / 1.08 / -3% |
| h2 | Archivo 700 | 32px / 1.15 / -2,5% |
| h3 | Archivo 700 | 22px / 1.25 / -1,5% |
| body-lg | IBM Plex Sans 400 | 18px / 1.6 |
| body | IBM Plex Sans 400 | 16px / 1.6 |
| label | IBM Plex Sans 600 | 14px / 1.4 |
| button | IBM Plex Sans 600 | 16px / 1 |
| overline | IBM Plex Mono 500 | 12px / +14% / caixa alta |
| data (tipo sanguíneo, hora, código) | IBM Plex Mono 500 | 15px / 1 |

Mobile: display 34px, h1 28px, mínimo absoluto 14px. Medida máxima 68 caracteres.
Títulos com `text-wrap:balance`, parágrafos com `pretty`. Nunca centralizar blocos com mais de duas linhas.

**Tom de voz:** direto e acolhedor, segunda pessoa ("você pode doar"); botões com verbo no infinitivo;
sem jargão médico sem explicação; sem alarmismo; sem emoji; números por extenso até dez, exceto dados clínicos.

## 7. Grid, espaço e forma
- Escala base 4: 4 · 8 · 12 · 16 · 24 · 32 · 48 · 72 · 96.
- Seções: 72px desktop, 48px mobile. Padding de cartão: 24px. Entre grupos relacionados: 12px.
- Raios: **8** chip · **12** controle · **20** superfície · **999** badge.
- Elevação: sm `0 1px 2px #1A181710` · md `0 6px 20px #1A181714` · lg `0 20px 44px #1A181724`.
- Contêiner 1180px, gutter 24px, margem 32px.

| Breakpoint | Largura | Colunas | Gutter |
| --- | --- | --- | --- |
| Mobile | < 640 | 4 | 16 |
| Tablet | 640–1023 | 8 | 20 |
| Desktop | 1024–1439 | 12 | 24 |
| Wide | ≥ 1440 | contêiner fixo centralizado | 24 |

## 8. Ícones
Material Symbols Rounded, `wght 400`, `FILL 0`, `opsz 24`.
Tamanhos: 18px em linha de texto · 20px em botões · 24px em navegação · 30px em blocos informativos.
Ícone sem rótulo exige `aria-label`.
Conjunto em uso: search, place, schedule, calendar_month, bloodtype, favorite, check_circle, error, info,
directions_bus, directions_walk, person, home, notifications, share, dark_mode, light_mode,
arrow_forward, arrow_back, expand_more, expand_less, tune, swap_vert, accessibility_new.

## 9. Componentes
Especificação completa (variantes, estados, medidas) em `design-system.json` → chave `components`.
Resumo:

- **Button** — primary / secondary / ghost / danger / disabled; alturas 40 · 48 · 52; raio 12; foco anel 3px a 35%.
- **StatusBadge** — pill com ponto 7px: abertas (verde), últimas vagas (âmbar, ≤ 4 vagas), em breve (azul), finalizada (neutro).
- **CampaignCard** — mídia 150px, título h3, três linhas de dados (data, local+distância, transporte+vagas), CTA + compartilhar; hover -3px.
- **Field** — rótulo sempre visível; controle 48px; erro com ícone + mensagem; sufixo "· opcional".
- **Alert** — info / atenção / sucesso: ícone 20px + título curto + uma frase.
- **HeaderDesktop** — 72px, máx. 4 links + 2 ações, ativo com sublinhado 2px.
- **TabBarMobile** — 4 destinos fixos (Início, Campanhas, Minhas, Perfil), ícone 24px, alvo 48px, rótulo sempre visível.
- **Stepper** — Dados → Revisão → Confirmação.
- **StockBar** — nível de estoque por tipo sanguíneo (trilha 3px).
- **RouteTimeline** (v3) — embarque → parada → hemocentro.

## 10. Acessibilidade
- Contraste: 4.5:1 em texto, 3:1 em ícones e bordas. Verificados: branco/vermelho 600 = 5.9:1 (AA);
  neutro 900/neutro 25 = 15.8:1 (AAA); neutro 600/branco = 7.6:1 (AAA).
- Alvos 44×44px com 8px de separação; ordem de tabulação segue a ordem visual; "pular para o conteúdo" no topo.
- Nenhuma informação apenas por cor. Zoom 200% sem rolagem horizontal.
- Transições 150–250ms, só `opacity`/`transform`; respeita `prefers-reduced-motion`.
- Imagens com proporção reservada e `loading="lazy"`.

## 11. Nomenclatura de tokens
`--rs-color-*` (brand-600, neutral-100, success-soft) · `--rs-space-*` (4…96) ·
`--rs-radius-*` (sm, md, lg, pill) · `--rs-font-*` (display, sans, mono) · `--rs-shadow-*` (sm, md, lg).
Declarados em `:root`, sobrescritos em `[data-theme="dark"]`.

## 12. Telas entregues
| Versão | Arquivo | Natureza |
| --- | --- | --- |
| v1 | `Rota Solidária - Design System / Desktop / Mobile` | especificação + telas estáticas |
| v2 | `Rota Solidária - Protótipo v2` | protótipo interativo (busca, filtros, inscrição, minhas inscrições) |
| v3 | `Rota Solidária - v3` | direção editorial interativa (timetable de rotas, estoque, modal de reserva) |

## 13. O que mudou em relação ao site original
Arial → Archivo + IBM Plex com escala definida · glifos improvisados (⌕ ◷ ⌖) → família de ícones real ·
status com ponto + texto e contraste corrigido · cartões com distância, vagas e transporte ·
menu mobile empilhado → barra inferior de 4 destinos · tema escuro completo (antes inexistente).
