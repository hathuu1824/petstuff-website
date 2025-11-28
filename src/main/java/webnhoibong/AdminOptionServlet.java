/*
 * Quản lý loại sản phẩm (sanpham_loai)
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
import java.util.*;

@MultipartConfig
@WebServlet(name = "AdminOptionServlet", urlPatterns = {"/admin_loaisp"})
public class AdminOptionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ===== SQL cho sanpham_loai =====
    private static final String SQL_LIST_TYPES =
            "SELECT l.id, l.sanpham_id, l.ten_loai, l.gia, l.soluong, l.anh, " +
            "       s.tensp " +
            "FROM sanpham_loai l " +
            "LEFT JOIN sanpham s ON l.sanpham_id = s.masp " +
            "ORDER BY l.id ASC";

    private static final String SQL_GET_ONE_TYPE =
            "SELECT l.id, l.sanpham_id, l.ten_loai, l.gia, l.soluong, l.anh, " +
            "       s.tensp " +
            "FROM sanpham_loai l " +
            "LEFT JOIN sanpham s ON l.sanpham_id = s.masp " +
            "WHERE l.id = ?";

    private static final String SQL_INSERT_TYPE =
            "INSERT INTO sanpham_loai (sanpham_id, ten_loai, gia, soluong, anh) " +
            "VALUES (?,?,?,?,?)";

    private static final String SQL_UPDATE_TYPE =
            "UPDATE sanpham_loai SET sanpham_id = ?, ten_loai = ?, gia = ?, soluong = ?, anh = ? " +
            "WHERE id = ?";

    private static final String SQL_DELETE_TYPE =
            "DELETE FROM sanpham_loai WHERE id = ?";

    // ===== SQL lấy danh sách sản phẩm (để chọn theo tên) =====
    private static final String SQL_ALL_PRODUCTS =
            "SELECT masp, tensp FROM sanpham ORDER BY tensp ASC";

    // ========== GET ==========
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Chỉ admin được vào
        HttpSession ss = req.getSession(false);
        String role = (ss != null) ? asString(ss.getAttribute("role")) : null;
        if (ss == null || role == null || !role.equalsIgnoreCase("admin")) {
            resp.sendRedirect(req.getContextPath() + "/trangchu");
            return;
        }

        String uname = asString(ss.getAttribute("username"));
        req.setAttribute("isLoggedIn", true);
        req.setAttribute("username", uname);
        req.setAttribute("role", role);

        String action = trim(req.getParameter("action"));
        String idStr  = trim(req.getParameter("id"));

        // Nếu bấm "Sửa" -> load bản ghi cần sửa
        if ("edit".equalsIgnoreCase(action) && !idStr.isEmpty()) {
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(SQL_GET_ONE_TYPE)) {

                ps.setInt(1, Integer.parseInt(idStr));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req.setAttribute("editTarget", mapLoaiRow(rs));
                    }
                }
            } catch (Exception e) {
                req.setAttribute("loadError",
                        "Không tải được dữ liệu loại sản phẩm cần sửa: " + e.getMessage());
            }
        }

        // Luôn load danh sách loại sản phẩm
        List<Map<String, Object>> types = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_LIST_TYPES);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                types.add(mapLoaiRow(rs));
            }
        } catch (Exception e) {
            req.setAttribute("loadError", "Lỗi tải danh sách loại sản phẩm: " + e.getMessage());
        }
        req.setAttribute("types", types);

        // Load danh sách sản phẩm để fill combobox (chọn theo tên)
        List<Map<String, Object>> sanphamList = new ArrayList<>();
        try (Connection conn2 = DatabaseConnection.getConnection();
             PreparedStatement ps2 = conn2.prepareStatement(SQL_ALL_PRODUCTS);
             ResultSet rs2 = ps2.executeQuery()) {

            while (rs2.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("masp", rs2.getInt("masp"));
                m.put("tensp", rs2.getString("tensp"));
                sanphamList.add(m);
            }
        } catch (Exception e) {
            req.setAttribute("loadErrorProducts",
                    "Lỗi tải danh sách sản phẩm: " + e.getMessage());
        }
        req.setAttribute("sanphamList", sanphamList);

        // JSP
        req.getRequestDispatcher("/admin/option.jsp").forward(req, resp);
    }

    // ========== POST ==========
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

                try (PreparedStatement ps = conn.prepareStatement(SQL_DELETE_TYPE)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                conn.commit();
                resp.sendRedirect(ctx + "/admin_loaisp?msg=deleted");
                return;
            }

            // Dữ liệu chung cho add/update
            int sanphamId = parseInt(req.getParameter("sanpham_id"), -1);
            String tenLoai = trim(req.getParameter("ten_loai"));
            BigDecimal gia = parseBig(req.getParameter("gia"));
            Integer soluong = parseIntObj(req.getParameter("soluong"));

            if (sanphamId <= 0) {
                throw new IllegalArgumentException("Chưa chọn sản phẩm.");
            }

            // Xử lý ảnh (cả add lẫn update đều là input name="anh")
            String anhPath = trim(req.getParameter("existingAnh")); // giữ ảnh cũ khi update
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
                        anhPath = fileName;
                    }
                }
            } catch (Exception ignore) {}

            // ===== THÊM =====
            if ("add".equalsIgnoreCase(action)) {

                try (PreparedStatement ps = conn.prepareStatement(SQL_INSERT_TYPE)) {
                    ps.setInt(1, sanphamId);
                    ps.setString(2, tenLoai.isEmpty() ? null : tenLoai);
                    if (gia != null) ps.setBigDecimal(3, gia); else ps.setNull(3, Types.DECIMAL);
                    if (soluong != null) ps.setInt(4, soluong); else ps.setNull(4, Types.INTEGER);
                    ps.setString(5, (anhPath == null || anhPath.isEmpty()) ? null : anhPath);

                    ps.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin_loaisp?msg=added");
                return;
            }

            // ===== CẬP NHẬT =====
            if ("update".equalsIgnoreCase(action)) {
                int id = parseInt(req.getParameter("id"), -1);
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID để cập nhật.");

                try (PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_TYPE)) {
                    ps.setInt(1, sanphamId);
                    ps.setString(2, tenLoai.isEmpty() ? null : tenLoai);
                    if (gia != null) ps.setBigDecimal(3, gia); else ps.setNull(3, Types.DECIMAL);
                    if (soluong != null) ps.setInt(4, soluong); else ps.setNull(4, Types.INTEGER);
                    ps.setString(5, (anhPath == null || anhPath.isEmpty()) ? null : anhPath);
                    ps.setInt(6, id);

                    ps.executeUpdate();
                }

                conn.commit();
                resp.sendRedirect(ctx + "/admin_loaisp?msg=updated");
                return;
            }

            // action không khớp
            resp.sendRedirect(ctx + "/admin_loaisp?err=unknown_action");

        } catch (Exception e) {
            req.setAttribute("loadError", "Lỗi thao tác: " + e.getMessage());
            doGet(req, resp);
        }
    }

    // ========== Helpers ==========

    private static Map<String, Object> mapLoaiRow(ResultSet rs) throws SQLException {
        Map<String, Object> row = new HashMap<>();
        row.put("id",          rs.getInt("id"));
        row.put("sanpham_id",  rs.getInt("sanpham_id"));
        row.put("ten_loai",    rs.getString("ten_loai"));
        row.put("gia",         rs.getBigDecimal("gia"));
        row.put("soluong",     rs.getObject("soluong") != null ? rs.getInt("soluong") : null);
        row.put("anh",         rs.getString("anh"));
        row.put("tensp",       rs.getString("tensp"));
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
}
