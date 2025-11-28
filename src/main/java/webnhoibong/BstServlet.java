package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;
import java.math.RoundingMode;

@WebServlet(name = "BstServlet", urlPatterns = {"/bst"})
public class BstServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String bstParam = request.getParameter("bst"); // ví dụ: "sanrio,doraemon"
        List<String> bstFilters     = parseBstParam(bstParam);
        List<String> bstFiltersNorm = normalizeForSql(bstFilters);
        List<String> slideUrls      = new ArrayList<>();

        Map<String, List<Map<String, Object>>> mapBST = new LinkedHashMap<>();
        List<Map<String, Object>> suggestList         = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ====== LOAD BỘ SƯU TẬP ======
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT masp, tensp, giatien, giakm, ")
               .append("       giam_pt, giam_tien, ")
               .append("       mota, anhsp, bst, noibat ")
               .append("FROM sanpham ")
               .append("WHERE bst IS NOT NULL ")
               .append("  AND TRIM(LOWER(bst)) <> 'khong' ");

            if (!bstFiltersNorm.isEmpty()) {
                sql.append("  AND TRIM(LOWER(bst)) IN (");
                for (int i = 0; i < bstFiltersNorm.size(); i++) {
                    if (i > 0) sql.append(',');
                    sql.append('?');
                }
                sql.append(')');
            }

            sql.append(" ORDER BY TRIM(LOWER(bst)), (CASE WHEN noibat = 1 THEN 0 ELSE 1 END), tensp");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                for (String n : bstFiltersNorm) {
                    ps.setString(idx++, n);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String rawBst = rs.getString("bst");
                        if (rawBst == null) continue;
                        String bstKeyForUI = rawBst.trim();

                        Map<String, Object> item = new HashMap<>();
                        item.put("masp",  rs.getInt("masp"));
                        item.put("tensp", rs.getString("tensp"));

                        BigDecimal giaTien   = rs.getBigDecimal("giatien");
                        BigDecimal giaKmDb   = rs.getBigDecimal("giakm");
                        BigDecimal giamTien  = rs.getBigDecimal("giam_tien");

                        Integer giamPt = null;
                        Object ptObj   = rs.getObject("giam_pt");
                        if (ptObj != null) {
                            giamPt = ((Number) ptObj).intValue();
                        }

                        // ---- TÍNH GIÁ KM HIỂN THỊ ----
                        BigDecimal giaKm = tinhGiaKmHienThi(giaTien, giaKmDb, giamTien, giamPt);

                        item.put("giatien", giaTien);   // giá gốc
                        item.put("giakm",   giaKm);     // giá sau KM (có thể null nếu không giảm)
                        item.put("ptkm",    giamPt);    // % giảm (cho badge)
                        item.put("makm",    null);      // chưa có cột makm → để null

                        item.put("anhsp",   rs.getString("anhsp"));
                        item.put("mota",    rs.getString("mota"));
                        item.put("noibat",  rs.getInt("noibat"));
                        item.put("bst",     bstKeyForUI);

                        mapBST.computeIfAbsent(bstKeyForUI, k -> new ArrayList<>()).add(item);
                    }
                }
            }

            // ====== GỢI Ý SẢN PHẨM (4 sản phẩm ngẫu nhiên có BST) ======
            final String SQL_SUGGEST =
                "SELECT masp, tensp, giatien, giakm, giam_pt, giam_tien, mota, anhsp, bst " +
                "FROM sanpham " +
                "WHERE bst IS NOT NULL " +
                "  AND TRIM(LOWER(bst)) <> 'khong' " +
                "ORDER BY RAND() " +
                "LIMIT 4";

            try (PreparedStatement ps = conn.prepareStatement(SQL_SUGGEST);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("masp",  rs.getInt("masp"));
                    item.put("tensp", rs.getString("tensp"));

                    BigDecimal giaTien   = rs.getBigDecimal("giatien");
                    BigDecimal giaKmDb   = rs.getBigDecimal("giakm");
                    BigDecimal giamTien  = rs.getBigDecimal("giam_tien");

                    Integer giamPt = null;
                    Object ptObj   = rs.getObject("giam_pt");
                    if (ptObj != null) {
                        giamPt = ((Number) ptObj).intValue();
                    }

                    BigDecimal giaKm = tinhGiaKmHienThi(giaTien, giaKmDb, giamTien, giamPt);

                    item.put("giatien", giaTien);
                    item.put("giakm",   giaKm);
                    item.put("ptkm",    giamPt);
                    item.put("makm",    null);

                    item.put("mota",  rs.getString("mota"));
                    item.put("anhsp", rs.getString("anhsp"));
                    item.put("bst",   rs.getString("bst"));
                    suggestList.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể tải dữ liệu bộ sưu tập/gợi ý.");
        }

        // ====== Banner slide ======
        final String sqlSlides =
            "SELECT banner_anh FROM banners WHERE hien_slide=1 ORDER BY thu_tu, id";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps2 = conn.prepareStatement(sqlSlides);
             ResultSet rs2 = ps2.executeQuery()) {

            while (rs2.next()) {
                slideUrls.add(rs2.getString(1));
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi truy vấn dữ liệu trang chủ", e);
        }

        request.setAttribute("mapBST",      mapBST);
        request.setAttribute("bstSelected", bstFilters);
        request.setAttribute("suggestList", suggestList);
        request.setAttribute("slideUrls",   slideUrls);

        request.getRequestDispatcher("/bst.jsp").forward(request, response);
    }

    // ====== HÀM TÍNH GIÁ KM HIỂN THỊ ======
    private BigDecimal tinhGiaKmHienThi(BigDecimal giaTien,
                                        BigDecimal giaKmDb,
                                        BigDecimal giamTien,
                                        Integer giamPt) {
        if (giaTien == null) return null;

        BigDecimal giaKm = giaKmDb;

        // 1. Nếu có sẵn giakm hợp lệ (< giatien) thì dùng luôn
        if (giaKm != null && giaKm.compareTo(BigDecimal.ZERO) > 0
                && giaKm.compareTo(giaTien) < 0) {
            return giaKm;
        }

        // 2. Nếu có giảm theo số tiền
        if (giamTien != null && giamTien.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal tmp = giaTien.subtract(giamTien);
            if (tmp.compareTo(BigDecimal.ZERO) > 0 && tmp.compareTo(giaTien) < 0) {
                giaKm = tmp;
            }
        }

        // 3. Nếu vẫn chưa có và có giảm theo %
        if ((giaKm == null || giaKm.compareTo(BigDecimal.ZERO) <= 0)
                && giamPt != null && giamPt > 0) {

            BigDecimal hundred = BigDecimal.valueOf(100);
            BigDecimal percent = hundred.subtract(BigDecimal.valueOf(giamPt));
            BigDecimal tmp = giaTien.multiply(percent)
                                    .divide(hundred, 0, RoundingMode.HALF_UP);
            if (tmp.compareTo(BigDecimal.ZERO) > 0 && tmp.compareTo(giaTien) < 0) {
                giaKm = tmp;
            }
        }

        return giaKm; // có thể null → JSP sẽ chỉ hiển thị giá gốc
    }

    // Parse 'bst' query param thành list, bỏ trống, không cho 'khong'
    private List<String> parseBstParam(String bstParam) {
        List<String> out = new ArrayList<>();
        if (bstParam == null || bstParam.trim().isEmpty()) return out;
        for (String s : bstParam.split(",")) {
            String v = s == null ? "" : s.trim();
            if (!v.isEmpty() && !v.equalsIgnoreCase("khong")) {
                out.add(v);
            }
        }
        return out;
    }

    // Chuẩn hóa danh sách BST để so sánh trong SQL (lower + trim)
    private List<String> normalizeForSql(List<String> list) {
        List<String> out = new ArrayList<>();
        for (String s : list) {
            if (s == null) continue;
            String norm = s.trim().toLowerCase();
            if (!norm.isEmpty() && !"khong".equals(norm)) {
                out.add(norm);
            }
        }
        return out;
    }
}
