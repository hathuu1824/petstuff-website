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

@WebServlet(name = "AllNewsServlet", urlPatterns = {"/all"})
public class AllNewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // ==== Cấu hình phân trang ====
        int page = parseInt(req.getParameter("page"), 1);
        int size = 6;
        if (page <= 0) page = 1;
        int offset = (page - 1) * size;

        List<Map<String, Object>> newsList = new ArrayList<>();

        final String SQL_COUNT =
            "SELECT COUNT(*) FROM baiviet WHERE COALESCE(kich_hoat,1)=1";
        final String SQL_NEWS_PAGED =
            "SELECT id, tieu_de, tom_tat, anh_dai_dien, ngay_dang " +
            "FROM baiviet " +
            "WHERE COALESCE(kich_hoat,1)=1 " +
            "ORDER BY ngay_dang DESC, id DESC " +
            "LIMIT ? OFFSET ?";

        int total = 0;
        int totalPages = 1;

        try (Connection conn = DatabaseConnection.getConnection()) {
            // --- Đếm tổng số bài viết ---
            try (PreparedStatement ps = conn.prepareStatement(SQL_COUNT);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) total = rs.getInt(1);
            }

            // --- Lấy danh sách bài viết ---
            try (PreparedStatement ps = conn.prepareStatement(SQL_NEWS_PAGED)) {
                ps.setInt(1, size);
                ps.setInt(2, offset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) newsList.add(rowNewsForJsp(rs));
                }
            }

            totalPages = (int) Math.ceil(total / (double) size);
            if (totalPages <= 0) totalPages = 1; 

        } catch (SQLException e) {
            throw new ServletException("Lỗi tải tin tức", e);
        }

        // --- Gắn attribute cho JSP ---
        req.setAttribute("newsList", newsList);
        req.setAttribute("page", page);
        req.setAttribute("size", size);
        req.setAttribute("total", total);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/allnews.jsp").forward(req, resp);
    }

    // ==== Helpers ====
    private static String nz(String s) { return s == null ? "" : s; }

    private static int parseInt(String v, int def) {
        try { return Integer.parseInt(v); } catch (Exception e) { return def; }
    }

    private static Map<String, Object> rowNewsForJsp(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        int id = rs.getInt("id");
        m.put("image", nz(rs.getString("anh_dai_dien")));
        m.put("title", nz(rs.getString("tieu_de")));
        m.put("excerpt", nz(rs.getString("tom_tat")));
        m.put("link", "tin?id=" + id);
        return m;
    }
}