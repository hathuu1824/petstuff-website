<%-- 
    Document   : admin
    Created on : 7 Nov 2025, 3:54:13 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.*, jakarta.servlet.http.HttpSession"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%
            String ctx = request.getContextPath();
        %>
        <link rel="stylesheet" href="<%= ctx %>/css/admin_account.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Trang quản trị</title>
    </head>
    <body>
        <%
            HttpSession ss = request.getSession(false);

            String username = null;
            String role     = null;

            if (ss != null) {
                username = (String) ss.getAttribute("username");  
                role     = (String) ss.getAttribute("role");      
            }

            boolean isLoggedIn = (username != null);
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
                        <li><a href="<%= ctx %>/admin" class="active">Quản lý tài khoản</a></li>
                        <li><a href="<%= ctx %>/admin_sanpham">Quản lý sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_loaisp">Quản lý loại sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_donhang">Quản lý đơn hàng</a></li>
                        <li><a href="<%= ctx %>/admin_voucher">Quản lý voucher</a></li>
                        <li><a href="<%= ctx %>/admin_km">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>

            <!-- Nội dung chính -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1 id="content-title">Quản lý tài khoản</h1>
                    <p>Quản lý các tài khoản sử dụng website</p>
                </div>
                <div class="table-container">
                    <div class="table-header">
                        <h3><i class="fas fa-list" style="margin-right:8px;"></i>Danh sách tài khoản</h3>
                        <button class="btn-add" onclick="openModal('addUserModal')"> Thêm tài khoản </button>
                    </div>
                    <table>
                        <thead>
                        <tr>
                            <th style="width: 50px;">ID</th>
                            <th style="width: 60px;">Ảnh</th>
                            <th style="width: 120px;">Tên tài khoản</th>
                            <th style="width: 140px;">Họ và tên</th>
                            <th style="width: 100px;">Ngày sinh</th>
                            <th style="width: 160px;">Email</th>
                            <th style="width: 110px;">SĐT</th>
                            <th style="width: 160px;">Địa chỉ</th>
                            <th style="width: 90px;">Vai trò</th>
                            <th style="width: 150px;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            List<Map<String, Object>> accounts =
                                    (List<Map<String, Object>>) request.getAttribute("accounts");
                            String loadError = (String) request.getAttribute("loadError");

                            if (loadError != null) {
                        %>
                        <tr>
                            <td colspan="10" style="color:#b91c1c; background:#fff0f0;">
                                Lỗi tải dữ liệu: <%= loadError %>
                            </td>
                        </tr>
                        <%
                            } else if (accounts == null || accounts.isEmpty()) {
                        %>
                        <tr>
                            <td colspan="10" style="text-align:center;">Không có dữ liệu</td>
                        </tr>
                        <%
                            } else {
                                for (Map<String, Object> row : accounts) {
                                    int id          = (Integer) row.get("id");
                                    String user     = (String) row.get("username");
                                    String hoten    = (String) row.get("hoten");
                                    java.sql.Date ns = (java.sql.Date) row.get("ngaysinh");
                                    String nsStr    = (ns != null) ? ns.toString() : "";
                                    String email    = (String) row.get("tk_email");
                                    String sdt      = (String) row.get("sdt");
                                    String diachi   = (String) row.get("diachi");
                                    String rolev    = (String) row.get("vaitro");
                                    String anh      = (String) row.get("anh");

                                    String avatarSrc =
                                            (anh == null || anh.trim().isEmpty())
                                                    ? (ctx + "/images/no-avatar.png")
                                                    : (ctx + "/images/" + anh);
                        %>
                        <tr>
                            <td><strong><%= id %></strong></td>
                            <td>
                                <img class="avatar" src="<%= avatarSrc %>" width="40" height="40"
                                     onerror="this.onerror=null;this.src='<%= ctx %>/images/no-avatar.png';">
                            </td>
                            <td><strong><%= (user != null ? user : "") %></strong></td>
                            <td><%= (hoten != null ? hoten : "") %></td>
                            <td><%= nsStr %></td>
                            <td><%= (email != null ? email : "") %></td>
                            <td><%= (sdt != null ? sdt : "") %></td>
                            <td><%= (diachi != null ? diachi : "") %></td>
                            <td><%= (rolev != null ? rolev : "") %></td>
                            <td class="action-buttons">
                                <form method="get" action="<%= ctx %>/admin" style="display:inline;">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="btn-edit">
                                        <i class="fas fa-edit"></i> Sửa
                                    </button>
                                </form>
                                <form method="post" action="<%= ctx %>/admin" style="display:inline;"
                                      onsubmit="return confirm('Xóa tài khoản #<%= id %>?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="btn-delete">
                                        <i class="fas fa-trash"></i> Xoá
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                } 
                            } 
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
                        
        <!-- Modal Thêm Tài Khoản -->
        <div id="addUserModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('addUserModal')">&times;</span>
                <h3><i class="fas fa-user-plus"></i> Thêm tài khoản</h3>
                <form action="<%= ctx %>/AdminAccountServlet" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tên tài khoản:</label>
                                <input class="form-control" type="text" name="tendangnhap" required>
                            </div>
                            <div class="form-group">
                                <label>Mật khẩu:</label>
                                <input class="form-control" type="password" name="matkhau" required>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Email:</label>
                                <input class="form-control" type="email" name="email" required>
                            </div>
                            <div class="form-group">
                                <label>Vai trò:</label>
                                <select class="form-control" name="vaitro" required>
                                    <option value="user">Người dùng</option>
                                    <option value="admin">Quản trị viên</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Họ và tên:</label>
                                <input class="form-control" type="text" name="hoten">
                            </div>
                            <div class="form-group">
                                <label>Ngày sinh:</label>
                                <input class="form-control" type="date" name="ngaysinh">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Số điện thoại:</label>
                                <input class="form-control" type="tel" name="sdt">
                            </div>
                            <div class="form-group">
                                <label>Địa chỉ:</label>
                                <input class="form-control" type="text" name="diachi">
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-group">
                        <label>Ảnh đại diện:</label>
                        <div class="image-upload-container">
                            <input type="file" name="anh" class="form-control" 
                                   accept="image/*" onchange="previewImage(this, 'addPreview')">
                            <img id="addPreview" alt="Preview" 
                                 style="max-width:100px;max-height:100px;display:none;border-radius:8px;">
                        </div>
                    </div>
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Thêm tài khoản
                    </button>
                </form>
            </div>
        </div>

        <!-- Modal Sửa tài khoản -->
        <div id="editUserModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('editUserModal')">&times;</span>
                <h3><i class="fas fa-edit"></i> Sửa thông tin tài khoản</h3>
                <form action="<%=ctx%>/admin" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="edit-id">
                    <input type="hidden" name="existingAnh" id="edit-existing-anh">
                    <div class="form-group">
                        <label>Email:</label>
                        <input class="form-control" type="email" name="tk_email" id="edit-tk-email" required>
                    </div>
                    <div class="form-group">
                        <label>Vai trò:</label>
                        <select class="form-control" name="vaitro" id="edit-vaitro">
                            <option value="user">Người dùng</option>
                            <option value="admin">Quản trị viên</option>
                        </select>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Họ và tên:</label>
                                <input class="form-control" type="text" name="hoten">
                            </div>
                            <div class="form-group">
                                <label>Ngày sinh:</label>
                                <input class="form-control" type="date" name="ngaysinh">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Số điện thoại:</label>
                                <input class="form-control" type="tel" name="sdt">
                            </div>
                            <div class="form-group">
                                <label>Địa chỉ:</label>
                                <input class="form-control" type="text" name="diachi">
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-group">
                        <label>Ảnh đại diện:</label>
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

        <script src="<%= ctx %>/javascript/account.js"></script>
        <%
            Map<String, Object> editTarget =
                    (Map<String, Object>) request.getAttribute("editTarget");
            if (editTarget != null) {
                String eId      = String.valueOf(editTarget.get("id"));
                String eEmailTk = (String) editTarget.get("tk_email");
                String eVaitro  = (String) editTarget.get("vaitro");
                String eHoten   = (String) editTarget.get("hoten");
                java.sql.Date eNs = (java.sql.Date) editTarget.get("ngaysinh");
                String eNsStr  = (eNs != null) ? eNs.toString() : "";
                String eSdt    = (String) editTarget.get("sdt");
                String eDiachi = (String) editTarget.get("diachi");
                String eAnh    = (String) editTarget.get("anh");
        %>
        <script>
        (function () {
            var idEl        = document.getElementById("edit-id");
            var emailEl     = document.getElementById("edit-tk-email");
            var roleEl      = document.getElementById("edit-vaitro");
            var nameEl      = document.getElementById("edit-hoten");
            var dobEl       = document.getElementById("edit-ngaysinh");
            var phoneEl     = document.getElementById("edit-sdt");
            var addrEl      = document.getElementById("edit-diachi");
            var existAnhEl  = document.getElementById("edit-existing-anh");

            if (idEl)       idEl.value       = "<%= eId %>";
            if (emailEl)    emailEl.value    = "<%= eEmailTk != null ? eEmailTk : "" %>";
            if (roleEl)     roleEl.value     = "<%= eVaitro  != null ? eVaitro  : "user" %>";
            if (nameEl)     nameEl.value     = "<%= eHoten   != null ? eHoten   : "" %>";
            if (dobEl)      dobEl.value      = "<%= eNsStr %>";
            if (phoneEl)    phoneEl.value    = "<%= eSdt     != null ? eSdt     : "" %>";
            if (addrEl)     addrEl.value     = "<%= eDiachi  != null ? eDiachi  : "" %>";
            if (existAnhEl) existAnhEl.value = "<%= eAnh     != null ? eAnh     : "" %>";

            var imgName  = "<%= eAnh != null ? eAnh : "" %>";
            var preview  = document.getElementById("editPreview");
            var nameSpan = document.getElementById("edit-anh-name");
            if (imgName && preview) {
                var baseUrl = "<%= ctx %>/uploads/avatars/";
                preview.src = baseUrl + imgName;
                preview.style.display = "block";
                if (nameSpan) nameSpan.textContent = imgName;
            }

            var modal = document.getElementById("editUserModal");
            if (modal) modal.style.display = "block";
        })();
        </script>
        <% } %>
    </body>
</html>