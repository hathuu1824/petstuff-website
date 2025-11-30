<%-- 
    Document   : cart
    Created on : 24 Nov 2025, 9:29:37 pm
    Author     : hathuu24
--%>
<%@ page import="java.util.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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
            username   = (String) ss.getAttribute("username"); 
            role       = (String) ss.getAttribute("role");   
        }
    }

    // ==== Nhận dữ liệu giỏ hàng từ CartServlet ====
    List<Map<String, Object>> cartItems =
        (List<Map<String, Object>>) request.getAttribute("cartItems");
    if (cartItems == null) cartItems = java.util.Collections.emptyList();

    Long subtotal = (Long) request.getAttribute("subtotal");
    Long discount = (Long) request.getAttribute("discount");
    Long shipping = (Long) request.getAttribute("shipping");
    Long total    = (Long) request.getAttribute("total");
    Long saved    = (Long) request.getAttribute("saved");

    if (subtotal == null) subtotal = 0L;
    if (discount == null) discount = 0L;
    if (shipping == null) shipping = 0L;
    if (total == null) total = 0L;
    if (saved == null) saved = 0L;
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="<%= ctx %>/css/cart.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Giỏ hàng</title>
    </head>
    <body
        data-ctx="<%= ctx %>"
        data-bank-code="CAKE"
        data-bank-account="0353086897"
        data-account-name="KIEU HA THU"
        data-qr-template="compact">
        <header>
            <!-- Header -->
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

            <!-- Dropdown -->
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
            <div class="cart-page">
                <div class="cart-header-simple">
                    <button class="back-btn" onclick="history.back()">
                        <i class="fa-solid fa-chevron-left"></i>
                    </button>
                    <h1>Giỏ hàng</h1>
                </div>

                <div class="cart-layout">
                    <div class="cart-box">
                        <div class="cart-header-row">
                            <div class="col-check">
                                <input type="checkbox" id="chkAll">
                                <label for="chkAll">Chọn tất cả</label>
                            </div>
                            <div class="col-name">Tên sản phẩm</div>
                            <div class="col-type">Phân loại</div>
                            <div class="col-price">Giá thành</div>
                            <div class="col-qty">Số lượng</div>
                            <div class="col-action">Thao tác</div>
                        </div>

                        <% if (cartItems.isEmpty()) { %>
                            <div class="cart-empty">
                                <div class="cart-empty-illustration">
                                    <div class="cart-icon"></div>
                                </div>
                                <h2>Giỏ hàng của bạn trống!</h2>
                                <p>Hãy thêm sản phẩm yêu thích vào giỏ hàng để thanh toán nhé!</p>
                                <button class="btn-primary"
                                        onclick="window.location.href='<%= ctx %>/sanpham'">
                                    Mua sắm ngay
                                </button>
                            </div>
                        <% } else { %>
                            <div class="cart-items">
                                <% for (Map<String,Object> item : cartItems) { %>
                                    <div class="cart-item-row"
                                         data-product-id="<%= item.get("sanphamId") %>">
                                        <div class="col-check">
                                            <input type="checkbox"
                                                   class="row-check"
                                                   name="selected"
                                                   value="<%= item.get("cartId") %>">
                                        </div>
                                        <div class="col-name">
                                            <span class="cart-item-name">
                                                <%= item.get("tenSP") %>
                                            </span>
                                        </div>
                                        <div class="col-type">
                                            <span>
                                                <%= item.get("loai") != null ? item.get("loai") : "-" %>
                                            </span>
                                        </div>
                                        <div class="col-price">
                                            <span><%= item.get("gia") %>đ</span>
                                        </div>
                                        <div class="col-qty">
                                            <form class="qty-form"
                                                  action="<%= ctx %>/cart"
                                                  method="post">
                                                <input type="hidden" name="action" value="updateQty">
                                                <input type="hidden" name="id" value="<%= item.get("cartId") %>">

                                                <button type="submit"
                                                        name="op"
                                                        value="minus"
                                                        class="qty-btn minus">−</button>

                                                <span class="qty-value">
                                                    <%= item.get("soLuong") %>
                                                </span>

                                                <button type="submit"
                                                        name="op"
                                                        value="plus"
                                                        class="qty-btn plus">+</button>
                                            </form>
                                        </div>
                                        <div class="col-action">
                                            <a href="<%= ctx %>/cart?action=remove&id=<%= item.get("cartId") %>">
                                                Xóa
                                            </a>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>

                    <aside class="summary-box">
                        <div class="summary-title">Tóm tắt đơn hàng</div>

                        <div class="summary-line">
                            <span>Tạm tính:</span>
                            <span><strong><%= subtotal %>đ</strong></span>
                        </div>
                        <div class="summary-line">
                            <span>Giảm giá:</span>
                            <span><strong><%= discount %>đ</strong></span>
                        </div>
                        <div class="summary-line">
                            <span>Phí ship:</span>
                            <span><strong><%= shipping %>đ</strong></span>
                        </div>
                        <div class="summary-line">
                            <span>Tiết kiệm được:</span>
                            <span><strong><%= saved %>đ</strong></span>
                        </div>

                        <div class="summary-divider"></div>

                        <div class="summary-total">
                            <span>Tổng tiền:</span>
                            <span><%= total %>đ</span>
                        </div>

                        <button class="summary-buy-btn">MUA HÀNG</button>
                    </aside>
                </div>
            </div>

            <!-- Modal thanh toán -->
            <div id="cartCheckoutModal" class="modal">
                <div class="modal-content">
                    <span class="close-btn" id="cartModalClose">&times;</span>

                    <div class="payment-info">
                        <h2>Thông tin thanh toán</h2>

                        <p>
                            Tổng số sản phẩm:
                            <span id="cartModalItemCount">0</span>
                        </p>
                        <p>
                            Tạm tính:
                            <span id="cartModalSubtotal">0đ</span>
                        </p>
                        <p>
                            Phí ship:
                            <span id="cartModalShip" data-ship="30000">30.000đ</span>
                        </p>
                        <p>
                            Giảm giá:
                            <span id="cartModalDiscount" data-discount="0">0đ</span>
                        </p>
                        <p>
                            <strong>Thành tiền:</strong>
                            <span id="cartModalTotal">0đ</span>
                        </p>

                        <div class="form-group horizontal">
                            <label for="cartPaymentMethod">Phương thức thanh toán:</label>
                            <select id="cartPaymentMethod" class="form-control">
                                <option value="COD">Thanh toán khi nhận hàng</option>
                                <option value="BANK">Chuyển khoản ngân hàng</option>
                            </select>
                        </div>

                        <div id="cartBankTransferBox"
                             class="bank-transfer"
                             style="display:none;">
                            <h3>Quét mã QR để thanh toán</h3>
                            <div class="qr">
                                <div class="qr-wrap">
                                    <img id="cartVietqrImg"
                                         alt="VietQR"
                                         style="max-width:240px;width:100%;border-radius:8px;">
                                </div>
                                <div class="qr-meta">
                                    <p>Ngân hàng: <span id="cartBankLabel"></span></p>
                                    <p>Chủ TK: <span id="cartAccNameLabel"></span></p>
                                    <p>Số TK: <span id="cartAccNoLabel"></span></p>
                                    <p>Số tiền: <strong id="cartTransferAmountLabel"></strong></p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal-actions">
                        <button id="cartConfirmBtn" class="btn btn-primary">Xác nhận</button>
                        <button id="cartModalCloseBtn" class="btn btn-secondary">Đóng</button>
                    </div>
                </div>
            </div>
        </main>      

        <!-- Liên hệ -->        
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
                        <a href="https://www.facebook.com" aria-label="Facebook">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="https://www.tiktok.com" aria-label="TikTok">
                            <i class="fab fa-tiktok"></i>
                        </a>
                        <a href="https://www.instagram.com" aria-label="Instagram">
                            <i class="fab fa-instagram"></i>
                        </a>
                        <a href="https://www.twitter.com" aria-label="Twitter">
                            <i class="fab fa-twitter"></i>
                        </a>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <p>Copyright &copy; 2025</p>
            </div>
        </footer>

        <script src="<%= ctx %>/javascript/cart.js"></script>
    </body>
</html>
