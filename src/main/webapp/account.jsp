<%-- 
    Document   : account
    Created on : 24 Oct 2025, 8:10:21 am
    Author     : hathuu24
--%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="webnhoibong.DatabaseConnection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String fullName = (String) request.getAttribute("full_name");
    String email    = (String) request.getAttribute("email");
    java.sql.Date dobSql = (java.sql.Date) request.getAttribute("dob");
    String dob = dobSql == null ? "" : dobSql.toString();    
    String phone   = (String) request.getAttribute("phone");
    String address = (String) request.getAttribute("address");
    String avatar  = (String) request.getAttribute("avatar_path");
    String avatarSrc = (avatar == null || avatar.isBlank())
        ? (ctx + "/images/ava.jfif")
        : avatar;
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/account.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Thông tin tài khoản</title>
    </head>
    <body>
        <%
            Boolean isLoggedIn = (Boolean) request.getAttribute("isLoggedIn");
            String username = (String) request.getAttribute("username");
            if (isLoggedIn == null) {
                isLoggedIn = false;
            }
        %>
        <header>
            <!-- Header -->
            <nav class="container">
                <a href="<%= request.getContextPath() %>/trangchu" id="logo">PetStuff</a>
                <div class="buttons">
                    <a class="icon-btn" href="<%= request.getContextPath() %>/cart.jsp" aria-label="Giỏ hàng" title="Giỏ hàng">
                        <i class="fa-solid fa-cart-shopping"></i>
                    </a>
                    <a class="icon-btn" href="<%= request.getContextPath() %>/AccountServlet" aria-label="Tài khoản" title="Tài khoản">
                        <i class="fa-solid fa-user"></i>
                    </a>
                    <% if (isLoggedIn) { %>
                        <span class="home">Xin chào, <%= username %>!</span>
                        <a href="<%= request.getContextPath() %>/dangxuat" class="home-btn">Đăng xuất</a>
                    <% } else { %>
                        <a href="login.jsp" class="home-btn">Đăng nhập</a>
                        <a href="register.jsp" class="home-btn">Đăng ký</a>
                    <% } %>
                </div>
            </nav>
            <!-- Dropdown -->
            <div class="subbar" id="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">
                        <li><a href="trangchu">Trang chủ</a></li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button">Sản phẩm</button>
                            <ul class="dropdown">
                                <li><a href="sanpham">Tất cả sản phẩm</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button">Bộ sưu tập</button>
                            <ul class="dropdown">
                                <li><a href="#">Baby Three</a></li>
                                <li><a href="#">Doraemon</a></li>
                                <li><a href="#">Sanrio</a></li>
                            </ul>
                        </li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button">Quà tặng</button>
                            <ul class="dropdown">
                                <li><a href="#">Khuyến mại</a></li>
                                <li><a href="#">Set quà tặng</a></li>
                            </ul>
                        </li>
                        <li><a href="#">Tin tức</a></li>
                    </ul>
                </nav>
            </div>    
        </header> 

        <main class="main">
            <div class="wrap">
                <div class="layout">
                    <!-- Sidebar -->
                    <aside class="aside">
                        <div class="aside-hd">
                            <img class="avatar" src="<%= (avatar==null||avatar.isBlank()) ? (ctx + "/images/avatar-placeholder.png") : avatar %>" alt="avatar">
                            <div>
                                <div class="acc-name"><%= accUsername.isEmpty()? "Tài khoản" : accUsername %></div>
                                <a class="edit-link" href="javascript:void(0)">Sửa hồ sơ</a>
                            </div>
                        </div>
                        <ul class="aside-nav">
                            <li><a class="active" href="<%= ctx %>/AccountServlet"><i class="fa-regular fa-user"></i> Hồ sơ</a></li>
                            <li><a href="javascript:void(0)"><i class="fa-regular fa-map"></i> Địa chỉ</a></li>
                            <li><a href="javascript:void(0)"><i class="fa-solid fa-shield-halved"></i> Bảo mật</a></li>
                            <li><a href="javascript:void(0)"><i class="fa-regular fa-bell"></i> Thông báo</a></li>
                        </ul>
                    </aside>
                    <!-- Hồ sơ -->
                    <section class="card">
                        <div class="card-hd">
                            <h1>Hồ sơ của tôi</h1>
                            <p>Quản lý thông tin hồ sơ để bảo mật tài khoản</p>
                        </div>
                        <form class="form-area" method="post" action="<%= ctx %>/AccountServlet" enctype="multipart/form-data">
                            <div>
                                <div class="form-table">
                                    <div class="label">Tên đăng nhập</div>
                                    <div class="val">
                                        <input type="text" name="username" value="<%= accUsername %>" readonly>
                                    </div>
                                    <div class="label">Họ và tên</div>
                                    <div class="val">
                                        <input type="text" name="fullname" value="<%= fullName==null? "" : fullName %>" placeholder="Nhập họ và tên">
                                    </div>
                                    <div class="label">Email</div>
                                    <div class="val">
                                        <input type="email" name="email" value="<%= email==null? "" : email %>" placeholder="Email">
                                        <div class="hint">Email dùng để đăng nhập & nhận thông báo</div>
                                    </div>
                                    <div class="label">Số điện thoại</div>
                                    <div class="val">
                                        <input type="tel" name="phone" value="<%= phone==null? "" : phone %>" placeholder="Số điện thoại">
                                    </div>
                                    <div class="label">Ngày sinh</div>
                                    <div class="val">
                                        <input type="date" name="dob" value="<%= dob %>">
                                    </div>
                                    <div class="label">Địa chỉ</div>
                                    <div class="val">
                                      <input type="text" name="address" value="<%= address==null? "" : address %>" placeholder="Địa chỉ nhận hàng">
                                    </div>
                                </div>
                            </div>
                            <!-- Avatar -->
                            <div class="avatar-box">
                                <img id="avatarPreview" class="avatar-lg"
                                     src="<%= (avatar==null||avatar.isBlank()) ? (ctx + "/images/avatar-placeholder.png") : avatar %>"
                                     alt="Ảnh đại diện">
                                <label class="btn">
                                    <input id="avatarInput" type="file" name="avatar" accept="image/*" style="display:none;">
                                    Chọn Ảnh
                                </label>
                                <div class="hint" style="text-align:center">
                                    Dung lượng tối đa 1MB<br/>Định dạng: JPG, PNG
                                </div>
                            </div>
                            <div class="actions">
                                <button type="submit" class="btn btn-primary">Lưu</button>
                            </div>
                        </form>
                    </section>
                </div>
            </div>
        </main>

        <% String ctx = request.getContextPath(); %>
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="<%= ctx %>/lienhe.jsp" title="Liên hệ" aria-label="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat" href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff" target="_blank" rel="noopener" title="Chatbot" aria-label="Chatbot">
                <i class="fa-regular fa-comments"></i>
            </a>
        </div>

        <!-- Footer -->        
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
                    <p><a href="#">Điều khoản dịch vụ</a></p>
                </div>
                <div class="footer-contact">
                    <h4>Hỗ trợ</h4>
                    <p><a href="#">Liên hệ</a></p>
                    <p><a href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff">Chatbot tư vấn</a></p>
                </div>
                <div class="footer-social">
                    <h4>Theo dõi</h4>
                    <div class="social">
                        <a href="https://www.facebook.com" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                        <a href="https://www.tiktok.com" aria-label="TikTok"><i class="fab fa-tiktok"></i></a>
                        <a href="https://www.instagram.com" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                        <a href="https://www.twitter.com" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>Copyright &copy; 2025</p>
            </div>
        </footer>
    </body>
</html>
