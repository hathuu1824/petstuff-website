<%-- 
    Document   : discount
    Created on : 24 Nov 2025, 3:24:41 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    // Định dạng ngày từ Timestamp -> yyyy-MM-dd
    private String formatDate(Timestamp ts) {
        if (ts == null) return "";
        return ts.toLocalDateTime().toLocalDate().toString();
    }
%>

<%
    String ctx = request.getContextPath();

    HttpSession ss = request.getSession(false);
    String username = null;
    String role     = null;

    if (ss != null) {
        username = (String) ss.getAttribute("username");
        role     = (String) ss.getAttribute("role");
    }
    boolean isLoggedIn = (username != null);

    List<Map<String,Object>> promos =
        (List<Map<String,Object>>) request.getAttribute("promos");
    String loadError =
        (String) request.getAttribute("loadError");

    Map<String,Object> editTarget =
        (Map<String,Object>) request.getAttribute("editTarget");

    // Sort lại theo id ASC ở phía view cho chắc
    if (promos != null) {
        java.util.Collections.sort(
            promos,
            new java.util.Comparator<Map<String,Object>>() {
                @Override
                public int compare(Map<String,Object> a, Map<String,Object> b) {
                    Integer ia = (Integer) a.get("id");
                    Integer ib = (Integer) b.get("id");
                    if (ia == null && ib == null) return 0;
                    if (ia == null) return -1;
                    if (ib == null) return 1;
                    return ia.compareTo(ib);
                }
            }
        );
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Trang quản trị</title>
        <link rel="stylesheet" href="<%= ctx %>/css/admin_product.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <!-- Header -->
        <header>
            <nav class="container">
                <a href="<%= ctx %>/admin_km" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle" href="#" aria-label="Tài khoản" title="Tài khoản">
                                <i class="fa-solid fa-user"></i>
                            </a>
                            <div class="user-popup" id="userPopup">
                                <div class="user-popup-header">
                                    <div class="user-popup-avatar">
                                        <img src="<%= ctx %>/images/avatar-default.png" alt="Avatar">
                                    </div>
                                    <div class="user-popup-name"><%= username %></div>
                                    <div class="user-popup-role-pill">
                                        <%= (role != null ? role : "admin") %>
                                    </div>
                                </div>
                                <div class="user-popup-body">
                                    <a href="<%= request.getContextPath() %>/profile" class="user-popup-item">
                                        <i class="fa-solid fa-user"></i>
                                        <span>Thông tin cá nhân</span>
                                    </a>
                                    <a href="<%= ctx %>/admin" class="user-popup-item">
                                        <i class="fa-solid fa-gear"></i>
                                        <span>Quản lý hệ thống</span>
                                    </a>
                                </div>
                                <div class="user-popup-footer">
                                    <a href="<%= ctx %>/dangxuat" class="home-btn logout-btn">
                                        <span>Đăng xuất</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                        <span class="home">Xin chào, <%= username %>!</span>
                    <% } else { %>
                        <a href="<%= ctx %>/login.jsp" class="home-btn">Đăng nhập</a>
                        <a href="<%= ctx %>/register.jsp" class="home-btn">Đăng ký</a>
                    <% } %>
                </div>
            </nav>
        </header>

        <main class="main">
            <!-- Sidebar -->
            <div class="dashboard-sidebar">
                <aside class="sidebar">
                    <div class="sidebar-header">
                        <i class="fas fa-list" style="margin-right:6px;"></i>
                        <h2>Bảng điều khiển</h2>
                    </div>
                    <ul class="sidebar-menu">
                        <li><a href="<%= ctx %>/admin">Quản lý tài khoản</a></li>
                        <li><a href="<%= ctx %>/admin_sanpham">Quản lý sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_loaisp">Quản lý loại sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_donhang">Quản lý đơn hàng</a></li>
                        <li><a href="<%= ctx %>/admin_voucher">Quản lý voucher</a></li>
                        <li><a href="<%= ctx %>/admin_km" class="active">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>

            <!-- Content -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1>Quản lý khuyến mại</h1>
                    <p>Quản lý các banner / slide khuyến mại trên trang chủ</p>
                </div>

                <div class="table-container">
                    <div class="table-header">
                        <h3><i class="fas fa-list" style="margin-right:8px;"></i>Danh sách khuyến mại</h3>
                        <button class="btn-add" onclick="openModal('addPromoModal')">
                             Thêm khuyến mại
                        </button>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th style="width:60px;">ID</th>
                                <th style="width:90px;">Ảnh</th>
                                <th style="width:260px;">Tiêu đề</th>
                                <th style="width:140px;">Ngày tạo</th>
                                <th style="width:160px;">Ngày cập nhật</th>
                                <th style="width:150px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (loadError != null) { %>
                                <tr>
                                    <td colspan="6" style="color:#b91c1c;background:#fff0f0;">
                                        Lỗi tải dữ liệu: <%= loadError %>
                                    </td>
                                </tr>
                            <% } else if (promos == null || promos.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align:center;">Không có khuyến mại</td>
                                </tr>
                            <% } else {
                                   for (Map<String,Object> row : promos) {

                                       int       id          = (Integer)   row.get("id");
                                       String    anhUrl      = (String)    row.get("anh_url");
                                       String    tieuDe      = (String)    row.get("tieu_de");
                                       Timestamp ngayTao     = (Timestamp) row.get("ngay_tao");
                                       Timestamp ngayCapNhat = (Timestamp) row.get("ngay_cap_nhat");

                                       String imgSrc = (anhUrl == null || anhUrl.trim().isEmpty())
                                                      ? (ctx + "/images/no-avatar.png")
                                                      : (ctx + "/images/" + anhUrl);

                                       String ngayTaoStr     = formatDate(ngayTao);
                                       String ngayCapNhatStr = formatDate(ngayCapNhat);
                            %>
                                <tr>
                                    <td><strong><%= id %></strong></td>
                                    <td>
                                        <img class="avatar" src="<%= imgSrc %>" width="70" height="70"
                                             onerror="this.onerror=null;this.src='<%= ctx %>/images/no-avatar.png';">
                                    </td>
                                    <td><%= (tieuDe != null ? tieuDe : "") %></td>
                                    <td><%= ngayTaoStr %></td>
                                    <td><%= ngayCapNhatStr %></td>
                                    <td class="action-buttons">
                                        <form method="get" action="<%= ctx %>/admin_km" style="display:inline;">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-edit">
                                                <i class="fas fa-edit"></i> Sửa
                                            </button>
                                        </form>
                                        <form method="post" action="<%= ctx %>/admin_km" style="display:inline;"
                                              onsubmit="return confirm('Xóa khuyến mại #<%= id %>?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-delete">
                                                <i class="fas fa-trash"></i> Xoá
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <%   } // end for
                               } // end else %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>

        <!-- Modal Thêm khuyến mại -->
        <div id="addPromoModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('addPromoModal')">&times;</span>
                <h3><i class="fas fa-bullhorn"></i> Thêm khuyến mại</h3>
                <form action="<%= ctx %>/admin_km" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tiêu đề:</label>
                                <input class="form-control" type="text" name="tieu_de" required>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label>Ảnh khuyến mại (banner):</label>
                        <div class="image-upload-container">
                            <input type="file" name="anhFile" class="form-control"
                                   accept="image/*" required
                                   onchange="previewImage(this, 'addPromoPreview')">
                            <img id="addPromoPreview" alt="Preview"
                                 style="max-width:260px;max-height:140px;display:none;border-radius:8px;">
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Thêm khuyến mại
                    </button>
                </form>
            </div>
        </div>

        <!-- Modal Sửa khuyến mại -->
        <div id="editPromoModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeEditModal()">&times;</span>
                <h3><i class="fas fa-edit"></i> Sửa khuyến mại</h3>
                <form action="<%= ctx %>/admin_km" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="edit-id">
                    <input type="hidden" name="existingAnh" id="edit-existing-anh">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tiêu đề:</label>
                                <input class="form-control" type="text" name="tieu_de"
                                       id="edit-tieu-de" required>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label>Ảnh khuyến mại:</label>
                        <div class="image-upload-container">
                            <img id="editPromoPreview" src="" alt="Preview"
                                 style="max-width:260px;max-height:140px;display:none;border-radius:8px;">
                            <input type="file" name="anhFile" id="edit-anh-file" accept="image/*"
                                   onchange="previewImage(this, 'editPromoPreview')">
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Cập nhật
                    </button>
                </form>
            </div>
        </div>

        <script>
            // ===== Popup user =====
            document.addEventListener("DOMContentLoaded", function () {
                const userMenu   = document.querySelector(".user-menu");
                const userToggle = document.querySelector(".user-toggle");
                const userPopup  = document.getElementById("userPopup");

                if (userMenu && userToggle && userPopup) {
                    userToggle.addEventListener("click", function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        userMenu.classList.toggle("open");
                    });

                    document.addEventListener("click", function (e) {
                        if (!userMenu.contains(e.target)) {
                            userMenu.classList.remove("open");
                        }
                    });

                    document.addEventListener("keydown", function (e) {
                        if (e.key === "Escape") {
                            userMenu.classList.remove("open");
                        }
                    });
                }
            });

            // ===== Modal helpers =====
            function openModal(id) {
                const modal = document.getElementById(id);
                if (modal) modal.style.display = "block";
            }
            function closeModal(id) {
                const modal = document.getElementById(id);
                if (modal) modal.style.display = "none";
            }
            function closeEditModal() {
                closeModal("editPromoModal");
                if (window.history && window.history.replaceState) {
                    const url = new URL(window.location.href);
                    url.searchParams.delete("action");
                    url.searchParams.delete("id");
                    window.history.replaceState({}, "", url.pathname + url.search);
                }
            }

            // ===== Preview ảnh =====
            function previewImage(input, imgId) {
                const file = input.files && input.files[0];
                const img  = document.getElementById(imgId);
                if (!file || !img) return;

                const reader = new FileReader();
                reader.onload = function (e) {
                    img.src = e.target.result;
                    img.style.display = "block";
                };
                reader.readAsDataURL(file);
            }

            // ===== Tự fill form sửa nếu có window.__EDIT_PROMO__ =====
            document.addEventListener("DOMContentLoaded", function () {
                if (!window.__EDIT_PROMO__) return;
                const p = window.__EDIT_PROMO__;

                const idEl       = document.getElementById("edit-id");
                const tieuDeEl   = document.getElementById("edit-tieu-de");
                const existAnhEl = document.getElementById("edit-existing-anh");
                const preview    = document.getElementById("editPromoPreview");

                if (idEl)       idEl.value       = p.id || "";
                if (tieuDeEl)   tieuDeEl.value   = p.tieu_de || "";
                if (existAnhEl) existAnhEl.value = p.anh_url || "";

                if (preview && p.anh_url) {
                    const base = window.location.origin +
                                 window.location.pathname.split("/admin_km")[0];
                    preview.src = base + "/images/" + p.anh_url;
                    preview.style.display = "block";
                }

                openModal("editPromoModal");
            });
        </script>

        <%
            // Xuất JS object cho bản ghi đang sửa (nếu có)
            if (editTarget != null) {
                int       eId        = (Integer)   editTarget.get("id");
                String    eAnhUrl    = (String)    editTarget.get("anh_url");
                String    eTieuDe    = (String)    editTarget.get("tieu_de");

                String jsAnhUrl = (eAnhUrl != null) ? eAnhUrl.replace("\"","\\\"") : "";
                String jsTieuDe = (eTieuDe != null) ? eTieuDe.replace("\"","\\\"") : "";
        %>
        <script>
            window.__EDIT_PROMO__ = {
                id:      <%= eId %>,
                anh_url: "<%= jsAnhUrl %>",
                tieu_de: "<%= jsTieuDe %>"
            };
        </script>
        <%
            }
        %>
    </body>
</html>
