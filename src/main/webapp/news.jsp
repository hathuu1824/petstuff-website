<%-- 
    Document   : news
    Created on : 29 Oct 2025, 2:29:56 pm
    Author     : hathuu24
--%>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%
            String ctx = request.getContextPath();
        %>
        <link rel="stylesheet" href="<%= ctx %>/css/news.css">
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
                <a href="<%= request.getContextPath() %>/trangchu" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <a class="icon-btn" href="<%= request.getContextPath() %>/cart" aria-label="Giỏ hàng" title="Giỏ hàng">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </a>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle" href="#" aria-label="Tài khoản" title="Tài khoản">
                                <i class="fa-solid fa-user"></i>
                            </a>
                            <div class="user-popup" id="userPopup">
                                <div class="user-popup-header">
                                    <div class="user-popup-avatar">
                                        <img src="<%= request.getContextPath() %>/images/avatar-default.png" alt="Avatar">
                                    </div>
                                    <div class="user-popup-name"><%= username %></div>
                                    <div class="user-popup-role-pill"><%= role %></div>
                                </div>
                                <div class="user-popup-body">
                                    <a href="<%= request.getContextPath() %>/profile" class="user-popup-item">
                                        <i class="fa-solid fa-user"></i>
                                        <span>Thông tin cá nhân</span>
                                    </a>
                                    <a href="<%= request.getContextPath() %>/donhang" class="user-popup-item">
                                        <i class="fa-solid fa-box"></i>
                                        <span>Đơn hàng của bạn</span>
                                    </a>
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
                        <a href="login.jsp" class="home-btn">Đăng nhập</a>
                        <a href="register.jsp" class="home-btn">Đăng ký</a>
                    <% } %>
                </div>
            </nav>
            <!-- Dropdown -->
            <div class="subbar" id="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">
                        <li><a href="<%= request.getContextPath() %>/trangchu">Trang chủ</a></li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button"><a href="<%= request.getContextPath() %>/sanpham">Sản phẩm</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button"><a href="<%= request.getContextPath() %>/bst">Bộ sưu tập</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= request.getContextPath() %>/bst#babythree">Baby Three</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#capybara">Capybara</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#doraemon">Doraemon</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#sanrio">Sanrio</a></li>
                            </ul>
                        </li>
                        <li><a href="<%= request.getContextPath() %>/giamgia">Khuyến mại</a></li>
                        <li><a href="<%= request.getContextPath() %>/tintuc">Tin tức</a></li>
                    </ul>
                </nav>
            </div>    
        </header> 
                            
        <main class="main">
            <!-- ===== Tin nổi bật ===== -->
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
                                       String img   = String.valueOf(s.getOrDefault("image","placeholder-hero.jpg"));
                                       String title = String.valueOf(s.getOrDefault("title","Tin nổi bật " + (i+1)));
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

                <!-- 2 tin nổi bật bên phải -->
                <div class="hot-news">
                    <%
                        List<Map<String,Object>> hotNews =
                            (List<Map<String,Object>>) request.getAttribute("hotNews");
                        if (hotNews != null && !hotNews.isEmpty()) {
                            for (Map<String,Object> n : hotNews) {
                                Number idNum = (Number) n.get("id");
                                int id       = (idNum != null ? idNum.intValue() : 0);

                                String img     = String.valueOf(n.getOrDefault("image","placeholder-news.jpg"));
                                String title   = String.valueOf(n.getOrDefault("title","Tiêu đề tin"));
                                String excerpt = String.valueOf(n.getOrDefault("excerpt","Mô tả ngắn..."));

                                // Link sang servlet chi tiết /newsdetail
                                String link    = ctx + "/newsdetail?id=" + id;
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

            <!-- ===== Tất cả tin tức ===== -->
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
                            String img     = String.valueOf(n.getOrDefault("image", "placeholder-news.jpg"));
                            String title   = String.valueOf(n.getOrDefault("title", "Tiêu đề tin tức"));
                            String excerpt = String.valueOf(n.getOrDefault("excerpt", "Tóm tắt ngắn..."));
                            int    id      = ((Number)n.get("id")).intValue();

                            String detailLink = ctx + "/newsdetail?id=" + id;   // dùng servlet /newsdetail
                %>
                    <article class="news-card">
                        <a href="<%= detailLink %>" class="news-thumb">
                            <img src="<%= ctx %>/images/<%= img %>" alt="<%= title %>">
                        </a>

                        <!-- Giữ .news-body để khớp CSS cũ -->
                        <div class="news-body">
                            <h3 class="news-title">
                                <a href="<%= detailLink %>"><%= title %></a>
                            </h3>
                            <p class="news-excerpt"><%= excerpt %></p>
                            <a href="<%= detailLink %>" class="read-more">
                                Đọc tiếp <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </article>
                <%
                        }
                    } else {
                %>
                    <div class="news-empty">
                        Hiện chưa có bài viết nào được đăng tải
                    </div>
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
                    <p><a href="<%= ctx %>/contact.jsp">Liên hệ</a></p>
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

        <script src="<%= ctx %>/javascript/news.js"></script>                      
    </body>
</html>
