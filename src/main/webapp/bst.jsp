<%-- 
    Document   : bst
    Created on : 28 Oct 2025, 8:42:02 am
    Author     : hathuu24
--%>

<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="<%= ctx %>/css/bst.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Bộ sưu tập</title>
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
                                        <img src="<%= ctx %>/images/avatar-default.png" alt="Avatar">
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
            <!-- Banner -->
            <div class="banner">
                <img src="<%= ctx %>/images/bst.png" alt="Banner" />
            </div>

            <!-- Gợi ý sản phẩm -->
            <div class="suggest">
                <div class="suggest-list">
                    <div class="list-title">
                        <h2>Gợi ý cho bạn</h2>
                        <%
                            StringBuilder allBstUrl = new StringBuilder(ctx + "/sanpham?size=9&page=1");

                            java.util.List<java.util.Map<String,Object>> suggestListScope =
                                (java.util.List<java.util.Map<String,Object>>) request.getAttribute("suggestList");

                            java.util.Set<String> seenBst = new java.util.LinkedHashSet<>();
                            if (suggestListScope != null) {
                                for (java.util.Map<String,Object> p : suggestListScope) {
                                    String bst = (String) p.get("bst");
                                    if (bst != null) {
                                        String k = bst.trim();
                                        if (!k.isEmpty() && !"khong".equalsIgnoreCase(k) && seenBst.add(k)) {
                                            allBstUrl.append("&bst=")
                                                     .append(java.net.URLEncoder.encode(k, "UTF-8"));
                                        }
                                    }
                                }
                            }
                        %>
                        <a href="<%= allBstUrl.toString() %>" class="view-btn">Xem tất cả</a>
                    </div>

                    <div class="list-product">
                        <%
                            java.util.List<java.util.Map<String,Object>> suggestList =
                                (java.util.List<java.util.Map<String,Object>>) request.getAttribute("suggestList");

                            if (suggestList != null && !suggestList.isEmpty()) {
                                java.text.NumberFormat vn =
                                    java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
                                vn.setGroupingUsed(true);
                                vn.setMaximumFractionDigits(0);

                                for (java.util.Map<String,Object> p : suggestList) {
                                    String tensp = (String) p.get("tensp");
                                    String anhsp = (String) p.get("anhsp");
                                    int masp     = ((Number) p.get("masp")).intValue();

                                    Number giaGoc = (Number) p.get("giatien");
                                    Number giaKm  = (Number) p.get("giakm");
                                    Integer ptkm  = (Integer) p.get("ptkm");
                                    String makm   = (String) p.get("makm");

                                    boolean hasKm = (giaKm != null && giaKm.doubleValue() > 0
                                                     && giaKm.doubleValue() < giaGoc.doubleValue());

                                    String giaGocFmt = vn.format(giaGoc.longValue()) + "đ";
                                    String giaKmFmt  = hasKm ? vn.format(giaKm.longValue()) + "đ" : giaGocFmt;
                        %>
                            <div class="card">
                                <img src="<%= ctx %>/images/<%= anhsp %>" height="250px" alt="<%= tensp %>">
                                <div class="card-content">
                                    <% if (hasKm) { %>
                                        <div class="price-row">
                                            <span class="price-now"><%= giaKmFmt %></span>
                                            <span class="price-old"><%= giaGocFmt %></span>
                                            <% if (ptkm != null && ptkm > 0) { %>
                                                <span class="price-badge">-<%= ptkm %>%</span>
                                            <% } %>
                                        </div>
                                        <% if (makm != null && !makm.isEmpty()) { %>
                                            <div class="promo-code">Mã KM: <%= makm %></div>
                                        <% } %>
                                    <% } else { %>
                                        <h3 class="price-now"><%= giaGocFmt %></h3>
                                    <% } %>
                                    <p><%= tensp %></p>
                                </div>
                                <div class="card-button">
                                    <a href="<%= ctx %>/chitiet?id=<%= masp %>" class="btn">Đặt hàng</a>
                                </div>
                            </div>
                        <%
                                } // end for suggestList
                            } else {
                        %>
                            <p>Không có sản phẩm</p>
                        <%
                            }
                        %>
                    </div>
                </div>
            </div>
                    
            <!-- Slider --> 
            <%
                java.util.List<String> slideUrls =
                    (java.util.List<String>) request.getAttribute("slideUrls");
                if (slideUrls == null) slideUrls = java.util.Collections.emptyList();
            %>
            <section class="background">
                <div class="hero-slider" id="hero">
                    <% if (!slideUrls.isEmpty()) { %>
                        <% for (int i = 0; i < slideUrls.size(); i++) { %>
                            <div class="slide <%= (i==0 ? "is-active" : "") %>">
                                <img src="<%= ctx %>/images/<%= slideUrls.get(i) %>" alt="banner <%= i+1 %>">
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
                            <img src="<%= ctx %>/images/placeholder-hero.jpg" alt="placeholder">
                        </div>
                    <% } %>
                </div>
            </section>
            
            <!-- Bộ sưu tập -->
            <div class="bst-container">
                <%
                    java.util.Map<String, java.util.List<java.util.Map<String, Object>>> mapBST =
                        (java.util.Map<String, java.util.List<java.util.Map<String, Object>>>) request.getAttribute("mapBST");

                    if (mapBST == null || mapBST.isEmpty()) {
                %>
                    <p>Không có sản phẩm.</p>
                <%
                    } else {
                        java.text.NumberFormat vn2 =
                            java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
                        vn2.setGroupingUsed(true);
                        vn2.setMaximumFractionDigits(0);

                        for (String bst : mapBST.keySet()) {
                            java.util.List<java.util.Map<String, Object>> list = mapBST.get(bst);
                            String bstId = bst.trim().toLowerCase().replaceAll("\\s+", "");
                %>
                    <div class="bst-list" id="<%= bstId %>">
                        <div class="bst-title">
                            <img src="<%= ctx %>/images/<%= bst %>.png" alt="<%= bst %>" class="bst-cover">
                        </div>

                        <div class="bst-product">
                            <%
                                for (java.util.Map<String, Object> p : list) {
                                    String tensp = (String) p.get("tensp");
                                    String anhsp = (String) p.get("anhsp");
                                    int masp     = ((Number) p.get("masp")).intValue();

                                    Number giaGoc = (Number) p.get("giatien");
                                    Number giaKm  = (Number) p.get("giakm");
                                    Integer ptkm  = (Integer) p.get("ptkm");
                                    String makm   = (String) p.get("makm");

                                    boolean hasKm = (giaKm != null && giaKm.doubleValue() > 0
                                                     && giaKm.doubleValue() < giaGoc.doubleValue());

                                    String giaGocFmt = vn2.format(giaGoc.longValue()) + "đ";
                                    String giaKmFmt  = hasKm ? vn2.format(giaKm.longValue()) + "đ" : giaGocFmt;
                            %>
                                <div class="card">
                                    <img src="<%= ctx %>/images/<%= anhsp %>" height="250px" alt="<%= tensp %>">
                                    <div class="card-content">
                                        <% if (hasKm) { %>
                                            <div class="price-row">
                                                <span class="price-now"><%= giaKmFmt %></span>
                                                <span class="price-old"><%= giaGocFmt %></span>
                                                <% if (ptkm != null && ptkm > 0) { %>
                                                    <span class="price-badge">-<%= ptkm %>%</span>
                                                <% } %>
                                            </div>
                                            <% if (makm != null && !makm.isEmpty()) { %>
                                                <div class="promo-code">Mã KM: <%= makm %></div>
                                            <% } %>
                                        <% } else { %>
                                            <h3 class="price-now"><%= giaGocFmt %></h3>
                                        <% } %>
                                        <p><%= tensp %></p>
                                    </div>
                                    <div class="card-button">
                                        <a href="<%= ctx %>/chitiet?id=<%= masp %>" class="btn">Đặt hàng</a>
                                    </div>
                                </div>
                            <%
                                } // end for p
                            %>
                        </div> <!-- /.bst-product -->

                        <%
                            String slug = bst.trim().toLowerCase().replaceAll("\\s+","");
                        %>
                        <div class="bst-view-more">
                            <a class="view-btn"
                               href="<%= ctx %>/sanpham?size=12&page=1&bst=<%= slug %>">
                               Xem tất cả
                            </a>
                        </div>
                    </div> <!-- /.bst-list -->
                <%
                        } // end for bst
                    } // end else mapBST
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
        <script src="<%= ctx %>/javascript/bst.js"></script>    
    </body>
</html>
