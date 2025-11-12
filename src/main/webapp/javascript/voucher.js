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
document.addEventListener("DOMContentLoaded", function() {
  const scroller = document.getElementById("voucherScroller");
  const prevBtn = document.querySelector(".v-prev");
  const nextBtn = document.querySelector(".v-next");

  if (!scroller || !prevBtn || !nextBtn) return;

  const scrollStep = scroller.clientWidth; // cuộn đúng 2 voucher/lần (chiều rộng viewport)

  prevBtn.addEventListener("click", () => {
    scroller.scrollBy({ left: -scrollStep, behavior: "smooth" });
  });

  nextBtn.addEventListener("click", () => {
    scroller.scrollBy({ left: scrollStep, behavior: "smooth" });
  });
});

(function(){
    const scroller = document.getElementById('promoSlider');
    if(!scroller) return;
    const step = scroller.clientWidth * 0.9;

    document.querySelector('.p-prev')?.addEventListener('click', () => {
      scroller.scrollBy({ left: -step, behavior: 'smooth' });
    });
    document.querySelector('.p-next')?.addEventListener('click', () => {
      scroller.scrollBy({ left: step, behavior: 'smooth' });
    });
})();
// Voucher code: uppercase + bỏ khoảng trắng + validate nhanh
document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('voucherForm');
  const code = document.getElementById('voucherCode');
  if (!form || !code) return;

  // Gõ tới đâu chuẩn hoá tới đó
  code.addEventListener('input', () => {
    code.value = code.value.toUpperCase().replace(/\s+/g, '');
    if (code.value) code.classList.remove('is-error');
  });

  // Chặn submit rỗng
  form.addEventListener('submit', (e) => {
    if (!code.value.trim()) {
      e.preventDefault();
      code.classList.add('is-error');
      code.focus();
    }
  });
});


