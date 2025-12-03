package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/**
 * Quản trị đơn hàng:
 *  - GET  /admin_donhang?action=detail&id=...  -> JSON chi tiết 1 đơn (cho modal)
 *  - GET  /admin_donhang                        -> Load danh sách đơn, tách theo trạng thái, forward JSP
 *  - POST /admin_donhang?action=confirm&id=&next=WAIT_PACK|WAIT_SHIP|DELIVERED
 *  - POST /admin_donhang?action=cancel&id=     -> Hủy đơn, chuyển CANCELED + ghi lý do hủy
 */
@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin_donhang"})
public class AdminOrderServlet extends HttpServlet {

    // ====================== HTTP METHODS ======================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("detail".equalsIgnoreCase(action)) {
            // Trả JSON chi tiết 1 đơn hàng (dùng cho modal Xem)
            handleDetail(request, response);
        } else {
            // Mặc định: load danh sách đơn và forward sang JSP
            loadAndForwardList(request, response, null);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("confirm".equalsIgnoreCase(action)) {
            // Xác nhận / đổi trạng thái đơn (PENDING -> WAIT_PACK -> WAIT_SHIP -> DELIVERED)
            handleConfirm(request, response);
        } else if ("cancel".equalsIgnoreCase(action)) {
            // Hủy đơn hàng
            handleCancel(request, response);
        } else {
            // Các action khác: quay lại danh sách
            response.sendRedirect(request.getContextPath() + "/admin_donhang");
        }
    }

    // ====================== GET: DETAIL ======================

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("id");
        response.setCharacterEncoding("UTF-8");

        if (idStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("Missing id");
            return;
        }

        long madon;
        try {
            madon = Long.parseLong(idStr);
        } catch (NumberFormatException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("Invalid id");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1) Lấy thông tin chung của đơn hàng
            String sqlOrder =
                    "SELECT madon, tennguoinhan, sdt, diachi, tongtien, phuongthuc, trangthai " +
                    "FROM donhang WHERE madon = ?";

            String tenNguoiNhan = null;
            String sdt          = null;
            String diachi       = null;
            BigDecimal tongTien = null;
            String phuongThuc   = null;
            String trangThai    = null;

            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setLong(1, madon);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        tenNguoiNhan = rs.getString("tennguoinhan");
                        sdt          = rs.getString("sdt");
                        diachi       = rs.getString("diachi");
                        tongTien     = rs.getBigDecimal("tongtien");
                        phuongThuc   = rs.getString("phuongthuc");
                        trangThai    = rs.getString("trangthai");
                    }
                }
            }

            if (tenNguoiNhan == null) {
                // Không tìm thấy đơn
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.setContentType("text/plain; charset=UTF-8");
                response.getWriter().write("Not found");
                return;
            }

            // 2) Lấy danh sách sản phẩm trong đơn từ bảng donhang_ct
            String sqlItems =
                    "SELECT masp, tensp, soluong, gia " +
                    "FROM donhang_ct " +
                    "WHERE donhang_id = ?";

            List<String> itemsJson = new ArrayList<>();

            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setLong(1, madon);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int    productId = rs.getInt("masp");
                        String tensp     = rs.getString("tensp");
                        int    soluong   = rs.getInt("soluong");
                        int    gia       = rs.getInt("gia");

                        String itemJson =
                                "{"
                                + "\"productId\":" + productId + ","
                                + "\"tensanpham\":\"" + jsonEscape(tensp) + "\","
                                + "\"soluong\":" + soluong + ","
                                + "\"gia\":" + gia
                                + "}";

                        itemsJson.add(itemJson);
                    }
                }
            }

            // 3) Build JSON trả về
            int tongInt = (tongTien != null ? tongTien.intValue() : 0);

            String json =
                    "{"
                    + "\"madon\":" + madon + ","
                    + "\"tennguoinhan\":\"" + jsonEscape(tenNguoiNhan) + "\","
                    + "\"sdt\":\"" + jsonEscape(sdt) + "\","
                    + "\"diachi\":\"" + jsonEscape(diachi) + "\","
                    + "\"tongtien\":" + tongInt + ","
                    + "\"phuongthuc\":\"" + jsonEscape(phuongThuc) + "\","
                    + "\"phuongthucLabel\":\"" + jsonEscape(fmtPayment(phuongThuc)) + "\","
                    + "\"trangthai\":\"" + jsonEscape(trangThai) + "\","
                    + "\"items\":[" + String.join(",", itemsJson) + "]"
                    + "}";

            response.setStatus(HttpServletResponse.SC_OK);
            response.setContentType("application/json; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(json);

        } catch (SQLException ex) {
            ex.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("DB error: " + ex.getMessage());
        }
    }

    // ====================== GET: LIST ======================

    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage)
            throws ServletException, IOException {

        try (Connection conn = DatabaseConnection.getConnection()) {
            loadAndForwardList(request, response, errorMessage, conn);
        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("loadError",
                    "Không kết nối được CSDL: " + ex.getMessage());
            request.getRequestDispatcher("/admin/order.jsp").forward(request, response);
        }
    }

    // Overload: dùng connection có sẵn
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage, Connection conn)
            throws ServletException, IOException {

        List<Map<String, Object>> allOrders       = new ArrayList<>();
        List<Map<String, Object>> pendingOrders   = new ArrayList<>(); // PENDING
        List<Map<String, Object>> packOrders      = new ArrayList<>(); // WAIT_PACK
        List<Map<String, Object>> shippingOrders  = new ArrayList<>(); // WAIT_SHIP
        List<Map<String, Object>> deliveredOrders = new ArrayList<>(); // DELIVERED
        List<Map<String, Object>> returnedOrders  = new ArrayList<>(); // RETURNED
        List<Map<String, Object>> canceledOrders  = new ArrayList<>(); // CANCELED
        List<Map<String, Object>> otherOrders     = new ArrayList<>(); // khác

        // Mặc định: đơn mới nhất hiển thị trên đầu
        String sql = "SELECT madon, taikhoan_id, tennguoinhan, sdt, diachi, "
                   + "soluong, phisp, phiship, tongtien, phuongthuc, trangthai, "
                   + "thoigianthanhtoan, thoigianhuy, ngaytao, ngaycapnhat, "
                   + "lydo_huy, lydo_hoan "
                   + "FROM donhang ORDER BY ngaytao DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> m = mapOrderRow(rs);
                allOrders.add(m);

                String st = (String) m.get("trangthai");
                if (st == null) st = "";

                switch (st) {
                    case "PENDING":
                        pendingOrders.add(m);
                        break;
                    case "WAIT_PACK":
                        packOrders.add(m);
                        break;
                    case "WAIT_SHIP":
                        shippingOrders.add(m);
                        break;
                    case "DELIVERED":
                        deliveredOrders.add(m);
                        break;
                    case "RETURNED":
                        returnedOrders.add(m);
                        break;
                    case "CANCELED":
                        canceledOrders.add(m);
                        break;
                    default:
                        otherOrders.add(m);
                        break;
                }
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            errorMessage = "Lỗi tải danh sách đơn hàng: " + ex.getMessage();
        }

        if (errorMessage != null) {
            request.setAttribute("loadError", errorMessage);
        }

        // Gửi sang JSP
        request.setAttribute("orders",          allOrders);
        request.setAttribute("pendingOrders",   pendingOrders);
        request.setAttribute("packOrders",      packOrders);
        request.setAttribute("shippingOrders",  shippingOrders);
        request.setAttribute("deliveredOrders", deliveredOrders);
        request.setAttribute("returnedOrders",  returnedOrders);
        request.setAttribute("canceledOrders",  canceledOrders);
        request.setAttribute("otherOrders",     otherOrders);

        request.getRequestDispatcher("/admin/order.jsp").forward(request, response);
    }

    // Ánh xạ 1 dòng ResultSet -> Map
    private Map<String, Object> mapOrderRow(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        m.put("madon", rs.getLong("madon"));
        m.put("taikhoan_id", rs.getObject("taikhoan_id") != null ? rs.getInt("taikhoan_id") : null);
        m.put("tennguoinhan", rs.getString("tennguoinhan"));
        m.put("sdt", rs.getString("sdt"));
        m.put("diachi", rs.getString("diachi"));
        m.put("soluong", rs.getObject("soluong") != null ? rs.getInt("soluong") : null);
        m.put("phisp", rs.getBigDecimal("phisp"));
        m.put("phiship", rs.getBigDecimal("phiship"));
        m.put("tongtien", rs.getBigDecimal("tongtien"));
        m.put("phuongthuc", rs.getString("phuongthuc"));
        m.put("trangthai", rs.getString("trangthai"));
        m.put("thoigianthanhtoan", rs.getTimestamp("thoigianthanhtoan"));
        m.put("thoigianhuy", rs.getTimestamp("thoigianhuy"));
        m.put("ngaytao", rs.getTimestamp("ngaytao"));
        m.put("ngaycapnhat", rs.getTimestamp("ngaycapnhat"));
        m.put("lydo_huy", rs.getString("lydo_huy"));
        m.put("lydo_hoan", rs.getString("lydo_hoan"));
        return m;
    }

    // ====================== POST: CONFIRM ======================

    /**
     * Xác nhận / cập nhật trạng thái đơn:
     *  - JS gửi: action=confirm&id=...&next=WAIT_PACK / WAIT_SHIP / DELIVERED
     *  - Trả về "OK" nếu thành công (status 200)
     *
     *  Quy ước thời điểm ghi thoigianthanhtoan:
     *   - Nếu phuongthuc = BANK  và duyệt PENDING  -> WAIT_PACK   => set thoigianthanhtoan = NOW()
     *   - Nếu phuongthuc = COD   và duyệt WAIT_SHIP -> DELIVERED  => set thoigianthanhtoan = NOW()
     */
    private void handleConfirm(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr  = request.getParameter("id");
        String nextSt = request.getParameter("next"); // WAIT_PACK / WAIT_SHIP / DELIVERED

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        if (idStr == null || nextSt == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing id/next");
            return;
        }

        long madon;
        try {
            madon = Long.parseLong(idStr);
        } catch (NumberFormatException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid id");
            return;
        }

        // Chỉ cho phép 3 trạng thái này (đúng flow JSP)
        if (!"WAIT_PACK".equals(nextSt) &&
            !"WAIT_SHIP".equals(nextSt) &&
            !"DELIVERED".equals(nextSt)) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid next status");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1) Lấy phuongthuc, trangthai hiện tại và thoigianthanhtoan
            String phuongThuc = null;
            String currentStatus = null;
            Timestamp payTime = null;

            String sqlSelect = "SELECT phuongthuc, trangthai, thoigianthanhtoan " +
                               "FROM donhang WHERE madon = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setLong(1, madon);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        phuongThuc    = rs.getString("phuongthuc");
                        currentStatus = rs.getString("trangthai");
                        payTime       = rs.getTimestamp("thoigianthanhtoan");
                    }
                }
            }

            if (currentStatus == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Order not found");
                return;
            }

            // 2) Quyết định có set thoigianthanhtoan hay không
            boolean setPayTime = false;

            if ("BANK".equals(phuongThuc)
                    && "PENDING".equals(currentStatus)
                    && "WAIT_PACK".equals(nextSt)
                    && payTime == null) {
                // Thanh toán chuyển khoản: xác nhận ở bảng Chờ xác nhận
                setPayTime = true;
            } else if ("COD".equals(phuongThuc)
                    && "WAIT_SHIP".equals(currentStatus)
                    && "DELIVERED".equals(nextSt)
                    && payTime == null) {
                // Thanh toán khi nhận hàng: xác nhận ở bảng Chờ giao
                setPayTime = true;
            }

            // 3) Cập nhật trạng thái (+ thời gian thanh toán nếu cần)
            String sqlUpdate;
            if (setPayTime) {
                sqlUpdate = "UPDATE donhang " +
                            "SET trangthai = ?, " +
                            "    thoigianthanhtoan = NOW(), " +
                            "    ngaycapnhat = NOW() " +
                            "WHERE madon = ?";
            } else {
                sqlUpdate = "UPDATE donhang " +
                            "SET trangthai = ?, " +
                            "    ngaycapnhat = NOW() " +
                            "WHERE madon = ?";
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setString(1, nextSt);
                ps.setLong(2, madon);
                int updated = ps.executeUpdate();

                if (updated == 0) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("Order not found");
                } else {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("OK");
                }
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("DB error: " + ex.getMessage());
        }
    }

    // ====================== POST: CANCEL ======================

    /**
     * Hủy đơn hàng:
     *  - JS gửi: action=cancel&id=...
     *  - Đơn được chuyển sang trạng thái CANCELED,
     *    cập nhật thoigianhuy = NOW(), ngaycapnhat = NOW(),
     *    lydo_huy tùy theo trạng thái hiện tại:
     *      PENDING   -> Đơn hàng không được xác nhận
     *      WAIT_PACK -> Không thể đóng gói đơn hàng
     *      WAIT_SHIP -> Giao hàng không thành công
     */
    private void handleCancel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("id");

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        if (idStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing id");
            return;
        }

        long madon;
        try {
            madon = Long.parseLong(idStr);
        } catch (NumberFormatException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid id");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1) Lấy trạng thái hiện tại
            String currentStatus = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT trangthai FROM donhang WHERE madon = ?")) {
                ps.setLong(1, madon);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentStatus = rs.getString("trangthai");
                    }
                }
            }

            if (currentStatus == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Order not found");
                return;
            }

            // 2) Map trạng thái -> lý do hủy
            String lydoHuy;
            switch (currentStatus) {
                case "PENDING":
                    lydoHuy = "Đơn hàng không được xác nhận";
                    break;
                case "WAIT_PACK":
                    lydoHuy = "Không thể đóng gói đơn hàng";
                    break;
                case "WAIT_SHIP":
                    lydoHuy = "Giao hàng không thành công";
                    break;
                default:
                    lydoHuy = "Đơn hàng bị huỷ";
            }

            // 3) Update sang CANCELED + ghi lý do
            String sql =
                    "UPDATE donhang " +
                    "SET trangthai = 'CANCELED', " +
                    "    lydo_huy = ?, " +
                    "    thoigianhuy = NOW(), " +
                    "    ngaycapnhat = NOW() " +
                    "WHERE madon = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, lydoHuy);
                ps.setLong(2, madon);
                int updated = ps.executeUpdate();

                if (updated == 0) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("Order not found");
                } else {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("OK");
                }
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("DB error: " + ex.getMessage());
        }
    }

    // ====================== Utils ======================

    private String fmtPayment(String m) {
        if (m == null) return "";
        switch (m) {
            case "COD":  return "Thanh toán khi nhận hàng";
            case "BANK": return "Chuyển khoản ngân hàng";
            default:     return m;
        }
    }

    private String jsonEscape(String s) {
        if (s == null) return "";
        return s
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}