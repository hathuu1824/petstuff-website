<%-- 
    Document   : gift
    Created on : 29 Oct 2025, 10:38:05 am
    Author     : hathuu24
--%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/discount.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Quà tặng</title>
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
                        <li><a href="discount">Khuyến mại</a></li>
                        <li><a href="#">Tin tức</a></li>
                    </ul>
                </nav>
            </div>    
        </header> 
                            
        <main class="main">
            <!-- Banner -->
            <div class="banner">
                <% String ctx = request.getContextPath(); %>
                <img src="<%= ctx %>/images/gift.png" alt="Banner" />
            </div>
            
            <!-- Voucher -->
            <section class="voucher-wrap">
                <h1 class="heading">VOUCHER</h1>
                <div class="voucher-list" id="voucherList">
                    <%
                        List<Map<String,Object>> vouchers =
                          (List<Map<String,Object>>) request.getAttribute("vouchers");
                        if (vouchers != null && !vouchers.isEmpty()) {
                          for (Map<String,Object> v : vouchers) {
                            String loai = (String) v.get("loai");
                            String ma   = (String) v.get("ma");
                            boolean badge = Boolean.TRUE.equals(v.get("badge"));
                    %>
                        <article class="coupon">
                            <div class="coupon-left">
                                <h3 class="coupon-title"><%= v.get("title") %></h3>
                                <p class="coupon-sub"><%= v.get("sub") %></p>
                                <p class="coupon-exp"><%= v.get("exp") %></p>
                            </div>
                            <div class="coupon-sep"></div>
                            <div class="coupon-right">
                              <% if ("NHAP_MA".equals(loai)) { %>
                                    <button class="btn-save" type="button"><%= (ma == null ? "NHẬP MÃ" : ma) %></button>
                              <% } else { %>
                                    <form method="post" action="<%= request.getContextPath() %>/claim-voucher">
                                        <input type="hidden" name="id" value="<%= v.get("id") %>">
                                        <button class="btn-save" type="submit">Lưu</button>
                                    </form>
                              <% } %>
                              <% if (badge) { %>
                                    <span class="badge-outline">Sản phẩm nhất định</span>
                              <% } %>
                            </div>
                            <span class="coupon-edge left"></span>
                            <span class="coupon-edge right"></span>
                        </article>
                    <%
                            } 
                        } 
                    %>
                </div>
                <div class="button-container">
                    <a href="#" class="view-btn">Xem tất cả</a>
                </div>
            </section>
            
            <!-- Khuyến mại -->
            <div class="discount-container">
                <h1 class="heading">KHUYẾN MẠI</h1>
                <%
                    java.util.List<java.util.Map<String,Object>> promos =
                        (java.util.List<java.util.Map<String,Object>>) request.getAttribute("promos");
                %>

                <div class="promo-slider" id="promoSlider">
                    <%
                        if (promos != null && !promos.isEmpty()) {
                            for (java.util.Map<String,Object> p : promos) {
                                String img = (String) p.get("image");   
                                String cap = (String) p.get("caption");  
                                String link = (String) p.get("link");    
                                String alt  = (cap != null && !cap.isEmpty()) ? cap : "Khuyến mại";
                    %>
                        <div class="promo-item">
                            <% if (link != null && !link.isEmpty()) { %>
                                <a href="<%= link %>">
                                    <img src="<%= ctx %>/images/<%= img %>" alt="<%= alt %>">
                                </a>
                            <% } else { %>
                                <img src="<%= ctx %>/images/<%= img %>" alt="<%= alt %>">
                            <% } %>

                            <% if (cap != null && !cap.isEmpty()) { %>
                                <h2 class="promo-caption"><%= cap %></h2>
                            <% } %>
                        </div>
                    <%
                            }
                        } else {
                    %>
                        <div class="promo-item">
                            <img src="<%= ctx %>/images/promo1.jpg" alt="Khuyến mại">
                            <h2 class="promo-caption">Ưu đãi đang cập nhật</h2>
                        </div>
                    <%
                        }
                    %>
                </div>
                <button class="p-nav p-prev" type="button" aria-label="Prev">‹</button>
                <button class="p-nav p-next" type="button" aria-label="Next">›</button>
                <div class="button-container">
                    <a href="#" class="view-btn">Xem tất cả</a>
                </div>
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
        <script src="javascript/discount.js"></script>
    </body>
</html>
