<#-- Scripts globais da aplicação -->
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const wrapper = document.getElementById('userDropdownWrapper');
    const toggleBtn = document.getElementById('userMenuBtn');
    if (toggleBtn && wrapper) {
      toggleBtn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        wrapper.classList.toggle('active');
        const isOpen = wrapper.classList.contains('active');
        toggleBtn.setAttribute('aria-expanded', isOpen);
      });
      document.addEventListener('click', function (e) {
        if (!wrapper.contains(e.target)) {
          wrapper.classList.remove('active');
          toggleBtn.setAttribute('aria-expanded', 'false');
        }
      });
      document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && wrapper.classList.contains('active')) {
          wrapper.classList.remove('active');
          toggleBtn.setAttribute('aria-expanded', 'false');
        }
      });
    }
  });
</script>
<script>
  // Toasts (includes/toast.ftlh): somem quando a linha de pulso termina de ser desenhada.
  // Com "reduzir movimento" ativo não há animação, então um temporizador faz o mesmo papel.
  document.addEventListener('DOMContentLoaded', function () {
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
      || document.documentElement.getAttribute('data-motion') === 'reduce';

    // Altura do header em --header-h: posiciona toasts e o painel de acessibilidade logo abaixo dele
    const header = document.querySelector('.site-header');
    if (header) {
      const measureHeader = function () {
        document.documentElement.style.setProperty('--header-h', header.offsetHeight + 'px');
      };
      measureHeader();
      window.addEventListener('resize', measureHeader);
    }

    document.querySelectorAll('[data-toast]').forEach(function (toast) {
      const dismiss = function () {
        if (toast.classList.contains('is-leaving')) return;
        toast.classList.add('is-leaving');
        if (reduceMotion) {
          toast.remove();
          return;
        }
        toast.addEventListener('animationend', function (e) {
          if (e.target === toast) toast.remove();
        });
      };

      toast.querySelector('[data-toast-close]').addEventListener('click', dismiss);

      if (!reduceMotion) {
        toast.querySelector('.toast__pulse-fill').addEventListener('animationend', dismiss);
        return;
      }

      const duration = parseInt(getComputedStyle(toast).getPropertyValue('--toast-duration'), 10) || 6000;
      let timer = setTimeout(dismiss, duration);
      const pause = function () { clearTimeout(timer); };
      const resume = function () {
        if (!toast.matches(':hover') && !toast.contains(document.activeElement)) {
          timer = setTimeout(dismiss, duration);
        }
      };
      toast.addEventListener('mouseenter', pause);
      toast.addEventListener('focusin', pause);
      toast.addEventListener('mouseleave', resume);
      toast.addEventListener('focusout', resume);
    });
  });
</script>
<script>
  // Painel de acessibilidade (includes/a11y-panel.ftlh): as escolhas valem na hora e ficam salvas no navegador
  document.addEventListener('DOMContentLoaded', function () {
    const toggle = document.querySelector('[data-a11y-toggle]');
    const panel = document.getElementById('a11y-panel');
    const backdrop = document.querySelector('.a11y-backdrop');
    if (!toggle || !panel || !window.rsA11y) return;
    const prefs = window.rsA11y.prefs;

    const render = function () {
      panel.querySelectorAll('.segmented').forEach(function (group) {
        const current = prefs[group.dataset.pref] || (group.dataset.pref === 'theme' ? 'light' : 'normal');
        group.querySelectorAll('button').forEach(function (btn) {
          btn.setAttribute('aria-pressed', String(btn.dataset.value === current));
        });
      });
      panel.querySelectorAll('.switch').forEach(function (sw) {
        sw.setAttribute('aria-checked', String(!!prefs[sw.dataset.pref]));
      });
    };

    const update = function (key, value) {
      prefs[key] = value;
      window.rsA11y.apply();
      window.rsA11y.save();
      render();
    };

    const open = function () {
      panel.hidden = false;
      backdrop.hidden = false;
      toggle.setAttribute('aria-expanded', 'true');
      render();
      panel.querySelector('button').focus();
    };

    const close = function () {
      if (panel.hidden) return;
      panel.hidden = true;
      backdrop.hidden = true;
      toggle.setAttribute('aria-expanded', 'false');
      toggle.focus();
    };

    toggle.addEventListener('click', function (e) {
      e.stopPropagation();
      panel.hidden ? open() : close();
    });
    panel.querySelectorAll('[data-a11y-close]').forEach(function (btn) { btn.addEventListener('click', close); });
    backdrop.addEventListener('click', close);
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
    document.addEventListener('click', function (e) {
      if (!panel.hidden && !panel.contains(e.target) && e.target !== toggle) close();
    });

    panel.querySelectorAll('.segmented button').forEach(function (btn) {
      btn.addEventListener('click', function () { update(btn.parentElement.dataset.pref, btn.dataset.value); });
    });
    panel.querySelectorAll('.switch').forEach(function (sw) {
      sw.addEventListener('click', function () { update(sw.dataset.pref, !prefs[sw.dataset.pref]); });
    });
  });
