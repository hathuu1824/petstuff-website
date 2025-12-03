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

    // Lấy đầy đủ thông tin tài khoản + avatar từ tt_user
    private static final String SQL_FIND_USER =
        "SELECT tk.id, tk.tendangnhap, tk.matkhau, tk.vaitro, " +
        "       u.anh AS avatar " +
        "FROM taikhoan tk " +
        "LEFT JOIN tt_user u ON u.taikhoan_id = tk.id " +
        "WHERE tk.tendangnhap = ? " +
        "LIMIT 1";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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
                    int    userId = rs.getInt("id");
                    String dbUser = rs.getString("tendangnhap");
                    String dbPass = rs.getString("matkhau");
                    String dbRole = rs.getString("vaitro");
                    String avatar = rs.getString("avatar");  // cột u.anh

                    if (password.equals(dbPass)) {
                        HttpSession session = req.getSession(true);
                        session.setAttribute("userId", userId);
                        session.setAttribute("username", dbUser);
                        session.setAttribute("role", (dbRole != null) ? dbRole : "user");
                        session.setAttribute("isLoggedIn", Boolean.TRUE);

                        // Lưu tên file avatar (nếu null thì để trống, JSP tự fallback)
                        if (avatar != null && !avatar.trim().isEmpty()) {
                            session.setAttribute("avatarPath", avatar.trim());
                        } else {
                            session.setAttribute("avatarPath", null);
                        }

                        session.setMaxInactiveInterval(30 * 60); // 30 phút

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

        req.setAttribute("loginError", "Tên đăng nhập hoặc mật khẩu không đúng.");
        req.setAttribute("enteredUser", username);
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }
}
