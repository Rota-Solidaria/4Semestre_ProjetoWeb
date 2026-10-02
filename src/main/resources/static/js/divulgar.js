/* Divulgar a campanha (templates/pages/organizador-divulgar.ftlh).
 * - Desenha no navegador a imagem da campanha (story 9:16, post 1:1 ou cartaz A4), com o bilhete,
 *   a rota e um QR code para a inscrição (biblioteca qrcode-generator, gratuita).
 * - A prévia é a própria imagem; por cima da gota desenhada fica a mesma gota, batendo como um coração.
 * - Compartilhar: menu do celular (Web Share), WhatsApp, Facebook, X, baixar ou copiar o link. Tudo gratuito.
 * - Logo depois de publicar (data-celebrar), as gotas estouram do hemocentro: no computador pelo mapa do
 *   bilhete (rota-mapa.js); no celular, onde o bilhete é a própria imagem, a partir da gota da imagem. */
(function () {
  'use strict';

  var raiz = document.getElementById('divulgar');
  if (!raiz) { return; }

  var d = raiz.dataset;
  var dados = {
    link: d.link, titulo: d.titulo, partida: d.partida, destino: d.destino, hemocentro: d.hemocentro,
    data: d.data, saida: d.saida, doacao: d.doacao, vagas: d.vagas, paradas: d.paradas
  };

  var FORMATOS = {
    story: { w: 1080, h: 1920, nome: 'story' },
    post: { w: 1080, h: 1080, nome: 'post' },
    cartaz: { w: 1240, h: 1754, nome: 'cartaz' }
  };

  var COR = { marca: '#B4232A', suave: '#FBE3E4', texto: '#1A1817', texto2: '#57514E', borda: '#E4E0DC', branco: '#FFFFFF' };
  var SANS = '"IBM Plex Sans", system-ui, sans-serif';
  var MONO = '"IBM Plex Mono", monospace';
  var TITULO = 'Archivo, sans-serif';
  var GOTA = new Path2D('M12 2.5c-3.8 4.8-6.5 8.3-6.5 11.7a6.5 6.5 0 0 0 13 0c0-3.4-2.7-6.9-6.5-11.7z');
  var ONIBUS = new Path2D('M8 3h8a3 3 0 0 1 3 3v9a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3z M5 11h14 M8 21v-3 M16 21v-3');

  var imagem = document.getElementById('divulgar-imagem');
  var previa = raiz.querySelector('.divulgar-previa');
  var gotaPrevia = raiz.querySelector('[data-previa-gota]');
  var carregando = raiz.querySelector('[data-previa-carregando]');
  var aviso = raiz.querySelector('[data-aviso]');
  var formatoAtual = 'story';
  var atual = null; // { canvas, blob, gota }

  function semAnimacao() {
    return document.documentElement.getAttribute('data-motion') === 'reduce'
      || (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  }

  /* ---------- Texto no canvas ---------- */

  function fonte(peso, tamanho, familia) {
    return peso + ' ' + Math.round(tamanho) + 'px ' + familia;
  }

  /** Diminui a fonte até caber; se nem no mínimo couber, corta com reticências. Devolve o tamanho usado. */
  function caber(ctx, texto, largura, peso, tamanho, familia, minimo) {
    var t = tamanho;
    ctx.font = fonte(peso, t, familia);
    while (ctx.measureText(texto).width > largura && t > minimo) {
      t -= 2;
      ctx.font = fonte(peso, t, familia);
    }
    return t;
  }

  function cortar(ctx, texto, largura) {
    if (ctx.measureText(texto).width <= largura) { return texto; }
    var t = texto;
    while (t.length > 1 && ctx.measureText(t + '…').width > largura) { t = t.slice(0, -1); }
    return t.trim() + '…';
  }

  function quebrar(ctx, texto, largura, maxLinhas) {
    var palavras = texto.split(/\s+/);
    var linhas = [];
    var linha = '';
    palavras.forEach(function (p) {
      var teste = linha ? linha + ' ' + p : p;
      if (ctx.measureText(teste).width > largura && linha) {
        linhas.push(linha);
        linha = p;
      } else {
        linha = teste;
      }
    });
    if (linha) { linhas.push(linha); }
    if (linhas.length > maxLinhas) {
      linhas = linhas.slice(0, maxLinhas);
      linhas[maxLinhas - 1] = cortar(ctx, linhas[maxLinhas - 1] + ' …', largura);
    }
    return linhas;
  }

  function espaco(ctx, px) {
    if ('letterSpacing' in ctx) { ctx.letterSpacing = px + 'px'; }
  }

  /* ---------- Peças do desenho ---------- */

  function fundo(ctx, w, h, cx, cy) {
    ctx.fillStyle = COR.marca;
    ctx.fillRect(0, 0, w, h);
    var brilho = ctx.createRadialGradient(cx, cy, 0, cx, cy, w * 0.75);
    brilho.addColorStop(0, 'rgba(255,255,255,0.18)');
    brilho.addColorStop(1, 'rgba(255,255,255,0)');
    ctx.fillStyle = brilho;
    ctx.fillRect(0, 0, w, h);
  }

  function logo(ctx, x, y, tamanho) {
    ctx.textAlign = 'left';
    ctx.textBaseline = 'alphabetic';
    espaco(ctx, 0);
    ctx.font = fonte(800, tamanho, TITULO);
    ctx.fillStyle = COR.branco;
    ctx.fillText('Rota', x, y);
    var w = ctx.measureText('Rota ').width;
    ctx.fillStyle = COR.suave;
    ctx.fillText('Solidária', x + w, y);
  }

  /** A gota do hemocentro: um "pino" branco com a gota vermelha. (cx, cy) é o centro. */
  function pinoGota(ctx, cx, cy, s) {
    ctx.save();
    ctx.shadowColor = 'rgba(0,0,0,0.25)';
    ctx.shadowBlur = s * 0.2;
    ctx.shadowOffsetY = s * 0.08;
    ctx.translate(cx, cy);
    ctx.rotate(-Math.PI / 4);
    ctx.beginPath();
    ctx.roundRect(-s / 2, -s / 2, s, s, [s / 2, s / 2, s / 2, s * 0.1]);
    ctx.fillStyle = COR.branco;
    ctx.fill();
    ctx.restore();
    ctx.save();
    var i = s * 0.5;
    ctx.translate(cx - i / 2, cy - i / 2);
    ctx.scale(i / 24, i / 24);
    ctx.fillStyle = COR.marca;
    ctx.fill(GOTA);
    ctx.restore();
  }

  function qr(ctx, texto, x, y, tamanho) {
    if (!window.qrcode) { return false; }
    var codigo = window.qrcode(0, 'M');
    codigo.addData(texto);
    codigo.make();
    var n = codigo.getModuleCount();
    var modulo = tamanho / (n + 2); // margem de 1 módulo
    ctx.fillStyle = COR.texto;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (codigo.isDark(r, c)) {
          ctx.fillRect(Math.floor(x + (c + 1) * modulo), Math.floor(y + (r + 1) * modulo), Math.ceil(modulo), Math.ceil(modulo));
        }
      }
    }
    return true;
  }

  function textoParadas() {
    return dados.paradas ? 'Passa por ' + dados.paradas : 'Ônibus até o hemocentro';
  }

  /** Mede o bilhete (cartão branco) antes de desenhar. */
  function medidasBilhete(ctx, w, u, qrTam) {
    var pad = 56 * u;
    ctx.font = fonte(400, 30 * u, SANS);
    var linhas = quebrar(ctx, textoParadas(), w - 2 * pad, 2);
    var altura = pad + 62 * u + 114 * u + 116 * u + linhas.length * 42 * u + 20 * u + 64 * u + qrTam + pad;
    return { pad: pad, linhas: linhas, altura: altura };
  }

  /** O bilhete: título, rota, dados, paradas, picote e o canhoto com o QR code. */
  function bilhete(ctx, x, y, w, u, qrTam, corFundo, incluiLink) {
    var m = medidasBilhete(ctx, w, u, qrTam);
    var pad = m.pad;
    var cy = y + pad;

    ctx.save();
    ctx.shadowColor = 'rgba(0,0,0,0.22)';
    ctx.shadowBlur = 40 * u;
    ctx.shadowOffsetY = 16 * u;
    ctx.beginPath();
    ctx.roundRect(x, y, w, m.altura, 44 * u);
    ctx.fillStyle = COR.branco;
    ctx.fill();
    ctx.restore();

    // Título da campanha
    ctx.textAlign = 'left';
    ctx.textBaseline = 'alphabetic';
    espaco(ctx, 4 * u);
    ctx.font = fonte(500, 28 * u, MONO);
    ctx.fillStyle = COR.marca;
    ctx.fillText(cortar(ctx, dados.titulo.toUpperCase(), w - 2 * pad), x + pad, cy + 26 * u);
    espaco(ctx, 0);
    cy += 62 * u;

    // Rota: partida ··· ônibus ··· destino
    var meio = 150 * u;
    var larguraCidade = (w - 2 * pad - meio) / 2;
    var tam = Math.min(caber(ctx, dados.partida, larguraCidade, 800, 64 * u, TITULO, 34 * u),
      caber(ctx, dados.destino, larguraCidade, 800, 64 * u, TITULO, 34 * u));
    ctx.font = fonte(800, tam, TITULO);
    ctx.fillStyle = COR.texto;
    var partida = cortar(ctx, dados.partida, larguraCidade);
    var destino = cortar(ctx, dados.destino, larguraCidade);
    var baseRota = cy + 64 * u;
    ctx.fillText(partida, x + pad, baseRota);
    ctx.textAlign = 'right';
    ctx.fillText(destino, x + w - pad, baseRota);
    ctx.textAlign = 'left';
    var iniLinha = x + pad + ctx.measureText(partida).width + 24 * u;
    var fimLinha = x + w - pad - ctx.measureText(destino).width - 24 * u;
    var meioY = baseRota - tam * 0.34;
    ctx.save();
    ctx.setLineDash([10 * u, 10 * u]);
    ctx.strokeStyle = '#CFC9C3';
    ctx.lineWidth = 4 * u;
    ctx.beginPath();
    ctx.moveTo(iniLinha, meioY);
    ctx.lineTo(fimLinha, meioY);
    ctx.stroke();
    ctx.restore();
    var onibusX = (iniLinha + fimLinha) / 2;
    ctx.beginPath();
    ctx.arc(onibusX, meioY, 28 * u, 0, Math.PI * 2);
    ctx.fillStyle = COR.marca;
    ctx.fill();
    ctx.save();
    ctx.translate(onibusX - 16 * u, meioY - 16 * u);
    ctx.scale(32 * u / 24, 32 * u / 24);
    ctx.strokeStyle = COR.branco;
    ctx.lineWidth = 2.2;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke(ONIBUS);
    ctx.restore();
    cy += 114 * u;

    // Dados: data, saída, doação, vagas
    var colunas = [
      { rotulo: 'DATA', valor: dados.data || 'A definir', peso: 0.34 },
      { rotulo: 'SAÍDA', valor: dados.saida || '—', peso: 0.22 },
      { rotulo: 'DOAÇÃO', valor: dados.doacao || '—', peso: 0.22 },
      { rotulo: 'VAGAS', valor: dados.vagas || '—', peso: 0.22 }
    ];
    var cx = x + pad;
    colunas.forEach(function (col) {
      var larg = (w - 2 * pad) * col.peso;
      espaco(ctx, 3 * u);
      ctx.font = fonte(500, 22 * u, MONO);
      ctx.fillStyle = COR.texto2;
      ctx.fillText(col.rotulo, cx, cy + 22 * u);
      espaco(ctx, 0);
      caber(ctx, col.valor, larg - 12 * u, 500, 40 * u, MONO, 24 * u);
      ctx.fillStyle = COR.texto;
      ctx.fillText(col.valor, cx, cy + 74 * u);
      cx += larg;
    });
    cy += 116 * u;

    // Paradas
    ctx.font = fonte(400, 30 * u, SANS);
    ctx.fillStyle = COR.texto2;
    m.linhas.forEach(function (linha, i) { ctx.fillText(linha, x + pad, cy + 30 * u + i * 42 * u); });
    cy += m.linhas.length * 42 * u + 20 * u;

    // Picote, com os recortes nas laterais
    var picoteY = cy + 20 * u;
    ctx.save();
    ctx.setLineDash([12 * u, 12 * u]);
    ctx.strokeStyle = COR.borda;
    ctx.lineWidth = 4 * u;
    ctx.beginPath();
    ctx.moveTo(x + 30 * u, picoteY);
    ctx.lineTo(x + w - 30 * u, picoteY);
    ctx.stroke();
    ctx.restore();
    ctx.fillStyle = corFundo;
    [x, x + w].forEach(function (px) {
      ctx.beginPath();
      ctx.arc(px, picoteY, 24 * u, 0, Math.PI * 2);
      ctx.fill();
    });
    cy += 64 * u;

    // Canhoto: QR code e o convite
    var temQr = qr(ctx, dados.link, x + pad, cy, qrTam);
    var tx = x + pad + (temQr ? qrTam + 36 * u : 0);
    var larguraTexto = x + w - pad - tx;
    ctx.fillStyle = COR.texto;
    ctx.font = fonte(700, 50 * u, TITULO);
    var topoTexto = cy + qrTam / 2 - (incluiLink ? 44 * u : 18 * u);
    ctx.fillText('Inscreva-se', tx, topoTexto);
    ctx.font = fonte(400, 28 * u, SANS);
    ctx.fillStyle = COR.texto2;
    ctx.fillText(cortar(ctx, temQr ? 'Aponte a câmera do celular' : 'Acesse o link da campanha', larguraTexto), tx, topoTexto + 44 * u);
    if (incluiLink) {
      caber(ctx, dados.link, larguraTexto, 500, 24 * u, MONO, 16 * u);
      ctx.fillStyle = COR.marca;
      ctx.fillText(cortar(ctx, dados.link, larguraTexto), tx, topoTexto + 84 * u);
    }
    return m.altura;
  }

  /* ---------- Os três formatos ---------- */

  /** Story e cartaz: tudo empilhado e centralizado; se não couber na altura, o conjunto encolhe. */
  function vertical(ctx, W, H) {
    var s = W / 1080;
    var Hu = H / s;
    ctx.save();
    ctx.scale(s, s);
    fundo(ctx, 1080, Hu, 540, Hu * 0.22);
    logo(ctx, 72, 120, 52);

    var larguraCartao = 960;
    var qrTam = 230;
    var alturaBilhete = medidasBilhete(ctx, larguraCartao, 1, qrTam).altura;
    var PINO = 180;
    var alturaPino = PINO * 1.42;
    var TITULO_TAM = 112;
    var alturaTitulo = TITULO_TAM * 2.15;
    var total = alturaPino + 44 + alturaTitulo + 72 + alturaBilhete;
    var disponivel = Hu - 200 - 150;
    var f = Math.min(1, disponivel / total);
    var topo = 200 + Math.max(0, (disponivel - total * f) / 2);

    ctx.save();
    ctx.translate(540, topo);
    ctx.scale(f, f);
    var yPino = PINO * 0.55;
    pinoGota(ctx, 0, yPino, PINO);
    ctx.textAlign = 'center';
    ctx.fillStyle = COR.branco;
    var tam = caber(ctx, 'A gente leva você.', 960, 800, TITULO_TAM, TITULO, 60);
    ctx.font = fonte(800, tam, TITULO);
    var yTitulo = alturaPino + 44;
    ctx.fillText('Doe sangue.', 0, yTitulo + tam * 0.9);
    ctx.fillText('A gente leva você.', 0, yTitulo + tam * 2);
    bilhete(ctx, -larguraCartao / 2, yTitulo + alturaTitulo + 72, larguraCartao, 1, qrTam, COR.marca, false);
    ctx.restore();

    ctx.textAlign = 'center';
    ctx.fillStyle = COR.suave;
    caber(ctx, dados.link, 960, 500, 32, MONO, 18);
    ctx.fillText(cortar(ctx, dados.link, 960), 540, Hu - 80);
    ctx.restore();

    // Centro da gota na imagem final (para a gota animada da prévia)
    return { x: 540 * s, y: (topo + yPino * f) * s, tamanho: PINO * f * s };
  }

  /** Post quadrado: título à esquerda, gota à direita e o bilhete embaixo (com o link no canhoto). */
  function quadrado(ctx, W, H) {
    fundo(ctx, W, H, W * 0.8, H * 0.1);
    logo(ctx, 64, 100, 44);
    var pino = { x: 930, y: 150, tamanho: 120 };
    pinoGota(ctx, pino.x, pino.y, pino.tamanho);
    ctx.textAlign = 'left';
    ctx.fillStyle = COR.branco;
    var tam = caber(ctx, 'A gente leva você.', 760, 800, 80, TITULO, 50);
    ctx.font = fonte(800, tam, TITULO);
    ctx.fillText('Doe sangue.', 64, 230);
    ctx.fillText('A gente leva você.', 64, 230 + tam * 1.05);
    var u = 0.82;
    var qrTam = 170;
    var alturaBilhete = medidasBilhete(ctx, 952, u, qrTam).altura;
    var y = Math.max(330 + tam * 0.4, H - 40 - alturaBilhete);
    bilhete(ctx, 64, y, 952, u, qrTam, COR.marca, true);
    return pino;
  }

  function desenhar(formato) {
    var f = FORMATOS[formato];
    var canvas = document.createElement('canvas');
    canvas.width = f.w;
    canvas.height = f.h;
    var ctx = canvas.getContext('2d');
    var gota = formato === 'post' ? quadrado(ctx, f.w, f.h) : vertical(ctx, f.w, f.h);
    return { canvas: canvas, gota: gota, formato: formato };
  }

  /* ---------- Prévia ---------- */

  function posicionarGota(gota, formato) {
    var f = FORMATOS[formato];
    gotaPrevia.style.left = (gota.x / f.w * 100) + '%';
    gotaPrevia.style.top = (gota.y / f.h * 100) + '%';
    gotaPrevia.style.width = (gota.tamanho / f.w * 100) + '%';
  }

  function mostrar(formato) {
    formatoAtual = formato;
    raiz.querySelectorAll('[data-formato]').forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.formato === formato));
    });
    previa.dataset.formatoAtual = formato;
    var r = desenhar(formato);
    atual = r;
    r.canvas.toBlob(function (blob) {
      if (atual !== r) { return; }
      r.blob = blob;
      if (imagem.dataset.url) { URL.revokeObjectURL(imagem.dataset.url); }
      imagem.dataset.url = URL.createObjectURL(blob);
      imagem.src = imagem.dataset.url;
      posicionarGota(r.gota, formato);
      carregando.hidden = true;
      previa.classList.add('is-pronta');
    }, 'image/png');
  }

  raiz.querySelectorAll('[data-formato]').forEach(function (b) {
    b.addEventListener('click', function () { if (b.dataset.formato !== formatoAtual) { mostrar(b.dataset.formato); } });
  });

  /* ---------- Compartilhar ---------- */

  function mensagem(curta) {
    var partes = [dados.titulo + ': transporte de ' + dados.partida + ' até o hemocentro em ' + dados.destino];
    if (dados.data) { partes[0] += ', ' + dados.data + (dados.saida ? ' às ' + dados.saida : ''); }
    if (!curta && dados.paradas) { partes.push('Passa por ' + dados.paradas + '.'); }
    partes.push(curta ? 'Doe sangue, a gente leva você.' : 'Doe sangue, a gente leva você. Inscreva-se:');
    return partes.join('. ').replace(/\.\./g, '.');
  }

  function nomeArquivo() {
    var base = dados.titulo.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase()
      .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'campanha';
    return 'rota-solidaria-' + base + '-' + formatoAtual + '.png';
  }

  function avisar(texto) {
    aviso.textContent = texto;
    clearTimeout(avisar.t);
    avisar.t = setTimeout(function () { aviso.textContent = ''; }, 4000);
  }

  function baixar() {
    if (!atual || !atual.blob) { return; }
    var a = document.createElement('a');
    a.href = URL.createObjectURL(atual.blob);
    a.download = nomeArquivo();
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(function () { URL.revokeObjectURL(a.href); }, 2000);
    avisar('Imagem baixada. Agora é só postar.');
  }

  function compartilhar() {
    if (!atual || !atual.blob) { return; }
    var arquivo = new File([atual.blob], nomeArquivo(), { type: 'image/png' });
    var pacote = { files: [arquivo], title: dados.titulo, text: mensagem(false) + ' ' + dados.link };
    if (navigator.canShare && navigator.canShare({ files: [arquivo] })) {
      navigator.share(pacote).catch(function (e) {
        if (e && e.name !== 'AbortError') { baixar(); }
      });
    } else {
      baixar(); // computador sem menu de compartilhar: baixa a imagem
    }
  }

  /** Cópia pelo jeito antigo (campo escondido + copiar), para quando a área de transferência recusa. */
  function copiarAntigo() {
    var campo = document.createElement('textarea');
    campo.value = dados.link;
    campo.setAttribute('readonly', '');
    campo.style.position = 'fixed';
    campo.style.opacity = '0';
    document.body.appendChild(campo);
    campo.select();
    var ok = false;
    try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
    campo.remove();
    return ok;
  }

  function copiar() {
    var rotulo = raiz.querySelector('[data-copiar-texto]');
    function pronto() {
      rotulo.textContent = 'Link copiado!';
      setTimeout(function () { rotulo.textContent = 'Copiar link'; }, 2200);
    }
    function reserva() {
      if (copiarAntigo()) { pronto(); } else { avisar('Copie o link: ' + dados.link); }
    }
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(dados.link).then(pronto, reserva);
    } else {
      reserva();
    }
  }

  var enc = encodeURIComponent;
  raiz.querySelector('[data-acao="whatsapp"]').href = 'https://wa.me/?text=' + enc(mensagem(false) + ' ' + dados.link);
  raiz.querySelector('[data-acao="facebook"]').href = 'https://www.facebook.com/sharer/sharer.php?u=' + enc(dados.link);
  raiz.querySelector('[data-acao="x"]').href = 'https://twitter.com/intent/tweet?text=' + enc(mensagem(true)) + '&url=' + enc(dados.link);
  raiz.querySelector('[data-acao="compartilhar"]').addEventListener('click', compartilhar);
  raiz.querySelector('[data-acao="baixar"]').addEventListener('click', baixar);
  raiz.querySelector('[data-acao="copiar"]').addEventListener('click', copiar);

  /* ---------- Comemoração (logo depois de publicar) ---------- */

  function comemorar() {
    var html = document.documentElement;
    if (!html.hasAttribute('data-celebrar') || !window.RotaGotas) { return; }
    var mapa = raiz.querySelector('[data-rota-compacto]');
    var mapaVisivel = mapa && mapa.getClientRects().length;
    // No computador quem comemora é a gota do mapa (rota-mapa.js); se ela não aparecer, a gota da imagem assume
    setTimeout(function () {
      if (html.dataset.celebrado) { return; }
      html.dataset.celebrado = 'true';
      var r = gotaPrevia.getBoundingClientRect();
      window.RotaGotas.estourar(r.left + r.width / 2, r.top + r.height / 2);
    }, mapaVisivel ? 8000 : (semAnimacao() ? 0 : 500));
  }

  /* ---------- Início: espera as fontes para desenhar com a tipografia certa ---------- */

  var fontes = document.fonts ? Promise.all([
    document.fonts.load(fonte(800, 60, TITULO)),
    document.fonts.load(fonte(700, 50, TITULO)),
    document.fonts.load(fonte(500, 30, MONO)),
    document.fonts.load(fonte(400, 30, SANS))
  ]) : Promise.resolve();
  var limite = new Promise(function (ok) { setTimeout(ok, 2500); });

  Promise.race([fontes, limite]).then(function () {
    mostrar('story');
    comemorar();
  });
})();
