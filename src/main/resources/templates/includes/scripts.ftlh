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
