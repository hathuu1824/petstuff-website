/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
// dropdown
document.addEventListener("DOMContentLoaded", () => {
    const headerHeight = document.querySelector("header")?.offsetHeight || 70;

    if (window.location.hash) {
        const target = document.querySelector(window.location.hash);
        if (target) {
            setTimeout(() => {
                const top = target.getBoundingClientRect().top + window.scrollY - headerHeight - 50; 
                window.scrollTo({ top, behavior: "smooth" });
            }, 200);
        }
    }

    document.querySelectorAll('a[href^="#"]').forEach(link => {
        link.addEventListener("click", e => {
            const targetId = link.getAttribute("href");
            const target = document.querySelector(targetId);
            if (target) {
                e.preventDefault();
                const top = target.getBoundingClientRect().top + window.scrollY - headerHeight - 10;
                window.scrollTo({ top, behavior: "smooth" });
                history.pushState(null, "", targetId);
            }
        });
    });
});

// slider
document.addEventListener('DOMContentLoaded', function(){
    const slider = document.getElementById('hero');
    if (!slider) return;

    const slides = Array.from(slider.querySelectorAll('.slide'));
    const dots   = Array.from(slider.querySelectorAll('.dot'));
    if (!slides.length) return;

    let i = slides.findIndex(s => s.classList.contains('is-active'));
    if (i < 0) i = 0;

    function layout(){
      slides.forEach((s, idx) => {
        const offset = (idx - i) * 100;
        s.style.transform = `translateX(${offset}%)`;
        s.classList.toggle('is-active', idx === i);
      });
      dots.forEach((d, idx) => d.classList.toggle('active', idx === i));
    }

    function go(n){
      i = (n + slides.length) % slides.length;
      layout();
    }
    function next(){ go(i + 1); }

    layout();
    let timer = setInterval(next, 2500);

    dots.forEach(d => d.addEventListener('click', () => { go(+d.dataset.index); clearInterval(timer); timer = setInterval(next, 5000); }));

    slider.addEventListener('mouseenter', () => clearInterval(timer));
    slider.addEventListener('mouseleave', () => { clearInterval(timer); timer = setInterval(next, 5000); });
});

