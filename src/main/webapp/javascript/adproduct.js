/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// ===== Popup user ở header =====
document.addEventListener("DOMContentLoaded", function () {
    const userMenu   = document.querySelector(".user-menu");
    const userToggle = userMenu ? userMenu.querySelector(".user-toggle") : null;
    const userPopup  = document.getElementById("userPopup");

    if (!userMenu || !userToggle || !userPopup) return;

    // Click icon user -> mở / đóng popup
    userToggle.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        // Thêm / bỏ class "open" trên .user-menu (đúng với CSS)
        userMenu.classList.toggle("open");
    });

    // Click ra ngoài -> đóng popup
    document.addEventListener("click", function (e) {
        if (!userMenu.contains(e.target)) {
            userMenu.classList.remove("open");
        }
    });

    // Nhấn ESC -> đóng popup
    document.addEventListener("keydown", function (e) {
        if (e.key === "Escape") {
            userMenu.classList.remove("open");
        }
    });
});

// ===== Hàm global cho modal (dùng trong onclick ở JSP) =====
window.openModal = function (id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    modal.style.display = "block";
    modal.classList.add("show");
};

window.closeModal = function (id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    modal.style.display = "none";
    modal.classList.remove("show");
};

// Dùng riêng cho modal sửa để xoá query ?action=edit&id=...
window.closeEditModal = function () {
    window.closeModal("editProductModal");

    if (window.history && window.history.replaceState) {
        const url = new URL(window.location.href);
        url.searchParams.delete("action");
        url.searchParams.delete("id");
        window.history.replaceState({}, "", url.pathname + (url.search || ""));
    }
};

// ===== Preview ảnh =====
window.previewImage = function (input, imgId) {
    const file = input.files && input.files[0];
    const img  = document.getElementById(imgId);
    if (!file || !img) return;

    const reader = new FileReader();
    reader.onload = function (e) {
        img.src = e.target.result;
        img.style.display = "block";
    };
    reader.readAsDataURL(file);
};

window.previewFile = function (input, imgId) {
    window.previewImage(input, imgId);
};

// ===== Tự động mở modal sửa nếu JSP set window.__EDIT_PRODUCT__ =====
document.addEventListener("DOMContentLoaded", function () {
    const p = window.__EDIT_PRODUCT__;
    if (!p) return;

    const idEl       = document.getElementById("edit-id");
    const tenspEl    = document.getElementById("edit-tensp");
    const giaEl      = document.getElementById("edit-giatien");
    const giakmEl    = document.getElementById("edit-giakm");
    const giamPtEl   = document.getElementById("edit-giam-pt");
    const giamTienEl = document.getElementById("edit-giam-tien");
    const kmTuEl     = document.getElementById("edit-km-tu");
    const kmDenEl    = document.getElementById("edit-km-den");
    const motaEl     = document.getElementById("edit-mota");
    const bstEl      = document.getElementById("edit-bst");
    const loaiEl     = document.getElementById("edit-loai");
    const existAnhEl = document.getElementById("edit-existing-anh");
    const preview    = document.getElementById("editPreview");
    const modeSel    = document.getElementById("edit-discount-mode");

    if (idEl)       idEl.value       = p.masp || "";
    if (tenspEl)    tenspEl.value    = p.tensp || "";
    if (giaEl)      giaEl.value      = p.giatien || "";
    if (giakmEl)    giakmEl.value    = p.giakm || "";
    if (giamPtEl)   giamPtEl.value   = p.giam_pt || "";
    if (giamTienEl) giamTienEl.value = p.giam_tien || "";
    if (kmTuEl)     kmTuEl.value     = p.km_tu  ? p.km_tu.replace(" ", "T").substring(0, 16) : "";
    if (kmDenEl)    kmDenEl.value    = p.km_den ? p.km_den.replace(" ", "T").substring(0, 16) : "";
    if (motaEl)     motaEl.value     = p.mota || "";
    if (bstEl)      bstEl.value      = p.bst || "";
    if (loaiEl)     loaiEl.value     = p.loai || "";
    if (existAnhEl) existAnhEl.value = p.anhsp || "";

    // set kiểu khuyến mãi
    if (modeSel) {
        let mode = "none";
        if (p.giakm && p.giakm !== "")             mode = "price";
        else if (p.giam_pt && Number(p.giam_pt)>0) mode = "percent";
        else if (p.giam_tien && p.giam_tien !== "") mode = "amount";
        modeSel.value = mode;
    }

    // ảnh preview
    if (preview && p.anhsp) {
        const basePath = window.location.origin +
            window.location.pathname.split("/admin_sanpham")[0];
        preview.src = basePath + "/images/" + p.anhsp;
        preview.style.display = "block";
    }

    // mở modal sửa
    window.openModal("editProductModal");
});
