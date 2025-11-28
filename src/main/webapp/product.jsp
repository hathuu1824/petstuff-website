<%-- 
    Document   : product
    Created on : 20 Sept 2025, 2:43:05 pm
    Author     : hathuu24
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.*"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sản phẩm</title>

        <link rel="stylesheet" href="css/product.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <%
            String ctx = request.getContextPath();

            // ==== Đăng nhập ====
            HttpSession ss = request.getSession(false);
            boolean isLoggedIn = false;
            String username = null;
            String role     = null;

            if (ss != null) {
                Integer userId = (Integer) ss.getAttribute("userId");
                if (userId != null) {
                    isLoggedIn = true;
                    username   = (String) ss.getAttribute("username");
                    role       = (String) ss.getAttribute("role");
                }
            }

            // ==== Dữ liệu từ servlet ====
            @SuppressWarnings("unchecked")
            List<Map<String,Object>> products =
                (List<Map<String,Object>>) request.getAttribute("products");

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

            // Format tiền
            NumberFormat vn = NumberFormat.getInstance(new java.util.Locale("vi","VN"));

            String qs = request.getQueryString();
            String qsKeep = "";
            if (qs != null) {
                qsKeep = qs.replaceAll("(^|&)?page=\\d+(&|$)", "$2");
                qsKeep = qsKeep.replaceAll("^&|&$", "");
                if (!qsKeep.isEmpty()) qsKeep += "&";
            }
            String baseUrl = ctx + "/sanpham?" + qsKeep + "page=";

            String sort = request.getParameter("sort") == null ? "" : request.getParameter("sort");

            Set<String> loaiSel = new HashSet<>();
            String[] loaiParams = request.getParameterValues("loai");
            if (loaiParams != null) Collections.addAll(loaiSel, loaiParams);

            Set<String> bstSel = new HashSet<>();
            String[] bstParams = request.getParameterValues("bst");
            if (bstParams != null) Collections.addAll(bstSel, bstParams);
        %>
        <!-- ================= HEADER ================= -->
        <header>
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
                                        <img src="images/avatar-default.png" alt="Avatar">
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

            <!-- Sub menu -->
            <div class="subbar" id="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">
                        <li><a href="trangchu">Trang chủ</a></li>

                        <li class="has-dd">
                            <button class="dd-toggle" type="button"><a href="sanpham">Sản phẩm</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= ctx %>/sanpham?loai=changoi">Chăn gối hình thú</a></li>
                                <li><a href="<%= ctx %>/sanpham?loai=mockhoa">Móc khóa</a></li>
                                <li><a href="<%= ctx %>/sanpham?loai=tnb">Thú nhồi bông</a></li>
                                <li><a href="<%= ctx %>/sanpham?loai=khac">Khác</a></li>
                            </ul>
                        </li>

                        <li class="has-dd">
                            <button class="dd-toggle" type="button"><a href="bst">Bộ sưu tập</a></button>
                            <ul class="dropdown">
                                <li><a href="<%= ctx %>/bst#babythree">Baby Three</a></li>
                                <li><a href="<%= ctx %>/bst#capybara">Capybara</a></li>
                                <li><a href="<%= ctx %>/bst#doraemon">Doraemon</a></li>
                                <li><a href="<%= ctx %>/bst#sanrio">Sanrio</a></li>
                            </ul>
                        </li>

                        <li><a href="giamgia">Khuyến mại</a></li>
                        <li><a href="tintuc">Tin tức</a></li>
                    </ul>
                </nav>
            </div>
        </header>

        <!-- ================= MAIN ================= -->
        <main class="main">
            <section class="catalog has-filters">
                <div class="catalog-wrap">
                    <!-- ====== BỘ LỌC ====== -->
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
                                </button>
                                <ul class="filter-list">
                                    <li><label><input type="checkbox" name="loai" value="changoi"  <%= loaiSel.contains("changoi")  ? "checked" : "" %>> Chăn gối hình thú</label></li>
                                    <li><label><input type="checkbox" name="loai" value="mockhoa" <%= loaiSel.contains("mockhoa") ? "checked" : "" %>> Móc khóa</label></li>
                                    <li><label><input type="checkbox" name="loai" value="tnb"     <%= loaiSel.contains("tnb")     ? "checked" : "" %>> Thú nhồi bông</label></li>
                                    <li><label><input type="checkbox" name="loai" value="khac"    <%= loaiSel.contains("khac")    ? "checked" : "" %>> Khác</label></li>
                                </ul>
                            </div>

                            <div class="filter-group open">
                                <button type="button" class="filter-head">
                                    <span>Bộ sưu tập</span>
                                </button>
                                <ul class="filter-list">
                                    <li><label><input type="checkbox" name="bst" value="babythree" <%= bstSel.contains("babythree") ? "checked" : "" %>> Baby Three</label></li>
                                    <li><label><input type="checkbox" name="bst" value="capybara"  <%= bstSel.contains("capybara")  ? "checked" : "" %>> Capybara</label></li>
                                    <li><label><input type="checkbox" name="bst" value="doraemon"  <%= bstSel.contains("doraemon")  ? "checked" : "" %>> Doraemon</label></li>
                                    <li><label><input type="checkbox" name="bst" value="sanrio"    <%= bstSel.contains("sanrio")    ? "checked" : "" %>> Sanrio</label></li>
                                </ul>
                            </div>
                        </form>
                    </aside>

                    <!-- ====== DANH SÁCH SẢN PHẨM ====== -->
                    <section class="products">
                    <%
                        if (products != null && !products.isEmpty()) {
                            for (Map<String,Object> p : products) {

                                // Lấy đúng key từ servlet
                                int masp = (p.get("masp") instanceof Number)
                                           ? ((Number) p.get("masp")).intValue()
                                           : 0;

                                String tensp = (String) p.get("tensp");
                                String anhsp = (String) p.get("anhsp");

                                BigDecimal priceSale     = (BigDecimal) p.get("priceSale");
                                BigDecimal priceOriginal = (BigDecimal) p.get("priceOriginal");
                                boolean hasDiscount      = Boolean.TRUE.equals(p.get("hasDiscount"));

                                // fallback tránh null
                                if (priceSale == null && priceOriginal != null) priceSale = priceOriginal;
                                if (priceOriginal == null && priceSale != null) priceOriginal = priceSale;
                                if (priceSale == null) priceSale = BigDecimal.ZERO;
                                if (priceOriginal == null) priceOriginal = priceSale;
                    %>

                        <a class="p-card p-link" href="<%= ctx %>/chitiet?id=<%= masp %>">
                            <span class="p-thumb">
                                <img src="<%= ctx %>/images/<%= anhsp %>" alt="<%= tensp %>" loading="lazy">
                            </span>

                            <div class="product-price">
                                <span class="price-current">
                                    <%= vn.format(priceSale) %>đ
                                </span>

                                <% if (hasDiscount) { %>
                                    <span class="price-old">
                                        <s><%= vn.format(priceOriginal) %>đ</s>
                                    </span>
                                <% } %>
                            </div>

                            <span class="p-title"><%= tensp %></span>
                        </a>

                    <%
                            } // end for
                        } else { // không có sản phẩm
                    %>

                        <article class="p-card p-link">
                            <span class="p-thumb">
                                <img src="<%= ctx %>/images/placeholder-500x500.png" alt="No data" loading="lazy">
                            </span>
                            <span class="p-title">Chưa có sản phẩm</span>
                            <span class="p-price">—</span>
                        </article>

                    <% } %>
                </section>
                </div>

                <!-- ====== PHÂN TRANG (nếu có) ====== -->
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

        <!-- ================= FLOATING ACTIONS ================= -->
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="<%= ctx %>/lienhe.jsp" title="Liên hệ" aria-label="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat" href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff"
               target="_blank" rel="noopener" title="Chatbot" aria-label="Chatbot">
                <i class="fa-regular fa-comments"></i>
            </a>
        </div>

        <!-- ================= FOOTER ================= -->
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
