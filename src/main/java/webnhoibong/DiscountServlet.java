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
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.*;

/**
 *
 * @author hathuu24
 */
@WebServlet(name = "DiscountServlet", urlPatterns = {"/discount"})
public class DiscountServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        List<Map<String, Object>> vouchers = new ArrayList<>();
        List<Map<String, Object>> promos   = new ArrayList<>();

        // ===== VOUCHER =====
        String sql =
            "SELECT id, loai, ma, tieu_de, phan_tram, so_tien_giam, " +
            "       don_toi_thieu, giam_toi_da, het_han, san_pham_nhat_dinh " +
            "FROM vouchers " +
            "WHERE kich_hoat=1 " +
            "  AND loai='LUU' " +                               
            "  AND (het_han IS NULL OR NOW() <= het_han) " +
            "ORDER BY thu_tu, id " +
            "LIMIT 4";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String loai = rs.getString("loai");

                if ("NHAP_MA".equalsIgnoreCase(loai)) {
                    continue;
                }

                Map<String,Object> v = new HashMap<>();
                v.put("id",   rs.getInt("id"));
                v.put("loai", loai);
                v.put("ma",   rs.getString("ma"));
                v.put("badge", rs.getInt("san_pham_nhat_dinh") == 1);

                // 1) Tiêu đề
                v.put("title", rs.getString("tieu_de"));

                // 2) Sub (Đơn tối thiểu … · Giảm tối đa …)
                BigDecimal minOrder = rs.getBigDecimal("don_toi_thieu");
                BigDecimal maxDisc  = rs.getBigDecimal("giam_toi_da");
                v.put("sub", buildSub(minOrder, maxDisc));

                // 3) Hạn sử dụng
                Timestamp hetHan = rs.getTimestamp("het_han");
                v.put("exp", buildExpire(hetHan));

                vouchers.add(v);
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi nạp voucher", e);
        }

        // ===== GIẢM GIÁ (khuyến mại) =====
        final String SQL_GIAMGIA =
            "SELECT id, anh_url, tieu_de, link, thu_tu, kich_hoat " +
            "FROM giamgia " +
            "WHERE COALESCE(kich_hoat,1)=1 " +
            "ORDER BY COALESCE(thu_tu,999), id " +
            "LIMIT 10";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GIAMGIA);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> p = new HashMap<>();
                p.put("image",   nz(rs.getString("anh_url")));
                p.put("caption", nz(rs.getString("tieu_de")));
                p.put("link",    nz(rs.getString("link")));
                promos.add(p);
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi nạp dữ liệu giảm giá", e);
        }

        // ---- Gắn attribute cho JSP ----
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("promos", promos);

        request.getRequestDispatcher("/discount.jsp").forward(request, response);
    }

    /* ================= Helpers ================= */

    private static String nz(String s) { return s == null ? "" : s; }

    private static String money(BigDecimal v) {
        if (v == null) return "0đ";
        var nf = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
        nf.setGroupingUsed(true);
        nf.setMaximumFractionDigits(0);
        return nf.format(v) + "đ";
    }

    private static String buildSub(BigDecimal minOrder, BigDecimal maxDisc) {
        String minTxt = (minOrder == null || minOrder.signum() == 0) ? "0đ" : money(minOrder);
        String maxTxt = (maxDisc == null || maxDisc.signum() == 0) ? "0đ" : money(maxDisc);
        return "Đơn tối thiểu " + minTxt + " · Giảm tối đa " + maxTxt;
    }

    private static String buildExpire(Timestamp expiresAt) {
        if (expiresAt == null) return "Sắp hết hạn: Không xác định";
        LocalDate today = LocalDate.now(ZoneId.systemDefault());
        LocalDate end   = expiresAt.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        long days = ChronoUnit.DAYS.between(today, end);
        if (days < 0)  return "Đã hết hạn";
        if (days == 0) return "Sắp hết hạn: Hôm nay";
        if (days == 1) return "Sắp hết hạn: Còn 1 ngày";
        return "Sắp hết hạn: Còn " + days + " ngày";
    }
}
