<%-- 
    Document   : news
    Created on : 29 Oct 2025, 2:29:56 pm
    Author     : hathuu24
--%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="webnhoibong.DatabaseConnection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%
            String ctx = request.getContextPath();
        %>
        <link rel="stylesheet" href="<%= ctx %>/css/news.css?v=1">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Tin tức</title>
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
                            <button class="dd-toggle" type="button"><a href="sanpham">Sản phẩm</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button"><a href="bst">Bộ sưu tập</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= request.getContextPath() %>/bst#babythree">Baby Three</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#capybara">Capybara</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#doraemon">Doraemon</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#sanrio">Sanrio</a></li>
                            </ul>
                        </li>
                        <li><a href="giamgia">Khuyến mại</a></li>
                        <li><a href="tintuc">Tin tức</a></li>
                    </ul>
                </nav>
            </div>    
        </header>
                            
        <main class="main">
            <div class="hotnews-title">
                <h2>Tin nổi bật</h2>
            </div>
            <div class="hotnews-container">
                <div class="slider">
                    <section class="background">
                        <%
                            List<Map<String,Object>> slides = 
                                (List<Map<String,Object>>) request.getAttribute("slides");
                            if (slides == null) slides = java.util.Collections.emptyList();
                        %>
                            <div class="hero-slider" id="hero">
                            <% if (!slides.isEmpty()) { %>
                                <% for (int i = 0; i < slides.size(); i++) {
                                     Map<String,Object> s = slides.get(i);
                                     String img = String.valueOf(s.getOrDefault("image", "placeholder-hero.jpg"));
                                     String title = String.valueOf(s.getOrDefault("title", "Tin nổi bật " + (i+1)));
                                %>
                                    <div class="slide <%= (i==0 ? "is-active" : "") %>">
                                        <img src="<%= ctx %>/images/<%= img %>" alt="<%= title %>">
                                        <div class="slide-caption">
                                            <h3><%= title %></h3>
                                        </div>
                                    </div>
                                <% } %>
                                <button class="hero-nav prev" aria-label="Trước">‹</button>
                                <button class="hero-nav next" aria-label="Tiếp">›</button>
                                <div class="dots">
                                    <% for (int i = 0; i < slides.size(); i++) { %>
                                        <button class="dot <%= (i==0 ? "active" : "") %>" data-index="<%= i %>"></button>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="slide is-active">
                                    <img src="<%= ctx %>/images/placeholder-hero.jpg" alt="placeholder">
                                    <div class="slide-caption">
                                        <h3>Đang cập nhật tin nổi bật...</h3>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </section>
                </div>
                <div class="hot-news">
                    <%
                        @SuppressWarnings("unchecked")
                        List<Map<String,Object>> hotNews =
                            (List<Map<String,Object>>) request.getAttribute("hotNews");
                        if (hotNews != null && !hotNews.isEmpty()) {
                          int limit = Math.min(2, hotNews.size());
                          for (int i = 0; i < limit; i++) {
                            Map<String,Object> n = hotNews.get(i);
                            String img = String.valueOf(n.getOrDefault("image","placeholder-news.jpg"));
                            String title = String.valueOf(n.getOrDefault("title","Tiêu đề tin"));
                            String excerpt = String.valueOf(n.getOrDefault("excerpt","Mô tả ngắn..."));
                            String link = String.valueOf(n.getOrDefault("link","#"));
                    %>
                    <article class="hot-card">
                        <a href="<%= link %>">
                            <img src="<%= ctx %>/images/<%= img %>" alt="<%= title %>">
                            <div class="hc-body">
                                <h3 class="hc-title"><%= title %></h3>
                                <p class="hc-excerpt"><%= excerpt %></p>
                            </div>
                        </a>
                    </article>
                    <%
                            }
                        } else {
                    %>
                        <div class="hot-empty">Đang cập nhật tin nổi bật</div>
                    <%
                      }
                    %>
                </div>
            </div>

            <div class="news-container">
                <div class="allnews-title">
                    <h2>Tất cả tin tức</h2>
                    <a href="all" class="view-btn">Xem tất cả</a>
                </div>
                <%
                    @SuppressWarnings("unchecked")
                    List<Map<String,Object>> newsList =
                        (List<Map<String,Object>>) request.getAttribute("newsList");
                    if (newsList != null && !newsList.isEmpty()) {
                      for (Map<String,Object> n : newsList) {
                        String img = String.valueOf(n.getOrDefault("image", "placeholder-news.jpg"));
                        String title = String.valueOf(n.getOrDefault("title", "Tiêu đề tin tức"));
                        String excerpt = String.valueOf(n.getOrDefault("excerpt", "Tóm tắt ngắn..."));
                        String link = String.valueOf(n.getOrDefault("link", "#"));
                %>
                    <article class="news-card">
                        <a href="<%= link %>" class="news-thumb">
                            <img src="<%= request.getContextPath() %>/images/<%= img %>" alt="<%= title %>">
                        </a>
                        <div class="news-body">
                            <h3 class="news-title"><a href="<%= link %>"><%= title %></a></h3>
                            <p class="news-excerpt"><%= excerpt %></p>
                            <a href="<%= link %>" class="read-more">Đọc tiếp <i class="fa-solid fa-arrow-right"></i></a>
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
            </div>
        </main>
                               
        <!-- Liên hệ -->      
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="<%= ctx %>/contact.jsp" title="Liên hệ" aria-label="Liên hệ">
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
                    <p><a href="https://maps.app.goo.gl/9VwaAcHsmykw54mj9">Vị trí cửa hàng</a></p>
                </div>
                <div class="footer-contact">
                    <h4>Hỗ trợ</h4>
                    <p><a href="contact.jsp">Liên hệ</a></p>
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
        <script src="javascript/news.js"></script>                      
    </body>
</html>
