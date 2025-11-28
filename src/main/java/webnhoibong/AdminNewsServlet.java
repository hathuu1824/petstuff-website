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
import java.nio.file.StandardCopyOption;
import java.sql.*;
import java.util.*;

/**
 * @author hathuu24
 */
@WebServlet(name = "AdminNewsServlet", urlPatterns = {"/admin_tintuc"})
@MultipartConfig(
        fileSizeThreshold = 2 * 1024 * 1024,  // 2MB
        maxFileSize = 10 * 1024 * 1024,       // 10MB
        maxRequestSize = 20 * 1024 * 1024     // 20MB
)
public class AdminNewsServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "images"; // lưu ảnh vào /images

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        if ("edit".equalsIgnoreCase(action)) {
            handleEditGet(request, response);
        } else {
            loadAndForwardList(request, response, null);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        if ("add".equalsIgnoreCase(action)) {
            handleAdd(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdate(request, response);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin_tintuc");
        }
    }

    // ====================== GET helpers ======================

    private void handleEditGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            loadAndForwardList(request, response, "Thiếu ID tin tức cần sửa.");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException ex) {
            loadAndForwardList(request, response, "ID tin tức không hợp lệ.");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            Map<String, Object> editTarget = null;

            String sql = "SELECT id, tieu_de, tom_tat, noi_dung, anh_dai_dien, " +
                         "noi_bat, kich_hoat, hien_slide, thu_tu, ngay_dang " +
                         "FROM baiviet WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        editTarget = mapNewsRow(rs);
                    }
                }
            }

            if (editTarget == null) {
                loadAndForwardList(request, response, "Không tìm thấy tin tức #" + id);
                return;
            }

            request.setAttribute("editTarget", editTarget);
            loadAndForwardList(request, response, null, conn); // dùng lại connection

        } catch (SQLException ex) {
            ex.printStackTrace();
            loadAndForwardList(request, response, "Lỗi tải dữ liệu tin tức: " + ex.getMessage());
        }
    }

    /** Load danh sách tin tức và forward sang /admin/news.jsp */
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage)
            throws ServletException, IOException {

        try (Connection conn = DatabaseConnection.getConnection()) {
            loadAndForwardList(request, response, errorMessage, conn);
        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("loadError", "Không kết nối được CSDL: " + ex.getMessage());
            request.getRequestDispatcher("/admin/news.jsp").forward(request, response);
        }
    }

    // Overload: dùng connection có sẵn
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage, Connection conn)
            throws ServletException, IOException {

        List<Map<String, Object>> newsList = new ArrayList<>();

        String sql = "SELECT id, tieu_de, tom_tat, noi_dung, anh_dai_dien, " +
                     "noi_bat, kich_hoat, hien_slide, thu_tu, ngay_dang " +
                     "FROM baiviet ORDER BY id ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                newsList.add(mapNewsRow(rs));
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            errorMessage = "Lỗi tải danh sách tin tức: " + ex.getMessage();
        }

        if (errorMessage != null) {
            request.setAttribute("loadError", errorMessage);
        }
        request.setAttribute("newsList", newsList);

        request.getRequestDispatcher("/admin/news.jsp").forward(request, response);
    }

    // Ánh xạ 1 dòng ResultSet -> Map
    private Map<String, Object> mapNewsRow(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        m.put("id", rs.getInt("id"));
        m.put("tieu_de", rs.getString("tieu_de"));
        m.put("tom_tat", rs.getString("tom_tat"));
        m.put("noi_dung", rs.getString("noi_dung"));
        m.put("anh_dai_dien", rs.getString("anh_dai_dien"));
        m.put("noi_bat", rs.getObject("noi_bat"));
        m.put("kich_hoat", rs.getObject("kich_hoat"));
        m.put("hien_slide", rs.getObject("hien_slide"));
        m.put("thu_tu", rs.getObject("thu_tu"));
        m.put("ngay_dang", rs.getTimestamp("ngay_dang"));
        return m;
    }

    // ====================== POST: ADD / UPDATE / DELETE ======================

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String tieuDe  = trimOrNull(request.getParameter("tieu_de"));
        String tomTat  = trimOrNull(request.getParameter("tom_tat"));
        String noiDung = trimOrNull(request.getParameter("noi_dung"));

        String anhFileName = saveUploadFile(request, "anh_dai_dien");

        int nextThuTu = getNextThuTu();  // thu_tu = MAX + 1

        String sql = "INSERT INTO baiviet " +
                     "(tieu_de, tom_tat, noi_dung, anh_dai_dien, " +
                     " noi_bat, kich_hoat, hien_slide, thu_tu) " +
                     "VALUES (?,?,?,?,?,?,?,?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, tieuDe);
            ps.setString(2, tomTat);
            ps.setString(3, noiDung);
            ps.setString(4, anhFileName);

            ps.setInt(5, 0); // noi_bat mặc định 0
            ps.setInt(6, 1); // kich_hoat mặc định 1
            ps.setInt(7, 0); // hien_slide mặc định 0
            ps.setInt(8, nextThuTu);

            ps.executeUpdate();

        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin_tintuc");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin_tintuc");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin_tintuc");
            return;
        }

        String tieuDe  = trimOrNull(request.getParameter("tieu_de"));
        String tomTat  = trimOrNull(request.getParameter("tom_tat"));
        String noiDung = trimOrNull(request.getParameter("noi_dung"));
        String existingAnh = request.getParameter("existingAnh");

        String newAnh = saveUploadFile(request, "anh_dai_dien_edit");
        String anhToSave = (newAnh != null && !newAnh.isEmpty()) ? newAnh : existingAnh;

        String sql = "UPDATE baiviet SET tieu_de=?, tom_tat=?, noi_dung=?, anh_dai_dien=? WHERE id=?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, tieuDe);
            ps.setString(2, tomTat);
            ps.setString(3, noiDung);
            ps.setString(4, anhToSave);
            ps.setInt(5, id);

            ps.executeUpdate();

        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin_tintuc");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                String sql = "DELETE FROM baiviet WHERE id = ?";

                try (Connection conn = DatabaseConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } catch (NumberFormatException | SQLException ex) {
                ex.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin_tintuc");
    }

    // ====================== Utils ======================

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    /** Tính thu_tu = MAX(thu_tu) + 1 */
    private int getNextThuTu() {
        int next = 1;
        String sql = "SELECT COALESCE(MAX(thu_tu), 0) AS max_tt FROM baiviet";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                next = rs.getInt("max_tt") + 1;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return next;
    }

    /** Lưu file upload, trả về tên file (không kèm path). Nếu không chọn file -> null */
    private String saveUploadFile(HttpServletRequest request, String partName)
            throws IOException, ServletException {

        Part part = null;
        try {
            part = request.getPart(partName);
        } catch (IllegalStateException | ServletException ex) {
            // form không phải multipart hoặc không có part này
            return null;
        }
        if (part == null || part.getSize() == 0) return null;

        String submitted = part.getSubmittedFileName();
        if (submitted == null || submitted.trim().isEmpty()) return null;

        String fileName = Paths.get(submitted).getFileName().toString();

        String appPath = request.getServletContext().getRealPath("");
        if (appPath == null) appPath = new File(".").getAbsolutePath();

        File uploadDir = new File(appPath, UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        Files.copy(
                part.getInputStream(),
                new File(uploadDir, fileName).toPath(),
                StandardCopyOption.REPLACE_EXISTING
        );

        return fileName;
    }
}