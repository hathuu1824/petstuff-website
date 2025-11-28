<%--
    Document   : order
    Created on : 24 Nov 2025
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    // Định dạng tiền: trả về số nguyên cho gọn
    private String fmtMoney(BigDecimal v) {
        if (v == null) return "";
        return String.valueOf(v.intValue());
    }

    // Hiển thị dạng đẹp cho phương thức thanh toán
    private String fmtPayment(String m) {
        if (m == null) return "";
        switch (m) {
            case "COD":  return "Thanh toán khi nhận hàng";
            case "BANK": return "Chuyển khoản ngân hàng";
            default:     return m;
        }
    }

    // Hiển thị dạng đẹp cho trạng thái đơn
    private String fmtStatus(String s) {
        if (s == null) return "";
        switch (s) {
            case "PENDING":   return "Chờ xác nhận";
            case "WAIT_PACK": return "Chờ đóng gói";
            case "WAIT_SHIP": return "Chờ giao hàng";
            case "DELIVERED": return "Đã giao";
            case "RETURNED":  return "Trả hàng";
            case "CANCELED":  return "Đã hủy";
            default:          return s;
        }
    }

    // Lấy đầy đủ ngày giờ (yyyy-MM-dd HH:mm:ss)
    private String fmtDateTime(Timestamp ts) {
        if (ts == null) return "";
        return ts.toLocalDateTime().toString().replace('T', ' ');
    }

    // Badge theo trạng thái
    private String statusBadge(String s) {
        if (s == null) return "badge-secondary";
        switch (s) {
            case "PENDING":   return "badge-warning";
            case "WAIT_PACK": return "badge-primary";
            case "WAIT_SHIP": return "badge-info";
            case "DELIVERED": return "badge-success";
            case "RETURNED":  return "badge-dark";
            case "CANCELED":  return "badge-danger";
            default:          return "badge-secondary";
        }
    }

    // Escape chuỗi để nhét an toàn vào JS
    private String jsStr(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'");
    }
%>

