<%-- 
    Document   : news
    Created on : 24 Nov 2025, 3:54:23 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    // Định dạng ngày đăng chỉ lấy phần yyyy-MM-dd
    private String formatDateOnly(Timestamp ts) {
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

    List<Map<String,Object>> newsList =
        (List<Map<String,Object>>) request.getAttribute("newsList");
    String loadError = (String) request.getAttribute("loadError");

    Map<String,Object> editTarget =
        (Map<String,Object>) request.getAttribute("editTarget");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Trang quản trị</title>
        <link rel="stylesheet" href="<%= ctx %>/css/admin_product.css"><!-- tái dùng css -->
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <!-- Header -->
        <header>
            <nav class="container">
                <a href="<%= ctx %>/admin_tintuc" id="logo">PetStuff</a>
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
                                    <div class="user-popup-role-pill"><%= role %></div>
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
                        <li><a href="<%= ctx %>/admin_km">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc" class="active">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>

            <!-- Content -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1>Quản lý tin tức</h1>
                    <p>Quản lý các bài viết / tin tức hiển thị trên website</p>
                </div>

                <div class="table-container">
                    <div class="table-header">
                        <h3><i class="fas fa-list" style="margin-right:8px;"></i>Danh sách tin tức</h3>
                        <button class="btn-add" onclick="openModal('addNewsModal')">
                            Thêm tin tức
                        </button>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th style="width:60px;">ID</th>
                                <th style="width:90px;">Ảnh</th>
                                <th style="width:260px;">Tiêu đề</th>
                                <th style="width:360px;">Tóm tắt</th>
                                <th style="width:360px;">Nội dung</th>
                                <th style="width:130px;">Ngày đăng</th>
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
                            <% } else if (newsList == null || newsList.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align:center;">Không có tin tức</td>
                                </tr>
                            <% } else {
                                   for (Map<String,Object> row : newsList) {

                                       int       id        = (Integer)  row.get("id");
                                       String    tieuDe    = (String)   row.get("tieu_de");
                                       String    tomTat    = (String)   row.get("tom_tat");
                                       String    noiDung    = (String)   row.get("noi_dung");
                                       String    anh       = (String)   row.get("anh_dai_dien");
                                       Timestamp ngayDang  = (Timestamp) row.get("ngay_dang");

                                       String imgSrc = (anh == null || anh.trim().isEmpty())
                                                       ? (ctx + "/images/no-avatar.png")
                                                       : (ctx + "/images/" + anh);
                                       String ngayDangStr = formatDateOnly(ngayDang);
                            %>
                                <tr>
                                    <td><strong><%= id %></strong></td>
                                    <td>
                                        <img class="avatar"
                                             src="<%= imgSrc %>"
                                             width="48" height="48"
                                             onerror="this.onerror=null;this.src='<%= ctx %>/images/no-avatar.png';">
                                    </td>
                                    <td><strong><%= (tieuDe != null ? tieuDe : "") %></strong></td>
                                    <td><%= (tomTat != null ? tomTat : "") %></td>
                                    <td><%= (noiDung != null ? noiDung : "") %></td>
                                    <td><%= ngayDangStr %></td>
                                    <td class="action-buttons">
                                        <form method="get" action="<%= ctx %>/admin_tintuc" style="display:inline;">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-edit">
                                                <i class="fas fa-edit"></i> Sửa
                                            </button>
                                        </form>
                                        <form method="post" action="<%= ctx %>/admin_tintuc" style="display:inline;"
                                              onsubmit="return confirm('Xóa tin tức #<%= id %>?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-delete">
                                                <i class="fas fa-trash"></i> Xoá
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <%     } // end for
                               }     // end else %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>

        <!-- Modal Thêm tin tức -->
        <div id="addNewsModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('addNewsModal')">&times;</span>
                <h3><i class="fas fa-plus"></i> Thêm tin tức</h3>
                <form action="<%= ctx %>/admin_tintuc" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tiêu đề:</label>
                                <input class="form-control" type="text" name="tieu_de" required>
                            </div>
                            <div class="form-group">
                                <label>Tóm tắt:</label>
                                <textarea class="form-control" name="tom_tat" rows="2"></textarea>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Nội dung:</label>
                                <textarea class="form-control" name="noi_dung" rows="5"></textarea>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label>Ảnh đại diện:</label>
                        <div class="image-upload-container">
                            <input type="file" name="anh_dai_dien" class="form-control"
                                   accept="image/*" onchange="previewImage(this, 'addNewsPreview')">
                            <img id="addNewsPreview" alt="Preview"
                                 style="max-width:120px;max-height:120px;display:none;border-radius:8px;">
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Thêm tin tức
                    </button>
                </form>
            </div>
        </div>

        <!-- Modal Sửa tin tức -->
        <div id="editNewsModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeEditModal()">&times;</span>
                <h3><i class="fas fa-edit"></i> Sửa tin tức</h3>
                <form action="<%= ctx %>/admin_tintuc" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="edit-id">
                    <input type="hidden" name="existingAnh" id="edit-existing-anh">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tiêu đề:</label>
                                <input class="form-control" type="text" name="tieu_de" id="edit-tieu-de" required>
                            </div>
                            <div class="form-group">
                                <label>Tóm tắt:</label>
                                <textarea class="form-control" name="tom_tat" id="edit-tom-tat" rows="2"></textarea>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Nội dung:</label>
                                <textarea class="form-control" name="noi_dung" id="edit-noi-dung" rows="5"></textarea>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label>Ảnh đại diện:</label>
                        <div class="image-upload-container">
                            <img id="editNewsPreview" src="" alt="Preview"
                                 style="max-width:120px;max-height:120px;display:none;border-radius:8px;">
                            <input type="file" name="anh_dai_dien_edit" id="edit-anh-file" accept="image/*"
                                   onchange="previewImage(this, 'editNewsPreview')">
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
                closeModal("editNewsModal");
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

            // ===== Tự fill form sửa nếu có window.__EDIT_NEWS__ =====
            document.addEventListener("DOMContentLoaded", function () {
                if (!window.__EDIT_NEWS__) return;
                const n = window.__EDIT_NEWS__;

                const idEl        = document.getElementById("edit-id");
                const tieuDeEl    = document.getElementById("edit-tieu-de");
                const tomTatEl    = document.getElementById("edit-tom-tat");
                const noiDungEl   = document.getElementById("edit-noi-dung");
                const existAnhEl  = document.getElementById("edit-existing-anh");
                const previewEl   = document.getElementById("editNewsPreview");

                if (idEl)      idEl.value      = n.id || "";
                if (tieuDeEl)  tieuDeEl.value  = n.tieu_de || "";
                if (tomTatEl)  tomTatEl.value  = n.tom_tat || "";
                if (noiDungEl) noiDungEl.value = n.noi_dung || "";
                if (existAnhEl) existAnhEl.value = n.anh_dai_dien || "";

                if (previewEl && n.anh_dai_dien) {
                    const base = window.location.origin + "<%= ctx %>";
                    previewEl.src = base + "/images/" + n.anh_dai_dien;
                    previewEl.style.display = "block";
                }

                openModal("editNewsModal");
            });
        </script>

        <%
            // Xuất JS object cho bản ghi đang sửa (nếu có)
            if (editTarget != null) {
                int       eId       = (Integer)   editTarget.get("id");
                String    eTieuDe   = (String)    editTarget.get("tieu_de");
                String    eTomTat   = (String)    editTarget.get("tom_tat");
                String    eNoiDung  = (String)    editTarget.get("noi_dung");
                String    eAnh      = (String)    editTarget.get("anh_dai_dien");

                String jsTieuDe  = (eTieuDe  != null) ? eTieuDe.replace("\"","\\\"") : "";
                String jsTomTat  = (eTomTat  != null) ? eTomTat.replace("\"","\\\"") : "";
                String jsNoiDung = (eNoiDung != null) ? eNoiDung.replace("\"","\\\"") : "";
                String jsAnh     = (eAnh     != null) ? eAnh : "";
        %>
        <script>
            window.__EDIT_NEWS__ = {
                id:           <%= eId %>,
                tieu_de:     "<%= jsTieuDe %>",
                tom_tat:     "<%= jsTomTat %>",
                noi_dung:    "<%= jsNoiDung %>",
                anh_dai_dien:"<%= jsAnh %>"
            };
        </script>
        <%
            }
        %>
    </body>
</html>
