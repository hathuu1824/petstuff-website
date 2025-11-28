<%-- 
    Document   : detail
    Mô tả      : Trang chi tiết sản phẩm + Mua ngay + Thêm vào giỏ hàng
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    /* ================== Chuẩn bị dữ liệu ================== */
    String ctx = request.getContextPath();

    HttpSession ss = request.getSession(false);
    boolean isLoggedIn = false;
    String username = null;
    String role = null;
    Integer userId = null;

    if (ss != null) {
        userId   = (Integer) ss.getAttribute("userId");
        username = (String) ss.getAttribute("username");
        role     = (String) ss.getAttribute("role");
        if (userId != null) isLoggedIn = true;
    }

    @SuppressWarnings("unchecked")
    Map<String,Object> productMap =
        (Map<String,Object>) request.getAttribute("product");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> optionMapList =
        (List<Map<String,Object>>) request.getAttribute("options");

    if (productMap == null) {
        response.sendRedirect(ctx + "/sanpham");
        return;
    }

    String productName   = (String) productMap.get("name");
    String description   = (String) productMap.get("description");
    String mainImageName = (String) productMap.get("imageMain");
    String mainImage     = (mainImageName != null && !mainImageName.isEmpty())
                           ? (ctx + "/images/" + mainImageName)
                           : (ctx + "/images/placeholder-500x500.png");

    BigDecimal priceOriginal = (BigDecimal) productMap.get("priceOriginal");
    BigDecimal priceSale     = (BigDecimal) productMap.get("priceSale");
    boolean hasDiscount      = Boolean.TRUE.equals(productMap.get("hasDiscount"));

    if (priceSale == null && priceOriginal != null)  priceSale = priceOriginal;
    if (priceOriginal == null && priceSale != null)  priceOriginal = priceSale;
    if (priceSale == null)     priceSale     = BigDecimal.ZERO;
    if (priceOriginal == null) priceOriginal = priceSale;

    NumberFormat nf = NumberFormat.getInstance(new java.util.Locale("vi", "VN"));

    /* ========= Ảnh & option + giá cho JS ========= */
    List<String> optionImages = new ArrayList<>();
    Map<String, BigDecimal> optionPriceMap = new LinkedHashMap<>();

    BigDecimal defaultSalePrice = priceSale;
    Integer defaultOptionId = null;

    if (optionMapList != null) {
        for (Map<String,Object> opt : optionMapList) {
            Integer    optId        = (Integer) opt.get("id");
            String     tenLoai      = (String) opt.get("ten_loai");
            BigDecimal giaSaleOpt   = (BigDecimal) opt.get("giaSale");
            String     anh          = (String) opt.get("anh");
            Boolean    isDefaultOpt = (Boolean) opt.get("isDefault");

            if (tenLoai == null || tenLoai.isEmpty()) tenLoai = "Mặc định";

            String imgPath = (anh != null && !anh.isEmpty())
                             ? (ctx + "/images/" + anh)
                             : mainImage;
            optionImages.add(imgPath);

            if (giaSaleOpt == null) giaSaleOpt = priceSale;
            optionPriceMap.put(tenLoai, giaSaleOpt);

            if (Boolean.TRUE.equals(isDefaultOpt) && defaultOptionId == null) {
                defaultOptionId  = optId;
                defaultSalePrice = giaSaleOpt;
            }
        }
    }

    if (defaultOptionId == null && optionMapList != null && !optionMapList.isEmpty()) {
        defaultOptionId  = (Integer) optionMapList.get(0).get("id");
        defaultSalePrice = (BigDecimal) optionMapList.get(0).get("giaSale");
        if (defaultSalePrice == null) defaultSalePrice = priceSale;
    }
    if (defaultSalePrice == null) defaultSalePrice = priceSale;

    String optionPriceJsonStr = "{}";
    if (!optionPriceMap.isEmpty()) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;

        for (Map.Entry<String, BigDecimal> e : optionPriceMap.entrySet()) {
            if (!first) sb.append(',');

            String k = e.getKey().replace("\"", "\\\"");
            BigDecimal v = e.getValue();
            if (v == null) v = defaultSalePrice;
            long vLong = v.longValue();

            sb.append("\"")
              .append(k)
              .append("\":")
              .append(vLong);

            first = false;
        }
        sb.append('}');
        optionPriceJsonStr = sb.toString();
    }

    int productIdInt = ((Number) productMap.get("id")).intValue();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title><%= (productName != null ? productName : "Chi tiết sản phẩm") %></title>
        <link rel="stylesheet" href="<%= ctx %>/css/detail.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body
        data-logged-in="<%= isLoggedIn %>"
        data-ctx="<%= ctx %>"
        data-bank-code="CAKE"
        data-bank-account="0353086897"
        data-account-name="KIEU HA THU"
        data-qr-template="compact">
        <header>
            <nav class="container">
                <a href="<%= ctx %>/trangchu" id="logo">PetStuff</a>

                <div class="buttons">
                    <% if (isLoggedIn) { %>
                        <a class="icon-btn"
                           href="<%= ctx %>/cart"
                           aria-label="Giỏ hàng"
                           title="Giỏ hàng">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </a>
                        <div class="user-menu">
                            <a class="icon-btn user-toggle"
                               href="#"
                               aria-label="Tài khoản"
                               title="Tài khoản">
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

            <div class="subbar" id="subbar">
                <nav class="subnav">
                    <ul class="subnav-list">
                        <li><a href="<%= ctx %>/trangchu">Trang chủ</a></li>

                        <li class="has-dd">
                            <button class="dd-toggle" type="button">
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
                            <button class="dd-toggle" type="button">
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

        <main class="main">
            <div class="product-container">
                <!-- Gallery -->
                <div class="product-gallery">
                    <div class="main-image">
                        <img src="<%= mainImage %>" alt="ảnh sản phẩm">
                    </div>
                    <div class="thumbnail-container">
                        <% if (!optionImages.isEmpty()) {
                               for (String img : optionImages) { %>
                            <div class="thumbnail">
                                <img src="<%= img %>" alt="option">
                            </div>
                        <% }
                           } else { %>
                            Không có ảnh mẫu sản phẩm
                        <% } %>
                    </div>
                </div>

                <!-- Thông tin + Mua -->
                <div class="product-details"
                     data-product-id="<%= productIdInt %>"
                     data-product-name="<%= productName != null ? productName : "" %>"
                     data-order-url="<%= ctx %>/order">
                    <h1><%= productName %></h1>
                    <div class="price"
                         id="priceBlock"
                         data-base-price="<%= defaultSalePrice.longValue() %>"
                         data-option-prices='<%= optionPriceJsonStr %>'>
                        <span class="price-current" id="detailSalePrice">
                            <%= nf.format(defaultSalePrice) %>đ
                        </span>
                        <% if (hasDiscount) { %>
                            <span class="price-old">
                                <s><%= nf.format(priceOriginal) %>đ</s>
                            </span>
                        <% } %>
                    </div>
                    <div class="product-shipping">
                        <h2>Vận chuyển:</h2>
                        <p>Nhận hàng trong 7–10 ngày, phí giao 0₫</p>
                    </div>

                    <!-- Loại sản phẩm -->
                    <div class="product-options">
                        <% if (optionMapList != null && !optionMapList.isEmpty()) {
                               for (int i = 0; i < optionMapList.size(); i++) {
                                   Map<String,Object> opt = optionMapList.get(i);
                                   String optName = (String) opt.get("ten_loai");
                                   if (optName == null || optName.isEmpty()) optName = "Mặc định";
                                   Integer optId  = (Integer) opt.get("id");
                                   BigDecimal giaSaleBtn = (BigDecimal) opt.get("giaSale");
                                   if (giaSaleBtn == null) giaSaleBtn = defaultSalePrice;
                        %>
                            <button class="option-btn <%= (i == 0 ? "active" : "") %>"
                                    data-option-id="<%= optId %>"
                                    data-option-name="<%= optName %>"
                                    data-price="<%= giaSaleBtn.longValue() %>">
                                <%= optName %>
                            </button>
                        <%     }
                           } else { %>
                            Không có mẫu sản phẩm nào
                        <% } %>
                    </div>

                    <!-- Số lượng -->
                    <div class="product-quantity">
                        <h2>Số lượng:</h2>
                        <button class="qty-btn minus" type="button">-</button>
                        <input type="number" id="qtyInput" value="1" min="1" max="100">
                        <button class="qty-btn plus" type="button">+</button>
                    </div>

                    <!-- Nút hành động -->
                    <form id="addCartForm"
                          action="<%= ctx %>/chitiet"
                          method="post"
                          style="display:inline-block;">
                        <input type="hidden" name="sanpham_id" value="<%= productIdInt %>">
                        <input type="hidden" name="loai_id" id="loaiIdInput"
                               value="<%= defaultOptionId != null ? defaultOptionId : 0 %>">
                        <input type="hidden" name="soluong" id="qtyHiddenInput" value="1">

                        <button id="addToCartBtn" class="cart-btn" type="submit">
                            Thêm vào giỏ hàng
                        </button>
                    </form>

                    <button id="buyNowBtn" class="buy-btn" type="button">
                        Mua ngay
                    </button>

                    <!-- Modal mua ngay + QR -->
                    <div id="buyModal" class="modal">
                        <div class="modal-content">
                            <span class="close-btn">&times;</span>
                            <div class="payment-info">
                                <h2>Thông tin thanh toán</h2>
                                <p>
                                    Tên sản phẩm:
                                    <span id="modalProductName"><%= productName %></span>
                                </p>
                                <p>
                                    Số lượng:
                                    <span id="modalQuantity">1</span>
                                </p>
                                <p>
                                    Giá sản phẩm:
                                    <span id="modalUnitPrice"></span>
                                </p>
                                <p>
                                    Phí ship:
                                    <span id="modalShipFee" data-ship="30000">30.000₫</span>
                                </p>
                                <p>
                                    Giảm giá:
                                    <span id="modalDiscount" data-discount="0">0₫</span>
                                </p>
                                <p>
                                    <strong>Thành tiền:</strong>
                                    <span id="modalTotalPrice"></span>
                                </p>
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
                                            <img id="vietqrImg"
                                                 alt="VietQR"
                                                 style="max-width:240px;width:100%;border-radius:8px;">
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
                                <button id="confirmOrderBtn" class="btn btn-primary">Xác nhận</button>
                                <button id="closeModalBtn" class="btn btn-secondary">Đóng</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Extra info -->
            <section class="product-extra">
                <div class="extra-info">
                    <div class="info-card">
                        <h3 class="card-title">CHI TIẾT SẢN PHẨM</h3>
                        <dl class="card-spec">
                            <div class="card-row">
                                <dt>Danh mục</dt>
                                <dd><span class="muted">Đang cập nhật</span></dd>
                            </div>
                            <div class="card-row">
                                <dt>Kho</dt>
                                <dd><strong>CÒN HÀNG</strong></dd>
                            </div>
                            <div class="card-row">
                                <dt>Chất liệu</dt>
                                <dd><span class="muted">Đang cập nhật</span></dd>
                            </div>
                            <div class="card-row">
                                <dt>Xuất xứ</dt>
                                <dd><span class="muted">Đang cập nhật</span></dd>
                            </div>
                        </dl>
                    </div>
                    <div class="info-card">
                        <h3 class="card-title">MÔ TẢ SẢN PHẨM</h3>
                        <div class="desc">
                            <%= description != null ? description : "" %>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <!-- Popup chưa đăng nhập -->
        <div id="loginPopup" class="popup-overlay">
            <div class="popup-box">
                <h3>Bạn không thể thực hiện khi chưa đăng nhập</h3>
                <div class="popup-actions">
                    <button id="popupCancel" class="btn-cancel">Hủy</button>
                    <button id="popupOK" class="btn-ok">OK</button>
                </div>
            </div>
        </div>

        <!-- Popup tạo đơn hàng thành công -->
        <div id="orderSuccessPopup" class="popup-overlay">
            <div class="popup-box">
                <h3>Tạo đơn hàng thành công</h3>
                <p>Mã đơn hàng: <span id="successOrderId"></span></p>
                <div class="popup-actions">
                    <button id="orderStayBtn" class="btn-cancel">Đóng</button>
                    <button id="orderViewBtn" class="btn-ok">Xem đơn hàng</button>
                </div>
            </div>
        </div>

        <!-- Quick actions -->
        <div class="floating-actions" aria-label="Quick actions">
            <a class="fa-btn contact"
               href="<%= ctx %>/contact.jsp"
               title="Liên hệ"
               aria-label="Liên hệ">
                <i class="fa-solid fa-phone"></i>
            </a>
            <a class="fa-btn chat"
               href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff"
               target="_blank"
               rel="noopener"
               title="Chatbot"
               aria-label="Chatbot">
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
                    <p>
                        <a href="https://chatgpt.com/g/g-68e0907641548191a2cdbdea080e601d-petstuff">
                            Chatbot tư vấn
                        </a>
                    </p>
                </div>
                <div class="footer-social">
                    <h4>Theo dõi</h4>
                    <div class="social">
                        <a href="#"><i class="fab fa-facebook-f"></i></a>
                        <a href="#"><i class="fab fa-tiktok"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>Copyright &copy; 2025</p>
            </div>
        </footer>

        <script src="<%= ctx %>/javascript/detail.js"></script>
    </body>
</html>