</script>
<script>
  // Campos de senha: botão mostrar/ocultar (data-password), medidor de força (data-password-strength)
  // e aviso de confirmação (data-password-confirm="#idDaSenha")
  document.addEventListener('DOMContentLoaded', function () {
    const icon = function (name) {
      const s = document.createElement('span');
      s.className = 'icon';
      s.setAttribute('aria-hidden', 'true');
      s.textContent = name;
      return s;
    };

    document.querySelectorAll('input[data-password]').forEach(function (input) {
      const wrap = document.createElement('div');
      wrap.className = 'pw-field';
      input.parentNode.insertBefore(wrap, input);
      wrap.appendChild(input);

      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'pw-toggle';
      btn.setAttribute('aria-label', 'Mostrar senha');
      btn.setAttribute('aria-pressed', 'false');
      btn.appendChild(icon('visibility'));
      btn.addEventListener('click', function () {
        const show = input.type === 'password';
        input.type = show ? 'text' : 'password';
        btn.setAttribute('aria-label', show ? 'Ocultar senha' : 'Mostrar senha');
        btn.setAttribute('aria-pressed', String(show));
        btn.firstChild.textContent = show ? 'visibility_off' : 'visibility';
      });
      wrap.appendChild(btn);
    });

    const rules = [
      { text: 'Pelo menos 8 caracteres', test: function (v) { return v.length >= 8; } },
      { text: 'Letras e números', test: function (v) { return /[A-Za-zÀ-ÿ]/.test(v) && /\d/.test(v); } },
      { text: 'Um símbolo, como ! ou # (opcional)', test: function (v) { return /[^A-Za-zÀ-ÿ0-9\s]/.test(v); } }
    ];
    const labels = ['', 'Senha fraca', 'Senha razoável', 'Senha boa', 'Senha forte'];

    document.querySelectorAll('input[data-password-strength]').forEach(function (input) {
      const anchor = input.closest('.pw-field') || input;
      const meter = document.createElement('div');
      meter.className = 'pw-meter';
      meter.setAttribute('aria-hidden', 'true');
      for (let i = 0; i < 4; i++) meter.appendChild(document.createElement('span'));
      const label = document.createElement('div');
      label.className = 'pw-label';
      label.setAttribute('aria-live', 'polite');
      const list = document.createElement('ul');
      list.className = 'pw-checks';
      const items = rules.map(function (rule) {
        const li = document.createElement('li');
        li.appendChild(icon('radio_button_unchecked'));
        li.appendChild(document.createTextNode(rule.text));
        list.appendChild(li);
        return li;
      });
      anchor.after(meter, label, list);

      const update = function () {
        const v = input.value;
        const passed = rules.map(function (rule) { return rule.test(v); });
        let score = 0;
        if (v.length > 0) score = 1;
        if (passed[0]) score = 2;
        if (passed[0] && passed[1]) score = 3;
        if (passed[0] && passed[1] && (passed[2] || v.length >= 12)) score = 4;
        meter.dataset.score = score;
        label.dataset.score = score;
        label.textContent = labels[score];
        items.forEach(function (li, i) {
          li.classList.toggle('is-ok', passed[i]);
          li.firstChild.textContent = passed[i] ? 'check_circle' : 'radio_button_unchecked';
        });
      };
      input.addEventListener('input', update);
      update();
    });

    document.querySelectorAll('input[data-password-confirm]').forEach(function (input) {
      const original = document.querySelector(input.dataset.passwordConfirm);
      if (!original) return;
      const anchor = input.closest('.pw-field') || input;
      const msg = document.createElement('div');
      msg.className = 'pw-match';
      msg.setAttribute('aria-live', 'polite');
      anchor.after(msg);
      const update = function () {
        msg.replaceChildren();
        msg.className = 'pw-match';
        if (!input.value) return;
        const ok = input.value === original.value;
        msg.classList.add(ok ? 'is-ok' : 'is-bad');
        msg.append(icon(ok ? 'check' : 'close'), ok ? 'As senhas conferem' : 'As senhas ainda não conferem');
      };
      input.addEventListener('input', update);
      original.addEventListener('input', update);
    });
  });
</script>
