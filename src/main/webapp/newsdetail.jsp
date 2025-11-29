<%-- 
    Document   : newsdetail
    Created on : 25 Nov 2025, 2:48:24 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="webnhoibong.DatabaseConnection"%>

<%
    String ctx = request.getContextPath();

    // ==== Lấy id bài viết từ URL ====
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect(ctx + "/tintuc");
        return;
    }

    int id;
    try {
        id = Integer.parseInt(idStr);
    } catch (NumberFormatException e) {
        response.sendRedirect(ctx + "/tintuc");
        return;
    }

    // ==== Biến hiển thị bài chính ====
    String title      = "";
    String content    = "";
    String imagePath  = "";
    String dateStr    = "";

    // ==== Danh sách tin khác ====
    List<Map<String,Object>> otherNews = new ArrayList<>();

    try (Connection conn = DatabaseConnection.getConnection()) {

        // --- Lấy bài viết chính ---
        String sqlMain =
            "SELECT tieu_de, ngay_dang, anh_dai_dien, noi_dung " +
            "FROM baiviet WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlMain)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    title     = rs.getString("tieu_de");
                    content   = rs.getString("noi_dung");
                    imagePath = rs.getString("anh_dai_dien"); // file trong /images

                    java.sql.Date d = rs.getDate("ngay_dang");
                    if (d != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                        dateStr = sdf.format(d);
                    }
                } else {
                    // Không tìm thấy bài -> quay lại danh sách
                    response.sendRedirect(ctx + "/tintuc");
                    return;
                }
            }
        }

        // --- Lấy các tin khác (trừ bài đang xem) ---
        String sqlOther =
            "SELECT id, tieu_de, anh_dai_dien, ngay_dang " +
            "FROM baiviet WHERE id <> ? " +
            "ORDER BY ngay_dang DESC, id DESC LIMIT 5";
        try (PreparedStatement ps = conn.prepareStatement(sqlOther)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("id",      rs.getInt("id"));
                    row.put("tieude",  rs.getString("tieu_de"));
                    row.put("anh",     rs.getString("anh_dai_dien"));
                    java.sql.Date d = rs.getDate("ngay_dang");
                    row.put("ngay", (d != null ? sdf.format(d) : ""));
                    otherNews.add(row);
                }
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="<%= ctx %>/css/newsdetail.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title><%= (title != null && !title.isEmpty()) ? title : "Tin tức" %></title>
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
            <section class="news-wrapper">
                <article class="news-main">
                    <h1 class="news-title"><%= title %></h1>
                    <p class="news-meta">
                        <i class="fa-regular fa-calendar"></i>
                        <span><%= dateStr %></span>
                    </p>
                    <% if (imagePath != null && !imagePath.isEmpty()) { %>
                        <div class="news-image">
                            <img src="<%= ctx %>/images/<%= imagePath %>" alt="<%= title %>">
                        </div>
                    <% } %>
                    <div class="news-content">
                        <%= (content != null ? content.replaceAll("\n", "<br>") : "") %>
                    </div>
                </article>
                <aside class="news-sidebar">
                    <h2 class="sidebar-heading">Tin khác</h2>
                    <div class="sidebar-list">
                        <% if (otherNews != null && !otherNews.isEmpty()) { 
                               for (Map<String,Object> row : otherNews) {
                                   int    oid   = (Integer) row.get("id");
                                   String otit  = (String) row.get("tieude");
                                   String oimg  = (String) row.get("anh");
                                   String ongay = (String) row.get("ngay");
                        %>
                            <a class="sidebar-item" href="<%= ctx %>/newsdetail?id=<%= oid %>">
                                <div class="sidebar-thumb">
                                    <% if (oimg != null && !oimg.isEmpty()) { %>
                                        <img src="<%= ctx %>/images/<%= oimg %>" alt="<%= otit %>">
                                    <% } %>
                                </div>
                                <div class="sidebar-info">
                                    <h3><%= otit %></h3>
                                    <span class="sidebar-date"><%= ongay %></span>
                                    <span class="sidebar-readmore"><strong>Đọc tiếp →</strong></span>
                                </div>
                            </a>
                        <%    }
                           } else { %>
                            <p>Chưa có tin nào khác.</p>
                        <% } %>
                    </div>
                </aside>
            </section>
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

        <script src="<%= ctx %>/javascript/home.js"></script>                       
    </body>
</html>
