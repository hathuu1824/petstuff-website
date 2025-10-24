/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
(() => {
  const root = document.querySelector('.catalog.has-filters');
  if (!root) return;

  root.addEventListener('click', (e) => {
    const head = e.target.closest('.filter-head');
    if (!head || !root.contains(head)) return;

    e.preventDefault(); 
    const group  = head.closest('.filter-group');
    const opened = group.classList.toggle('open');
    head.setAttribute('aria-expanded', String(opened));

    const groups = Array.from(root.querySelectorAll('.filter-group'));
    const idx    = groups.indexOf(group);
    try { sessionStorage.setItem('fg:' + idx, opened ? '1' : '0'); } catch (err) {}
  });

  const groups = Array.from(root.querySelectorAll('.filter-group'));
  groups.forEach((g, i) => {
    const v = sessionStorage.getItem('fg:' + i);
    if (v === '1') g.classList.add('open');
    if (v === '0') g.classList.remove('open');
  });

  const form = document.getElementById('filterForm');
  if (form) {
    form.addEventListener('change', (e) => {
      if (e.target.matches('input[type="checkbox"], select')) {
        const pageInput = form.querySelector('input[name="page"]');
        if (pageInput) pageInput.value = '1'; 
        form.submit();
      }
    });
  }
})();