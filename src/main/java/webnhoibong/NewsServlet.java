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

@WebServlet(name = "NewsServlet", urlPatterns = {"/tintuc"})
public class NewsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // ===== Phân trang danh sách tin =====
        int page = parseInt(req.getParameter("page"), 1);
        int size = parseInt(req.getParameter("size"), 12);
        if (size <= 0 || size > 50) size = 12;
        if (page <= 0) page = 1;
        int offset = (page - 1) * size;

        List<Map<String, Object>> slides   = new ArrayList<>();
        List<Map<String, Object>> hotNews  = new ArrayList<>();
        List<Map<String, Object>> newsList = new ArrayList<>();

        // ===== SQL theo bảng baiviet =====

        // Slides lấy từ baiviet (hien_slide = 1, có ảnh đại diện)
        final String SQL_SLIDES =
            "SELECT id, tieu_de, tom_tat, anh_dai_dien, thu_tu, ngay_dang " +
            "FROM baiviet " +
            "WHERE COALESCE(kich_hoat,1)=1 " +
            "  AND COALESCE(hien_slide,0)=1 " +
            "  AND COALESCE(anh_dai_dien,'')<>'' " +
            "ORDER BY COALESCE(thu_tu,999), ngay_dang DESC, id DESC " +
            "LIMIT 5";

        // 2 tin nổi bật
        final String SQL_HOT =
            "SELECT id, tieu_de, tom_tat, anh_dai_dien, ngay_dang " +
            "FROM baiviet " +
            "WHERE COALESCE(noi_bat,0)=1 AND COALESCE(kich_hoat,1)=1 " +
            "ORDER BY ngay_dang DESC, id DESC " +
            "LIMIT 2";

        // Danh sách tin (phân trang)
        final String SQL_NEWS =
            "SELECT id, tieu_de, tom_tat, anh_dai_dien, ngay_dang " +
            "FROM baiviet " +
            "WHERE COALESCE(kich_hoat,1)=1 " +
            "ORDER BY ngay_dang DESC, id DESC " +
            "LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ===== Slides =====
            try (PreparedStatement ps = conn.prepareStatement(SQL_SLIDES);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    int id = rs.getInt("id");
                    m.put("image",   nz(rs.getString("anh_dai_dien")));       // file trong /images
                    m.put("title",   nz(rs.getString("tieu_de")));
                    m.put("summary", nz(rs.getString("tom_tat")));            // dùng nếu muốn hiện tóm tắt
                    m.put("link",    "tinchitiet.jsp?id=" + id);              // link chi tiết dùng id
                    slides.add(m);
                }
            }

            // ===== Hot news (2 tin) =====
            try (PreparedStatement ps = conn.prepareStatement(SQL_HOT);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    hotNews.add(rowNewsForJsp(rs));
                }
            }

            // ===== News list (paging) =====
            try (PreparedStatement ps = conn.prepareStatement(SQL_NEWS)) {
                ps.setInt(1, size);
                ps.setInt(2, offset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        newsList.add(rowNewsForJsp(rs));
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi nạp dữ liệu trang Tin tức", e);
        }

        // Gắn attribute cho JSP
        req.setAttribute("slides",   slides);
        req.setAttribute("hotNews",  hotNews);
        req.setAttribute("newsList", newsList);
        req.setAttribute("page", page);
        req.setAttribute("size", size);

        req.getRequestDispatcher("/news.jsp").forward(req, resp);
    }

    // ===== Helpers =====
    private static String nz(String s) { return (s == null) ? "" : s; }

    private static int parseInt(String v, int def) {
        try { return Integer.parseInt(v); } catch (Exception e) { return def; }
    }

    /** Map 1 dòng bài viết đúng key mà JSP cần: image, title, excerpt, link */
    private static Map<String,Object> rowNewsForJsp(ResultSet rs) throws SQLException {
        Map<String,Object> m = new HashMap<>();
        int id       = rs.getInt("id");
        String img   = rs.getString("anh_dai_dien");
        String title = rs.getString("tieu_de");
        String sum   = rs.getString("tom_tat");

        m.put("image",   img == null || img.isBlank() ? "placeholder-news.jpg" : img);
        m.put("title",   nz(title));
        m.put("excerpt", nz(sum));
        m.put("link",    "tinchitiet.jsp?id=" + id); 
        return m;
    }
}
