<%-- 
    Document   : introduction
    Created on : 3 Dec 2025, 10:36:39 am
    Author     : hathuu24
--%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="webnhoibong.DatabaseConnection" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="<%= ctx %>/css/introduction.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Trang chủ</title>
    </head>
    <body>
        <%
            HttpSession ss = request.getSession(false);

            boolean isLoggedIn = false;
            String username = null;
            String role = null;
            String avatarFile = null; 

            if (ss != null) {
                Integer userId = (Integer) ss.getAttribute("userId");
                if (userId != null) {
                    isLoggedIn = true;
                    username = (String) ss.getAttribute("username"); 
                    role     = (String) ss.getAttribute("role");  
                    avatarFile = (String) ss.getAttribute("avatarPath"); 
                }
            }
            
            String avatarUrl;
            if (avatarFile == null || avatarFile.trim().isEmpty()) {
                avatarUrl = ctx + "/images/avatar-default.png";
            } else {
                avatarUrl = ctx + "/images/" + avatarFile;
            }
        %>
        <header>
            <!-- Header -->
            <nav class="container">
                <a href="<%= ctx %>/trangchu" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <a class="icon-btn" href="<%= ctx %>/cart" aria-label="Giỏ hàng" title="Giỏ hàng">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </a>
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
                            <button class="dd-toggle" type="button"><a href="<%= ctx %>/sanpham">Sản phẩm</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%= request.getContextPath() %>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>
                        <li class="has-dd">
                            <button class="dd-toggle" type="button"><a href="<%= ctx %>/bst">Bộ sưu tập</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= request.getContextPath() %>/bst#babythree">Baby Three</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#capybara">Capybara</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#doraemon">Doraemon</a></li>
                                <li><a href="<%= request.getContextPath() %>/bst#sanrio">Sanrio</a></li>
                            </ul>
                        </li>
                        <li><a href="<%= ctx %>/giamgia">Khuyến mại</a></li>
                        <li><a href="<%= ctx %>/tintuc">Tin tức</a></li>
                    </ul>
                </nav>
            </div>    
        </header> 
                    
        <main class="main">
            <div class="intro-container">
                <h1 class="page-title">Giới thiệu về PetStuff</h1>
                <p class="page-subtitle">
                    Nơi gửi gắm những chiếc gấu bông và phụ kiện dễ thương đến tận tay khách hàng
                </p>
                <div class="about-grid">
                    <div class="about-text">
                        <p>
                            PetStuff được thành lập với mong muốn mang đến những sản phẩm mềm mại, an toàn và đáng yêu
                            dành cho mọi lứa tuổi. Từ những chiếc gấu bông kinh điển cho tới các mẫu thú nhồi bông độc đáo,
                            tụi mình luôn cố gắng chọn lọc kỹ về chất liệu và thiết kế.
                        </p>
                        <p>
                            Không chỉ dừng lại ở việc bán sản phẩm, PetStuff muốn trở thành một người bạn nhỏ đồng hành cùng bạn
                            trong những khoảnh khắc thư giãn, làm quà tặng hay đơn giản là một góc nhỏ xinh trong căn phòng của bạn.
                        </p>
                        <div class="about-highlight">
                            “Chỉ cần ôm một chiếc gấu bông mềm, mọi mệt mỏi trong ngày dường như nhẹ đi một chút.”
                        </div>
                    </div>
                    <aside class="info-box">
                        <h3>Thông tin nhanh</h3>
                        <ul>
                            <li><span class="info-label">Thành lập:</span> 2025</li>
                            <li><span class="info-label">Lĩnh vực:</span> Đồ nhồi bông & phụ kiện</li>
                            <li><span class="info-label">Địa chỉ:</span> 68 Nguyễn Chí Thanh, Láng Thượng, Đống Đa, Hà Nội</li>
                            <li><span class="info-label">Email:</span> petstuff6868@hotmail.com</li>
                        </ul>
                    </aside>
                </div>
                <section class="section">
                    <h2>Sứ mệnh</h2>
                    <p>
                        Mang lại những sản phẩm đáng yêu, chất lượng tốt với mức giá hợp lý, đồng thời xây dựng một không gian mua sắm
                        thân thiện, đơn giản và ấm áp cho khách hàng.
                    </p>
                </section>
                <section class="section">
                    <h2>Giá trị cốt lõi</h2>
                    <ul class="values-list">
                        <li>Chất lượng và độ an toàn luôn được đặt lên hàng đầu.</li>
                        <li>Thiết kế đáng yêu, phù hợp nhiều phong cách và độ tuổi.</li>
                        <li>Thái độ phục vụ thân thiện, sẵn sàng hỗ trợ khách hàng.</li>
                    </ul>
                </section>
                <div class="cta-box">
                    <span>Muốn tìm một người bạn gấu bông mới? Hãy xem bộ sưu tập hiện tại của tụi mình nhé!</span>
                    <a href="<%= ctx %>/sanpham">Xem sản phẩm</a>
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
                    <p><a href="<%= ctx %>/introduction.jsp">Giới thiệu</a></p>
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
        <script src="<%= ctx %>/javascript/cart.js"></script>
    </body>
</html>
