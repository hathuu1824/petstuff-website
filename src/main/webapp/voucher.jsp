<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="<%= ctx %>/css/voucher.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Voucher</title>
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
                    role = (String) ss.getAttribute("role");
                }
            }
        %>

        <!-- HEADER -->
        <header>
            <nav class="container">
                <a href="<%= ctx %>/trangchu" id="logo">PetStuff</a>

                <div class="buttons">
                    <% if (isLoggedIn) { %>

                        <a class="icon-btn" href="<%= ctx %>/cart" title="Giỏ hàng">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </a>

                        <div class="user-menu">
                            <a class="icon-btn user-toggle" href="#" title="Tài khoản">
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

            <!-- SUBBAR -->
            <div class="subbar" id="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">

                        <li><a href="<%= ctx %>/trangchu">Trang chủ</a></li>

                        <li class="has-dd">
                            <button class="dd-toggle">
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
                            <button class="dd-toggle">
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

        <!-- MAIN -->
        <main class="main">

            <!-- VOUCHER GIỚI HẠN -->
            <section class="voucher-wrap">
                <h1 class="heading">VOUCHER GIỚI HẠN</h1>

                <div class="voucher-scroller" id="voucherScroller">
                    <%
                        List<Map<String,Object>> limited =
                            (List<Map<String,Object>>) request.getAttribute("limited");

                        if (limited != null && !limited.isEmpty()) {
                            for (Map<String,Object> v : limited) {
                                String loai  = String.valueOf(v.get("loai"));
                                String ma    = String.valueOf(v.get("ma"));
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

                                <button class="btn-save" type="button">
                                    <%= (ma == null || "null".equalsIgnoreCase(ma)) ? "NHẬP MÃ" : ma %>
                                </button>

                            <% } else { %>

                                <form method="post" action="<%= ctx %>/claim-voucher">
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
                        } else {
                    %>

                    <article class="coupon is-empty">
                        <div class="coupon-left">
                            <h3 class="coupon-title">Đang cập nhật voucher</h3>
                            <p class="coupon-sub">Vui lòng quay lại sau</p>
                        </div>
                        <div class="coupon-sep"></div>
                        <div class="coupon-right">
                            <button class="btn-save" type="button" disabled>Không có</button>
                        </div>
                        <span class="coupon-edge left"></span>
                        <span class="coupon-edge right"></span>
                    </article>

                    <% } %>
                </div>

                <button class="v-nav v-prev">‹</button>
                <button class="v-nav v-next">›</button>
            </section>

            <!-- TẤT CẢ VOUCHER -->
            <div class="all-voucher">
                <h1 class="heading">TẤT CẢ VOUCHER</h1>

                <!-- NHẬP MÃ -->
                <section class="voucher-input-wrap">
                    <form id="voucherForm" class="voucher-input"
                          method="post" action="<%= ctx %>/claim-voucher">

                        <i class="fa-solid fa-ticket"></i>
                        <input type="text" name="code" maxlength="24"
                               placeholder="Nhập mã voucher (ví dụ: PET20, WELCOME...)">

                        <button class="v-btn" type="submit">Áp dụng</button>
                    </form>

                    <%
                        String claimMsg  = (String) request.getAttribute("claimMsg");
                        String claimType = (String) request.getAttribute("claimType");

                        if (claimMsg != null) {
                    %>

                    <div class="v-alert <%= "success".equalsIgnoreCase(claimType) ? "ok" : "err" %>">
                        <%= claimMsg %>
                    </div>

                    <% } %>
                </section>

                <!-- LIST VOUCHER -->
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

                                <button class="btn-save" type="button">
                                    <%= (ma == null ? "NHẬP MÃ" : ma) %>
                                </button>

                            <% } else { %>

                                <form method="post" action="<%= ctx %>/claim-voucher">
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
                        } else {
                    %>

                    <h2 class="promo-caption">Voucher đang cập nhật</h2>

                    <% } %>


                    <!-- PHÂN TRANG -->
                    <%
                        int pg  = (request.getAttribute("page") != null) ? (Integer) request.getAttribute("page") : 1;
                        int sz  = (request.getAttribute("size") != null) ? (Integer) request.getAttribute("size") : 12;
                        int tp  = (request.getAttribute("totalPages") != null) ? (Integer) request.getAttribute("totalPages") : 1;

                        String base = ctx + "/voucher?size=" + sz + "&page=";
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
            </div>
        </main>

        <!-- FLOATING CONTACT -->
        <div class="floating-actions">
            <a class="fa-btn contact" href="<%= ctx %>/contact.jsp" title="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat" href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff"
               target="_blank">
                <i class="fa-regular fa-comments"></i>
            </a>
        </div>

        <!-- FOOTER -->
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
                    <p><a href="#">Liên hệ</a></p>
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

            <div class="footer-bottom">
                <p>Copyright © 2025</p>
            </div>
        </footer>

        <!-- JS -->
        <script src="<%= ctx %>/javascript/voucher.js"></script>

    </body>
</html>
