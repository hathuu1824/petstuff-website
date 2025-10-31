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

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "dangnhap", urlPatterns = {"/dangnhap"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String SQL_FIND_USER =
        "SELECT matkhau FROM taikhoan WHERE tendangnhap = ? LIMIT 1";

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String username = trim(req.getParameter("username"));
        String password = trim(req.getParameter("password"));

        if (username.isEmpty() || password.isEmpty()) {
            req.setAttribute("loginError", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            req.setAttribute("enteredUser", username);
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_USER)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString(1);
                    boolean ok = password.equals(stored);
                    if (ok) {
                        HttpSession session = req.getSession(true);
                        session.setAttribute("user", username);
                        resp.sendRedirect(req.getContextPath() + "/trangchu");
                        return;
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi đăng nhập", e);
        }

        req.setAttribute("loginError", "Tên đăng nhập hoặc mật khẩu không đúng.");
        req.setAttribute("enteredUser", username);
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}
