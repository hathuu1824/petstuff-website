/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 *
 * @author hathuu24
 */

@MultipartConfig
@WebServlet(name = "AdminAccountServlet", urlPatterns = {"/admin"})
public class AdminAccountServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ================ SQL =================
    private static final String SQL_LIST =
            "SELECT t.id, t.tendangnhap AS username, t.email AS tk_email, t.vaitro, " +
            "       u.hoten, u.ngaysinh, u.sdt, u.diachi, u.anh " +
            "FROM taikhoan t " +
            "LEFT JOIN tt_user u ON u.taikhoan_id = t.id " +
            "ORDER BY t.id ASC";

    private static final String SQL_GET_ONE =
            "SELECT t.id, t.tendangnhap AS username, t.email AS tk_email, t.vaitro, " +
            "       u.hoten, u.ngaysinh, u.sdt, u.diachi, u.anh " +
            "FROM taikhoan t " +
            "LEFT JOIN tt_user u ON u.taikhoan_id = t.id " +
            "WHERE t.id = ?";

    private static final String SQL_UPDATE_TK =
            "UPDATE taikhoan SET email = ?, vaitro = ? WHERE id = ?";

    // tt_user KHÔNG còn cột email
    private static final String SQL_UPDATE_TT =
            "UPDATE tt_user SET hoten = ?, ngaysinh = ?, sdt = ?, diachi = ?, anh = ? " +
            "WHERE taikhoan_id = ?";

    private static final String SQL_INSERT_TT =
            "INSERT INTO tt_user (taikhoan_id, hoten, ngaysinh, sdt, diachi, anh) " +
            "VALUES (?,?,?,?,?,?)";

    private static final String SQL_DELETE_TT =
            "DELETE FROM tt_user WHERE taikhoan_id = ?";

    private static final String SQL_DELETE_TK =
            "DELETE FROM taikhoan WHERE id = ?";

    // ================ GET =================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Phân quyền: chỉ admin được vào /admin
        HttpSession ss = req.getSession(false);
        String role = (ss != null) ? asString(ss.getAttribute("role")) : null;
        if (ss == null || role == null || !role.equalsIgnoreCase("admin")) {
            resp.sendRedirect(req.getContextPath() + "/trangchu");
            return;
        }

        String uname = asString(ss.getAttribute("username"));
        req.setAttribute("isLoggedIn", true);
        req.setAttribute("username", uname);

        String action = trim(req.getParameter("action"));
        String idStr  = trim(req.getParameter("id"));

        // Nếu bấm Sửa: load bản ghi cần sửa
        if ("edit".equalsIgnoreCase(action) && !idStr.isEmpty()) {
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(SQL_GET_ONE)) {

                ps.setInt(1, Integer.parseInt(idStr));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req.setAttribute("editTarget", mapRow(rs));
                    }
                }
            } catch (Exception e) {
                req.setAttribute("loadError", "Không tải được dữ liệu sửa: " + e.getMessage());
            }
        }

        // Luôn load danh sách tài khoản
        List<Map<String, Object>> accounts = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_LIST);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                accounts.add(mapRow(rs));
            }
        } catch (Exception e) {
            req.setAttribute("loadError", "Lỗi tải danh sách: " + e.getMessage());
        }

        req.setAttribute("accounts", accounts);
        // JSP chính: /admin/account.jsp
        req.getRequestDispatcher("/admin/account.jsp").forward(req, resp);
    }

    // ================ POST =================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession ss = req.getSession(false);
        String role = (ss != null) ? asString(ss.getAttribute("role")) : null;
        if (ss == null || role == null || !role.equalsIgnoreCase("admin")) {
            resp.sendRedirect(req.getContextPath() + "/trangchu");
            return;
        }

        String action = trim(req.getParameter("action"));
        String ctx = req.getContextPath();

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // ===== THÊM TÀI KHOẢN =====
            if ("add".equalsIgnoreCase(action)) {

                String tendangnhap = trim(req.getParameter("tendangnhap"));
                String matkhau     = trim(req.getParameter("matkhau"));
                String email       = trim(req.getParameter("email"));
                String vaitro      = trim(req.getParameter("vaitro"));

                if (vaitro == null || vaitro.isBlank()) vaitro = "user";

                // ===== Insert bảng taikhoan =====
                String sqlInsertTK =
                    "INSERT INTO taikhoan (tendangnhap, matkhau, email, vaitro) VALUES (?,?,?,?)";

                int newId = -1;
                try (PreparedStatement ps = conn.prepareStatement(sqlInsertTK, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, tendangnhap);
                    ps.setString(2, matkhau);
                    ps.setString(3, email);
                    ps.setString(4, vaitro);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) newId = rs.getInt(1);
                    }
                }

                if (newId <= 0) throw new RuntimeException("Không tạo được tài khoản.");

                // ===== Insert bảng tt_user =====
                String hoten   = trim(req.getParameter("hoten"));
                String sdt     = trim(req.getParameter("sdt"));
                String diachi  = trim(req.getParameter("diachi"));
                java.sql.Date ngaysinh = parseDate(req.getParameter("ngaysinh"));

                // Upload ảnh
                String anh = null;
                Part filePart = req.getPart("anh");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = System.currentTimeMillis() + "_" +
                            Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                    String uploadRoot = getServletContext().getRealPath("/images/");
                    Files.createDirectories(Paths.get(uploadRoot));
                    filePart.write(uploadRoot + File.separator + fileName);

                    anh = fileName;
                }

                try (PreparedStatement ps = conn.prepareStatement(SQL_INSERT_TT)) {
                    ps.setInt(1, newId);
                    ps.setString(2, hoten.isEmpty() ? null : hoten);
                    if (ngaysinh != null) ps.setDate(3, ngaysinh); else ps.setNull(3, Types.DATE);
                    ps.setString(4, sdt.isEmpty() ? null : sdt);
                    ps.setString(5, diachi.isEmpty() ? null : diachi);
                    ps.setString(6, anh);
                    ps.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin?msg=added");
                return;
            }

            // ===== XOÁ =====
            if ("delete".equalsIgnoreCase(action)) {
                int id = parseInt(req.getParameter("id"), -1);
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID để xoá.");

                try (PreparedStatement ps1 = conn.prepareStatement(SQL_DELETE_TT)) {
                    ps1.setInt(1, id);
                    ps1.executeUpdate();
                }
                try (PreparedStatement ps2 = conn.prepareStatement(SQL_DELETE_TK)) {
                    ps2.setInt(1, id);
                    ps2.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin?msg=deleted");
                return;
            }

            // ===== CẬP NHẬT / THÊM HỒ SƠ =====
            if ("update".equalsIgnoreCase(action)) {
                int id = parseInt(req.getParameter("id"), -1);
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID để cập nhật.");

                // bảng taikhoan
                String emailTK = trim(req.getParameter("tk_email"));
                String vaitro  = trim(req.getParameter("vaitro"));
                if (vaitro.isEmpty()) vaitro = "user";

                // bảng tt_user
                String hoten   = trim(req.getParameter("hoten"));
                String sdt     = trim(req.getParameter("sdt"));
                String diachi  = trim(req.getParameter("diachi"));
                java.sql.Date ngaysinh = parseDate(req.getParameter("ngaysinh"));

                // Ảnh đại diện: tên file cũ
                String anh = trim(req.getParameter("existingAnh"));

                // xử lý upload file nếu chọn ảnh mới
                try {
                    Part filePart = req.getPart("anhFile"); // name="anhFile"
                    if (filePart != null && filePart.getSize() > 0) {
                        String submittedName = Paths.get(filePart.getSubmittedFileName())
                                                    .getFileName().toString();
                        if (!submittedName.isBlank()) {
                            String uploadRoot = getServletContext()
                                    .getRealPath("/images/");
                            Files.createDirectories(Paths.get(uploadRoot));

                            String fileName = System.currentTimeMillis() + "_" + submittedName;
                            filePart.write(uploadRoot + File.separator + fileName);

                            anh = fileName; // lưu tên file mới
                        }
                    }
                } catch (Exception ignore) {
                    // lỗi upload -> giữ ảnh cũ
                }

                // update taikhoan
                try (PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_TK)) {
                    ps.setString(1, emailTK);
                    ps.setString(2, vaitro);
                    ps.setInt(3, id);
                    ps.executeUpdate();
                }

                // update / insert tt_user
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_TT)) {
                    ps.setString(1, hoten.isEmpty() ? null : hoten);
                    if (ngaysinh != null) ps.setDate(2, ngaysinh); else ps.setNull(2, Types.DATE);
                    ps.setString(3, sdt.isEmpty() ? null : sdt);
                    ps.setString(4, diachi.isEmpty() ? null : diachi);
                    ps.setString(5, anh.isEmpty() ? null : anh);
                    ps.setInt(6, id);
                    updated = ps.executeUpdate();
                }

                if (updated == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(SQL_INSERT_TT)) {
                        ps.setInt(1, id);
                        ps.setString(2, hoten.isEmpty() ? null : hoten);
                        if (ngaysinh != null) ps.setDate(3, ngaysinh); else ps.setNull(3, Types.DATE);
                        ps.setString(4, sdt.isEmpty() ? null : sdt);
                        ps.setString(5, diachi.isEmpty() ? null : diachi);
                        ps.setString(6, anh.isEmpty() ? null : anh);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin?msg=updated");
                return;
            }

            resp.sendRedirect(ctx + "/admin?err=unknown_action");

        } catch (Exception e) {
            req.setAttribute("loadError", "Lỗi thao tác: " + e.getMessage());
            doGet(req, resp);
        }
    }

    // ================ Helpers ================
    private static Map<String, Object> mapRow(ResultSet rs) throws SQLException {
        Map<String, Object> row = new HashMap<>();
        row.put("id",       rs.getInt("id"));
        row.put("username", rs.getString("username"));
        row.put("tk_email", rs.getString("tk_email"));
        row.put("vaitro",   rs.getString("vaitro"));
        row.put("hoten",    rs.getString("hoten"));
        row.put("ngaysinh", rs.getDate("ngaysinh"));
        row.put("sdt",      rs.getString("sdt"));
        row.put("diachi",   rs.getString("diachi"));
        row.put("anh",      rs.getString("anh"));
        return row;
    }

    private static String trim(String s) { return (s == null) ? "" : s.trim(); }
    private static String asString(Object o) { return (o == null) ? null : String.valueOf(o); }

    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private static java.sql.Date parseDate(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            java.util.Date d = new SimpleDateFormat("dd/MM/yyyy").parse(s);
            return new java.sql.Date(d.getTime());
        } catch (Exception ignore) {
            try {
                return java.sql.Date.valueOf(s);
            } catch (Exception e2) {
                return null;
            }
        }
    }
}