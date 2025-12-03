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
<%
    String ctx = request.getContextPath();
%>
<%!
    private String fmtMoney(BigDecimal v) {
        if (v == null) return "0đ";
        return String.format("%,dđ", v.longValue());
    }

    private String fmtDate(Timestamp ts) {
        if (ts == null) return "";
        return ts.toLocalDateTime().toLocalDate().toString();
    }

    private String fmtStatus(String s) {
        if (s == null) return "";
        switch (s) {
            case "PENDING":    return "Chờ duyệt";
            case "WAIT_PACK":  return "Chờ đóng gói";
            case "WAIT_SHIP":  return "Đang giao";
            case "DELIVERED":  return "Đã giao";
            case "CANCELED":   return "Đã hủy";
            case "RETURNED":   return "Hoàn trả";
            default:           return s;
        }
    }

    private String statusSlug(String s) {
        if (s == null) return "khac";
        switch (s) {
            case "PENDING":    return "cho-duyet";
            case "WAIT_PACK":  return "cho-dong-goi";
            case "WAIT_SHIP":  return "dang-giao";
            case "DELIVERED":  return "da-giao";
            case "CANCELED":
            case "RETURNED":   return "da-huy";
            default:           return "khac";
        }
    }
%>
<%

    List<Map<String,Object>> orders =
        (List<Map<String,Object>>) request.getAttribute("orders");
    if (orders == null) orders = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Đơn hàng</title>
        <link rel="stylesheet" href="<%= ctx %>/css/order.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <%
            HttpSession ss = request.getSession(false);

            boolean isLoggedIn = false;
            String username = null;
            String role = null;
            String avatarFile = null; 

            if (ss != null) {
                Integer userId = (Integer) ss.getAttribute("userId");
                if (userId != null) {
                    isLoggedIn = true;
                    username = (String) ss.getAttribute("username"); 
                    role     = (String) ss.getAttribute("role");  
                    avatarFile = (String) ss.getAttribute("avatarPath"); 
                }
            }
            
            String avatarUrl;
            if (avatarFile == null || avatarFile.trim().isEmpty()) {
                avatarUrl = ctx + "/images/avatar-default.png";
            } else {
                avatarUrl = ctx + "/images/" + avatarFile;
            }
        %>
        <header>
            <!-- Header -->
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
                                        <img src="<%= avatarUrl %>" alt="Avatar">
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
                    <button class="tab-btn" data-tab="cho-dong-goi">Chờ đóng gói</button>
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
                <div class="orders-pagination" id="ordersPagination"></div>
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
                    <p><a href="<%= ctx %>/introduction.jsp">Giới thiệu</a></p>
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

        <!-- ========== MODAL CHI TIẾT ĐƠN (USER) ========== -->
        <div id="orderDetailModal" class="modal">
            <div class="modal-dialog">
                <div class="modal-header">
                    <h3><i class="fas fa-eye"></i> Chi tiết đơn hàng</h3>
                    <button type="button" class="modal-close-btn" onclick="closeOrderModal()">
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

                    <!-- Sản phẩm (giữ giống hình 1) -->
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
                    <button type="button" class="btn-close-modal" onclick="closeOrderModal()">
                        Đóng
                    </button>
                </div>
            </div>
        </div>

        <script>
            // Dùng lại context path trong JS
            var CTX = "<%= ctx %>";

            /* ========== HÀM GỌI API CHI TIẾT ĐƠN ========== */
            function showOrderDetail(id) {
                fetch(CTX + "/donhang?action=detail&id=" + encodeURIComponent(id))
                    .then(function (res) {
                        if (!res.ok) throw new Error("HTTP " + res.status);
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

            /* ========== MODAL CHI TIẾT ========== */
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
                                "<b>" + name + "</b><br>" +
                                "Số lượng: " + sl + "<br>" +
                                "Giá: " + gia;

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

            /* ========== SETUP POPUP USER ========== */
            function setupUserPopup() {
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
            }

            /* ========== CLICK NỀN ĐÓNG MODAL ========== */
            function setupModalClose() {
                var modal = document.getElementById("orderDetailModal");
                if (!modal) return;

                modal.addEventListener("click", function (e) {
                    if (e.target === modal) {
                        closeOrderModal();
                    }
                });
            }

            /* ========== TABS + PHÂN TRANG ========== */
            function setupTabsAndPagination() {
                var PAGE_SIZE = 5;

                var tabs  = document.querySelectorAll(".tab-btn");
                var cards = Array.from(document.querySelectorAll(".order-card"));
                var empty = document.getElementById("ordersEmpty");
                var pager = document.getElementById("ordersPagination");

                // Không có đơn nào
                if (!cards.length) {
                    if (empty) empty.style.display = "flex";
                    if (pager) pager.innerHTML = "";
                    return;
                }

                var currentTab  = "all";
                var currentPage = 1;

                function filterCards() {
                    if (currentTab === "all") return cards;
                    return cards.filter(function (c) {
                        return c.getAttribute("data-status") === currentTab;
                    });
                }

                function render() {
                    var list  = filterCards();
                    var total = list.length;
                    var pages = Math.max(1, Math.ceil(total / PAGE_SIZE));

                    if (currentPage > pages) currentPage = pages;

                    // Ẩn hết
                    cards.forEach(function (c) { c.style.display = "none"; });

                    // Không có đơn ở tab hiện tại
                    if (total === 0) {
                        if (empty) empty.style.display = "flex";
                        if (pager) pager.innerHTML = "";
                        return;
                    }

                    if (empty) empty.style.display = "none";

                    // Hiện theo trang
                    var start = (currentPage - 1) * PAGE_SIZE;
                    list.slice(start, start + PAGE_SIZE).forEach(function (c) {
                        c.style.display = "block";
                    });

                    // Không cần phân trang nếu chỉ 1 trang
                    if (!pager || pages <= 1) {
                        if (pager) pager.innerHTML = "";
                        return;
                    }

                    // Vẽ nút trang 
                    var html = "";

                    // prev
                    html += '<button class="page-btn" data-page="prev"';
                    if (currentPage === 1) html += ' disabled';
                    html += '>&laquo;</button>';

                    // số trang
                    for (var i = 1; i <= pages; i++) {
                        html += '<button class="page-btn';
                        if (i === currentPage) html += ' active';
                        html += '" data-page="' + i + '">' + i + '</button>';
                    }

                    // next
                    html += '<button class="page-btn" data-page="next"';
                    if (currentPage === pages) html += ' disabled';
                    html += '>&raquo;</button>';

                    pager.innerHTML = html;
                }

                // Click tab
                tabs.forEach(function (btn) {
                    btn.addEventListener("click", function () {
                        tabs.forEach(function (b) { b.classList.remove("active"); });
                        btn.classList.add("active");

                        currentTab  = btn.getAttribute("data-tab");
                        currentPage = 1;
                        render();
                    });
                });

                // Click phân trang
                if (pager) {
                    pager.addEventListener("click", function (e) {
                        var target = e.target;
                        if (!target.classList.contains("page-btn")) return;

                        var p = target.getAttribute("data-page");
                        var list  = filterCards();
                        var total = list.length;
                        var pages = Math.max(1, Math.ceil(total / PAGE_SIZE));

                        if (p === "prev" && currentPage > 1) {
                            currentPage--;
                        } else if (p === "next" && currentPage < pages) {
                            currentPage++;
                        } else if (p !== "prev" && p !== "next") {
                            var num = parseInt(p, 10);
                            if (!isNaN(num)) currentPage = num;
                        }

                        render();
                    });
                }

                // Render lần đầu
                render();
            }

            /* ========== CHẠY SAU KHI DOM SẴN SÀNG ========== */
            document.addEventListener("DOMContentLoaded", function () {
                setupUserPopup();
                setupModalClose();
                setupTabsAndPagination();
            });
        </script>
    </body>
</html>
