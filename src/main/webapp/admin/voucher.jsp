<%--
    Document   : voucher
    Created on : 24 Nov 2025
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    // Hiển thị dạng đẹp cho cột "loai"
    private String formatVoucherType(String loai) {
        if (loai == null) return "";
        switch (loai) {
            case "NHAP_MA": return "Nhập mã";
            case "LUU":     return "Voucher lưu";
            default:        return loai;
        }
    }

    // Định dạng tiền (ở đây trả về chuỗi int cho đơn giản)
    private String fmtMoney(BigDecimal v) {
        if (v == null) return "";
        return String.valueOf(v.intValue());
    }

    // Lấy chuỗi ngày (yyyy-MM-dd) từ Timestamp
    private String formatDate(Timestamp ts) {
        if (ts == null) return "";
        return ts.toLocalDateTime().toLocalDate().toString(); // yyyy-MM-dd
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

    List<Map<String,Object>> vouchers =
        (List<Map<String,Object>>) request.getAttribute("vouchers");
    String loadError = (String) request.getAttribute("loadError");

    Map<String,Object> editTarget =
        (Map<String,Object>) request.getAttribute("editTarget");

    // Ép sort theo id tăng dần (phòng trường hợp DB hoặc servlet trả ngược)
    if (vouchers != null) {
        java.util.Collections.sort(
            vouchers,
            new java.util.Comparator<Map<String,Object>>() {
                @Override
                public int compare(Map<String,Object> a, Map<String,Object> b) {
                    Integer ia = (Integer) a.get("id");
                    Integer ib = (Integer) b.get("id");
                    if (ia == null && ib == null) return 0;
                    if (ia == null) return -1;
                    if (ib == null) return 1;
                    return ia.compareTo(ib); // ASC
                }
            }
        );
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Trang quản trị</title>
        <link rel="stylesheet" href="<%= ctx %>/css/admin_product.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>
        <!-- Header -->
        <header>
            <nav class="container">
                <a href="<%= ctx %>/admin_voucher" id="logo">PetStuff</a>
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
                                    <div class="user-popup-role-pill">
                                        <%= (role != null ? role : "admin") %>
                                    </div>
                                </div>
                                <div class="user-popup-body">
                                    <a href="<%= request.getContextPath() %>/profile" class="user-popup-item">
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
                        <li><a href="<%= ctx %>/admin_donhang">Quản lý đơn hàng</a></li>
                        <li><a href="<%= ctx %>/admin_voucher" class="active">Quản lý voucher</a></li>
                        <li><a href="<%= ctx %>/admin_km">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>

            <!-- Content -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1>Quản lý voucher</h1>
                    <p>Thiết lập các mã giảm giá / voucher cho hệ thống</p>
                </div>

                <div class="table-container">
                    <div class="table-header">
                        <h3><i class="fas fa-list" style="margin-right:8px;"></i>Danh sách voucher</h3>
                        <button class="btn-add" onclick="openModal('addVoucherModal')">
                            Thêm voucher
                        </button>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th style="width:60px;">ID</th>
                                <th style="width:110px;">Loại</th>
                                <th style="width:130px;">Mã</th>
                                <th style="width:220px;">Tiêu đề</th>
                                <th style="width:120px;">Kiểu giảm</th>
                                <th style="width:110px;">Giá trị</th>
                                <th style="width:130px;">Đơn tối thiểu</th>
                                <th style="width:130px;">Giảm tối đa</th>
                                <th style="width:150px;">Hạn sử dụng</th>
                                <th style="width:90px;">SP nhất định</th>
                                <th style="width:140px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (loadError != null) {
                            %>
                                <tr>
                                    <td colspan="11" style="color:#b91c1c;background:#fff0f0;">
                                        Lỗi tải dữ liệu: <%= loadError %>
                                    </td>
                                </tr>
                            <%
                                } else if (vouchers == null || vouchers.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="11" style="text-align:center;">Không có voucher</td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String,Object> row : vouchers) {

                                        int        id             = (Integer)    row.get("id");
                                        String     loaiVoucher    = (String)     row.get("loai");
                                        String     ma             = (String)     row.get("ma");
                                        String     tieuDe         = (String)     row.get("tieu_de");
                                        BigDecimal phanTram       = (BigDecimal) row.get("phan_tram");
                                        BigDecimal soTienGiam     = (BigDecimal) row.get("so_tien_giam");
                                        BigDecimal donToiThieu    = (BigDecimal) row.get("don_toi_thieu");
                                        BigDecimal giamToiDa      = (BigDecimal) row.get("giam_toi_da");
                                        Timestamp  hetHan         = (Timestamp)  row.get("het_han");
                                        Object     spNhatDinhObj  =              row.get("san_pham_nhat_dinh");

                                        boolean spNhatDinh = false;
                                        if (spNhatDinhObj instanceof Number) {
                                            spNhatDinh = ((Number) spNhatDinhObj).intValue() == 1;
                                        } else if (spNhatDinhObj instanceof Boolean) {
                                            spNhatDinh = (Boolean) spNhatDinhObj;
                                        }

                                        String kieuGiam   = "Không";
                                        String giaTriGiam = "";
                                        if (phanTram != null && phanTram.compareTo(BigDecimal.ZERO) > 0) {
                                            kieuGiam   = "Giảm %";
                                            giaTriGiam = phanTram.stripTrailingZeros().toPlainString() + "%";
                                        } else if (soTienGiam != null && soTienGiam.compareTo(BigDecimal.ZERO) > 0) {
                                            kieuGiam   = "Giảm tiền";
                                            giaTriGiam = fmtMoney(soTienGiam);
                                        }

                                        String hanSuDung = formatDate(hetHan); // chỉ hiển thị ngày
                            %>
                                <tr>
                                    <td><strong><%= id %></strong></td>
                                    <td><%= formatVoucherType(loaiVoucher) %></td>
                                    <td><%= (ma != null ? ma : "") %></td>
                                    <td><%= (tieuDe != null ? tieuDe : "") %></td>
                                    <td><%= kieuGiam %></td>
                                    <td><%= giaTriGiam %></td>
                                    <td><%= fmtMoney(donToiThieu) %></td>
                                    <td><%= fmtMoney(giamToiDa) %></td>
                                    <td><%= hanSuDung %></td>
                                    <td style="text-align:center;">
                                        <% if (spNhatDinh) { %>
                                            <i class="fas fa-check" style="color:#16a34a;"></i>
                                        <% } %>
                                    </td>
                                    <td class="action-buttons">
                                        <form method="get" action="<%= ctx %>/admin_voucher" style="display:inline;">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-edit">
                                                <i class="fas fa-edit"></i> Sửa
                                            </button>
                                        </form>
                                        <form method="post" action="<%= ctx %>/admin_voucher" style="display:inline;"
                                              onsubmit="return confirm('Xóa voucher #<%= id %>?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= id %>">
                                            <button type="submit" class="btn-delete">
                                                <i class="fas fa-trash"></i> Xoá
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <%
                                    } // end for
                                } // end else
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>

        <!-- Modal thêm voucher -->
        <div id="addVoucherModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('addVoucherModal')">&times;</span>
                <h3><i class="fas fa-ticket"></i> Thêm voucher</h3>
                <form action="<%= ctx %>/admin_voucher" method="POST">
                    <input type="hidden" name="action" value="add">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Loại voucher:</label>
                                <select class="form-control" name="loai" id="add-loai" required>
                                    <option value="NHAP_MA">Nhập mã khi thanh toán</option>
                                    <option value="LUU">Voucher đã lưu</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Mã voucher (nếu là &quot;Nhập mã&quot;):</label>
                                <input class="form-control" type="text" name="ma">
                            </div>
                            <div class="form-group">
                                <label>Tiêu đề:</label>
                                <input class="form-control" type="text" name="tieu_de" required>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giảm theo %:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="phan_tram">
                            </div>
                            <div class="form-group">
                                <label>Giảm theo số tiền:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="so_tien_giam">
                            </div>
                            <div class="form-group">
                                <label>Áp dụng cho sản phẩm nhất định:</label>
                                <label style="display:flex;align-items:center;gap:8px;">
                                    <input type="checkbox" name="san_pham_nhat_dinh" value="1">
                                    <span>Chỉ áp dụng cho một số sản phẩm</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Đơn tối thiểu:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="don_toi_thieu">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giảm tối đa:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="giam_toi_da">
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Hạn sử dụng:</label>
                                <input class="form-control" type="datetime-local" name="het_han">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Thêm voucher
                    </button>
                </form>
            </div>
        </div>

        <!-- Modal sửa voucher -->
        <div id="editVoucherModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeEditModal()">&times;</span>
                <h3><i class="fas fa-edit"></i> Sửa voucher</h3>
                <form action="<%= ctx %>/admin_voucher" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="edit-id">

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Loại voucher:</label>
                                <select class="form-control" name="loai" id="edit-loai" required>
                                    <option value="NHAP_MA">Nhập mã khi thanh toán</option>
                                    <option value="LUU">Voucher đã lưu</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Mã voucher:</label>
                                <input class="form-control" type="text" name="ma" id="edit-ma">
                            </div>
                            <div class="form-group">
                                <label>Tiêu đề:</label>
                                <input class="form-control" type="text" name="tieu_de" id="edit-tieu-de" required>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giảm theo %:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="phan_tram" id="edit-phan-tram">
                            </div>
                            <div class="form-group">
                                <label>Giảm theo số tiền:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="so_tien_giam" id="edit-so-tien-giam">
                            </div>
                            <div class="form-group">
                                <label>Áp dụng cho sản phẩm nhất định:</label>
                                <label style="display:flex;align-items:center;gap:8px;">
                                    <input type="checkbox" name="san_pham_nhat_dinh"
                                           id="edit-san-pham-nhat-dinh" value="1">
                                    <span>Chỉ áp dụng cho một số sản phẩm</span>
                                </label>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Đơn tối thiểu:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="don_toi_thieu" id="edit-don-toi-thieu">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giảm tối đa:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="giam_toi_da" id="edit-giam-toi-da">
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Hạn sử dụng:</label>
                                <input class="form-control" type="datetime-local"
                                       name="het_han" id="edit-het-han">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Cập nhật
                    </button>
                </form>
            </div>
        </div>

        <script>
            // ===== Popup user =====
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

            // ===== Modal helpers =====
            function openModal(id) {
                const modal = document.getElementById(id);
                if (modal) modal.style.display = "block";
            }
            function closeModal(id) {
                const modal = document.getElementById(id);
                if (modal) modal.style.display = "none";
            }
            function closeEditModal() {
                closeModal("editVoucherModal");
                if (window.history && window.history.replaceState) {
                    const url = new URL(window.location.href);
                    url.searchParams.delete("action");
                    url.searchParams.delete("id");
                    window.history.replaceState({}, "", url.pathname + url.search);
                }
            }

            // ===== Tự fill form sửa nếu có window.__EDIT_VOUCHER__ =====
            document.addEventListener("DOMContentLoaded", function () {
                if (!window.__EDIT_VOUCHER__) return;
                const v = window.__EDIT_VOUCHER__;

                const idEl          = document.getElementById("edit-id");
                const loaiEl        = document.getElementById("edit-loai");
                const maEl          = document.getElementById("edit-ma");
                const tieuDeEl      = document.getElementById("edit-tieu-de");
                const phanTramEl    = document.getElementById("edit-phan-tram");
                const soTienEl      = document.getElementById("edit-so-tien-giam");
                const donToiThieuEl = document.getElementById("edit-don-toi-thieu");
                const giamToiDaEl   = document.getElementById("edit-giam-toi-da");
                const hetHanEl      = document.getElementById("edit-het-han");
                const spNdEl        = document.getElementById("edit-san-pham-nhat-dinh");

                if (idEl)          idEl.value          = v.id || "";
                if (loaiEl)        loaiEl.value        = v.loai || "NHAP_MA";
                if (maEl)          maEl.value          = v.ma || "";
                if (tieuDeEl)      tieuDeEl.value      = v.tieu_de || "";
                if (phanTramEl)    phanTramEl.value    = v.phan_tram || "";
                if (soTienEl)      soTienEl.value      = v.so_tien_giam || "";
                if (donToiThieuEl) donToiThieuEl.value = v.don_toi_thieu || "";
                if (giamToiDaEl)   giamToiDaEl.value   = v.giam_toi_da || "";
                if (hetHanEl)      hetHanEl.value      = v.het_han || "";
                if (spNdEl)        spNdEl.checked      = (v.san_pham_nhat_dinh === "1");

                openModal("editVoucherModal");
            });
        </script>

        <%
            // Xuất JS object cho bản ghi đang sửa (nếu có)
            if (editTarget != null) {
                int        eId          = (Integer)    editTarget.get("id");
                String     eLoai        = (String)     editTarget.get("loai");
                String     eMa          = (String)     editTarget.get("ma");
                String     eTieuDe      = (String)     editTarget.get("tieu_de");
                BigDecimal ePhanTram    = (BigDecimal) editTarget.get("phan_tram");
                BigDecimal eSoTienGiam  = (BigDecimal) editTarget.get("so_tien_giam");
                BigDecimal eDonToiThieu = (BigDecimal) editTarget.get("don_toi_thieu");
                BigDecimal eGiamToiDa   = (BigDecimal) editTarget.get("giam_toi_da");
                Timestamp  eHetHan      = (Timestamp)  editTarget.get("het_han");
                Object     eSpNdObj     =              editTarget.get("san_pham_nhat_dinh");

                boolean eSpNdBool = false;
                if (eSpNdObj instanceof Number) {
                    eSpNdBool = ((Number) eSpNdObj).intValue() == 1;
                } else if (eSpNdObj instanceof Boolean) {
                    eSpNdBool = (Boolean) eSpNdObj;
                }

                String jsLoai        = (eLoai        != null) ? eLoai : "";
                String jsMa          = (eMa          != null) ? eMa.replace("\"","\\\"")     : "";
                String jsTieuDe      = (eTieuDe      != null) ? eTieuDe.replace("\"","\\\"") : "";
                String jsPhanTram    = (ePhanTram    != null) ? ePhanTram.stripTrailingZeros().toPlainString()     : "";
                String jsSoTienGiam  = (eSoTienGiam  != null) ? eSoTienGiam.stripTrailingZeros().toPlainString()  : "";
                String jsDonToiThieu = (eDonToiThieu != null) ? eDonToiThieu.stripTrailingZeros().toPlainString() : "";
                String jsGiamToiDa   = (eGiamToiDa   != null) ? eGiamToiDa.stripTrailingZeros().toPlainString()   : "";
                String jsHetHan      = (eHetHan      != null) ? eHetHan.toLocalDateTime().toString()             : "";
                String jsSpNd        = eSpNdBool ? "1" : "0";
        %>
        <script>
            window.__EDIT_VOUCHER__ = {
                id:               <%= eId %>,
                loai:            "<%= jsLoai %>",
                ma:              "<%= jsMa %>",
                tieu_de:         "<%= jsTieuDe %>",
                phan_tram:       "<%= jsPhanTram %>",
                so_tien_giam:    "<%= jsSoTienGiam %>",
                don_toi_thieu:   "<%= jsDonToiThieu %>",
                giam_toi_da:     "<%= jsGiamToiDa %>",
                het_han:         "<%= jsHetHan %>",
                san_pham_nhat_dinh: "<%= jsSpNd %>"
            };
        </script>
        <%
            }
        %>
    </body>
</html>
