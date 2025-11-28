/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

@WebServlet(name = "UserOrderServlet", urlPatterns = {"/donhang"})
public class UserOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("detail".equalsIgnoreCase(action)) {
            // Trả JSON cho modal
            handleDetail(request, response);
        } else {
            // Mặc định: hiển thị danh sách đơn
            handleList(request, response);
        }
    }

    /* ========== DANH SÁCH ĐƠN ========== */
    private void handleList(HttpServletRequest request,
                            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html; charset=UTF-8");

        HttpSession ss = request.getSession(false);
        if (ss == null || ss.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Integer userId = (Integer) ss.getAttribute("userId");

        List<Map<String, Object>> orders = new ArrayList<>();

        String sql =
            "SELECT madon, tongtien, ngaytao, trangthai, phuongthuc " +
            "FROM donhang " +
            "WHERE taikhoan_id = ? " +
            "ORDER BY ngaytao DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("madon",      rs.getLong("madon"));
                    row.put("tongtien",   rs.getBigDecimal("tongtien"));
                    row.put("ngaytao",    rs.getTimestamp("ngaytao"));
                    row.put("trangthai",  rs.getString("trangthai"));
                    row.put("phuongthuc", rs.getString("phuongthuc"));
                    orders.add(row);
                }
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("orderError",
                "Lỗi tải đơn hàng: " + ex.getMessage());
        }

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/order.jsp").forward(request, response);
    }

    /* ========== CHI TIẾT ĐƠN (JSON CHO MODAL) ========== */
    private void handleDetail(HttpServletRequest request,
                              HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json; charset=UTF-8");

        HttpSession ss = request.getSession(false);
        if (ss == null || ss.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"NOT_LOGIN\"}");
            return;
        }

        int userId = (Integer) ss.getAttribute("userId");

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"MISSING_ID\"}");
            return;
        }

        long madon;
        try {
            madon = Long.parseLong(idStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"INVALID_ID\"}");
            return;
        }

        String tenNguoiNhan = null;
        String sdt          = null;
        String diachi       = null;
        long   tongtien     = 0;
        String phuongthuc   = null;

        List<Map<String,Object>> items = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Thông tin đơn (check đúng chủ)
            String sqlOrder =
                "SELECT madon, tennguoinhan, sdt, diachi, tongtien, phuongthuc " +
                "FROM donhang WHERE madon = ? AND taikhoan_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setLong(1, madon);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"NOT_FOUND\"}");
                        return;
                    }
                    tenNguoiNhan = rs.getString("tennguoinhan");
                    sdt          = rs.getString("sdt");
                    diachi       = rs.getString("diachi");
                    BigDecimal tong = rs.getBigDecimal("tongtien");
                    tongtien     = (tong != null ? tong.longValue() : 0);
                    phuongthuc   = rs.getString("phuongthuc");
                }
            }

            // Chi tiết sản phẩm
            String sqlItems =
                "SELECT tensp, soluong, gia " +
                "FROM donhang_ct " +
                "WHERE donhang_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setLong(1, madon);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> row = new HashMap<>();
                        row.put("tensanpham", rs.getString("tensp"));
                        row.put("soluong",    rs.getInt("soluong"));
                        BigDecimal gia = rs.getBigDecimal("gia");
                        row.put("gia", (gia != null ? gia.longValue() : 0));
                        items.add(row);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"DB_ERROR\"}");
            return;
        }

        String ptLabel;
        if ("BANK".equals(phuongthuc)) {
            ptLabel = "Chuyển khoản ngân hàng";
        } else if ("COD".equals(phuongthuc)) {
            ptLabel = "Thanh toán khi nhận hàng";
        } else {
            ptLabel = (phuongthuc != null ? phuongthuc : "");
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"madon\":").append(madon).append(",");
        sb.append("\"tennguoinhan\":\"").append(escapeJson(tenNguoiNhan)).append("\",");
        sb.append("\"sdt\":\"").append(escapeJson(sdt)).append("\",");
        sb.append("\"diachi\":\"").append(escapeJson(diachi)).append("\",");
        sb.append("\"tongtien\":").append(tongtien).append(",");
        sb.append("\"phuongthuc\":\"").append(escapeJson(phuongthuc)).append("\",");
        sb.append("\"phuongthucLabel\":\"").append(escapeJson(ptLabel)).append("\",");

        sb.append("\"items\":[");
        for (int i = 0; i < items.size(); i++) {
            Map<String,Object> it = items.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"tensanpham\":\"").append(escapeJson((String) it.get("tensanpham"))).append("\",");
            sb.append("\"soluong\":").append(it.get("soluong")).append(",");
            sb.append("\"gia\":").append(it.get("gia"));
            sb.append("}");
        }
        sb.append("]}");

        PrintWriter out = response.getWriter();
        out.write(sb.toString());
        out.flush();
    }

    // Escape chuỗi cho JSON
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
