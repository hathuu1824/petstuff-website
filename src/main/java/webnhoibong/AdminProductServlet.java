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
import java.math.BigDecimal;
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
@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin_sanpham"})
public class AdminProductServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ================== SQL ==================
    private static final String SQL_LIST =
            "SELECT masp, tensp, giatien, giakm, giam_pt, giam_tien, " +
            "       km_tu, km_den, mota, anhsp, bst, loai " +
            "FROM sanpham ORDER BY masp ASC";

    private static final String SQL_GET_ONE =
            "SELECT masp, tensp, giatien, giakm, giam_pt, giam_tien, " +
            "       km_tu, km_den, mota, anhsp, bst, loai " +
            "FROM sanpham WHERE masp = ?";

    private static final String SQL_INSERT =
            "INSERT INTO sanpham " +
            "  (tensp, giatien, giakm, giam_pt, giam_tien, km_tu, km_den, mota, anhsp, bst, loai) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?)";

    private static final String SQL_UPDATE =
            "UPDATE sanpham SET " +
            "  tensp = ?, giatien = ?, giakm = ?, giam_pt = ?, giam_tien = ?, " +
            "  km_tu = ?, km_den = ?, mota = ?, anhsp = ?, bst = ?, loai = ? " +
            "WHERE masp = ?";

    private static final String SQL_DELETE =
            "DELETE FROM sanpham WHERE masp = ?";

    // ================== GET ==================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // chỉ admin được vào
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

        // Nếu bấm Sửa: load sản phẩm cần sửa
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

        // Luôn load danh sách sản phẩm
        List<Map<String, Object>> products = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_LIST);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                products.add(mapRow(rs));
            }
        } catch (Exception e) {
            req.setAttribute("loadError", "Lỗi tải danh sách: " + e.getMessage());
        }

        req.setAttribute("products", products);
        // JSP: admin_sanpham.jsp
        req.getRequestDispatcher("/admin/products.jsp").forward(req, resp);
    }

    // ================== POST ==================
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
        String ctx    = req.getContextPath();

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);

            // ===== XOÁ =====
            if ("delete".equalsIgnoreCase(action)) {
                int id = parseInt(req.getParameter("id"), -1);
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID để xoá.");

                try (PreparedStatement ps = conn.prepareStatement(SQL_DELETE)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                conn.commit();
                resp.sendRedirect(ctx + "/admin_sanpham?msg=deleted");
                return;
            }

            // ===== THÊM SẢN PHẨM =====
            if ("add".equalsIgnoreCase(action)) {
                String tensp     = trim(req.getParameter("tensp"));
                BigDecimal gia   = parseBig(req.getParameter("giatien"));
                BigDecimal giaKm = parseBig(req.getParameter("giakm"));
                Integer giamPt   = parseIntObj(req.getParameter("giam_pt"));
                BigDecimal giamTien = parseBig(req.getParameter("giam_tien"));
                Timestamp kmTu   = parseDateTime(req.getParameter("km_tu"));
                Timestamp kmDen  = parseDateTime(req.getParameter("km_den"));
                String mota      = trim(req.getParameter("mota"));
                String bst       = trim(req.getParameter("bst"));
                String loai      = trim(req.getParameter("loai"));

                // upload ảnh (name="anh")
                String anhsp = null;
                try {
                    Part filePart = req.getPart("anh");
                    if (filePart != null && filePart.getSize() > 0) {
                        String submitted = Paths.get(filePart.getSubmittedFileName())
                                                .getFileName().toString();
                        if (!submitted.isBlank()) {
                            String uploadRoot = getServletContext().getRealPath("/images/");
                            Files.createDirectories(Paths.get(uploadRoot));
                            String fileName = System.currentTimeMillis() + "_" + submitted;
                            filePart.write(uploadRoot + File.separator + fileName);
                            anhsp = fileName;
                        }
                    }
                } catch (Exception ignore) {}

                try (PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {
                    ps.setString(1, tensp.isEmpty() ? null : tensp);
                    if (gia != null) ps.setBigDecimal(2, gia); else ps.setNull(2, Types.DECIMAL);
                    if (giaKm != null) ps.setBigDecimal(3, giaKm); else ps.setNull(3, Types.DECIMAL);
                    if (giamPt != null) ps.setInt(4, giamPt); else ps.setNull(4, Types.TINYINT);
                    if (giamTien != null) ps.setBigDecimal(5, giamTien); else ps.setNull(5, Types.DECIMAL);

                    if (kmTu != null) ps.setTimestamp(6, kmTu); else ps.setNull(6, Types.TIMESTAMP);
                    if (kmDen != null) ps.setTimestamp(7, kmDen); else ps.setNull(7, Types.TIMESTAMP);

                    ps.setString(8, mota.isEmpty() ? null : mota);
                    ps.setString(9, (anhsp == null || anhsp.isEmpty()) ? null : anhsp);
                    ps.setString(10, bst.isEmpty() ? null : bst);
                    ps.setString(11, loai.isEmpty() ? null : loai);

                    ps.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin_sanpham?msg=added");
                return;
            }

            // ===== CẬP NHẬT SẢN PHẨM =====
            if ("update".equalsIgnoreCase(action)) {
                int id = parseInt(req.getParameter("id"), -1);
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID để cập nhật.");

                String tensp     = trim(req.getParameter("tensp"));
                BigDecimal gia   = parseBig(req.getParameter("giatien"));
                BigDecimal giaKm = parseBig(req.getParameter("giakm"));
                Integer giamPt   = parseIntObj(req.getParameter("giam_pt"));
                BigDecimal giamTien = parseBig(req.getParameter("giam_tien"));
                Timestamp kmTu   = parseDateTime(req.getParameter("km_tu"));
                Timestamp kmDen  = parseDateTime(req.getParameter("km_den"));
                String mota      = trim(req.getParameter("mota"));
                String bst       = trim(req.getParameter("bst"));
                String loai      = trim(req.getParameter("loai"));

                String anhsp = trim(req.getParameter("existingAnh")); // giữ ảnh cũ

                // Nếu chọn ảnh mới
                try {
                    Part filePart = req.getPart("anhspFile"); // name trong modal sửa
                    if (filePart != null && filePart.getSize() > 0) {
                        String submitted = Paths.get(filePart.getSubmittedFileName())
                                                .getFileName().toString();
                        if (!submitted.isBlank()) {
                            String uploadRoot = getServletContext().getRealPath("/images/");
                            Files.createDirectories(Paths.get(uploadRoot));
                            String fileName = System.currentTimeMillis() + "_" + submitted;
                            filePart.write(uploadRoot + File.separator + fileName);
                            anhsp = fileName;
                        }
                    }
                } catch (Exception ignore) {}

                try (PreparedStatement ps = conn.prepareStatement(SQL_UPDATE)) {
                    ps.setString(1, tensp.isEmpty() ? null : tensp);
                    if (gia != null) ps.setBigDecimal(2, gia); else ps.setNull(2, Types.DECIMAL);
                    if (giaKm != null) ps.setBigDecimal(3, giaKm); else ps.setNull(3, Types.DECIMAL);
                    if (giamPt != null) ps.setInt(4, giamPt); else ps.setNull(4, Types.TINYINT);
                    if (giamTien != null) ps.setBigDecimal(5, giamTien); else ps.setNull(5, Types.DECIMAL);

                    if (kmTu != null) ps.setTimestamp(6, kmTu); else ps.setNull(6, Types.TIMESTAMP);
                    if (kmDen != null) ps.setTimestamp(7, kmDen); else ps.setNull(7, Types.TIMESTAMP);

                    ps.setString(8, mota.isEmpty() ? null : mota);
                    ps.setString(9, (anhsp == null || anhsp.isEmpty()) ? null : anhsp);
                    ps.setString(10, bst.isEmpty() ? null : bst);
                    ps.setString(11, loai.isEmpty() ? null : loai);
                    ps.setInt(12, id);

                    ps.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin_sanpham?msg=updated");
                return;
            }

            // nếu action không khớp
            resp.sendRedirect(ctx + "/admin_sanpham?err=unknown_action");

        } catch (Exception e) {
            // nếu lỗi -> quay lại trang kèm message
            req.setAttribute("loadError", "Lỗi thao tác: " + e.getMessage());
            doGet(req, resp);
        }
    }

    // ================== Helpers ==================
    private static Map<String, Object> mapRow(ResultSet rs) throws SQLException {
        Map<String, Object> row = new HashMap<>();
        row.put("masp",      rs.getInt("masp"));
        row.put("tensp",     rs.getString("tensp"));
        row.put("giatien",   rs.getBigDecimal("giatien"));
        row.put("giakm",     rs.getBigDecimal("giakm"));
        row.put("giam_pt",   rs.getObject("giam_pt") != null ? rs.getInt("giam_pt") : null);
        row.put("giam_tien", rs.getBigDecimal("giam_tien"));
        row.put("km_tu",     rs.getTimestamp("km_tu"));
        row.put("km_den",    rs.getTimestamp("km_den"));
        row.put("mota",      rs.getString("mota"));
        row.put("anhsp",     rs.getString("anhsp"));
        row.put("bst",       rs.getString("bst"));
        row.put("loai",      rs.getString("loai"));
        return row;
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private static String asString(Object o) {
        return (o == null) ? null : String.valueOf(o);
    }

    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private static Integer parseIntObj(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Integer.valueOf(s); } catch (Exception e) { return null; }
    }

    private static BigDecimal parseBig(String s) {
        if (s == null || s.isBlank()) return null;
        try { return new BigDecimal(s); } catch (Exception e) { return null; }
    }

    // convert input type="datetime-local" (yyyy-MM-ddTHH:mm) -> Timestamp
    private static Timestamp parseDateTime(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            // trình duyệt gửi dạng 2025-11-21T13:45
            String norm = s.replace("T", " ");
            SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            java.util.Date d = fmt.parse(norm);
            return new Timestamp(d.getTime());
        } catch (Exception e) {
            try {
                return Timestamp.valueOf(s);
            } catch (Exception e2) {
                return null;
            }
        }
    }
}