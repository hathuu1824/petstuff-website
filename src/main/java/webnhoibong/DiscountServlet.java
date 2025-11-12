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
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.text.NumberFormat;
import java.util.*;

/**
 * /giamgia: Trang khuyến mại
 */
@WebServlet(name = "DiscountServlet", urlPatterns = {"/giamgia"})
public class DiscountServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        List<Map<String, Object>> vouchers = new ArrayList<>();
        List<Map<String, Object>> promos   = new ArrayList<>();
        List<Map<String, Object>> deals    = new ArrayList<>();  // <<< NEW

        /* ===================== VOUCHER ===================== */
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
                if ("NHAP_MA".equalsIgnoreCase(loai)) continue;

                Map<String,Object> v = new HashMap<>();
                v.put("id",   rs.getInt("id"));
                v.put("loai", loai);
                v.put("ma",   rs.getString("ma"));
                v.put("badge", rs.getInt("san_pham_nhat_dinh") == 1);

                // 1) Tiêu đề
                v.put("title", rs.getString("tieu_de"));

                // 2) Sub
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

        /* ===================== BANNER GIẢM GIÁ ===================== */
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

        /* ===================== DEALS SẢN PHẨM (NEW) ===================== */
        // Chọn các cột cần thiết từ sanpham
        // giatien = giá gốc; giakm = giá khuyến mại trực tiếp (nếu có)
        final String SQL_DEALS =
            "SELECT masp, tensp, anhsp, giatien, giakm, giam_pt, giam_tien, " +
            "       km_tu, km_den, bogo, qua_moi_don, uu_tien, kich_hoat " +
            "FROM sanpham " +
            "WHERE COALESCE(kich_hoat,1)=1 " +
            // Phải có ít nhất 1 trong các điều kiện KM: giakm | giam_pt | giam_tien | bogo | qua_moi_don
            "  AND ( (giakm IS NOT NULL AND giakm > 0 AND giakm < giatien) " +
            "     OR (giam_pt IS NOT NULL AND giam_pt > 0) " +
            "     OR (giam_tien IS NOT NULL AND giam_tien > 0) " +
            "     OR bogo=1 " +
            "     OR qua_moi_don=1 ) " +
            // Trong khung thời gian nếu có đặt (NULL = luôn hợp lệ)
            "  AND (km_tu IS NULL OR NOW() >= km_tu) " +
            "  AND (km_den IS NULL OR NOW() <= km_den) " +
            "ORDER BY COALESCE(uu_tien, 999999), masp " +
            "LIMIT 8";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_DEALS);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();

                int id          = rs.getInt("masp");
                String name     = rs.getString("tensp");
                String img      = rs.getString("anhsp");

                Double giaGoc   = nzD(rs, "giatien");
                Double giaKM    = nzD(rs, "giakm");          // giá khuyến mại trực tiếp (ưu tiên 1)
                Integer giamPt  = nzI(rs, "giam_pt");        // giảm %
                Double giamTien = nzD(rs, "giam_tien");      // giảm theo số tiền
                Timestamp tu    = rs.getTimestamp("km_tu");
                Timestamp den   = rs.getTimestamp("km_den");
                boolean bogo    = rs.getInt("bogo") == 1;
                boolean qua     = rs.getInt("qua_moi_don") == 1;

                boolean trongTG = inTime(tu, den);

                // Tính giá bán hiển thị + tag
                Double giaBan = giaGoc;
                String tag;

                if (trongTG && giaKM != null) {
                    giaBan = giaKM;
                    tag = "Ưu đãi";
                } else if (trongTG && giamPt != null) {
                    giaBan = Math.max(0d, Math.round(giaGoc * (100 - giamPt) / 100.0));
                    tag = "Giảm " + giamPt + "%";
                } else if (trongTG && giamTien != null) {
                    giaBan = Math.max(0d, giaGoc - giamTien);
                    tag = "Giảm " + toVND(giamTien);
                } else if (bogo) {
                    tag = "Mua 1 tặng 1";
                } else if (qua) {
                    tag = "Quà mọi đơn";
                } else {
                    tag = "Ưu đãi";
                }

                String note = (giaBan != null && !Objects.equals(giaBan, giaGoc))
                        ? ("Giảm còn " + toVND(giaBan))
                        : "";

                m.put("id", id);
                m.put("tensp", name);
                m.put("img",  (img == null || img.isBlank()) ? "placeholder.png" : img);
                m.put("tag",  tag);
                m.put("note", note);

                deals.add(m);
            }
        } catch (SQLException e) {
            throw new ServletException("Lỗi nạp danh sách deals", e);
        }

        /* ===================== GẮN ATTRIBUTE ===================== */
        request.setAttribute("vouchers", vouchers);
        request.setAttribute("promos",   promos);
        request.setAttribute("deals",    deals);     // <<< NEW

        request.getRequestDispatcher("/discount.jsp").forward(request, response);
    }

    /* ================= Helpers ================= */

    private static String nz(String s) { return s == null ? "" : s; }

    private static String money(BigDecimal v) {
        if (v == null) return "0đ";
        var nf = NumberFormat.getInstance(new Locale("vi", "VN"));
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

    // ===== Helpers dành cho DEALS =====
    private static final NumberFormat VND = NumberFormat.getInstance(new Locale("vi","VN"));
    private static String toVND(Number n){ return (n == null) ? "0₫" : (VND.format(n) + "₫"); }

    private static Double nzD(ResultSet rs, String col) throws SQLException {
        double v = rs.getDouble(col);
        return rs.wasNull() ? null : v;
    }
    private static Integer nzI(ResultSet rs, String col) throws SQLException {
        int v = rs.getInt(col);
        return rs.wasNull() ? null : v;
    }
    private static boolean inTime(Timestamp tu, Timestamp den) {
        LocalDateTime now = LocalDateTime.now();
        boolean okStart = (tu == null)  || !now.isBefore(tu.toLocalDateTime());
        boolean okEnd   = (den == null) || !now.isAfter(den.toLocalDateTime());
        return okStart && okEnd;
    }
}
