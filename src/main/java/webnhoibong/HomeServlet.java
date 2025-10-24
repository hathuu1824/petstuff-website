/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "trangchu", urlPatterns = {"/trangchu"})
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("user") : null;
        boolean isLoggedIn = (username != null);

        request.setAttribute("isLoggedIn", isLoggedIn);
        if (isLoggedIn) {
            request.setAttribute("username", username);
        }

        List<Map<String, Object>> featured = new ArrayList<>();
        List<String> slideUrls = new ArrayList<>();

        final String sqlFeatured =
                "SELECT masp, anhsp, tensp, giatien, mota FROM sanpham WHERE noibat = 1";
        final String sqlSlides =
                "SELECT url_anh FROM banners WHERE an_hien=1 ORDER BY thu_tu, id";

        try (Connection conn = DatabaseConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlFeatured);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("masp", rs.getInt("masp"));
                    row.put("anhsp", rs.getString("anhsp"));
                    row.put("tensp", rs.getString("tensp"));
                    row.put("giatien", rs.getBigDecimal("giatien"));
                    row.put("mota", rs.getString("mota"));
                    featured.add(row);
                }
            }

            try (PreparedStatement ps2 = conn.prepareStatement(sqlSlides);
                 ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) {
                    slideUrls.add(rs2.getString(1));
                }
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi truy vấn dữ liệu trang chủ", e);
        }

        request.setAttribute("featured", featured);
        request.setAttribute("slideUrls", slideUrls);
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}