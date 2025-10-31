/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
//Đóng/mở dropdown
document.addEventListener('DOMContentLoaded', () => {
    const style = document.createElement('style');
    style.textContent = `.has-dd.open .dropdown{display:block}`;
    document.head.appendChild(style);

    document.querySelectorAll('.has-dd').forEach(li => {
        const btn   = li.querySelector('.dd-toggle');
        const panel = li.querySelector('.dropdown');
        let hideTimer = null;

        const openNow = () => {
            clearTimeout(hideTimer);
            document.querySelectorAll('.has-dd.open').forEach(x => { if (x !== li) x.classList.remove('open'); });
            li.classList.add('open');
        };

        const closeLater = () => {
            clearTimeout(hideTimer);
            hideTimer = setTimeout(() => li.classList.remove('open'), 250);
        };

        const closeNow = () => { clearTimeout(hideTimer); li.classList.remove('open'); };

        li.addEventListener('mouseenter', openNow);
        li.addEventListener('mouseleave', closeLater);
        panel?.addEventListener('mouseenter', openNow);
        panel?.addEventListener('mouseleave', closeLater);

        btn?.addEventListener('click', (e) => {
            e.stopPropagation();
            if (li.classList.contains('open')) closeNow();
            else openNow();
        });
    });
  
    document.addEventListener('click', () => {
        document.querySelectorAll('.has-dd.open').forEach(li => li.classList.remove('open'));
    });
});

//Slider
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

//Tạo map
window.addEventListener('load', function(){
    var iframe = document.querySelector('.review .loc-map iframe');
    if(!iframe) return;
    var address = '68 Đ. Nguyễn Chí Thanh, Láng Thượng, Đống Đa, Hà Nội, Việt Nam';
    iframe.src = 'https://www.google.com/maps?q=' + encodeURIComponent(address) + '&hl=vi&z=16&output=embed';
    if(!iframe.hasAttribute('width')) iframe.setAttribute('width','100%');
    if(!iframe.hasAttribute('height')) iframe.setAttribute('height','420');
});