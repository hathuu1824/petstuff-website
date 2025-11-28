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

