<%-- 
    Document   : product
    Created on : 20 Sept 2025, 2:43:05 pm
    Author     : hathuu24
--%>

<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();

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

    List<Map<String,Object>> list =
        (List<Map<String,Object>>) request.getAttribute("list");
    if (list == null) list = java.util.Collections.emptyList();

    String loai = request.getParameter("loai");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sản phẩm</title>
        <link rel="stylesheet" href="<%=ctx%>/css/product.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <header>
            <nav class="container">
                <a href="<%=ctx%>/trangchu" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <a class="icon-btn" href="<%=ctx%>/cart">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </a>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle" href="#">
                                <i class="fa-solid fa-user"></i>
                            </a>
                            <div class="user-popup">
                                <div class="user-popup-header">
                                    <img src="<%=ctx%>/images/avatar-default.png" class="user-popup-avatar">
                                    <div class="user-popup-name"><%= username %></div>
                                    <div class="user-popup-role-pill"><%= role %></div>
                                </div>
                                <div class="user-popup-body">
                                    <a href="<%=ctx%>/profile" class="user-popup-item">
                                        <i class="fa-solid fa-user"></i> Thông tin cá nhân
                                    </a>
                                    <a href="<%=ctx%>/donhang" class="user-popup-item">
                                        <i class="fa-solid fa-box"></i> Đơn hàng của bạn
                                    </a>
                                </div>
                                <div class="user-popup-footer">
                                    <a href="<%=ctx%>/dangxuat" class="home-btn logout-btn">Đăng xuất</a>
                                </div>
                            </div>
                        </div>
                    <% } else { %>
                        <a href="<%=ctx%>/login.jsp" class="home-btn">Đăng nhập</a>
                        <a href="<%=ctx%>/register.jsp" class="home-btn">Đăng ký</a>
                    <% } %>
                </div>
            </nav>
            <div class="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">
                        <li><a href="<%=ctx%>/trangchu">Trang chủ</a></li>
                        <li class="has-dd">
                            <a href="<%=ctx%>/sanpham" class="dd-toggle">Sản phẩm</a>
                            <ul class="dropdown">
                                <li><a href="<%=ctx%>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%=ctx%>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%=ctx%>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%=ctx%>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>
                        <li><a href="<%=ctx%>/bst">Bộ sưu tập</a></li>
                        <li><a href="<%=ctx%>/giamgia">Khuyến mại</a></li>
                        <li><a href="<%=ctx%>/tintuc">Tin tức</a></li>
                    </ul>
                </nav>
            </div>
        </header>
        
        <main>
            <h1 class="heading">
                <% if (loai == null) { %>
                    TẤT CẢ SẢN PHẨM
                <% } else { %>
                    <% if (loai.equals("changoi")) { %> CHĂN GỐI HÌNH THÚ
                    <% } else if (loai.equals("mockhoa")) { %> MÓC KHÓA
                    <% } else if (loai.equals("tnb")) { %> THÚ NHỒI BÔNG
                    <% } else { %> SẢN PHẨM KHÁC <% } %>
                <% } %>
            </h1>
            <div class="product-container">
                <% if (!list.isEmpty()) { %>
                    <% for (Map<String,Object> p : list) { %>
                        <div class="product-card">
                            <img src="<%=ctx%>/images/<%= p.get("anhsp") %>"
                                 class="product-img"
                                 alt="<%= p.get("tensp") %>">
                            <div class="product-info">
                                <h3><%= p.get("tensp") %></h3>
                                <%
                                    java.math.BigDecimal giaGoc = (java.math.BigDecimal)p.get("giatien");
                                    java.math.BigDecimal giaKm  = (java.math.BigDecimal)p.get("giakm");
        
                                    java.text.NumberFormat vn =
                                        java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
                                    vn.setGroupingUsed(true);
        
                                    String goc = vn.format(giaGoc.longValue()) + "₫";
        
                                    boolean hasKm = (giaKm != null
                                        && giaKm.compareTo(java.math.BigDecimal.ZERO) > 0
                                        && giaKm.compareTo(giaGoc) < 0);
        
                                    String km  = hasKm ? vn.format(giaKm.longValue()) + "₫" : goc;
                                %>
                                <% if (hasKm) { %>
                                    <div class="price-row">
                                        <span class="price-now"><%=km%></span>
                                        <span class="price-old"><%=goc%></span>
                                    </div>
                                <% } else { %>
                                    <div class="price-row">
                                        <span class="price-now"><%=goc%></span>
                                    </div>
                                <% } %>
                                <a class="btn"
                                   href="<%=ctx%>/chitiet?id=<%=p.get("masp")%>">Xem chi tiết</a>
                            </div>
                        </div>
                    <% } %>
                <% } else { %>
                    <p class="no-product">Không có sản phẩm nào.</p>
                <% } %>
            </div>
        </main>
        
        <footer>
            <div class="footer-container">
                <div class="footer-infor">
                    <h4>PetStuff</h4>
                    <p>Địa chỉ: 68 Nguyễn Chí Thanh, Hà Nội</p>
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
                    <p><a href="<%=ctx%>/contact.jsp">Liên hệ</a></p>
                    <p><a href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff">Chatbot tư vấn</a></p>
                </div>
                <div class="footer-social">
                    <h4>Theo dõi</h4>
                    <div class="social">
                        <a href="https://www.facebook.com"><i class="fab fa-facebook-f"></i></a>
                        <a href="https://www.tiktok.com"><i class="fab fa-tiktok"></i></a>
                        <a href="https://www.instagram.com"><i class="fab fa-instagram"></i></a>
                        <a href="https://www.twitter.com"><i class="fab fa-twitter"></i></a>
                    </div>
                </div>
            </div>
        </footer>
        <script src="<%=ctx%>/javascript/product.js"></script>
    </body>
</html>