<%
    String ctx = request.getContextPath();

    HttpSession ss = request.getSession(false);
    String username = null;
    String role     = null;

    if (ss != null) {
        username = (String) ss.getAttribute("username");
        role     = (String) ss.getAttribute("role");
    }
    boolean isLoggedIn = (username != null);

    List<Map<String,Object>> orders =
        (List<Map<String,Object>>) request.getAttribute("orders");
    String loadError = (String) request.getAttribute("loadError");

    if (orders == null) orders = Collections.emptyList();

    // ===== Chia danh sách theo trạng thái =====
    List<Map<String,Object>> pendingOrders   = new ArrayList<>();
    List<Map<String,Object>> packOrders      = new ArrayList<>();
    List<Map<String,Object>> shippingOrders  = new ArrayList<>();
    List<Map<String,Object>> deliveredOrders = new ArrayList<>();
    List<Map<String,Object>> returnedOrders  = new ArrayList<>();
    List<Map<String,Object>> canceledOrders  = new ArrayList<>();

    for (Map<String,Object> row : orders) {
        String st = (String) row.get("trangthai");
        if ("PENDING".equals(st)) {
            pendingOrders.add(row);
        } else if ("WAIT_PACK".equals(st)) {
            packOrders.add(row);
        } else if ("WAIT_SHIP".equals(st)) {
            shippingOrders.add(row);
        } else if ("DELIVERED".equals(st)) {
            deliveredOrders.add(row);
        } else if ("RETURNED".equals(st)) {
            returnedOrders.add(row);
        } else if ("CANCELED".equals(st)) {
            canceledOrders.add(row);
        }
    }

    int pendingCount   = pendingOrders.size();
    int packCount      = packOrders.size();
    int shippingCount  = shippingOrders.size();
    int deliveredCount = deliveredOrders.size();
    int returnedCount  = returnedOrders.size();
    int canceledCount  = canceledOrders.size();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Trang quản trị</title>
        <link rel="stylesheet" href="<%= ctx %>/css/admin_order.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <!-- Header -->
        <header>
            <nav class="container">
                <a href="<%= ctx %>/admin_sanpham" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
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
                                    <a href="<%= ctx %>/profile" class="user-popup-item">
                                        <i class="fa-solid fa-user"></i>
                                        <span>Thông tin cá nhân</span>
                                    </a>
                                    <a href="<%= ctx %>/admin" class="user-popup-item">
                                        <i class="fa-solid fa-gear"></i>
                                        <span>Quản lý hệ thống</span>
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
        </header>

        <main class="main">
            <!-- Sidebar -->
            <div class="dashboard-sidebar">
                <aside class="sidebar">
                    <div class="sidebar-header">
                        <i class="fas fa-list" style="margin-right:6px;"></i>
                        <h2>Bảng điều khiển</h2>
                    </div>
                    <ul class="sidebar-menu">
                        <li><a href="<%= ctx %>/admin">Quản lý tài khoản</a></li>
                        <li><a href="<%= ctx %>/admin_sanpham">Quản lý sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_loaisp">Quản lý loại sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_donhang" class="active">Quản lý đơn hàng</a></li>
                        <li><a href="<%= ctx %>/admin_voucher">Quản lý voucher</a></li>
                        <li><a href="<%= ctx %>/admin_khuyenmai">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>

            <!-- Content -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1>Quản lý đơn hàng</h1>
                    <p>Theo dõi và cập nhật trạng thái các đơn đặt hàng</p>
                </div>

                <!-- Thống kê nhanh -->
                <div class="stat-cards">
                    <div class="stat-card">
                        <div class="stat-title">Chờ xác nhận</div>
                        <div class="stat-value"><%= pendingCount %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-title">Chờ đóng gói</div>
                        <div class="stat-value"><%= packCount %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-title">Chờ giao</div>
                        <div class="stat-value"><%= shippingCount %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-title">Đã giao</div>
                        <div class="stat-value"><%= deliveredCount %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-title">Hoàn trả</div>
                        <div class="stat-value"><%= returnedCount %></div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-title">Đã huỷ</div>
                        <div class="stat-value"><%= canceledCount %></div>
                    </div>
                </div>

                <% if (loadError != null) { %>
                    <div class="alert alert-danger"><%= loadError %></div>
                <% } %>

                <%-- ========== BẢNG: CHỜ XÁC NHẬN ========== --%>
                <div class="table-container">
                    <div class="table-header">
                        <h3>Đơn chờ xác nhận</h3>
                        <button class="btn-add" onclick="location.reload()">Làm mới</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:90px;">Mã đơn</th>
                                <th>Người nhận</th>
                                <th>SĐT</th>
                                <th style="width:200px;">Địa chỉ</th>
                                <th>SL</th>
                                <th>Tổng tiền</th>
                                <th style="width:140px;">Thanh toán</th>
                                <th>Trạng thái</th>
                                <th style="width:200px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (pendingOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="9" class="empty-row">
                                        Không có đơn chờ xác nhận
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : pendingOrders) {
                                        long       madon      = (Long)       row.get("madon");
                                        String     tenNhan    = (String)     row.get("tennguoinhan");
                                        String     sdt        = (String)     row.get("sdt");
                                        String     diachi     = (String)     row.get("diachi");
                                        Integer    soluong    = (Integer)    row.get("soluong");
                                        BigDecimal tongtien   = (BigDecimal) row.get("tongtien");
                                        String     phuongthuc = (String)     row.get("phuongthuc");
                                        String     trangthai  = (String)     row.get("trangthai");

                                        String statusLabel = fmtStatus(trangthai);
                                        String badgeClass  = statusBadge(trangthai);
                            %>
                                <tr>
                                    <td><strong>#<%= madon %></strong></td>
                                    <td><%= tenNhan %></td>
                                    <td><%= sdt %></td>
                                    <td><%= diachi %></td>
                                    <td><%= (soluong != null ? soluong : 0) %></td>
                                    <td><%= fmtMoney(tongtien) %></td>
                                    <td><%= fmtPayment(phuongthuc) %></td>
                                    <td>
                                        <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                                    </td>
                                    <td class="action-buttons">
                                        <button type="button" class="btn-edit"
                                                onclick="showOrderDetail(<%= madon %>, 'WAIT_PACK')">
                                            <i class="fas fa-eye"></i> Xem
                                        </button>
                                        <button type="button" class="btn-confirm"
                                                onclick="xacNhanDonHang(<%= madon %>, 'WAIT_PACK')">
                                            <i class="fas fa-check"></i> Xác nhận
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <%-- ========== BẢNG: CHỜ ĐÓNG GÓI ========== --%>
                <div class="table-container">
                    <div class="table-header">
                        <h3>Đơn chờ đóng gói</h3>
                        <button class="btn-add" onclick="location.reload()">Làm mới</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:90px;">Mã đơn</th>
                                <th>Người nhận</th>
                                <th>SĐT</th>
                                <th style="width:200px;">Địa chỉ</th>
                                <th>SL</th>
                                <th>Tổng tiền</th>
                                <th style="width:140px;">Thanh toán</th>
                                <th>Trạng thái</th>
                                <th style="width:200px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (packOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="9" class="empty-row">
                                        Không có đơn chờ đóng gói
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : packOrders) {
                                        long       madon      = (Long)       row.get("madon");
                                        String     tenNhan    = (String)     row.get("tennguoinhan");
                                        String     sdt        = (String)     row.get("sdt");
                                        String     diachi     = (String)     row.get("diachi");
                                        Integer    soluong    = (Integer)    row.get("soluong");
                                        BigDecimal tongtien   = (BigDecimal) row.get("tongtien");
                                        String     phuongthuc = (String)     row.get("phuongthuc");
                                        String     trangthai  = (String)     row.get("trangthai");

                                        String statusLabel = fmtStatus(trangthai);
                                        String badgeClass  = statusBadge(trangthai);
                            %>
                                <tr>
                                    <td><strong>#<%= madon %></strong></td>
                                    <td><%= tenNhan %></td>
                                    <td><%= sdt %></td>
                                    <td><%= diachi %></td>
                                    <td><%= (soluong != null ? soluong : 0) %></td>
                                    <td><%= fmtMoney(tongtien) %></td>
                                    <td><%= fmtPayment(phuongthuc) %></td>
                                    <td>
                                        <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                                    </td>
                                    <td class="action-buttons">
                                        <button type="button" class="btn-edit"
                                                onclick="showOrderDetail(<%= madon %>, 'WAIT_SHIP')">
                                            <i class="fas fa-eye"></i> Xem
                                        </button>
                                        <button type="button" class="btn-confirm"
                                                onclick="xacNhanDonHang(<%= madon %>, 'WAIT_SHIP')">
                                            <i class="fas fa-check"></i> Xác nhận
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <%-- ========== BẢNG: CHỜ GIAO ========== --%>
                <div class="table-container">
                    <div class="table-header">
                        <h3>Đơn chờ giao</h3>
                        <button class="btn-add" onclick="location.reload()">Làm mới</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:90px;">Mã đơn</th>
                                <th>Người nhận</th>
                                <th>SĐT</th>
                                <th style="width:200px;">Địa chỉ</th>
                                <th>SL</th>
                                <th>Tổng tiền</th>
                                <th style="width:140px;">Thanh toán</th>
                                <th>Trạng thái</th>
                                <th style="width:200px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (shippingOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="9" class="empty-row">
                                        Không có đơn chờ giao
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : shippingOrders) {
                                        long       madon      = (Long)       row.get("madon");
                                        String     tenNhan    = (String)     row.get("tennguoinhan");
                                        String     sdt        = (String)     row.get("sdt");
                                        String     diachi     = (String)     row.get("diachi");
                                        Integer    soluong    = (Integer)    row.get("soluong");
                                        BigDecimal tongtien   = (BigDecimal) row.get("tongtien");
                                        String     phuongthuc = (String)     row.get("phuongthuc");
                                        String     trangthai  = (String)     row.get("trangthai");

                                        String statusLabel = fmtStatus(trangthai);
                                        String badgeClass  = statusBadge(trangthai);
                            %>
                                <tr>
                                    <td><strong>#<%= madon %></strong></td>
                                    <td><%= tenNhan %></td>
                                    <td><%= sdt %></td>
                                    <td><%= diachi %></td>
                                    <td><%= (soluong != null ? soluong : 0) %></td>
                                    <td><%= fmtMoney(tongtien) %></td>
                                    <td><%= fmtPayment(phuongthuc) %></td>
                                    <td>
                                        <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                                    </td>
                                    <td class="action-buttons">
                                        <button type="button" class="btn-edit"
                                                onclick="showOrderDetail(<%= madon %>, 'DELIVERED')">
                                            <i class="fas fa-eye"></i> Xem
                                        </button>
                                        <button type="button" class="btn-confirm"
                                                onclick="xacNhanDonHang(<%= madon %>, 'DELIVERED')">
                                            <i class="fas fa-check"></i> Xác nhận
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <%-- ========== BẢNG: ĐÃ GIAO ========== --%>
                <div class="table-container">
                    <div class="table-header">
                        <h3>Đơn đã giao</h3>
                        <button class="btn-add" onclick="location.reload()">Làm mới</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:90px;">Mã đơn</th>
                                <th>Người nhận</th>
                                <th>SĐT</th>
                                <th>SL</th>
                                <th>Tổng tiền</th>
                                <th>Ngày tạo</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (deliveredOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" class="empty-row">
                                        Không có đơn đã giao
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : deliveredOrders) {
                                        long       madon    = (Long)       row.get("madon");
                                        String     tenNhan  = (String)     row.get("tennguoinhan");
                                        String     sdt      = (String)     row.get("sdt");
                                        Integer    soluong  = (Integer)    row.get("soluong");
                                        BigDecimal tongtien = (BigDecimal) row.get("tongtien");
                                        Timestamp  ngaytao  = (Timestamp)  row.get("ngaytao");
                            %>
                                <tr>
                                    <td><strong>#<%= madon %></strong></td>
                                    <td><%= tenNhan %></td>
                                    <td><%= sdt %></td>
                                    <td><%= (soluong != null ? soluong : 0) %></td>
                                    <td><%= fmtMoney(tongtien) %></td>
                                    <td><%= fmtDateTime(ngaytao) %></td>
                                    <td><span class="badge badge-success">Thành công</span></td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <%-- ========== BẢNG: HOÀN TRẢ ========== --%>
                <div class="table-container">
                    <div class="table-header">
                        <h3>Đơn hoàn trả</h3>
                        <button class="btn-add" onclick="location.reload()">Làm mới</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:90px;">Mã đơn</th>
                                <th>Người nhận</th>
                                <th>SĐT</th>
                                <th>SL</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (returnedOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="6" class="empty-row">
                                        Không có đơn hoàn trả
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : returnedOrders) {
                                        long       madon    = (Long)       row.get("madon");
                                        String     tenNhan  = (String)     row.get("tennguoinhan");
                                        String     sdt      = (String)     row.get("sdt");
                                        Integer    soluong  = (Integer)    row.get("soluong");
                                        BigDecimal tongtien = (BigDecimal) row.get("tongtien");
                            %>
                                <tr>
                                    <td><strong>#<%= madon %></strong></td>
                                    <td><%= tenNhan %></td>
                                    <td><%= sdt %></td>
                                    <td><%= (soluong != null ? soluong : 0) %></td>
                                    <td><%= fmtMoney(tongtien) %></td>
                                    <td><span class="badge badge-dark">Trả hàng</span></td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <%-- ========== BẢNG: ĐÃ HUỶ ========== --%>
                <div class="table-container">
                    <div class="table-header">
                        <h3>Đơn đã huỷ</h3>
                        <button class="btn-add" onclick="location.reload()">Làm mới</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:90px;">Mã đơn</th>
                                <th>Người nhận</th>
                                <th>SĐT</th>
                                <th>SL</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (canceledOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="6" class="empty-row">
                                        Không có đơn huỷ
                                    </td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : canceledOrders) {
                                        long       madon    = (Long)       row.get("madon");
                                        String     tenNhan  = (String)     row.get("tennguoinhan");
                                        String     sdt      = (String)     row.get("sdt");
                                        Integer    soluong  = (Integer)    row.get("soluong");
                                        BigDecimal tongtien = (BigDecimal) row.get("tongtien");
                            %>
                                <tr>
                                    <td><strong>#<%= madon %></strong></td>
                                    <td><%= tenNhan %></td>
                                    <td><%= sdt %></td>
                                    <td><%= (soluong != null ? soluong : 0) %></td>
                                    <td><%= fmtMoney(tongtien) %></td>
                                    <td><span class="badge badge-danger">Đã huỷ</span></td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>

        <!-- Modal xem chi tiết đơn hàng -->
        <div id="viewOrderModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeViewModal()">&times;</span>
                <h3><i class="fas fa-eye"></i> Chi tiết đơn hàng</h3>
                <div class="row2col">
                    <div class="form-group">
                        <label>Mã đơn:</label>
                        <input class="form-control" id="view-madon" disabled>
                    </div>
                    <div class="form-group">
                        <label>Người nhận:</label>
                        <input class="form-control" id="view-tennguoinhan" disabled>
                    </div>
                </div>
                <div class="row2col">
                    <div class="form-group">
                        <label>Số điện thoại:</label>
                        <input class="form-control" id="view-sdt" disabled>
                    </div>
                    <div class="form-group">
                        <label>Địa chỉ:</label>
                        <input class="form-control" id="view-diachi" disabled>
                    </div>
                </div>
                <hr>
                <h4>Sản phẩm</h4>
                <div id="view-order-items">
                    <!-- JS sẽ append vào đây -->
                </div>
                <div class="row2col" style="margin-top:10px;">
                    <div class="form-group">
                        <label>Tổng tiền:</label>
                        <input class="form-control" id="view-tongtien" disabled>
                    </div>
                    <div class="form-group">
                        <label>Phương thức thanh toán:</label>
                        <input class="form-control" id="view-phuongthuc" disabled>
                    </div>
                </div>
                <hr>
                <div class="modal-actions">
                    <button class="btn-confirm" onclick="confirmModalOrder()">
                        <i class="fas fa-check"></i> Xác nhận
                    </button>
                    <button class="btn-close" onclick="closeViewModal()">
                        Đóng
                    </button>
                </div>
            </div>
        </div>

        <script>
            /* ========== POPUP USER ========== */
            document.addEventListener("DOMContentLoaded", function () {
                const userMenu   = document.querySelector(".user-menu");
                const userToggle = document.querySelector(".user-toggle");
                const userPopup  = document.getElementById("userPopup");

                if (userMenu && userToggle && userPopup) {
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
                        }
                    });
                }
            });

            // Biến lưu lại đơn đang mở trong modal
            let modalOrderId    = null;
            let modalNextStatus = null;

            // BẤM "Xem" ở bất kỳ bảng nào
            function showOrderDetail(id, nextStatus) {
                modalOrderId    = id;
                modalNextStatus = nextStatus || null;

                // Gọi servlet lấy chi tiết đơn (JSON)
                fetch('<%= ctx %>/admin_donhang?action=detail&id=' + id)
                    .then(function (res) {
                        if (!res.ok) throw new Error("Network error");
                        return res.json();
                    })
                    .then(function (order) {
                        openViewModal(order);
                    })
                    .catch(function (err) {
                        console.error(err);
                        alert("Không tải được chi tiết đơn hàng.");
                    });
            }

            function openViewModal(order) {
                // 4 ô thông tin đầu
                document.getElementById("view-madon").value        = "#" + (order.madon || "");
                document.getElementById("view-tennguoinhan").value = order.tennguoinhan || "";
                document.getElementById("view-sdt").value          = order.sdt || "";
                document.getElementById("view-diachi").value       = order.diachi || "";

                // Tổng tiền + phương thức thanh toán
                document.getElementById("view-tongtien").value =
                    Number(order.tongtien || 0).toLocaleString("vi-VN") + "₫";

                document.getElementById("view-phuongthuc").value = order.phuongthucLabel || "";

                // Danh sách sản phẩm
                var container = document.getElementById("view-order-items");
                container.innerHTML = "";

                if (order.items && order.items.length > 0) {
                    order.items.forEach(function (item) {
                        var tensp   = item.tensanpham || "";
                        var sluong  = item.soluong || 0;
                        var giaSo   = Number(item.gia || 0).toLocaleString("vi-VN") + "₫";

                        container.innerHTML +=
                            '<div class="order-item">' +
                                '<b>' + tensp + '</b><br>' +
                                'Số lượng: ' + sluong + '<br>' +
                                'Giá: ' + giaSo +
                            '</div>';
                    });
                } else {
                    container.innerHTML = '<em>Không có sản phẩm trong đơn này.</em>';
                }

                // Hiện modal
                document.getElementById("viewOrderModal").style.display = "block";
            }

            function closeViewModal() {
                document.getElementById("viewOrderModal").style.display = "none";
            }

            // Bấm nút "Xác nhận" trong modal
            function confirmModalOrder() {
                if (!modalOrderId || !modalNextStatus) {
                    alert("Không xác định được đơn hàng hoặc trạng thái mới.");
                    return;
                }
                xacNhanDonHang(modalOrderId, modalNextStatus);
            }

            // Bấm nút "Xác nhận" trong bảng (hoặc từ modal)
            function xacNhanDonHang(id, nextStatus) {
                if (!id || !nextStatus) {
                    alert("Thiếu thông tin đơn hàng.");
                    return;
                }

                if (!confirm("Xác nhận cập nhật trạng thái đơn hàng #" + id + "?")) {
                    return;
                }

                fetch('<%= ctx %>/admin_donhang?action=confirm', {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                    },
                    body: "id=" + encodeURIComponent(id) +
                          "&next=" + encodeURIComponent(nextStatus)
                })
                .then(function (res) {
                    if (res.ok) {
                        alert("Đã cập nhật trạng thái đơn hàng!");
                        closeViewModal();
                        location.reload();
                    } else {
                        return res.text().then(function (t) {
                            throw new Error(t || "Lỗi khi xác nhận đơn hàng.");
                        });
                    }
                })
                .catch(function (err) {
                    console.error(err);
                    alert(err.message || "Không thể kết nối máy chủ.");
                });
            }
        </script>
    </body>
</html>
