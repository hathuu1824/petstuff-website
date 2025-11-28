package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

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
        } else {
            // Hiện tại không dùng update/delete nữa, redirect về danh sách
            response.sendRedirect(request.getContextPath() + "/admin_donhang");
        }
    }

    // ====================== GET: LIST & DETAIL ======================

    /**
     * Trả JSON chi tiết 1 đơn hàng:
     * {
     *   madon: 1,
     *   tennguoinhan: "...",
     *   sdt: "...",
     *   diachi: "...",
     *   tongtien: 177500,
     *   phuongthuc: "COD",
     *   phuongthucLabel: "Thanh toán khi nhận hàng",
     *   trangthai: "PENDING",
     *   items: [
     *     { productId: 1, tensanpham: "...", soluong: 2, gia: 120000 },
     *     ...
     *   ]
     * }
     */
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
            //
            // Cấu trúc bảng donhang_ct:
            // id, donhang_id, masp, soluong, gia, thanhtien, loai, tensp
            //
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

        List<Map<String, Object>> orders = new ArrayList<>();

        // Mặc định: đơn mới nhất hiển thị trên đầu
        String sql = "SELECT madon, taikhoan_id, tennguoinhan, sdt, diachi, " +
                     "soluong, phisp, phiship, tongtien, phuongthuc, trangthai, " +
                     "thoigianthanhtoan, thoigianhuy, ngaytao, ngaycapnhat " +
                     "FROM donhang ORDER BY ngaytao DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                orders.add(mapOrderRow(rs));
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            errorMessage = "Lỗi tải danh sách đơn hàng: " + ex.getMessage();
        }

        if (errorMessage != null) {
            request.setAttribute("loadError", errorMessage);
        }
        request.setAttribute("orders", orders);

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
        return m;
    }

    // ====================== POST: CONFIRM ======================

    /**
     * Xác nhận / cập nhật trạng thái đơn:
     *  - JS gửi: action=confirm&id=...&next=WAIT_PACK / WAIT_SHIP / DELIVERED
     *  - Trả về "OK" nếu thành công (status 200)
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

        String sql = "UPDATE donhang SET trangthai = ?, ngaycapnhat = NOW() WHERE madon = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

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

        } catch (SQLException ex) {
            ex.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("DB error: " + ex.getMessage());
        }
    }

    // ====================== Utils ======================

    // Dùng lại logic hiển thị phương thức thanh toán
    private String fmtPayment(String m) {
        if (m == null) return "";
        switch (m) {
            case "COD":  return "Thanh toán khi nhận hàng";
            case "BANK": return "Chuyển khoản ngân hàng";
            default:     return m;
        }
    }

    // Escape chuỗi cho JSON
    private String jsonEscape(String s) {
        if (s == null) return "";
        return s
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
