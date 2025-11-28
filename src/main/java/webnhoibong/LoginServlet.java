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

    // Lấy đầy đủ thông tin tài khoản
    private static final String SQL_FIND_USER =
        "SELECT id, tendangnhap, matkhau, vaitro " +
        "FROM taikhoan WHERE tendangnhap = ? LIMIT 1";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Nếu đã đăng nhập rồi thì không cho vào lại trang login nữa
        HttpSession ss = req.getSession(false);
        if (ss != null && ss.getAttribute("userId") != null) {
            resp.sendRedirect(req.getContextPath() + "/trangchu");
            return;
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        // tên input trong form: name="username" và name="password"
        String username = trim(req.getParameter("username"));
        String password = trim(req.getParameter("password"));

        // Validate đơn giản
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
                    int    userId = rs.getInt("id");
                    String dbUser = rs.getString("tendangnhap");  // tên đăng nhập trong DB
                    String dbPass = rs.getString("matkhau");      // mật khẩu trong DB
                    String dbRole = rs.getString("vaitro");       // vai trò trong DB

                    // TODO: Nếu sau này mã hoá mật khẩu thì thay bằng hàm verify hash
                    if (password.equals(dbPass)) {
                        // Đăng nhập thành công → lưu vào session
                        HttpSession session = req.getSession(true);
                        session.setAttribute("userId", userId);
                        session.setAttribute("username", dbUser);                       // tên đăng nhập
                        session.setAttribute("role", (dbRole != null) ? dbRole : "user"); // vai trò
                        session.setAttribute("isLoggedIn", Boolean.TRUE);
                        session.setMaxInactiveInterval(30 * 60); // 30 phút

                        // Điều hướng theo vai trò
                        if ("admin".equalsIgnoreCase(dbRole)) {
                            resp.sendRedirect(req.getContextPath() + "/admin");
                        } else {
                            resp.sendRedirect(req.getContextPath() + "/trangchu");
                        }
                        return;
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Lỗi đăng nhập", e);
        }

        // Sai tài khoản hoặc mật khẩu
        req.setAttribute("loginError", "Tên đăng nhập hoặc mật khẩu không đúng.");
        req.setAttribute("enteredUser", username);
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }
}