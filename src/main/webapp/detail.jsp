<%-- 
    Document   : extent
    Created on : 20 Sept 2025, 3:03:50 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/detail.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Chi tiết sản phẩm</title>
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
                    <a class="icon-btn" href="<%= request.getContextPath() %>/account.jsp" aria-label="Tài khoản" title="Tài khoản">
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
                                <li><a href="#">Chăn gối hình thú</a></li>
                                <li><a href="#">Móc khóa</a></li>
                                <li><a href="#">Thú nhồi bông</a></li>
                                <li><a href="#">Khác</a></li>
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
            <% 
                String ctx = request.getContextPath();
            %>
        </main>
                    
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="<%= ctx %>/lienhe.jsp" title="Liên hệ" aria-label="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat" href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff" target="_blank" rel="noopener" title="Chatbot" aria-label="Chatbot">
                <i class="fa-regular fa-comments"></i>
            </a>
        </div>            
  
        <footer>
            <div class="footer-container">
                <div class="social-link">
                    <a href="https://www.facebook.com"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-facebook-messenger"></i></a>
                    <a href="https://www.twitter.com"><i class="fab fa-twitter"></i></a>
                    <a href="https://myaccount.google.com"><i class="fab fa-google"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                </div>
                <div class="footer-nav">
                    <ul>
                        <li><a href="trangchu">Trang chủ</a></li>
                        <li><a href="sanpham">Sản phẩm</a></li>
                        <li><a href="help.html">Trợ giúp</a></li>
                        <li><a href="contact.html">Liên hệ</a></li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p>Copyright &copy; 2025</p>
            </div>
        </footer>
        <script src="javascript/home.js"></script>    
    </body>
</html>
