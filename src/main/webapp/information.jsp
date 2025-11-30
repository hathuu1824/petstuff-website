<%-- 
    Document   : information
    Created on : 24 Nov 2025
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();

    // ===== Kiểm tra đăng nhập =====
    HttpSession ss = request.getSession(false);

    boolean isLoggedIn   = false;
    Integer userId       = null;
    String  username     = null;
    String  roleSession  = null;

    if (ss != null) {
        userId      = (Integer) ss.getAttribute("userId");
        username    = (String)  ss.getAttribute("username");
        roleSession = (String)  ss.getAttribute("role");

        if (userId != null) {
            isLoggedIn = true;
        }
    }

    if (!isLoggedIn) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // ===== Dữ liệu hồ sơ lấy từ InfoServlet (doGet đã setAttribute) =====
    String fullName  = (String) request.getAttribute("fullName");
    String dobStr    = (String) request.getAttribute("dobStr");
    String phone     = (String) request.getAttribute("phone");
    String address   = (String) request.getAttribute("address");
    String imagePath = (String) request.getAttribute("imagePath");
    String email     = (String) request.getAttribute("email");
    String roleLabel = (String) request.getAttribute("roleLabel");

    // Fallback nếu servlet chưa set roleLabel thì lấy từ session
    if (roleLabel == null || roleLabel.trim().isEmpty()) {
        roleLabel = (roleSession != null ? roleSession : "");
    }

    if (fullName == null)  fullName  = "";
    if (dobStr   == null)  dobStr    = "";
    if (phone    == null)  phone     = "";
    if (address  == null)  address   = "";
    if (imagePath== null)  imagePath = "";
    if (email    == null)  email     = "";
    if (roleLabel== null)  roleLabel = "";

    // ===== Xác định có phải admin không =====
    boolean isAdmin = false;
    if (!roleLabel.isEmpty()) {
        String rl = roleLabel.trim().toLowerCase();
        isAdmin = rl.equals("admin") || rl.equals("administrator") || rl.equals("role_admin");
    }

    // Đường dẫn ảnh đại diện hiển thị
    String avatarUrl = (imagePath != null && !imagePath.isEmpty())
                        ? (ctx + "/" + imagePath)
                        : (ctx + "/images/avatar-default.png");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Thông tin cá nhân</title>
        <link rel="stylesheet" href="<%= ctx %>/css/information.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <!-- ================= HEADER ================= -->
        <header>
            <nav class="container">
                <a href="<%= ctx %>/trangchu" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <% if (!isAdmin) { %>
                            <a class="icon-btn" href="<%= ctx %>/cart"
                               aria-label="Giỏ hàng" title="Giỏ hàng">
                                <i class="fa-solid fa-cart-shopping"></i>
                            </a>
                        <% } %>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle" href="#"
                               aria-label="Tài khoản" title="Tài khoản">
                                <i class="fa-solid fa-user"></i>
                            </a>
                            <div class="user-popup" id="userPopup">
                                <div class="user-popup-header">
                                    <div class="user-popup-avatar">
                                        <img src="<%= ctx %>/images/avatar-default.png" alt="Avatar">
                                    </div>
                                    <div class="user-popup-name"><%= username %></div>
                                    <div class="user-popup-role-pill"><%= roleLabel %></div>
                                </div>
                                <div class="user-popup-body">
                                    <a href="<%= ctx %>/profile" class="user-popup-item">
                                        <i class="fa-solid fa-user"></i>
                                        <span>Thông tin cá nhân</span>
                                    </a>
                                    <% if (isAdmin) { %>
                                        <a href="<%= ctx %>/admin_donhang" class="user-popup-item">
                                            <i class="fa-solid fa-screwdriver-wrench"></i>
                                            <span>Quản lý hệ thống</span>
                                        </a>
                                    <% } else { %>
                                        <a href="<%= ctx %>/donhang" class="user-popup-item">
                                            <i class="fa-solid fa-box"></i>
                                            <span>Đơn hàng của bạn</span>
                                        </a>
                                    <% } %>
                                </div>
                                <div class="user-popup-footer">
                                    <a href="<%= request.getContextPath() %>/dangxuat" class="home-btn logout-btn">
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

            <!-- Thanh menu phụ -->
            <div class="subbar" id="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">
                        <li><a href="<%= ctx %>/trangchu">Trang chủ</a></li>

                        <li class="has-dd">
                            <button class="dd-toggle" type="button">
                                <a href="<%= ctx %>/sanpham">Sản phẩm</a>
                            </button>
                            <ul class="dropdown">
                                <li><a href="<%= ctx %>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%= ctx %>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%= ctx %>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%= ctx %>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>

                        <li class="has-dd">
                            <button class="dd-toggle" type="button">
                                <a href="<%= ctx %>/bst">Bộ sưu tập</a>
                            </button>
                            <ul class="dropdown">
                                <li><a href="<%= ctx %>/bst#babythree">Baby Three</a></li>
                                <li><a href="<%= ctx %>/bst#capybara">Capybara</a></li>
                                <li><a href="<%= ctx %>/bst#doraemon">Doraemon</a></li>
                                <li><a href="<%= ctx %>/bst#sanrio">Sanrio</a></li>
                            </ul>
                        </li>

                        <li><a href="<%= ctx %>/giamgia">Khuyến mại</a></li>
                        <li><a href="<%= ctx %>/tintuc">Tin tức</a></li>
                    </ul>
                </nav>
            </div>
        </header>

        <!-- ================= MAIN ================= -->
        <main class="main">
            <div class="profile-container">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <img id="avatar-img" src="<%= avatarUrl %>" alt="Ảnh đại diện">
                        <div class="avatar-overlay">
                            <i class="fas fa-camera"></i>
                        </div>
                    </div>
                    <h2>Thông Tin Cá Nhân</h2>
                </div>

                <form class="profile-form"
                      method="POST"
                      action="<%= ctx %>/profile"
                      enctype="multipart/form-data">

                    <div class="form-grid">
                        <!-- Hàng 1: Tài khoản + Vai trò (readonly) -->
                        <div class="form-group">
                            <label for="usernameDisplay">
                                <i class="fas fa-id-badge"></i> Tài khoản
                            </label>
                            <input type="text"
                                   id="usernameDisplay"
                                   value="<%= (username != null ? username : "") %>"
                                   readonly disabled>
                        </div>

                        <div class="form-group">
                            <label for="roleDisplay">
                                <i class="fas fa-user-shield"></i> Vai trò
                            </label>
                            <input type="text"
                                   id="roleDisplay"
                                   value="<%= roleLabel %>"
                                   readonly disabled>
                        </div>

                        <!-- Hàng 2: Họ tên + Email -->
                        <div class="form-group">
                            <label for="fullname">
                                <i class="fas fa-user"></i> Họ và tên
                            </label>
                            <input type="text"
                                   id="fullname"
                                   name="fullname"
                                   value="<%= fullName %>"
                                   placeholder="Nhập họ và tên">
                        </div>

                        <div class="form-group">
                            <label for="email">
                                <i class="fas fa-envelope"></i> Email
                            </label>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   value="<%= email %>"
                                   placeholder="Nhập email">
                        </div>

                        <!-- Hàng 3: Ngày sinh + SĐT -->
                        <div class="form-group">
                            <label for="dob">
                                <i class="fas fa-birthday-cake"></i> Ngày sinh
                            </label>
                            <input type="date"
                                   id="dob"
                                   name="dob"
                                   value="<%= dobStr %>">
                        </div>

                        <div class="form-group">
                            <label for="phone">
                                <i class="fas fa-phone"></i> Số điện thoại
                            </label>
                            <input type="tel"
                                   id="phone"
                                   name="phone"
                                   value="<%= phone %>"
                                   placeholder="Nhập số điện thoại">
                        </div>

                        <!-- Hàng 4: Địa chỉ -->
                        <div class="form-group full-width">
                            <label for="address">
                                <i class="fas fa-map-marker-alt"></i> Địa chỉ
                            </label>
                            <input type="text"
                                   id="address"
                                   name="address"
                                   value="<%= address %>"
                                   placeholder="Nhập địa chỉ">
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn-toggle">
                            <i class="fas fa-edit"></i> Thêm/Chỉnh sửa
                        </button>
                    </div>

                    <input type="file" id="avatar" name="avatar" accept="image/*" style="display:none;">
                </form>
            </div>
        </main>

        <!-- ================= FLOATING CONTACT ================= -->
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="<%= ctx %>/contact.jsp"
               title="Liên hệ" aria-label="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat"
               href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff"
               target="_blank" rel="noopener"
               title="Chatbot" aria-label="Chatbot">
                <i class="fa-regular fa-comments"></i>
            </a>
        </div>

        <!-- ================= FOOTER ================= -->
        <footer>
            <div class="footer-container">
                <div class="footer-infor">
                    <h4>PetStuff</h4>
                    <p>Địa chỉ: 68 Nguyễn Chí Thanh, Láng Thượng, Đống Đa, Hà Nội</p>
                    <p>Điện thoại: +84 23 4597 6688</p>
                    <p>Email: petstuff6688@hotmail.com</p>
                </div>
                <div class="footer-about">
                    <h4>Về chúng tôi</h4>
                    <p><a href="#">Giới thiệu</a></p>
                    <p><a href="https://maps.app.goo.gl/9VwaAcHsmykw54mj9">Vị trí cửa hàng</a></p>
                </div>
                <div class="footer-contact">
                    <h4>Hỗ trợ</h4>
                    <p><a href="<%= ctx %>/contact.jsp">Liên hệ</a></p>
                    <p><a href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff">Chatbot tư vấn</a></p>
                </div>
                <div class="footer-social">
                    <h4>Theo dõi</h4>
                    <div class="social">
                        <a href="https://www.facebook.com" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                        <a href="https://www.tiktok.com"   aria-label="TikTok"><i class="fab fa-tiktok"></i></a>
                        <a href="https://www.instagram.com" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                        <a href="https://www.twitter.com"  aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>Copyright &copy; 2025</p>
            </div>
        </footer>

        <!-- ================= JS ================= -->
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const form        = document.querySelector('.profile-form');
                const toggleBtn   = form.querySelector('.btn-toggle');
                const textInputs  = form.querySelectorAll('#fullname, #email, #dob, #phone, #address');
                const avatarWrap  = document.querySelector('.profile-avatar');
                const avatarInput = document.getElementById('avatar');
                const avatarImg   = document.getElementById('avatar-img');

                // Mặc định: khóa các trường chỉnh sửa
                textInputs.forEach(i => i.disabled = true);
                avatarInput.disabled = true;

                let editing = false;

                // Khi đang chỉnh sửa mới cho click để chọn ảnh
                avatarWrap.addEventListener('click', () => {
                    if (editing) {
                        avatarInput.click();
                    }
                });

                avatarInput.addEventListener('change', e => {
                    if (e.target.files && e.target.files[0]) {
                        const reader = new FileReader();
                        reader.onload = ev => {
                            avatarImg.src = ev.target.result;
                            avatarWrap.style.transform = 'scale(1.06)';
                            setTimeout(() => avatarWrap.style.transform = 'scale(1)', 220);
                        };
                        reader.readAsDataURL(e.target.files[0]);
                    }
                });

                // Nút Thêm/Chỉnh sửa
                toggleBtn.addEventListener('click', e => {
                    e.preventDefault();

                    if (!editing) {
                        editing = true;
                        textInputs.forEach(i => i.disabled = false);
                        avatarInput.disabled = false;
                        toggleBtn.innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
                        toggleBtn.classList.add('saving-mode');
                        if (textInputs.length > 0) textInputs[0].focus();
                    } else {
                        editing = false;
                        form.submit();
                    }
                });

                // Popup user ở icon tài khoản
                const userMenu   = document.querySelector('.user-menu');
                const userToggle = document.querySelector('.user-toggle');

                if (userMenu && userToggle) {
                    userToggle.addEventListener('click', (ev) => {
                        ev.preventDefault();
                        ev.stopPropagation();
                        userMenu.classList.toggle('open');
                    });

                    document.addEventListener('click', (ev) => {
                        if (!userMenu.contains(ev.target)) {
                            userMenu.classList.remove('open');
                        }
                    });

                    window.addEventListener('keydown', (ev) => {
                        if (ev.key === 'Escape') {
                            userMenu.classList.remove('open');
                        }
                    });
                }
            });
        </script>
    </body>
</html>
