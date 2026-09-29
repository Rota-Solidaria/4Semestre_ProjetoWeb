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
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // Posiciona os toasts logo abaixo do header, que muda de altura no celular
    const region = document.querySelector('.toast-region');
    const header = document.querySelector('.site-header');
    if (region && header) {
      const placeBelowHeader = function () {
        region.style.setProperty('--toast-top', header.offsetHeight + 'px');
      };
      placeBelowHeader();
      window.addEventListener('resize', placeBelowHeader);
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
