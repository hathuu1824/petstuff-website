<%--
    Document   : option
    Created on : 22 Nov 2025, 7:58:42 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%
    String ctx = request.getContextPath();

    List<Map<String,Object>> types =
        (List<Map<String,Object>>) request.getAttribute("types");
    List<Map<String,Object>> sanphamList =
        (List<Map<String,Object>>) request.getAttribute("sanphamList");

    String loadError        = (String) request.getAttribute("loadError");
    String loadErrorProduct = (String) request.getAttribute("loadErrorProducts");

    Map<String,Object> editTarget =
        (Map<String,Object>) request.getAttribute("editTarget");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Trang quản trị</title>
        <link rel="stylesheet" href="<%= ctx %>/css/admin_option.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <%
            HttpSession ss = request.getSession(false);

            Integer userId    = null;
            String username   = null;
            String role       = null;
            String avatarFile = null; 

            if (ss != null) {
                userId     = (Integer) ss.getAttribute("userId");
                username   = (String) ss.getAttribute("username");  
                role       = (String) ss.getAttribute("role");  
                avatarFile = (String) ss.getAttribute("avatarPath"); 
            }

            boolean isLoggedIn = (username != null);
            if (userId != null) isLoggedIn = true;

            String avatarUrl;
            if (avatarFile == null || avatarFile.trim().isEmpty()) {
                avatarUrl = ctx + "/images/avatar-default.png";
            } else {
                avatarUrl = ctx + "/images/" + avatarFile;
            }
        %>
        <header>
            <nav class="container">
                <a href="<%= ctx %>/admin" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle" href="#" aria-label="Tài khoản" title="Tài khoản">
                                <i class="fa-solid fa-user"></i>
                            </a>
                            <div class="user-popup" id="userPopup">
                                <div class="user-popup-header">
                                    <div class="user-popup-avatar">
                                        <img src="<%= avatarUrl %>" alt="Avatar">
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
                        <li><a href="<%= ctx %>/admin_loaisp" class="active">Quản lý loại sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_donhang">Quản lý đơn hàng</a></li>
                        <li><a href="<%= ctx %>/admin_voucher">Quản lý voucher</a></li>
                        <li><a href="<%= ctx %>/admin_km">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>

            <!-- Content -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1>Quản lý loại sản phẩm</h1>
                    <p>Thiết lập các biến thể/loại cho từng sản phẩm</p>
                </div>

                <div class="table-container">
                    <div class="table-header">
                        <h3><i class="fas fa-list" style="margin-right:8px;"></i>Danh sách loại sản phẩm</h3>
                        <button class="btn-add" onclick="openModal('addTypeModal')">
                           Thêm loại sản phẩm
                        </button>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th style="width:60px;">ID</th>
                                <th style="width:80px;">Ảnh</th>
                                <th style="width:200px;">Tên sản phẩm</th>
                                <th style="width:180px;">Tên loại</th>
                                <th style="width:90px;">Giá</th>
                                <th style="width:80px;">Số lượng</th>
                                <th style="width:150px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (loadError != null) { %>
                                <tr>
                                    <td colspan="8" style="color:#b91c1c;background:#fff0f0;">
                                        Lỗi tải dữ liệu: <%= loadError %>
                                    </td>
                                </tr>
                            <% } else if (types == null || types.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" style="text-align:center;">Không có loại sản phẩm</td>
                                </tr>
                            <% } else {
                                   for (Map<String,Object> row : types) {
                                       int         id        = (Integer) row.get("id");
                                       String      tensp     = (String)  row.get("tensp");
                                       String      tenLoai   = (String)  row.get("ten_loai");
                                       BigDecimal  gia       = (BigDecimal) row.get("gia");
                                       Integer     soluong   = (Integer) row.get("soluong");
                                       String      anh       = (String)  row.get("anh");

                                       String imgSrc = (anh == null || anh.trim().isEmpty())
                                                       ? (ctx + "/images/no-avatar.png")
                                                       : (ctx + "/images/" + anh);
                            %>
                                <tr>
                                    <td><strong><%= id %></strong></td>
                                    <td>
                                        <img class="avatar"
                                             src="<%= imgSrc %>"
                                             width="40" height="40"
                                             onerror="this.onerror=null;this.src='<%= ctx %>/images/no-avatar.png';">
                                    </td>
                                    <td><strong><%= tensp != null ? tensp : "" %></strong></td>
                                    <td><%= tenLoai != null ? tenLoai : "" %></td>
                                    <td><%= gia != null ? gia.intValue() : "" %></td>
                                    <td><%= soluong != null ? soluong : "" %></td>
                                    <td class="action-buttons">
                                        <form method="get" action="<%= ctx %>/admin_loaisp" style="display:inline;">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-edit">
                                                <i class="fas fa-edit"></i> Sửa
                                            </button>
                                        </form>
                                        <form method="post" action="<%= ctx %>/admin_loaisp" style="display:inline;"
                                              onsubmit="return confirm('Xóa loại sản phẩm #<%= id %>?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-delete">
                                                <i class="fas fa-trash"></i> Xoá
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <%     }
                                 }  %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>

        <!-- Modal Thêm loại -->
        <div id="addTypeModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('addTypeModal')">&times;</span>
                <h3><i class="fas fa-box"></i> Thêm loại sản phẩm</h3>
                <form action="<%= ctx %>/admin_loaisp" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Sản phẩm:</label>
                                <select class="form-control" name="sanpham_id" required>
                                    <option value="">Chọn sản phẩm</option>
                                    <%
                                        if (sanphamList != null) {
                                            for (Map<String,Object> sp : sanphamList) {
                                                int    maspSp  = (Integer) sp.get("masp");
                                                String tenspSp = (String)  sp.get("tensp");
                                    %>
                                                <option value="<%= maspSp %>">
                                                    <%= tenspSp %>
                                                </option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Tên loại:</label>
                                <input class="form-control" type="text" name="ten_loai" required>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giá:</label>
                                <input class="form-control" type="number" step="0.01" min="0" name="gia">
                            </div>
                            <div class="form-group">
                                <label>Số lượng:</label>
                                <input class="form-control" type="number" min="0" name="soluong">
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label>Ảnh loại sản phẩm:</label>
                        <div class="image-upload-container">
                            <input type="file" name="anh" class="form-control"
                                   accept="image/*" onchange="previewImage(this, 'addTypePreview')">
                            <img id="addTypePreview" alt="Preview"
                                 style="max-width:100px;max-height:100px;display:none;border-radius:8px;">
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Thêm loại
                    </button>
                </form>
            </div>
        </div>

        <!-- Modal Sửa loại -->
        <div id="editTypeModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeEditModal()">&times;</span>
                <h3><i class="fas fa-edit"></i> Sửa loại sản phẩm</h3>
                <form action="<%= ctx %>/admin_loaisp" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="edit-id">
                    <input type="hidden" name="existingAnh" id="edit-existing-anh">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Sản phẩm:</label>
                                <select class="form-control" name="sanpham_id" id="edit-sanpham-id">
                                    <option value="">Chọn sản phẩm</option>
                                    <%
                                        if (sanphamList != null) {
                                            for (Map<String,Object> sp : sanphamList) {
                                                int    maspSp  = (Integer) sp.get("masp");
                                                String tenspSp = (String)  sp.get("tensp");
                                    %>
                                                <option value="<%= maspSp %>">
                                                    <%= tenspSp %>
                                                </option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Tên loại:</label>
                                <input class="form-control" type="text" name="ten_loai"
                                       id="edit-ten-loai" required>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giá:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="gia" id="edit-gia">
                            </div>
                            <div class="form-group">
                                <label>Số lượng:</label>
                                <input class="form-control" type="number" min="0"
                                       name="soluong" id="edit-soluong">
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-group">
                        <label>Ảnh loại sản phẩm:</label>
                        <div class="image-upload-container">
                            <img id="editPreview" src="" alt="Preview"
                                 style="max-width:100px;max-height:100px;display:none;border-radius:8px;">
                            <input type="file" name="anhFile" id="edit-anh-file" accept="image/*"
                                   onchange="previewFile(this, 'editPreview')">
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
                if (modal) {
                    modal.style.display = "block";
                }
            }

            function closeModal(id) {
                const modal = document.getElementById(id);
                if (modal) {
                    modal.style.display = "none";
                }
            }

            function closeEditModal() {
                closeModal("editTypeModal");
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

            // ===== Tự fill form sửa nếu có window.__EDIT_TYPE__ =====
            document.addEventListener("DOMContentLoaded", function () {
                if (!window.__EDIT_TYPE__) return;
                const p = window.__EDIT_TYPE__;

                const idEl       = document.getElementById("edit-id");
                const spIdEl     = document.getElementById("edit-sanpham-id");
                const tenLoaiEl  = document.getElementById("edit-ten-loai");
                const giaEl      = document.getElementById("edit-gia");
                const soluongEl  = document.getElementById("edit-soluong");
                const existAnhEl = document.getElementById("edit-existing-anh");
                const preview    = document.getElementById("editTypePreview");

                if (idEl)       idEl.value       = p.id || "";
                if (spIdEl)     spIdEl.value     = p.sanpham_id || "";
                if (tenLoaiEl)  tenLoaiEl.value  = p.ten_loai || "";
                if (giaEl)      giaEl.value      = p.gia || "";
                if (soluongEl)  soluongEl.value  = p.soluong || "";
                if (existAnhEl) existAnhEl.value = p.anh || "";

                if (preview && p.anh) {
                    const base = window.location.origin
                              + window.location.pathname.split("/admin_loaisp")[0];
                    preview.src = base + "/images/" + p.anh;
                    preview.style.display = "block";
                }

                openModal("editTypeModal");
            });
        </script>

        <%
            // Xuất JS object cho bản ghi đang sửa (nếu có)
            if (editTarget != null) {
                int        eId      = (Integer)   editTarget.get("id");
                int        eSpId    = (Integer)   editTarget.get("sanpham_id");
                String     eTenLoai = (String)    editTarget.get("ten_loai");
                BigDecimal eGia     = (BigDecimal) editTarget.get("gia");
                Integer    eSoluong = (Integer)   editTarget.get("soluong");
                String     eAnh     = (String)    editTarget.get("anh");

                String jsTenLoai = (eTenLoai != null) ? eTenLoai.replace("\"", "\\\"") : "";
                String jsGia     = (eGia != null) ? String.valueOf(eGia.intValue())    : "";
                String jsSl      = (eSoluong != null) ? String.valueOf(eSoluong)       : "";
                String jsAnh     = (eAnh != null) ? eAnh                                : "";
        %>
        <script>
            window.__EDIT_TYPE__ = {
                id:         <%= eId %>,
                sanpham_id: <%= eSpId %>,
                ten_loai:   "<%= jsTenLoai %>",
                gia:        "<%= jsGia %>",
                soluong:    "<%= jsSl %>",
                anh:        "<%= jsAnh %>"
            };
        </script>
        <%
            }
        %>
    </body>
</html>