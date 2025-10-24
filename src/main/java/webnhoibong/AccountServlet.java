/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.time.LocalDate;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "AccountServlet", urlPatterns = {"/AccountServlet"})
@MultipartConfig(fileSizeThreshold = 2 * 1024 * 1024,
                 maxFileSize = 10 * 1024 * 1024,
                 maxRequestSize = 20 * 1024 * 1024)
public class AccountServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/avatars";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession ss = request.getSession(false);
        if (ss == null || ss.getAttribute("taikhoanId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int tkId = (int) ss.getAttribute("taikhoanId");

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Lấy username/email hiện tại từ bảng taikhoan (nếu bạn muốn hiển thị)
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT tendangnhap, email FROM taikhoan WHERE id=?")) {
                ps.setInt(1, tkId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("username_from_login", rs.getString("tendangnhap"));
                        if (request.getAttribute("email") == null) {
                            request.setAttribute("email", rs.getString("email"));
                        }
                    }
                }
            }

            // Lấy hồ sơ từ tt_user
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, hoten, email, ngaysinh, sdt, diachi, anh " +
                    "FROM tt_user WHERE taikhoan_id=?")) {
                ps.setInt(1, tkId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("profile_id", rs.getInt("id"));
                        request.setAttribute("full_name", rs.getString("hoten"));
                        // Ưu tiên email từ tt_user nếu có, còn không dùng email từ bảng taikhoan ở trên
                        if (rs.getString("email") != null) {
                            request.setAttribute("email", rs.getString("email"));
                        }
                        request.setAttribute("dob", rs.getDate("ngaysinh")); // có thể null
                        request.setAttribute("phone", rs.getString("sdt"));
                        request.setAttribute("address", rs.getString("diachi"));
                        request.setAttribute("avatar_path", rs.getString("anh"));
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession ss = request.getSession(false);
        if (ss == null || ss.getAttribute("taikhoanId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        int tkId = (int) ss.getAttribute("taikhoanId");

        String hoten  = nvl(request.getParameter("fullname"));
        String email  = nvl(request.getParameter("email"));
        String sdt    = nvl(request.getParameter("phone"));
        String diachi = nvl(request.getParameter("address"));
        String dobStr = nvl(request.getParameter("dob"));
        java.sql.Date ngaysinh = null;
        if (!dobStr.isEmpty()) {
            ngaysinh = java.sql.Date.valueOf(LocalDate.parse(dobStr));
        }

        // upload ảnh (tùy chọn)
        Part avatarPart = request.getPart("avatar");
        String avatarRelPath = null;
        if (avatarPart != null && avatarPart.getSize() > 0 && avatarPart.getSubmittedFileName() != null) {
            String fileName = sanitize(avatarPart.getSubmittedFileName());
            String ext = "";
            int dot = fileName.lastIndexOf('.');
            if (dot >= 0) ext = fileName.substring(dot);
            String newName = "tk" + tkId + "_" + System.currentTimeMillis() + ext;

            String absUploadDir = getServletContext().getRealPath("/") + File.separator + UPLOAD_DIR;
            Files.createDirectories(Paths.get(absUploadDir));
            Path dest = Paths.get(absUploadDir, newName);
            try (InputStream in = avatarPart.getInputStream()) {
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }
            avatarRelPath = request.getContextPath() + "/" + UPLOAD_DIR + "/" + newName;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Có hồ sơ chưa?
                boolean exists;
                try (PreparedStatement ck = conn.prepareStatement(
                        "SELECT 1 FROM tt_user WHERE taikhoan_id=?")) {
                    ck.setInt(1, tkId);
                    try (ResultSet rs = ck.executeQuery()) { exists = rs.next(); }
                }

                if (exists) {
                    StringBuilder sb = new StringBuilder(
                            "UPDATE tt_user SET hoten=?, email=?, ngaysinh=?, sdt=?, diachi=?");
                    if (avatarRelPath != null) sb.append(", anh=?");
                    sb.append(" WHERE taikhoan_id=?");

                    try (PreparedStatement ps = conn.prepareStatement(sb.toString())) {
                        int i = 1;
                        ps.setString(i++, emptyToNull(hoten));
                        ps.setString(i++, emptyToNull(email));
                        ps.setDate(i++, ngaysinh);
                        ps.setString(i++, emptyToNull(sdt));
                        ps.setString(i++, emptyToNull(diachi));
                        if (avatarRelPath != null) ps.setString(i++, avatarRelPath);
                        ps.setInt(i, tkId);
                        ps.executeUpdate();
                    }
                } else {
                    String sql = "INSERT INTO tt_user (taikhoan_id, hoten, email, ngaysinh, sdt, diachi, anh) " +
                                 "VALUES (?,?,?,?,?,?,?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, tkId);
                        ps.setString(2, emptyToNull(hoten));
                        ps.setString(3, emptyToNull(email));
                        ps.setDate(4, ngaysinh);
                        ps.setString(5, emptyToNull(sdt));
                        ps.setString(6, emptyToNull(diachi));
                        ps.setString(7, avatarRelPath);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/AccountServlet");
    }

    private static String nvl(String s){ return s==null ? "" : s.trim(); }
    private static String emptyToNull(String s){ return (s==null || s.isEmpty()) ? null : s; }
    private static String sanitize(String s){ return s.replaceAll("[^a-zA-Z0-9._-]", "_"); }
}