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

// Khuyến mại slider
const slider = document.querySelector('.promo-slider');
const nextBtn = document.querySelector('.p-next');
const prevBtn = document.querySelector('.p-prev');

if (slider && nextBtn && prevBtn) {
    const slideWidth = slider.querySelector('.promo-item').offsetWidth + 24;

    nextBtn.onclick = () => {
        slider.scrollBy({ left: slideWidth, behavior: 'smooth' });
    };
    prevBtn.onclick = () => {
        slider.scrollBy({ left: -slideWidth, behavior: 'smooth' });
    };
}
