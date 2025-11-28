package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet(name = "sanpham", urlPatterns = {"/sanpham"})
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // ===== Phân trang =====
        int size = parseInt(req.getParameter("size"), 9);
        if (size <= 0) size = 9;

        int page = parseInt(req.getParameter("page"), 1);
        if (page <= 0) page = 1;

        // ===== Lọc =====
        String[] loaiArr = req.getParameterValues("loai");  // cột loai trong sanpham
        String[] bstArr  = req.getParameterValues("bst");   // cột bst trong sanpham
        String sort      = req.getParameter("sort");

        List<String> whereParts  = new ArrayList<>();
        List<Object> whereParams = new ArrayList<>();

        if (loaiArr != null && loaiArr.length > 0) {
            whereParts.add("loai IN (" + placeholders(loaiArr.length) + ")");
            Collections.addAll(whereParams, (Object[]) loaiArr);
        }
        if (bstArr != null && bstArr.length > 0) {
            whereParts.add("bst IN (" + placeholders(bstArr.length) + ")");
            Collections.addAll(whereParams, (Object[]) bstArr);
        }

        String whereSql = whereParts.isEmpty()
                ? ""
                : (" WHERE " + String.join(" AND ", whereParts));

        // ===== Sắp xếp =====
        String orderSql;
        if ("price_asc".equalsIgnoreCase(sort)) {
            orderSql = " ORDER BY giatien ASC";
        } else if ("price_desc".equalsIgnoreCase(sort)) {
            orderSql = " ORDER BY giatien DESC";
        } else if ("newest".equalsIgnoreCase(sort)) {
            orderSql = " ORDER BY masp DESC";
        } else {
            // mặc định: ưu tiên + mới nhất
            orderSql = " ORDER BY COALESCE(uu_tien,0) DESC, masp DESC";
        }

        long totalCount = 0;
        int totalPages  = 1;
        List<Map<String,Object>> products = new ArrayList<>();

        final String SQL_COUNT =
                "SELECT COUNT(*) FROM sanpham" + whereSql;

        final String SQL_PAGE =
                "SELECT masp, tensp, anhsp, giatien, giakm, giam_pt, giam_tien " +
                "FROM sanpham" +
                whereSql +
                orderSql +
                " LIMIT ? OFFSET ?";

        try (Connection c = DatabaseConnection.getConnection()) {

            // ===== Đếm tổng sản phẩm =====
            try (PreparedStatement ps = c.prepareStatement(SQL_COUNT)) {
                bindParams(ps, whereParams);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getLong(1);
                }
            }

            totalPages = (int) Math.ceil(totalCount / (double) size);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * size;

            // ===== Lấy 1 trang dữ liệu =====
            try (PreparedStatement ps = c.prepareStatement(SQL_PAGE)) {
                int idx = bindParams(ps, whereParams);
                ps.setInt(idx++, size);
                ps.setInt(idx, offset);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> p = new HashMap<>();

                        int masp      = rs.getInt("masp");
                        String tensp  = rs.getString("tensp");
                        String anhsp  = rs.getString("anhsp");

                        BigDecimal giaTien  = rs.getBigDecimal("giatien");
                        BigDecimal giaKm    = rs.getBigDecimal("giakm");
                        int         giamPt  = rs.getInt("giam_pt");
                        BigDecimal giamTien = rs.getBigDecimal("giam_tien");

                        // ===== Tính giá gốc & giá sale =====
                        BigDecimal giaGoc = (giaTien != null) ? giaTien : BigDecimal.ZERO;
                        BigDecimal giaSale = giaGoc;

                        if (giaKm != null && giaKm.compareTo(BigDecimal.ZERO) > 0) {
                            giaSale = giaKm;
                        } else if (giamPt > 0) {
                            giaSale = giaGoc
                                    .multiply(BigDecimal.valueOf(100 - giamPt))
                                    .divide(BigDecimal.valueOf(100));
                        } else if (giamTien != null && giamTien.compareTo(BigDecimal.ZERO) > 0) {
                            giaSale = giaGoc.subtract(giamTien);
                        }

                        boolean hasDiscount = giaSale.compareTo(giaGoc) < 0;

                        // put đúng KEY mà JSP sẽ dùng
                        p.put("masp", masp);
                        p.put("tensp", tensp);
                        p.put("anhsp", anhsp);
                        p.put("giatien", giaTien);

                        p.put("priceOriginal", giaGoc);
                        p.put("priceSale", giaSale);
                        p.put("hasDiscount", hasDiscount);

                        products.add(p);
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi lấy danh sách sản phẩm (lọc/sắp xếp/phân trang)", e);
        }

        // ===== Gửi sang JSP =====
        req.setAttribute("products", products);
        req.setAttribute("page", page);
        req.setAttribute("size", size);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);

        req.getRequestDispatcher("/product.jsp").forward(req, resp);
    }

    // ==== helper ====
    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private static String placeholders(int n) {
        if (n <= 0) return "";
        return String.join(",", java.util.Collections.nCopies(n, "?"));
    }

    private static int bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        if (params != null) {
            for (Object o : params) ps.setObject(idx++, o);
        }
        return idx;
    }
}