<%-- 
    Document   : bst
    Created on : 28 Oct 2025, 8:42:02 am
    Author     : hathuu24
--%>

<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/bst.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Bộ sưu tập</title>
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
                                java.text.NumberFormat vn = java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
                                vn.setGroupingUsed(true);
                                vn.setMaximumFractionDigits(0);
                                for (java.util.Map<String,Object> p : suggestList) {
                                  String tensp = (String) p.get("tensp");
                                  String anhsp = (String) p.get("anhsp");
                                  Number giatienNum = (Number) p.get("giatien");
                                  String giaFmt = vn.format(giatienNum.longValue()) + "đ";
                                  int masp = ((Number) p.get("masp")).intValue();
                          %>
                            <div class="card">
                                <img src="<%= ctx %>/images/<%= anhsp %>" height="250px" alt="<%= tensp %>">
                                <div class="card-content">
                                    <h3><%= giaFmt %></h3>
                                    <p><%= tensp %></p>
                                </div>
                                <div class="card-button">
                                    <a href="<%= ctx %>/detail.jsp?masp=<%= masp %>" class="btn">Đặt hàng</a>
                                </div>
                            </div>
                        <%
                                }
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
                      java.text.NumberFormat vn = java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));
                      vn.setGroupingUsed(true);
                      vn.setMaximumFractionDigits(0);

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
                                    Number giatien = (Number) p.get("giatien"); 
                                    String giaFmt = vn.format(giatien.doubleValue()) + "đ";
                                    int masp = ((Number) p.get("masp")).intValue();
                            %>
                                <div class="card">
                                    <img src="<%= ctx %>/images/<%= anhsp %>" height="250px" alt="<%= tensp %>">
                                    <div class="card-content">
                                        <h3><%= giaFmt %></h3>
                                        <p><%= tensp %></p>
                                    </div>
                                    <div class="card-button">
                                        <a href="<%= ctx %>/detail.jsp?masp=<%= masp %>" class="btn">Đặt hàng</a>
                                    </div>
                                </div>
                            <%
                                } 
                            %>
                        </div>
                    </div>
                    <%
                        String slug = bst.trim().toLowerCase().replaceAll("\\s+","");
                    %>
                    <div class="bst-view-more">
                        <a class="view-btn"
                           href="<%= ctx %>/sanpham?size=12&page=1&bst=<%= slug %>">
                           Xem tất cả
                        </a>
                    </div>
                <%
                      } 
                    }
                %>
            </div>
        </main>  
                            
        <!-- Liên hệ -->
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="<%= ctx %>/lienhe.jsp" title="Liên hệ" aria-label="Liên hệ">
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
        <script src="javascript/bst.js"></script>    
    </body>
</html>
