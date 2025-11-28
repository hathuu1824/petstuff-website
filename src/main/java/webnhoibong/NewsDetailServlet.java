package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet(name = "NewsDetailServlet", urlPatterns = {"/newsdetail"})
public class NewsDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Lấy id bài viết từ query string
        int id = parseInt(req.getParameter("id"), -1);
        if (id <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu hoặc sai id bài viết");
            return;
        }

        // Map chứa bài viết chính
        Map<String,Object> article = null;
        // Danh sách tin khác
        List<Map<String,Object>> otherNews = new ArrayList<>();

        final String SQL_ONE =
            "SELECT id, tieu_de, noi_dung, tom_tat, anh_dai_dien, ngay_dang " +
            "FROM baiviet " +
            "WHERE COALESCE(kich_hoat,1)=1 AND id = ?";

        final String SQL_OTHER =
            "SELECT id, tieu_de, tom_tat, anh_dai_dien, ngay_dang " +
            "FROM baiviet " +
            "WHERE COALESCE(kich_hoat,1)=1 AND id <> ? " +
            "ORDER BY ngay_dang DESC, id DESC " +
            "LIMIT 4";

        try (Connection conn = DatabaseConnection.getConnection()) {

            // === Bài viết chính ===
            try (PreparedStatement ps = conn.prepareStatement(SQL_ONE)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        article = new HashMap<>();
                        article.put("id",        rs.getInt("id"));
                        article.put("title",     nz(rs.getString("tieu_de")));
                        article.put("summary",   nz(rs.getString("tom_tat")));
                        article.put("content",   nz(rs.getString("noi_dung")));
                        article.put("image",     imgOrDefault(rs.getString("anh_dai_dien")));
                        article.put("publishAt", rs.getDate("ngay_dang")); // java.sql.Date
                    }
                }
            }

            if (article == null) {
                // Không tìm thấy bài
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy bài viết");
                return;
            }

            // === Tin khác ===
            try (PreparedStatement ps = conn.prepareStatement(SQL_OTHER)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> m = new HashMap<>();
                        m.put("id",        rs.getInt("id"));
                        m.put("title",     nz(rs.getString("tieu_de")));
                        m.put("excerpt",   nz(rs.getString("tom_tat")));
                        m.put("image",     imgOrDefault(rs.getString("anh_dai_dien")));
                        m.put("publishAt", rs.getDate("ngay_dang"));
                        otherNews.add(m);
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi nạp dữ liệu tin chi tiết", e);
        }

        // Gắn attribute cho JSP
        req.setAttribute("article",   article);
        req.setAttribute("otherNews", otherNews);

        // Forward sang JSP chi tiết
        req.getRequestDispatcher("/newsdetail.jsp").forward(req, resp);
    }

    // ===== Helpers =====
    private static String nz(String s) {
        return (s == null) ? "" : s;
    }

    private static String imgOrDefault(String img) {
        return (img == null || img.isBlank()) ? "placeholder-news.jpg" : img;
    }

    private static int parseInt(String v, int def) {
        try { return Integer.parseInt(v); } catch (Exception e) { return def; }
    }
}
