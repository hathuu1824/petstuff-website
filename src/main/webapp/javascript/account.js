/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* ===== Popup user ở header (admin) ===== */
document.addEventListener("DOMContentLoaded", () => {
    const userMenu   = document.querySelector(".user-menu");
    const userToggle = document.querySelector(".user-toggle");

    if (userMenu && userToggle) {
        // Mở / đóng khi click icon
        userToggle.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            userMenu.classList.toggle("open");
        });

        // Click ra ngoài -> đóng
        document.addEventListener("click", (e) => {
            if (!userMenu.contains(e.target)) {
                userMenu.classList.remove("open");
            }
        });

        // ESC -> đóng
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape") {
                userMenu.classList.remove("open");
            }
        });
    }

    /* ===== Modal Thêm tài khoản ===== */
    const addModalId   = "addUserModal";          // id của modal thêm
    const addUserModal = document.getElementById(addModalId);
    const btnOpenAdd   = document.getElementById("btnOpenAddUser");

    if (btnOpenAdd && addUserModal) {
        btnOpenAdd.addEventListener("click", (e) => {
            e.preventDefault();
            openModal(addModalId);
        });
    }

    // Trong modal thêm: các nút có data-close="addUserModal"
    if (addUserModal) {
        addUserModal
            .querySelectorAll("[data-close='addUserModal']")
            .forEach((btn) => {
                btn.addEventListener("click", (e) => {
                    e.preventDefault();
                    closeModal(addModalId);
                });
            });
    }
});

/* ===== Helpers cho modal (dùng chung cả Thêm + Sửa) ===== */
function openModal(id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    modal.style.display = "block";
    modal.classList.add("show");
    document.body.style.overflow = "hidden";
}

function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.style.display = "none";

    if (id === "editUserModal" && window.history.replaceState) {
        const cleanURL = window.location.origin + window.location.pathname;
        window.history.replaceState(null, "", cleanURL);
    }
}


// Cho phép gọi trong HTML inline: onclick="closeModal('editUserModal')"
window.openModal  = openModal;
window.closeModal = closeModal;

/* Đóng modal khi click overlay */
window.addEventListener("click", (e) => {
    const editModal = document.getElementById("editUserModal");
    const addModal  = document.getElementById("addUserModal");

    if (e.target === editModal) closeModal("editUserModal");
    if (e.target === addModal)  closeModal("addUserModal");
});

/* ===== Preview file ảnh (Sửa) ===== */
function previewFile(input, imgId, nameId) {
    const file = input.files && input.files[0];
    const img  = document.getElementById(imgId);
    const nameSpan = nameId ? document.getElementById(nameId) : null;

    if (!file || !img) return;

    const reader = new FileReader();
    reader.onload = (e) => {
        img.src = e.target.result;
        img.style.display = "block";
    };
    reader.readAsDataURL(file);

    if (nameSpan) nameSpan.textContent = file.name;
}
window.previewFile = previewFile;

/* ===== Preview ảnh (Thêm) nếu bạn dùng id khác ===== */
function previewImage(input, previewId) {
    const file = input.files && input.files[0];
    const img  = document.getElementById(previewId);
    if (!img) return;

    if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            img.src = e.target.result;
            img.style.display = "block";
        };
        reader.readAsDataURL(file);
    } else {
        img.src = "";
        img.style.display = "none";
    }
}
window.previewImage = previewImage;
