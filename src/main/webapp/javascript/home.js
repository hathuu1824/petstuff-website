/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// Đóng/mở dropdown + popup user
document.addEventListener('DOMContentLoaded', () => {
    // ===== Dropdown "Sản phẩm", "Bộ sưu tập" =====
    const style = document.createElement('style');
    style.textContent = `.has-dd.open .dropdown{display:block}`;
    document.head.appendChild(style);

    const dropdownItems = document.querySelectorAll('.has-dd');

    dropdownItems.forEach(li => {
        const btn   = li.querySelector('.dd-toggle');
        const panel = li.querySelector('.dropdown');
        let hideTimer = null;

        const openNow = () => {
            clearTimeout(hideTimer);
            // đóng các dropdown khác
            dropdownItems.forEach(x => {
                if (x !== li) x.classList.remove('open');
            });
            li.classList.add('open');
        };

        const closeLater = () => {
            clearTimeout(hideTimer);
            hideTimer = setTimeout(() => li.classList.remove('open'), 250);
        };

        const closeNow = () => {
            clearTimeout(hideTimer);
            li.classList.remove('open');
        };

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

    // ===== Popup user ở icon tài khoản =====
    const userMenu   = document.querySelector('.user-menu');
    const userToggle = document.querySelector('.user-toggle');

    if (userMenu && userToggle) {
        // Bật / tắt khi click icon user
        userToggle.addEventListener('click', (e) => {
            e.preventDefault();   // không chuyển trang
            e.stopPropagation();  // không cho sự kiện nổi lên doc
            userMenu.classList.toggle('open');
        });
    }

    // ===== Click ra ngoài -> đóng dropdown & popup user =====
    document.addEventListener('click', (e) => {
        // đóng tất cả dropdown
        dropdownItems.forEach(li => li.classList.remove('open'));

        // đóng popup user nếu click ngoài
        if (userMenu && !userMenu.contains(e.target)) {
            userMenu.classList.remove('open');
        }
    });

    // ===== Nhấn ESC -> đóng hết =====
    window.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            dropdownItems.forEach(li => li.classList.remove('open'));
            if (userMenu) userMenu.classList.remove('open');
        }
    });
});

// Slider
document.addEventListener('DOMContentLoaded', function () {
  const slider = document.getElementById('hero');
  if (!slider) return;

  const slides = Array.from(slider.querySelectorAll('.slide'));
  const dots   = Array.from(slider.querySelectorAll('.dot'));
  const btnPrev = slider.querySelector('.hero-nav.prev');
  const btnNext = slider.querySelector('.hero-nav.next');

  if (!slides.length) return;

  // index hiện tại (ưu tiên slide có .is-active)
  let i = slides.findIndex(s => s.classList.contains('is-active'));
  if (i < 0) i = 0;

  // ====== layout ======
  function layout() {
    slides.forEach((s, idx) => {
      const offset = (idx - i) * 100; // mỗi slide lệch 100%
      s.style.transform = `translateX(${offset}%)`;
      s.classList.toggle('is-active', idx === i);
    });
    dots.forEach((d, idx) => d.classList.toggle('active', idx === i));
  }

  function go(n) {
    i = (n + slides.length) % slides.length;
    layout();
  }
  function next() { go(i + 1); }
  function prev() { go(i - 1); }

  // ====== auto play ======
  const AUTOPLAY_MS = 5000;
  let timer = null;
  function startTimer() {
    stopTimer();
    timer = setInterval(next, AUTOPLAY_MS);
  }
  function stopTimer() {
    if (timer) clearInterval(timer);
    timer = null;
  }

  // init
  layout();
  startTimer();

  // ====== dots click ======
  dots.forEach(d => {
    d.addEventListener('click', () => {
      const idx = Number(d.dataset.index ?? -1);
      if (idx >= 0) {
        go(idx);
        startTimer();
      }
    });
  });

  // ====== nav buttons ======
  btnNext && btnNext.addEventListener('click', () => { next(); startTimer(); });
  btnPrev && btnPrev.addEventListener('click', () => { prev(); startTimer(); });

  // ====== hover pause ======
  slider.addEventListener('mouseenter', stopTimer);
  slider.addEventListener('mouseleave', startTimer);

  // ====== keyboard (← →) ======
  slider.setAttribute('tabindex', '0');
  slider.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight') { next(); startTimer(); }
    else if (e.key === 'ArrowLeft') { prev(); startTimer(); }
  });

  // ====== touch swipe cơ bản ======
  let touchX = null;
  slider.addEventListener('touchstart', (e) => {
    touchX = e.touches[0].clientX;
    stopTimer();
  }, { passive: true });

  slider.addEventListener('touchend', (e) => {
    if (touchX !== null) {
      const dx = e.changedTouches[0].clientX - touchX;
      if (Math.abs(dx) > 40) { // ngưỡng vuốt
        if (dx < 0) next(); else prev();
      }
      touchX = null;
    }
    startTimer();
  });

  // ====== pause khi chuyển tab ======
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) stopTimer(); else startTimer();
  });
});

// Tạo map
window.addEventListener('load', function(){
    var iframe = document.querySelector('.review .loc-map iframe');
    if(!iframe) return;
    var address = '68 Đ. Nguyễn Chí Thanh, Láng Thượng, Đống Đa, Hà Nội, Việt Nam';
    iframe.src = 'https://www.google.com/maps?q=' + encodeURIComponent(address) + '&hl=vi&z=16&output=embed';
    if(!iframe.hasAttribute('width')) iframe.setAttribute('width','100%');
    if(!iframe.hasAttribute('height')) iframe.setAttribute('height','420');
});
