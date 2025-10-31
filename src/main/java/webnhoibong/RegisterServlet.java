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
import java.util.regex.Pattern;

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "DangKyServlet", urlPatterns = {"/dangky"})
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final Pattern USER_RE = Pattern.compile("^[A-Za-z0-9_\\.\\-]{3,30}$");
    private static final Pattern EMAIL_RE = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

    private static final String SQL_CHECK_USER  = "SELECT id FROM taikhoan WHERE tendangnhap=? LIMIT 1";
    private static final String SQL_CHECK_EMAIL = "SELECT id FROM taikhoan WHERE email=? LIMIT 1";
    private static final String SQL_INSERT_USER = "INSERT INTO taikhoan (tendangnhap, matkhau, email, vaitro) VALUES (?,?,?,'user')";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username = n(req.getParameter("username"));
        String password = n(req.getParameter("password"));
        String confirm  = n(req.getParameter("confirm"));
        String email    = n(req.getParameter("email"));
        boolean agreed  = req.getParameter("agree") != null;

        // 0) PHẢI đồng ý điều khoản
        if (!agreed) {
            backWithError(req, resp,
                "Bạn phải đồng ý với điều khoản & dịch vụ trước khi đăng ký.",
                username, email);
            return;
        }

        if (!USER_RE.matcher(username).matches()) {
            backWithError(req, resp,
                "Tên đăng nhập 3–30 ký tự, chỉ gồm chữ/số/_ . -",
                username, email);
            return;
        }
        if (password.length() < 6) {
            backWithError(req, resp,
                "Mật khẩu phải tối thiểu 6 ký tự.",
                username, email);
            return;
        }
        if (!password.equals(confirm)) {
            backWithError(req, resp,
                "Xác nhận mật khẩu không khớp.",
                username, email);
            return;
        }
        if (!EMAIL_RE.matcher(email).matches()) {
            backWithError(req, resp,
                "Email không hợp lệ.",
                username, email);
            return;
        }

        try (Connection c = DatabaseConnection.getConnection()) {

            try (PreparedStatement ps = c.prepareStatement(SQL_CHECK_USER)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        backWithError(req, resp, "Tên đăng nhập đã tồn tại.", username, email);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = c.prepareStatement(SQL_CHECK_EMAIL)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        backWithError(req, resp, "Email đã được sử dụng.", username, email);
                        return;
                    }
                }
            }

            try (PreparedStatement ps = c.prepareStatement(SQL_INSERT_USER)) {
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, email);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi đăng ký tài khoản", e);
        }

        resp.sendRedirect(req.getContextPath() + "/dangnhap?registered=1");
    }

    private void backWithError(HttpServletRequest req, HttpServletResponse resp, String msg, String username, String email)
            throws ServletException, IOException {
        req.setAttribute("regError", msg);
        req.setAttribute("enteredUser", username);
        req.setAttribute("enteredEmail", email);
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
}

    private static String n(String s){ return s==null? "" : s.trim(); }
}