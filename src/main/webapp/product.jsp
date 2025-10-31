<%-- 
    Document   : product
    Created on : 20 Sept 2025, 2:43:05 pm
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
        <link rel="stylesheet" href="css/product.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Sản phẩm</title>
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

        <%
            String ctx = request.getContextPath();

            java.util.List<java.util.Map<String,Object>> products =
                (java.util.List<java.util.Map<String,Object>>) request.getAttribute("products");

            int  currPage   = 1;
            int  size       = 9;
            int  totalPages = 1;
            long totalCount = 0L;

            Object tmp = request.getAttribute("page");
            if (tmp instanceof Number) currPage = ((Number) tmp).intValue();

            tmp = request.getAttribute("size");
            if (tmp instanceof Number) size = ((Number) tmp).intValue();

            tmp = request.getAttribute("totalPages");
            if (tmp instanceof Number) totalPages = ((Number) tmp).intValue();

            tmp = request.getAttribute("totalCount");
            if (tmp instanceof Number) totalCount = ((Number) tmp).longValue();

            java.text.NumberFormat nf =
                java.text.NumberFormat.getInstance(new java.util.Locale("vi","VN"));

            String qs = request.getQueryString();
            String qsKeep = "";
            if (qs != null) {
                qsKeep = qs.replaceAll("(^|&)?page=\\d+(&|$)", "$2");
                qsKeep = qsKeep.replaceAll("^&|&$", "");
                if (!qsKeep.isEmpty()) qsKeep += "&";
            }
            String baseUrl = ctx + "/sanpham?" + qsKeep + "page=";

            java.util.Set<String> loaiSel = new java.util.HashSet<>();
            String[] loaiParams = request.getParameterValues("loai");
            if (loaiParams != null) java.util.Collections.addAll(loaiSel, loaiParams);

            java.util.Set<String> bstSel = new java.util.HashSet<>();
            String[] bstParams = request.getParameterValues("bst");
            if (bstParams != null) java.util.Collections.addAll(bstSel, bstParams);

            String sort = request.getParameter("sort") == null ? "" : request.getParameter("sort");
        %>
        <main class="main">
            <section class="catalog has-filters">
                <div class="catalog-wrap">
                    <aside class="filters">
                        <form id="filterForm" method="get" action="<%= ctx %>/sanpham">
                            <input type="hidden" name="size" value="<%= size %>">
                            <input type="hidden" name="page" value="1">
                            <div class="sort-box">
                                <label class="sort-label" for="sort">Sắp xếp</label>
                                <div class="select-wrap">
                                    <select id="sort" name="sort" onchange="document.getElementById('filterForm').submit()">
                                        <option value=""          <%= sort.equals("")           ? "selected" : "" %>>Sản phẩm nổi bật</option>
                                        <option value="price_asc" <%= sort.equals("price_asc")  ? "selected" : "" %>>Giá: thấp → cao</option>
                                        <option value="price_desc"<%= sort.equals("price_desc") ? "selected" : "" %>>Giá: cao → thấp</option>
                                        <option value="newest"    <%= sort.equals("newest")     ? "selected" : "" %>>Mới nhất</option>
                                    </select>
                                    <i class="fa-solid fa-chevron-down" aria-hidden="true"></i>
                                </div>
                            </div>
                            <div class="filter-group open">
                                <button type="button" class="filter-head">
                                    <span>Loại sản phẩm</span>
                                    <!--<i class="fa-solid fa-minus"></i>
                                    <i class="fa-solid fa-plus"></i>-->
                                </button>
                                <ul class="filter-list">
                                    <li><label><input type="checkbox" name="loai" value="changoi"  <%= loaiSel.contains("changoi")  ? "checked" : "" %>> Chăn gối hình thú</label></li>
                                    <li><label><input type="checkbox" name="loai" value="mockhoa"     <%= loaiSel.contains("mockhoa")     ? "checked" : "" %>> Móc khóa</label></li>
                                    <li><label><input type="checkbox" name="loai" value="tnb"    <%= loaiSel.contains("tnb")    ? "checked" : "" %>> Thú nhồi bông</label></li>
                                    <li><label><input type="checkbox" name="loai" value="khac"   <%= loaiSel.contains("khac")   ? "checked" : "" %>> Khác</label></li>
                          
                                </ul>
                            </div>
                            <div class="filter-group open">
                                <button type="button" class="filter-head">
                                    <span>Bộ sưu tập</span>
                                    <!--<i class="fa-solid fa-minus"></i>
                                    <i class="fa-solid fa-plus"></i>-->
                                </button>
                                <ul class="filter-list">
                                    <li><label><input type="checkbox" name="bst" value="babythree"   <%= bstSel.contains("babythree")   ? "checked" : "" %>> Baby Three</label></li>
                                    <li><label><input type="checkbox" name="bst" value="capybara" <%= bstSel.contains("capybara")? "checked" : "" %>> Capybara</label></li>
                                    <li><label><input type="checkbox" name="bst" value="doraemon"    <%= bstSel.contains("doraemon")    ? "checked" : "" %>> Doraemon</label></li>
                                    <li><label><input type="checkbox" name="bst" value="sanrio" <%= bstSel.contains("sanrio")? "checked" : "" %>> Sanrio</label></li>
                                </ul>
                            </div>
                        </form>
                    </aside>

                    <section class="products">
                        <% if (products != null && !products.isEmpty()) {
                               for (java.util.Map<String,Object> p : products) {
                                   int    id    = (Integer) p.get("masp");
                                   String name  = (String)  p.get("tensp");
                                   String img   = (String)  p.get("anhsp");
                                   java.math.BigDecimal price = (java.math.BigDecimal) p.get("giatien");
                                   String priceStr = (price != null) ? nf.format(price) : "";
                        %>
                        <a class="p-card p-link" href="<%= ctx %>/chitiet?id=<%= id %>">
                            <span class="p-thumb">
                                <img src="images/<%= img %>" alt="<%= name %>" loading="lazy">
                            </span>
                            <span class="p-price">
                                <%= priceStr %><span class="currency">đ</span>
                            </span>
                            <span class="p-title"><%= name %></span>
                        </a>
                        <%     }
                           } else { %>
                        <article class="p-card p-link">
                            <span class="p-thumb">
                                <img src="images/placeholder-500x500.png" alt="No data" loading="lazy">
                            </span>
                            <span class="p-title">Chưa có sản phẩm</span>
                            <span class="p-price">—</span>
                        </article>
                        <% } %>
                    </section>
                </div>
                <% if (totalPages > 1) { %>
                <nav class="pagination" aria-label="Phân trang">
                    <a class="page-btn prev <%= (currPage <= 1 ? "disabled" : "") %>"
                       href="<%= (currPage <= 1 ? "#" : baseUrl + (currPage - 1)) %>">Trước</a>
                    <div class="page-list">
                        <% for (int i = 1; i <= totalPages; i++) { %>
                            <a class="page-num <%= (i == currPage ? "active" : "") %>"
                               href="<%= baseUrl + i %>"><%= i %></a>
                        <% } %>
                    </div>
                    <a class="page-btn next <%= (currPage >= totalPages ? "disabled" : "") %>"
                       href="<%= (currPage >= totalPages ? "#" : baseUrl + (currPage + 1)) %>">Sau</a>
                </nav>
                <% } %>
            </section>
        </main>
        
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
        <script src="javascript/product.js"></script>
    </body>
</html>