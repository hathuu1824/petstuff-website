<%-- 
    Document   : trangchu
    Created on : 13 Sept 2025, 8:51:25 pm
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
        <link rel="stylesheet" href="css/home.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Trang chủ</title>
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
            <!-- Slider -->
            <section class="background">
                <%
                    List<String> slideUrls = (List<String>) request.getAttribute("slideUrls");
                    if (slideUrls == null) slideUrls = java.util.Collections.emptyList();
                %>
                <div class="hero-slider" id="hero">
                <% if (!slideUrls.isEmpty()) { %>
                    <% for (int i = 0; i < slideUrls.size(); i++) { %>
                        <div class="slide <%= (i==0 ? "is-active" : "") %>">
                            <img src="images/<%= slideUrls.get(i) %>" alt="banner <%= i+1 %>">
                        </div>
                    <% } %>
                    <button class="hero-nav prev" aria-label="Trước">‹</button>
                    <button class="hero-nav next" aria-label="Tiếp">›</button>
                    <div class="dots">
                        <% for (int i = 0; i < slideUrls.size(); i++) { %>
                            <button class="dot <%= (i==0 ? "active" : "") %>" data-index="<%= i %>"></button>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="slide is-active">
                        <img src="images/placeholder-hero.jpg" alt="placeholder">
                    </div>
                <% } %>
                </div>              
            </section>  

            <!-- Giới thiệu -->  
            <section class="about">
                <div class="about-us">
                    <div class="about-container">
                        <div class="about-image">
                            <img src="images/fluffy-toy-texture-close-up_23-2149686894.avif" width="500px">
                        </div>
                        <div class="about-content">
                            <h3>Chào mừng bạn đến với PetStuff – Thế giới nhồi bông đáng yêu dành cho mọi lứa tuổi!</h3>
                            <p>Chúng tôi chuyên cung cấp các sản phẩm nhồi bông cao cấp với đa dạng kích thước, mẫu mã và chất liệu mềm mịn, an toàn cho sức khỏe.</p>
                            <p>Cam kết của chúng tôi:</p> 
                            <p>- Chất lượng cao, bông êm ái, an toàn tuyệt đối.</p>
                            <p>- Mẫu mã đa dạng, cập nhật xu hướng mới nhất.</p>
                            <p>- Giá cả hợp lý, dịch vụ tận tâm.</p>   
                            <p>Hãy để những người bạn bông mềm mại mang đến niềm vui và sự ấm áp cho bạn!</p> 
                            <p>Mua sắm ngay hôm nay và nhận nhiều ưu đãi hấp dẫn!</p>
                            <a href="sanpham" class="btn">Mua ngay</a>
                        </div>
                    </div>
                </div>   
            </section>     

            <!-- Mô tả -->
            <section class="icons-container">
                <div class="icons">
                    <img src="images/basket-regular-60.png">
                    <div class="info">
                        <h3>Đặt Hàng</h3>
                        <span>Đặt mua các sản phẩm thú nhồi bông có mặt tại trang web</span>
                    </div>
                </div>
                <div class="icons">
                    <img src="images/message-rounded-dots-regular-60.png">
                    <div class="info">
                        <h3>Hỗ Trợ</h3>
                        <span>Chatbot hỗ trợ và tư vấn tùy theo nhu cầu của khách hàng</span>
                    </div>
                </div>
                <div class="icons">
                    <img src="images/message-rounded-dots-regular-60.png">
                    <div class="info">
                        <h3>Quà Tặng</h3>
                        <span>Thông tin về khuyến mại và các set quà tặng tùy theo đợt</span>
                    </div>
                </div>
                <div class="icons">
                    <img src="images/line-chart-regular-60.png">
                    <div class="info">
                        <h3>Tin tức</h3>
                        <span>Liên tục cập nhật thông tin về các sản phẩm nhồi bông mới nhất</span>
                    </div>
                </div>
            </section>
        
            <!-- Sản phẩm nổi bật -->    
            <h1 class="heading">SẢN PHẨM NỔI BẬT</h1>
            <div class="card-container">
            <%
                List<Map<String,Object>> featured =
                    (List<Map<String,Object>>) request.getAttribute("featured");

                if (featured != null && !featured.isEmpty()) {
                    for (Map<String,Object> p : featured) {
            %>
                <div class="card">
                    <img src="images/<%= p.get("anhsp") %>" height="250px" alt="<%= p.get("tensp") %>">
                    <div class="card-content">
                        <%
                            java.math.BigDecimal raw = (java.math.BigDecimal) p.get("giatien");

                            java.text.NumberFormat vn = java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
                            vn.setGroupingUsed(true);      
                            vn.setMaximumFractionDigits(0);

                            String giaFmt = vn.format(raw.longValue()) + "đ";
                        %>
                        <h3><%= giaFmt %></h3>
                        <p><%= p.get("tensp") %></p>
                    </div>
                    <div class="card-button">
                        <a href="detail.jsp?masp=<%= p.get("masp") %>" class="btn">Đặt hàng</a>
                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <p>Hiện chưa có sản phẩm nổi bật.</p>
            <%
                } 
            %>
                <div class="button-container">
                    <a href="sanpham" class="view-btn">Xem tất cả</a>
                </div>
            </div>
      
            <!-- Vị trí -->
            <section class="review">
                <h1 class="heading">VỊ TRÍ CỬA HÀNG</h1>
                <div class="loc-map">
                    <iframe title="Google Map" loading="lazy"
                            referrerpolicy="no-referrer-when-downgrade" allowfullscreen>
                    </iframe>
                </div>
            </section>
        </main>
  
        <!-- Liên hệ -->        
        <% String ctx = request.getContextPath(); %>
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
        <script src="javascript/home.js"></script>    
    </body>
</html>