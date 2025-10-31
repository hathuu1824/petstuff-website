<%-- 
    Document   : extent
    Created on : 20 Sept 2025, 3:03:50 pm
    Author     : hathuu24
--%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@page import="java.util.List"%>
<%@ page import="webnhoibong.DatabaseConnection" %>
<%@page import="model.OptionItem"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Lấy dữ liệu từ Servlet
    String mainImage = (String) request.getAttribute("mainImage");
    List<String> optionImages = (List<String>) request.getAttribute("optionImages");

    List<OptionItem> optionList = (List<OptionItem>) request.getAttribute("optionList");
    List<String> optionNames = (List<String>) request.getAttribute("optionNames");
    Map<String, Integer> optionPriceMap = (Map<String, Integer>) request.getAttribute("optionPriceMap");

    String description = (String) request.getAttribute("description");

    // Build JSON cho data-option-prices (không dùng Gson)
    String optionPriceJsonStr = "{}";
    if (optionPriceMap != null && !optionPriceMap.isEmpty()) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Integer> e : optionPriceMap.entrySet()) {
            if (!first) sb.append(',');
            String k = (e.getKey() == null ? "Mặc định" : e.getKey()).replace("\"", "\\\"");
            int v = (e.getValue() == null ? 0 : e.getValue());
            sb.append("\"").append(k).append("\":").append(v);
            first = false;
        }
        sb.append('}');
        optionPriceJsonStr = sb.toString();
    } else {
        // Fallback nếu map rỗng mà vẫn cần JSON cho JS
        if (optionList != null && !optionList.isEmpty()) {
            optionPriceJsonStr = "{\"Mặc định\":" + optionList.get(0).getPrice() + "}";
        }
    }
%>
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
            <div class="product-container">
                <div class="product-gallery">
                    <div class="main-image">
                        <img src="<%= mainImage %>" alt="anh1">
                    </div>
                    <div class="thumbnail-container">
                        <% if (optionImages != null && !optionImages.isEmpty()) {
                            for (String img : optionImages) { %>
                          <div class="thumbnail"><img src="<%= img %>" alt="option"></div>
                        <% } } else { %>
                            Không có ảnh mẫu sản phẩm
                        <% } %>
                    </div>
                </div>
                    
                <div class="product-details"
                        data-order-id="<%= orderId %>"
                        data-bank-code="VCB"
                        data-bank-account="0123456789"
                        data-account-name="CONG TY PETSTUFF"
                        data-qr-template="compact">
                    <h1>${product.name}</h1>
                    <% if (optionList != null && !optionList.isEmpty()) { %>
                        <div class="price"
                             data-base-price="<%= optionList.get(0).getPrice() %>"
                             data-option-prices='<%= optionPriceJsonStr %>'>
                            <%= optionList.get(0).getPrice() %>đ
                        </div>
                    <% } else { %>
                        <div class="price">Không có tuỳ chọn sản phẩm.</div>
                    <% } %>

                    <div class="product-shipping">
                        <h2>Vận chuyển:</h2>
                        <p>Nhận hàng trong 7–10 ngày, phí giao 0₫</p>
                    </div>
                    <div class="product-options">
                        <% if (optionNames != null && !optionNames.isEmpty()) {
                             for (int i = 0; i < optionNames.size(); i++) {
                               String name = optionNames.get(i); %>
                            <button
                              class="option-btn <%= (i == 0 ? "active" : "") %>"
                              data-option-name="<%= name %>"><%= name %></button>
                        <% } } else { %>
                            Không có mẫu sản phẩm nào
                        <% } %>
                    </div>

                    <div class="product-quantity">
                        <h2>Số lượng:</h2>
                        <button class="qty-btn minus">-</button>
                        <input type="number" id="qtyInput" value="1" min="1" max="100">
                        <button class="qty-btn plus">+</button>
                    </div>
                    <button class="cart-btn">Thêm vào giỏ hàng</button>
                    <button class="buy-btn">Mua ngay</button>

                    <div id="buyModal" class="modal">
                        <div class="modal-content">
                            <span class="close-btn">&times;</span>
                            <div class="payment-info">
                                <h2>Thông tin thanh toán</h2>
                                <p>Tên sản phẩm: <span id="modalProductName">${product.name}</span></p>
                                <p>Số lượng: <span id="modalQuantity">1</span></p>
                                <p>Phí ship: <span id="modalShipFee" data-ship="30000">30.000₫</span></p>
                                <p>Giảm giá: <span id="modalDiscount" data-discount="0">0₫</span></p>
                                <p><strong>Thành tiền:</strong> <span id="modalTotalPrice"></span></p>
                                <div class="form-group horizontal">
                                    <label for="paymentMethod">Phương thức thanh toán:</label>
                                    <select id="paymentMethod" class="form-control">
                                        <option value="COD">Thanh toán khi nhận hàng</option>
                                        <option value="Bank">Chuyển khoản ngân hàng</option>
                                    </select>
                                </div>
                                <div id="bankTransferBox" class="bank-transfer" style="display:none;">
                                    <h3>Quét mã QR để thanh toán</h3>
                                    <div class="qr">
                                        <div class="qr-wrap">
                                            <img id="vietqrImg" alt="VietQR" style="max-width:240px;width:100%;border-radius:8px;">
                                        </div>
                                        <div class="qr-meta">
                                            <p>Ngân hàng: <span id="bankLabel"></span></p>
                                            <p>Chủ TK: <span id="accNameLabel"></span></p>
                                            <p>Số TK: <span id="accNoLabel"></span></p>
                                            <p>Số tiền: <strong id="transferAmountLabel"></strong></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-actions">
                                <button class="btn btn-secondary cancel-btn">Xác nhận</button>
                                <button class="btn btn-secondary cancel-btn">Đóng</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <section class="product-extra">
                <div class="extra-info">
                    <div class="info-card">
                        <h3 class="card-title">CHI TIẾT SẢN PHẨM</h3>
                        <dl class="card-spec">
                            <div class="card-row">
                                <dt>Danh mục</dt><dd><span class="muted">Đang cập nhật</span></dd>
                            </div>
                            <div class="card-row">
                                <dt>Kho</dt><dd><strong>CÒN HÀNG</strong></dd>
                            </div>
                            <div class="card-row">
                                <dt>Chất liệu</dt><dd><span class="muted">Đang cập nhật</span></dd>
                            </div>
                            <div class="card-row">
                                <dt>Xuất xứ</dt><dd><span class="muted">Đang cập nhật</span></dd>
                            </div>
                        </dl>
                    </div>
                    <div class="info-card">
                        <h3 class="card-title">MÔ TẢ SẢN PHẨM</h3>
                        <div class="desc">
                            <%= (description != null ? description : "") %>
                        </div>
                    </div>
                </div>
            </section>
        </main>
                    
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact" href="" title="Liên hệ" aria-label="Liên hệ">
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
        <script src="javascript/detail.js"></script>    
    </body>
</html>
