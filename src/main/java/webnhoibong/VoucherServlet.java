/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.text.NumberFormat;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * /voucher  (GET): hiển thị trang voucher
 * /claim-voucher (POST): xử lý nhập mã hoặc lưu voucher
 */
@WebServlet(name = "VoucherServlet", urlPatterns = {"/voucher", "/claim-voucher"})
public class VoucherServlet extends HttpServlet {

    // ======= Format helpers =======
    private static final NumberFormat VND = NumberFormat.getInstance(new Locale("vi", "VN"));
    private static final DateTimeFormatter VN_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm", new Locale("vi", "VN"));

    private static String toVND(Number n) {
        if (n == null) return "0₫";
        return VND.format(n) + "₫";
    }

    /** Nhận DATETIME/TIMESTAMP -> Chuỗi hạn dùng */
    private static String formatExp(Timestamp exp) {
        if (exp == null) return "Không thời hạn";
        LocalDateTime dt = exp.toLocalDateTime();
        return "HSD: " + VN_DATE.format(dt);
        // Nếu muốn đếm ngược:
        // long days = Duration.between(LocalDateTime.now(), dt).toDays();
        // return days >= 0 ? ("Còn " + days + " ngày") : "Đã hết hạn";
    }

    private static boolean nzBool(ResultSet rs, String col) throws SQLException {
        return rs.getInt(col) == 1;
    }

    // Xây “sub” từ các trường %/tiền/đơn tối thiểu/tối đa
    private static String buildSub(BigDecimal percent, BigDecimal money, BigDecimal minOrder, BigDecimal maxDiscount) {
        StringBuilder sb = new StringBuilder();
        if (percent != null && percent.compareTo(BigDecimal.ZERO) > 0) {
            sb.append("Giảm ").append(percent.stripTrailingZeros().toPlainString()).append("%");
            if (maxDiscount != null && maxDiscount.compareTo(BigDecimal.ZERO) > 0) {
                sb.append(" (tối đa ").append(toVND(maxDiscount)).append(")");
            }
        } else if (money != null && money.compareTo(BigDecimal.ZERO) > 0) {
            sb.append("Giảm ").append(toVND(money));
        }

        if (minOrder != null && minOrder.compareTo(BigDecimal.ZERO) > 0) {
            if (sb.length() > 0) sb.append(" · ");
            sb.append("Đơn từ ").append(toVND(minOrder));
        }
        return sb.length() == 0 ? "Ưu đãi đặc biệt" : sb.toString();
    }

    // Map 1 row -> Map cho JSP (title, sub, exp, loai, ma, id, badge…)
    private static Map<String, Object> mapVoucher(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        String loai = rs.getString("loai");
        String ma = rs.getString("ma");

        BigDecimal phanTram    = rs.getBigDecimal("phan_tram");
        BigDecimal soTienGiam  = rs.getBigDecimal("so_tien_giam");
        BigDecimal donToiThieu = rs.getBigDecimal("don_toi_thieu");
        BigDecimal giamToiDa   = rs.getBigDecimal("giam_toi_da");
        Timestamp  hetHan      = rs.getTimestamp("het_han");

        m.put("id", rs.getInt("id"));
        m.put("loai", loai == null ? "NHAP_MA" : loai);
        m.put("ma", ma == null ? "" : ma);
        m.put("title", rs.getString("tieu_de"));
        m.put("sub", buildSub(phanTram, soTienGiam, donToiThieu, giamToiDa));
        m.put("exp", formatExp(hetHan));
        m.put("badge", nzBool(rs, "san_pham_nhat_dinh")); // tùy tên cột
        return m;
    }

    // ======= Data access =======
    private static final String SQL_ACTIVE_VOUCHERS =
        "SELECT id, loai, ma, tieu_de, phan_tram, so_tien_giam, don_toi_thieu, giam_toi_da, " +
        "       het_han, san_pham_nhat_dinh, kich_hoat, thu_tu " +
        "FROM vouchers " +
        "WHERE COALESCE(kich_hoat,1)=1 " +
        "ORDER BY COALESCE(thu_tu,999), id";

    private static final String SQL_LIMITED =
        "SELECT id, loai, ma, tieu_de, phan_tram, so_tien_giam, don_toi_thieu, giam_toi_da, " +
        "       het_han, san_pham_nhat_dinh, kich_hoat, thu_tu " +
        "FROM vouchers " +
        "WHERE COALESCE(kich_hoat,1)=1 " +
        "ORDER BY het_han IS NULL, het_han ASC, COALESCE(thu_tu,999), id " +
        "LIMIT 10";

    private List<Map<String, Object>> fetchLimited(Connection conn) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(SQL_LIMITED);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapVoucher(rs));
        }
        return list;
    }

    private List<Map<String, Object>> fetchAllActive(Connection conn) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(SQL_ACTIVE_VOUCHERS);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapVoucher(rs));
        }
        return list;
    }

    // ======= HTTP =======
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        try (Connection conn = DatabaseConnection.getConnection()) {
            req.setAttribute("limited", fetchLimited(conn));       // phần “VOUCHER GIỚI HẠN”
            req.setAttribute("vouchers", fetchAllActive(conn));    // phần “TẤT CẢ VOUCHER”
        } catch (SQLException e) {
            throw new ServletException("Không load được dữ liệu voucher", e);
        }

        req.getRequestDispatcher("/voucher.jsp").forward(req, resp);
    }

    /** Nhập mã / lưu voucher */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        // Mặc định: thông báo rỗng
        String claimMsg = null, claimType = "success";

        // 1) Người dùng nhập mã ở ô “Nhập mã voucher”
        if ("/claim-voucher".equals(path)) {
            String code = trim(req.getParameter("code"));
            String idStr = trim(req.getParameter("id"));

            try (Connection conn = DatabaseConnection.getConnection()) {
                if (code != null && !code.isEmpty()) {
                    // ví dụ kiểm tra tồn tại mã
                    boolean ok = checkCodeExists(conn, code);
                    if (ok) {
                        claimMsg = "Đã áp dụng mã: " + code;
                        claimType = "success";
                    } else {
                        claimMsg = "Mã không hợp lệ hoặc đã hết hạn.";
                        claimType = "error";
                    }
                } else if (idStr != null && !idStr.isEmpty()) {
                    // Lưu voucher theo id (nếu bạn muốn cơ chế này)
                    claimMsg = "Đã lưu voucher #" + idStr;
                    claimType = "success";
                } else {
                    claimMsg = "Vui lòng nhập mã voucher.";
                    claimType = "error";
                }

                // reload dữ liệu để render lại trang cùng thông báo
                req.setAttribute("limited", fetchLimited(conn));
                req.setAttribute("vouchers", fetchAllActive(conn));
            } catch (SQLException e) {
                throw new ServletException("Lỗi xử lý voucher", e);
            }

            req.setAttribute("claimMsg", claimMsg);
            req.setAttribute("claimType", claimType);
            req.getRequestDispatcher("/voucher.jsp").forward(req, resp);
            return;
        }

        // fallback
        doGet(req, resp);
    }

    private static boolean checkCodeExists(Connection conn, String code) throws SQLException {
        String sql = "SELECT 1 FROM vouchers WHERE COALESCE(kich_hoat,1)=1 AND loai='NHAP_MA' AND ma=? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private static String trim(String s) { return s == null ? null : s.trim(); }
}