<%-- 
    Document   : allnews
    Created on : 10 Nov 2025, 10:26:27 am
    Author     : hathuu24
--%>
<%@ page import="java.util.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%
            String ctx = request.getContextPath();
        %>
        <link rel="stylesheet" href="<%= ctx %>/css/allnews.css?v=1">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Tin tức</title>
    </head>
    <body>
        <%
            HttpSession ss = request.getSession(false);

            boolean isLoggedIn = false;
            String username = null;
            String role = null;

            if (ss != null) {
                Integer userId = (Integer) ss.getAttribute("userId");
                if (userId != null) {
                    isLoggedIn = true;
                    username = (String) ss.getAttribute("username"); 
                    role     = (String) ss.getAttribute("role");   
                }
            }
        %>
        <header>
            <!-- Header -->
            <nav class="container">
                <a href="<%= ctx %>/trangchu" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <a class="icon-btn"
                           href="<%= ctx %>/cart"
                           aria-label="Giỏ hàng"
                           title="Giỏ hàng">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </a>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle"
                               href="#"
                               aria-label="Tài khoản"
                               title="Tài khoản">
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
                                    <a href="<%= ctx %>/profile" class="user-popup-item">
                                        <i class="fa-solid fa-user"></i>
                                        <span>Thông tin cá nhân</span>
                                    </a>
                                    <a href="<%= ctx %>/donhang" class="user-popup-item">
                                        <i class="fa-solid fa-box"></i>
                                        <span>Đơn hàng của bạn</span>
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
            <!-- Dropdown -->
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
                            
        <main class="main">
            <div class="news-container">
                <%
                    @SuppressWarnings("unchecked")
                    List<Map<String,Object>> newsList =
                        (List<Map<String,Object>>) request.getAttribute("newsList");
                    if (newsList != null && !newsList.isEmpty()) {
                        for (Map<String,Object> n : newsList) {
                            String img     = String.valueOf(n.getOrDefault("image", "placeholder-news.jpg"));
                            String title   = String.valueOf(n.getOrDefault("title", "Tiêu đề tin tức"));
                            String excerpt = String.valueOf(n.getOrDefault("excerpt", "Tóm tắt ngắn..."));
                            Number idNum   = (Number) n.get("id");
                            int id         = (idNum != null ? idNum.intValue() : 0);
                            String link    = ctx + "/newsdetail?id=" + id;
                %>
                    <article class="news-card">
                        <a href="<%= link %>" class="news-thumb">
                            <img src="<%= ctx %>/images/<%= img %>" alt="<%= title %>">
                        </a>
                        <div class="news-body">
                            <h3 class="news-title">
                                <a href="<%= link %>"><%= title %></a>
                            </h3>
                            <p class="news-excerpt"><%= excerpt %></p>
                            <a href="<%= link %>" class="read-more">
                                Đọc tiếp <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </article>
                <%
                        }
                    } else {
                %>
                    <div class="news-empty">Hiện chưa có bài viết nào được đăng tải</div>
                <%
                    }
                %>

                <%
                    int pg  = (request.getAttribute("page")       != null) ? (Integer) request.getAttribute("page")       : 1;
                    int sz  = (request.getAttribute("size")       != null) ? (Integer) request.getAttribute("size")       : 12;
                    int tp  = (request.getAttribute("totalPages") != null) ? (Integer) request.getAttribute("totalPages") : 1;
                    String base = ctx + "/all?size=" + sz + "&page=";
                %>
                <% if (tp >= 1) { %>
                    <div class="pager">
                        <a class="p-btn <%= (pg <= 1) ? "disabled" : "" %>"
                           href="<%= (pg <= 1) ? "#" : base + (pg - 1) %>">‹</a>
                        <%
                          int window = 5;
                          int start = Math.max(1, pg - 2);
                          int end   = Math.min(tp, start + window - 1);
                          start     = Math.max(1, end - window + 1);
                          for (int p = start; p <= end; p++) {
                        %>
                          <a class="p-btn <%= (p == pg) ? "active" : "" %>"
                             href="<%= base + p %>"><%= p %></a>
                        <% } %>
                        <a class="p-btn <%= (pg >= tp) ? "disabled" : "" %>"
                           href="<%= (pg >= tp) ? "#" : base + (pg + 1) %>">›</a>
                    </div>
                <% } %>
            </div>
        </main>
            
        <!-- Liên hệ -->      
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact"
               href="<%= ctx %>/contact.jsp"
               title="Liên hệ"
               aria-label="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat"
               href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff"
               target="_blank"
               rel="noopener"
               title="Chatbot"
               aria-label="Chatbot">
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
                    <p><a href="https://maps.app.goo.gl/9VwaAcHsmykw54mj9">Vị trí cửa hàng</a></p>
                </div>
                <div class="footer-contact">
                    <h4>Hỗ trợ</h4>
                    <p><a href="<%= ctx %>/contact.jsp">Liên hệ</a></p>
                    <p>
                        <a href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff">
                            Chatbot tư vấn
                        </a>
                    </p>
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
        <script src="<%= ctx %>/javascript/news.js"></script>
    </body>
</html>
