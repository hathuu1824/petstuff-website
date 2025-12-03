<%-- 
    Document   : products
    Created on : 21 Nov 2025, 8:50:58 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="jakarta.servlet.http.HttpSession"%>

<%!
    // Định dạng tên bộ sưu tập từ mã bst
    private String formatCollection(String bst) {
        if (bst == null || bst.trim().isEmpty() || "khong".equalsIgnoreCase(bst)) {
            return "Không";
        }
        String v = bst.toLowerCase();
        switch (v) {
            case "babythree": return "BabyThree";
            case "capybara":  return "Capybara";
            case "doraemon":  return "Doraemon";
            case "sanrio":    return "Sanrio";
            default:          return bst;
        }
    }

    // Định dạng tên loại từ mã loai
    private String formatCategory(String loai) {
        if (loai == null || loai.trim().isEmpty()) {
            return "";
        }
        String v = loai.toLowerCase();
        switch (v) {
            case "changoi": return "Chăn gối";
            case "mockhoa": return "Móc khóa";
            case "tnb":     return "Thú nhồi bông";
            case "khac":    return "Khác";
            default:        return loai;
        }
    }
%>
<%
    String ctx = request.getContextPath();

    List<Map<String, Object>> products =
        (List<Map<String, Object>>) request.getAttribute("products");
    String loadError = (String) request.getAttribute("loadError");

    Map<String, Object> editTarget =
        (Map<String, Object>) request.getAttribute("editTarget");
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
        <%
            HttpSession ss = request.getSession(false);

            Integer userId    = null;
            String username   = null;
            String role       = null;
            String avatarFile = null; 

            if (ss != null) {
                userId     = (Integer) ss.getAttribute("userId");
                username   = (String) ss.getAttribute("username");  
                role       = (String) ss.getAttribute("role");  
                avatarFile = (String) ss.getAttribute("avatarPath"); 
            }

            boolean isLoggedIn = (username != null);
            if (userId != null) isLoggedIn = true;

            String avatarUrl;
            if (avatarFile == null || avatarFile.trim().isEmpty()) {
                avatarUrl = ctx + "/images/avatar-default.png";
            } else {
                avatarUrl = ctx + "/images/" + avatarFile;
            }
        %>
        <header>
            <nav class="container">
                <a href="<%= ctx %>/admin" id="logo">PetStuff</a>
                <div class="buttons">
                    <% if (isLoggedIn) { %>
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
                        <li><a href="<%= ctx %>/admin_sanpham" class="active">Quản lý sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_loaisp">Quản lý loại sản phẩm</a></li>
                        <li><a href="<%= ctx %>/admin_donhang">Quản lý đơn hàng</a></li>
                        <li><a href="<%= ctx %>/admin_voucher">Quản lý voucher</a></li>
                        <li><a href="<%= ctx %>/admin_km">Quản lý khuyến mại</a></li>
                        <li><a href="<%= ctx %>/admin_tintuc">Quản lý tin tức</a></li>
                    </ul>
                </aside>
            </div>
                    
            <!-- Bảng quản lý -->
            <div class="dashboard-content">
                <div class="content-header">
                    <h1 id="content-title">Quản lý sản phẩm</h1>
                    <p>Quản lý các sản phẩm có mặt trên website</p>
                </div>
                <div class="table-container">
                    <div class="table-header">
                        <h3><i class="fas fa-list" style="margin-right:8px;"></i>Danh sách sản phẩm</h3>
                        <button class="btn-add" onclick="openModal('addProductModal')">
                            Thêm sản phẩm
                        </button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th style="width:60px;">ID</th>
                                <th style="width:70px;">Ảnh</th>
                                <th style="width:200px;">Tên sản phẩm</th>
                                <th style="width:90px;">Giá gốc</th>
                                <th style="width:90px;">Giá KM</th>
                                <th style="width:110px;">Kiểu KM</th>
                                <th style="width:120px;">Bộ sưu tập</th>
                                <th style="width:110px;">Loại</th>
                                <th style="width:120px;">Thời gian KM</th>
                                <th style="width:150px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (loadError != null) {
                            %>
                                <tr>
                                    <td colspan="10" style="color:#b91c1c;background:#fff0f0;">
                                        Lỗi tải dữ liệu: <%= loadError %>
                                    </td>
                                </tr>
                            <%
                                } else if (products == null || products.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="10" style="text-align:center;">Không có sản phẩm</td>
                                </tr>
                            <%
                                } else {
                                    for (Map<String, Object> row : products) {

                                        int masp             = (Integer)    row.get("masp");
                                        String tensp         = (String)     row.get("tensp");
                                        BigDecimal gia       = (BigDecimal) row.get("giatien");
                                        BigDecimal giakm     = (BigDecimal) row.get("giakm");
                                        Integer giamPt       = (Integer)    row.get("giam_pt");
                                        BigDecimal giamTien  = (BigDecimal) row.get("giam_tien");
                                        Timestamp kmTu       = (Timestamp)  row.get("km_tu");
                                        Timestamp kmDen      = (Timestamp)  row.get("km_den");
                                        String anhsp         = (String)     row.get("anhsp");
                                        String bst           = (String)     row.get("bst");
                                        String loai          = (String)     row.get("loai");

                                        BigDecimal giaKmHienThi = null;
                                        String kieuKm = "Không";

                                        if (giakm != null) {
                                            giaKmHienThi = giakm;
                                            kieuKm = "Giá niêm yết";
                                        } else if (giamPt != null && gia != null) {
                                            giaKmHienThi = gia.subtract(
                                                    gia.multiply(new BigDecimal(giamPt))
                                                       .divide(new BigDecimal(100))
                                            );
                                            kieuKm = giamPt + "%";
                                        } else if (giamTien != null && gia != null) {
                                            giaKmHienThi = gia.subtract(giamTien);
                                            kieuKm = "- " + giamTien.intValue();   
                                        }

                                        String imgSrc = (anhsp == null || anhsp.trim().isEmpty())
                                                        ? (ctx + "/images/no-avatar.png")
                                                        : (ctx + "/images/" + anhsp);

                                        String kmRange = "";
                                        if (kmTu  != null) kmRange += kmTu.toString();
                                        if (kmDen != null) kmRange += " → " + kmDen.toString();

                                        String displayBst  = formatCollection(bst);
                                        String displayLoai = formatCategory(loai);
                            %>
                                <tr>
                                    <td><strong><%= masp %></strong></td>
                                    <td>
                                        <img class="avatar" src="<%= imgSrc %>" width="48" height="48"
                                             onerror="this.onerror=null;this.src='<%= ctx %>/images/no-avatar.png';">
                                    </td>
                                    <td><strong><%= (tensp != null ? tensp : "") %></strong></td>
                                    <td><%= (gia != null ? gia.intValue() : "") %></td>
                                    <td><%= (giaKmHienThi != null ? giaKmHienThi.intValue() : "") %></td>
                                    <td><%= kieuKm %></td>
                                    <td><%= displayBst %></td>
                                    <td><%= displayLoai %></td>
                                    <td><%= kmRange %></td>
                                    <td class="action-buttons">
                                        <form method="get" action="<%= ctx %>/admin_sanpham" style="display:inline;">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="id" value="<%= masp %>">
                                            <button type="submit" class="btn-edit">
                                                <i class="fas fa-edit"></i> Sửa
                                            </button>
                                        </form>
                                        <form method="post" action="<%= ctx %>/admin_sanpham" style="display:inline;"
                                              onsubmit="return confirm('Xóa sản phẩm #<%= masp %>?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= masp %>">
                                            <button type="submit" class="btn-delete">
                                                <i class="fas fa-trash"></i> Xoá
                                            </button>
                                        </form>
                                    </td>
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

        <!-- Modal Thêm sản phẩm -->
        <div id="addProductModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal('addProductModal')">&times;</span>
                <h3><i class="fas fa-box"></i> Thêm sản phẩm</h3>
                <form action="<%= ctx %>/admin_sanpham" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tên sản phẩm:</label>
                                <input class="form-control" type="text" name="tensp" required>
                            </div>
                            <div class="form-group">
                                <label>Giá gốc:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="giatien" required>
                            </div>
                            <div class="form-group">
                                <label>Giá khuyến mãi (niêm yết):</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="giakm">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Giảm theo %:</label>
                                <input class="form-control" type="number" min="0" max="100"
                                       name="giam_pt">
                            </div>
                            <div class="form-group">
                                <label>Giảm theo số tiền:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="giam_tien">
                            </div>
                            <div class="form-group">
                                <label>Bộ sưu tập:</label>
                                <select class="form-control" name="bst">
                                    <option value="">Chọn bộ sưu tập</option>
                                    <option value="khong">Không</option>
                                    <option value="babythree">BabyThree</option>
                                    <option value="capybara">Capybara</option>
                                    <option value="doraemon">Doraemon</option>
                                    <option value="sanrio">Sanrio</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Loại:</label>
                                <select class="form-control" name="loai">
                                    <option value="">Chọn loại</option>
                                    <option value="changoi">Chăn gối</option>
                                    <option value="mockhoa">Móc khóa</option>
                                    <option value="tnb">Thú nhồi bông</option>
                                    <option value="khac">Khác</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Khuyến mãi từ:</label>
                                <input class="form-control" type="datetime-local" name="km_tu">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Khuyến mãi đến:</label>
                                <input class="form-control" type="datetime-local" name="km_den">
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-group">
                        <label>Mô tả:</label>
                        <textarea class="form-control" name="mota" rows="3"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Ảnh sản phẩm:</label>
                        <div class="image-upload-container">
                            <input type="file" name="anh" class="form-control"
                                   accept="image/*" onchange="previewImage(this, 'addPreview')">
                            <img id="addPreview" alt="Preview"
                                 style="max-width:100px;max-height:100px;display:none;border-radius:8px;">
                        </div>
                    </div>
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Thêm sản phẩm
                    </button>
                </form>
            </div>
        </div>

        <!-- Modal Sửa sản phẩm -->
        <div id="editProductModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="closeEditModal()">&times;</span>
                <h3><i class="fas fa-edit"></i> Sửa sản phẩm</h3>
                <form action="<%= ctx %>/admin_sanpham" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="edit-id">
                    <input type="hidden" name="existingAnh" id="edit-existing-anh">
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Tên sản phẩm:</label>
                                <input class="form-control" type="text" name="tensp" id="edit-tensp" required>
                            </div>
                            <div class="form-group">
                                <label>Giá gốc:</label>
                                <input class="form-control" type="number" step="0.01" min="0"
                                       name="giatien" id="edit-giatien" required>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Kiểu khuyến mãi:</label>
                                <select class="form-control" id="edit-discount-mode">
                                    <option value="none">Không khuyến mãi</option>
                                    <option value="price">Giá niêm yết</option>
                                    <option value="percent">Giảm theo %</option>
                                    <option value="amount">Giảm theo số tiền</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div id="edit-discount-fields">
                        <div class="form-row">
                            <div class="form-col">
                                <div class="form-group">
                                    <label>Giá khuyến mãi (niêm yết):</label>
                                    <input class="form-control" type="number" step="0.01" min="0"
                                           name="giakm" id="edit-giakm">
                                </div>
                            </div>
                            <div class="form-col">
                                <div class="form-group">
                                    <label>Giảm theo %:</label>
                                    <input class="form-control" type="number" min="0" max="100"
                                           name="giam_pt" id="edit-giam-pt">
                                </div>
                                <div class="form-group">
                                    <label>Giảm theo số tiền:</label>
                                    <input class="form-control" type="number" step="0.01" min="0"
                                           name="giam_tien" id="edit-giam-tien">
                                </div>
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Khuyến mãi từ:</label>
                                <input class="form-control" type="datetime-local" name="km_tu" id="edit-km-tu">
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Khuyến mãi đến:</label>
                                <input class="form-control" type="datetime-local" name="km_den" id="edit-km-den">
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-col">
                            <div class="form-group">
                                <label>Bộ sưu tập:</label>
                                <select class="form-control" name="bst" id="edit-bst">
                                    <option value="">Chọn bộ sưu tập</option>
                                    <option value="khong">Không</option>
                                    <option value="babythree">BabyThree</option>
                                    <option value="capybara">Capybara</option>
                                    <option value="doraemon">Doraemon</option>
                                    <option value="sanrio">Sanrio</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Loại:</label>
                                <select class="form-control" name="loai" id="edit-loai">
                                    <option value="">Chọn loại</option>
                                    <option value="changoi">Chăn gối</option>
                                    <option value="mockhoa">Móc khóa</option>
                                    <option value="tnb">Thú nhồi bông</option>
                                    <option value="khac">Khác</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-col">
                            <div class="form-group">
                                <label>Mô tả:</label>
                                <textarea class="form-control" name="mota" id="edit-mota" rows="3"></textarea>
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="form-group">
                        <label>Ảnh sản phẩm:</label>
                        <div class="image-upload-container">
                            <img id="editPreview" src="" alt="Preview"
                                 style="max-width:100px;max-height:100px;display:none;border-radius:8px;">
                            <input type="file" name="anhspFile" id="edit-anh-file" accept="image/*"
                                   onchange="previewFile(this, 'editPreview')">
                        </div>
                    </div>
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Cập nhật
                    </button>
                </form>
            </div>
        </div>

        <script src="<%= ctx %>/javascript/adproduct.js"></script>
        <%
            if (editTarget != null) {
                int        eId       = (Integer)     editTarget.get("masp");
                String     eTensp    = (String)      editTarget.get("tensp");
                BigDecimal eGia      = (BigDecimal)  editTarget.get("giatien");
                BigDecimal eGiaKm    = (BigDecimal)  editTarget.get("giakm");
                Integer    eGiamPt   = (Integer)     editTarget.get("giam_pt");
                BigDecimal eGiamTien = (BigDecimal)  editTarget.get("giam_tien");
                Timestamp  eKmTu     = (Timestamp)   editTarget.get("km_tu");
                Timestamp  eKmDen    = (Timestamp)   editTarget.get("km_den");
                String     eMota     = (String)      editTarget.get("mota");
                String     eAnh      = (String)      editTarget.get("anhsp");
                String     eBst      = (String)      editTarget.get("bst");
                String     eLoai     = (String)      editTarget.get("loai");

                String jsTensp    = (eTensp    != null) ? eTensp.replace("\"","\\\"") : "";
                String jsGia      = (eGia      != null) ? String.valueOf(eGia.intValue())      : "";
                String jsGiaKm    = (eGiaKm    != null) ? String.valueOf(eGiaKm.intValue())    : "";
                String jsGiamTien = (eGiamTien != null) ? String.valueOf(eGiamTien.intValue()) : "";
                String jsKmTu     = (eKmTu     != null) ? eKmTu.toLocalDateTime().toString()   : "";
                String jsKmDen    = (eKmDen    != null) ? eKmDen.toLocalDateTime().toString()  : "";
                String jsMota     = (eMota     != null) ? eMota.replace("\"","\\\"")           : "";
                String jsAnh      = (eAnh      != null) ? eAnh                                : "";
                String jsBst      = (eBst      != null) ? eBst                                : "";
                String jsLoai     = (eLoai     != null) ? eLoai                               : "";
                int    jsGiamPt   = (eGiamPt   != null) ? eGiamPt : 0;
        %>
        <script>
            window.__EDIT_PRODUCT__ = {
                masp: <%= eId %>,
                tensp: "<%= jsTensp %>",
                giatien: "<%= jsGia %>",
                giakm: "<%= jsGiaKm %>",
                giam_pt: <%= jsGiamPt %>,
                giam_tien: "<%= jsGiamTien %>",
                km_tu: "<%= jsKmTu %>",
                km_den: "<%= jsKmDen %>",
                mota: "<%= jsMota %>",
                anhsp: "<%= jsAnh %>",
                bst: "<%= jsBst %>",
                loai: "<%= jsLoai %>"
            };
        </script>
        <%
            }
        %>
    </body>
</html>
