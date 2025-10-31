/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

/**
 *
 * @author hathuu24
 */
@WebServlet(name = "BstServlet", urlPatterns = {"/bst"})
public class BstServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ---- Parse tham số bst (có thể nhiều, ngăn cách dấu phẩy) ----
        String bstParam = request.getParameter("bst"); // ví dụ: "sanrio,doraemon"
        List<String> bstFilters = parseBstParam(bstParam);         // giữ để hiển thị
        List<String> bstFiltersNorm = normalizeForSql(bstFilters); // dùng cho SQL (lower+trim)
        List<String> slideUrls = new ArrayList<>();

        // ===== Kết quả cho JSP =====
        Map<String, List<Map<String, Object>>> mapBST = new LinkedHashMap<>(); // nhóm theo bst
        List<Map<String, Object>> suggestList = new ArrayList<>();             // gợi ý (bst <> 'khong')

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ---------- Nạp mapBST: lọc chung + lọc theo tham số ----------
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT masp, tensp, giatien, mota, anhsp, bst, noibat ")
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
                        String bstKeyForUI = rawBst.trim(); // giữ nguyên để dùng ảnh cover/caption

                        Map<String, Object> item = new HashMap<>();
                        item.put("masp",    rs.getInt("masp"));
                        item.put("tensp",   rs.getString("tensp"));
                        item.put("giatien", rs.getDouble("giatien"));
                        item.put("anhsp",   rs.getString("anhsp"));
                        item.put("mota",    rs.getString("mota"));
                        item.put("noibat",  rs.getInt("noibat"));

                        mapBST.computeIfAbsent(bstKeyForUI, k -> new ArrayList<>()).add(item);
                    }
                }
            }

            // ---------- Nạp suggestList: 8 sản phẩm ngẫu nhiên bst <> 'khong' ----------
            final String SQL_SUGGEST =
                "SELECT masp, tensp, giatien, mota, anhsp, bst " +
                "FROM sanpham " +
                "WHERE bst IS NOT NULL " +
                "  AND TRIM(LOWER(bst)) <> 'khong' " +
                "ORDER BY RAND() " +
                "LIMIT 4";
            try (PreparedStatement ps = conn.prepareStatement(SQL_SUGGEST);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("masp",    rs.getInt("masp"));
                    item.put("tensp",   rs.getString("tensp"));
                    // Dùng BigDecimal để khớp với JSP gợi ý cũ
                    BigDecimal price = rs.getBigDecimal("giatien");
                    item.put("giatien", price);
                    item.put("mota",    rs.getString("mota"));
                    item.put("anhsp",   rs.getString("anhsp"));
                    item.put("bst",     rs.getString("bst"));
                    suggestList.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace(); // prod: dùng logger
            request.setAttribute("error", "Không thể tải dữ liệu bộ sưu tập/gợi ý.");
        }

        // ---- Đẩy sang JSP ----
        request.setAttribute("mapBST", mapBST);
        request.setAttribute("bstSelected", bstFilters); // để UI hiển thị trạng thái lọc (nếu cần)
        request.setAttribute("suggestList", suggestList); // block “Gợi ý cho bạn”
        
        final String sqlSlides =
            "SELECT banner_anh FROM banners WHERE hien_slide=1 ORDER BY thu_tu, id";

        try (Connection conn = DatabaseConnection.getConnection()) {

            try (PreparedStatement ps2 = conn.prepareStatement(sqlSlides);
                 ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) {
                    slideUrls.add(rs2.getString(1));
                }
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi truy vấn dữ liệu trang chủ", e);
        }

        request.setAttribute("slideUrls", slideUrls);
        
        // ---- Forward view (đổi nếu bạn dùng trang khác) ----
        request.getRequestDispatcher("/bst.jsp").forward(request, response);
    }

    // ================= Helpers =================

    // Parse 'bst' query param thành list, bỏ trống, không cho 'khong'
    private List<String> parseBstParam(String bstParam) {
        List<String> out = new ArrayList<>();
        if (bstParam == null || bstParam.trim().isEmpty()) return out;
        for (String s : bstParam.split(",")) {
            String v = s == null ? "" : s.trim();
            if (!v.isEmpty() && !v.equalsIgnoreCase("khong")) {
                out.add(v); // giữ nguyên chính tả để hiển thị
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