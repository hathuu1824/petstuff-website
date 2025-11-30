<%-- 
    Document   : order
    Created on : 27 Nov 2025
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    private String fmtMoney(BigDecimal v) {
        if (v == null) return "0đ";
        return String.valueOf(v.longValue()) + "đ";
    }

    private String fmtDate(Timestamp ts) {
        if (ts == null) return "";
        return ts.toLocalDateTime().toLocalDate().toString();
    }

    private String fmtStatus(String s) {
        if (s == null) return "";
        switch (s) {
            case "PENDING":    return "Chờ duyệt";
            case "PACKED":     return "Chờ đóng gói";
            case "WAIT_SHIP":  return "Đang giao";
            case "DELIVERED":  return "Đã giao";
            case "CANCELED":   return "Đã hủy";
            case "RETURNED":   return "Hoàn trả";
            default:           return s;
        }
    }

    // status để lọc theo tab
    private String statusSlug(String s) {
        if (s == null) return "khac";
        switch (s) {
            case "PENDING":
            case "PACKED":    return "cho-duyet";
            case "WAIT_SHIP": return "dang-giao";
            case "DELIVERED": return "da-giao";
            case "CANCELED":  return "da-huy";
            default:          return "khac";
        }
    }
%>

<%
    String ctx = request.getContextPath();

    List<Map<String,Object>> orders =
        (List<Map<String,Object>>) request.getAttribute("orders");
    if (orders == null) orders = java.util.Collections.emptyList();

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
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Đơn hàng</title>
        <link rel="stylesheet" href="<%= ctx %>/css/order.css">
        <!-- Boxicons không dùng nên bỏ -->
        <!-- <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css"> -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>

    <body>
        <!-- ========== HEADER ========== -->
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

        <!-- ========== MAIN ========== -->
        <main class="orders-main">
            <section class="orders-hero">
                <h1>Theo dõi đơn hàng của bạn</h1>
                <div class="orders-tabs">
                    <button class="tab-btn active" data-tab="all">Tất cả</button>
                    <button class="tab-btn" data-tab="cho-duyet">Chờ duyệt</button>
                    <button class="tab-btn" data-tab="dang-giao">Đang giao</button>
                    <button class="tab-btn" data-tab="da-giao">Đã giao</button>
                    <button class="tab-btn" data-tab="da-huy">Đã hủy</button>
                </div>
            </section>

            <section class="orders-section">
                <div class="orders-list">
                    <%
                        for (Map<String,Object> row : orders) {
                            long       madon      = (Long)       row.get("madon");
                            BigDecimal tongtien   = (BigDecimal) row.get("tongtien");
                            Timestamp  ngaytao    = (Timestamp)  row.get("ngaytao");
                            String     trangthai  = (String)     row.get("trangthai");
                            String     phuongthuc = (String)     row.get("phuongthuc");

                            String slug   = statusSlug(trangthai);
                            String status = fmtStatus(trangthai);
                    %>
                    <article class="order-card" data-status="<%= slug %>">
                        <div class="order-card-header">
                            <div>
                                <div class="order-id">Đơn hàng #<%= madon %></div>
                                <div class="order-date">Ngày đặt: <%= fmtDate(ngaytao) %></div>
                            </div>
                            <span class="order-status badge-<%= slug %>">
                                <%= status %>
                            </span>
                        </div>

                        <div class="order-card-body">
                            <div class="order-row">
                                <span>Tổng tiền</span>
                                <strong><%= fmtMoney(tongtien) %></strong>
                            </div>
                            <div class="order-row">
                                <span>Phương thức thanh toán</span>
                                <span>
                                    <%= "BANK".equals(phuongthuc) ? "Chuyển khoản ngân hàng"
                                        : "COD".equals(phuongthuc) ? "Thanh toán khi nhận hàng"
                                        : (phuongthuc != null ? phuongthuc : "") %>
                                </span>
                            </div>
                        </div>

                        <div class="order-card-footer">
                            <button type="button"
                                    class="btn-detail"
                                    onclick="showOrderDetail(<%= madon %>)">
                                Xem chi tiết
                            </button>
                        </div>
                    </article>
                    <%
                        }
                    %>
                </div>

                <div class="orders-empty" id="ordersEmpty">
                    <h2>Bạn chưa có đơn hàng nào</h2>
                    <p>Hãy mua sắm ngay để trải nghiệm những sản phẩm tuyệt vời của chúng tôi</p>
                    <button class="btn-shop"
                            onclick="window.location.href='<%= ctx %>/sanpham'">
                        Mua sắm ngay
                    </button>
                </div>
            </section>
        </main>

        <!-- ========== FLOATING CONTACT ========== -->
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

        <!-- ========== FOOTER ========== -->
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

        <!-- ========== MODAL CHI TIẾT ĐƠN (USER) ========== -->
        <div id="orderDetailModal" class="modal">
            <div class="modal-dialog">
                <div class="modal-header">
                    <h3>
                        <i class="fas fa-eye"></i> Chi tiết đơn hàng
                    </h3>
                    <button type="button"
                            class="modal-close-btn"
                            onclick="closeOrderModal()">
                        &times;
                    </button>
                </div>

                <div class="modal-body">
                    <!-- Hàng 1: Mã đơn + Người nhận -->
                    <div class="row2col">
                        <div class="form-group">
                            <label>Mã đơn:</label>
                            <input id="view-madon" class="form-control" disabled>
                        </div>
                        <div class="form-group">
                            <label>Người nhận:</label>
                            <input id="view-tennguoinhan" class="form-control" disabled>
                        </div>
                    </div>

                    <!-- Hàng 2: SĐT + Địa chỉ -->
                    <div class="row2col">
                        <div class="form-group">
                            <label>Số điện thoại:</label>
                            <input id="view-sdt" class="form-control" disabled>
                        </div>
                        <div class="form-group">
                            <label>Địa chỉ:</label>
                            <input id="view-diachi" class="form-control" disabled>
                        </div>
                    </div>

                    <hr class="modal-divider">

                    <!-- Sản phẩm -->
                    <h4 class="modal-section-title">Sản phẩm</h4>
                    <div id="view-order-items" class="order-items-box">
                        <!-- JS append .order-item vào đây -->
                    </div>

                    <!-- Hàng 3: Tổng tiền + Phương thức thanh toán -->
                    <div class="row2col modal-bottom-row">
                        <div class="form-group">
                            <label>Tổng tiền:</label>
                            <input id="view-tongtien" class="form-control" disabled>
                        </div>
                        <div class="form-group">
                            <label>Phương thức thanh toán:</label>
                            <input id="view-phuongthuc" class="form-control" disabled>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button"
                            class="btn-close-modal"
                            onclick="closeOrderModal()">
                        Đóng
                    </button>
                </div>
            </div>
        </div>

        <!-- ========== SCRIPTS ========== -->
        <script>
            // Context path cho JS
            var CTX = "<%= ctx %>";

            // Gọi từ onclick trong HTML
            function showOrderDetail(id) {
                fetch(CTX + "/donhang?action=detail&id=" + encodeURIComponent(id))
                    .then(function (res) {
                        if (!res.ok) {
                            throw new Error("HTTP " + res.status);
                        }
                        return res.json();
                    })
                    .then(function (order) {
                        openOrderModal(order);
                    })
                    .catch(function (err) {
                        console.error(err);
                        alert("Không tải được chi tiết đơn hàng. Vui lòng thử lại sau.");
                    });
            }

            function openOrderModal(order) {
                var modal     = document.getElementById("orderDetailModal");
                if (!modal) return;

                var madonEl   = document.getElementById("view-madon");
                var tenEl     = document.getElementById("view-tennguoinhan");
                var sdtEl     = document.getElementById("view-sdt");
                var dcEl      = document.getElementById("view-diachi");
                var tongEl    = document.getElementById("view-tongtien");
                var ptEl      = document.getElementById("view-phuongthuc");
                var itemsWrap = document.getElementById("view-order-items");

                if (madonEl) madonEl.value = "#" + (order.madon || "");
                if (tenEl)   tenEl.value   = order.tennguoinhan || "";
                if (sdtEl)   sdtEl.value   = order.sdt || "";
                if (dcEl)    dcEl.value    = order.diachi || "";

                if (tongEl) {
                    tongEl.value = Number(order.tongtien || 0).toLocaleString("vi-VN") + "₫";
                }

                if (ptEl) {
                    ptEl.value = order.phuongthucLabel || "";
                }

                if (itemsWrap) {
                    itemsWrap.innerHTML = "";
                    if (order.items && order.items.length > 0) {
                        order.items.forEach(function (item) {
                            var div  = document.createElement("div");
                            div.className = "order-item";

                            var name = item.tensanpham || item.tensp || "";
                            var sl   = item.soluong || 0;
                            var gia  = Number(item.gia || 0).toLocaleString("vi-VN") + "₫";

                            div.innerHTML =
                                  "<b>" + name + "</b><br>"
                                + "Số lượng: " + sl + "<br>"
                                + "Giá: " + gia;

                            itemsWrap.appendChild(div);
                        });
                    } else {
                        itemsWrap.innerHTML = "<em>Không có sản phẩm trong đơn này.</em>";
                    }
                }

                modal.style.display = "block";
            }

            function closeOrderModal() {
                var modal = document.getElementById("orderDetailModal");
                if (modal) modal.style.display = "none";
            }

            document.addEventListener("DOMContentLoaded", function () {

                // Popup user
                (function setupUserPopup() {
                    var userMenu   = document.querySelector(".user-menu");
                    var userToggle = document.querySelector(".user-toggle");
                    var userPopup  = document.getElementById("userPopup");

                    if (!userMenu || !userToggle || !userPopup) return;

                    userToggle.addEventListener("click", function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        userMenu.classList.toggle("open");
                    });

                    document.addEventListener("click", function (e) {
                        if (!userMenu.contains(e.target)) {
                            userMenu.classList.remove("open");
                        }
                    });

                    document.addEventListener("keydown", function (e) {
                        if (e.key === "Escape") {
                            userMenu.classList.remove("open");
                            closeOrderModal();
                        }
                    });
                })();

                // Tabs lọc đơn
                (function setupTabs() {
                    var tabs  = document.querySelectorAll(".tab-btn");
                    var cards = document.querySelectorAll(".order-card");
                    var empty = document.getElementById("ordersEmpty");

                    if (!tabs.length || !empty) return;

                    function applyFilter(tab) {
                        var shown = 0;
                        cards.forEach(function (card) {
                            var st   = card.getAttribute("data-status");
                            var show = (tab === "all") || (st === tab);
                            card.style.display = show ? "block" : "none";
                            if (show) shown++;
                        });
                        empty.style.display = (shown === 0 ? "flex" : "none");
                    }

                    tabs.forEach(function (btn) {
                        btn.addEventListener("click", function () {
                            tabs.forEach(function (b) { b.classList.remove("active"); });
                            btn.classList.add("active");
                            applyFilter(btn.getAttribute("data-tab"));
                        });
                    });

                    applyFilter("all");
                })();

                // Click nền để đóng modal
                (function setupModalClose() {
                    var modal = document.getElementById("orderDetailModal");
                    if (!modal) return;

                    modal.addEventListener("click", function (e) {
                        if (e.target === modal) {
                            closeOrderModal();
                        }
                    });
                })();
            });
        </script>
    </body>
</html>
