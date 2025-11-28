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
import java.sql.*;
import java.util.*;

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "AdminDiscountServlet", urlPatterns = {"/admin_km"})
@MultipartConfig(
        fileSizeThreshold = 2 * 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024
)
public class AdminDiscountServlet extends HttpServlet {

    // Thư mục lưu ảnh (trong webapp/images)
    private static final String UPLOAD_DIR = "images";

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
            response.sendRedirect(request.getContextPath() + "/admin_km");
        }
    }

    // ====================== GET helpers ======================

    private void handleEditGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            loadAndForwardList(request, response, "Thiếu ID khuyến mại cần sửa.");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException ex) {
            loadAndForwardList(request, response, "ID khuyến mại không hợp lệ.");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            Map<String, Object> editTarget = null;

            String sql = "SELECT id, anh_url, tieu_de, link, thu_tu, kich_hoat, "
                       + "ngay_tao, ngay_cap_nhat "
                       + "FROM giamgia WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        editTarget = mapPromoRow(rs);
                    }
                }
            }

            if (editTarget == null) {
                loadAndForwardList(request, response, "Không tìm thấy khuyến mại #" + id);
                return;
            }

            request.setAttribute("editTarget", editTarget);
            loadAndForwardList(request, response, null, conn); // dùng lại connection

        } catch (SQLException ex) {
            ex.printStackTrace();
            loadAndForwardList(request, response, "Lỗi tải dữ liệu khuyến mại: " + ex.getMessage());
        }
    }

    /**
     * Load danh sách khuyến mại và forward sang khuyenmai.jsp
     */
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage)
            throws ServletException, IOException {

        try (Connection conn = DatabaseConnection.getConnection()) {
            loadAndForwardList(request, response, errorMessage, conn);
        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("loadError", "Không kết nối được CSDL: " + ex.getMessage());
            request.getRequestDispatcher("/admin/discount.jsp").forward(request, response);
        }
    }

    // Overload: dùng connection có sẵn (khi đang trong handleEditGet)
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage, Connection conn)
            throws ServletException, IOException {

        List<Map<String, Object>> promos = new ArrayList<>();

        String sql = "SELECT id, anh_url, tieu_de, link, thu_tu, kich_hoat, "
                   + "ngay_tao, ngay_cap_nhat "
                   + "FROM giamgia "
                   + "ORDER BY id ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                promos.add(mapPromoRow(rs));
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            errorMessage = "Lỗi tải danh sách khuyến mại: " + ex.getMessage();
        }

        if (errorMessage != null) {
            request.setAttribute("loadError", errorMessage);
        }
        request.setAttribute("promos", promos);

        request.getRequestDispatcher("/admin/discount.jsp").forward(request, response);
    }

    // Ánh xạ 1 dòng ResultSet -> Map
    private Map<String, Object> mapPromoRow(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        m.put("id", rs.getInt("id"));
        m.put("anh_url", rs.getString("anh_url"));
        m.put("tieu_de", rs.getString("tieu_de"));
        m.put("link", rs.getString("link"));
        m.put("thu_tu", rs.getObject("thu_tu"));
        m.put("kich_hoat", rs.getObject("kich_hoat"));
        m.put("ngay_tao", rs.getTimestamp("ngay_tao"));
        m.put("ngay_cap_nhat", rs.getTimestamp("ngay_cap_nhat"));
        return m;
    }

    // ====================== POST: ADD / UPDATE / DELETE ======================

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String tieuDe = trimOrNull(request.getParameter("tieu_de"));

        Part filePart = request.getPart("anhFile");
        String fileName = getFileName(filePart);

        // Lưu file ảnh vào /images
        if (fileName != null && !fileName.isEmpty()) {
            saveUploadedFile(filePart, fileName, request);
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Lấy thu_tu lớn nhất hiện có
            int maxThuTu = 0;
            String sqlMax = "SELECT COALESCE(MAX(thu_tu), 0) FROM giamgia";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sqlMax)) {
                if (rs.next()) {
                    maxThuTu = rs.getInt(1);
                }
            }
            int newThuTu = maxThuTu + 1;

            // Thêm mới: kich_hoat luôn = 1, link = NULL (chưa dùng)
            String sql = "INSERT INTO giamgia (anh_url, tieu_de, thu_tu, kich_hoat) "
                       + "VALUES (?, ?, ?, 1)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, fileName);
                ps.setString(2, tieuDe);
                ps.setInt(3, newThuTu);
                ps.executeUpdate();
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin_km");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin_km");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin_km");
            return;
        }

        String tieuDe = trimOrNull(request.getParameter("tieu_de"));
        String existingAnh = trimOrNull(request.getParameter("existingAnh"));

        Part filePart = request.getPart("anhFile");
        String fileName = getFileName(filePart);

        // Nếu upload ảnh mới thì lưu lại và cập nhật tên file
        boolean hasNewFile = (fileName != null && !fileName.isEmpty());
        if (hasNewFile) {
            saveUploadedFile(filePart, fileName, request);
        } else {
            fileName = existingAnh; // dùng lại ảnh cũ
        }

        String sql;
        if (fileName != null && !fileName.isEmpty()) {
            sql = "UPDATE giamgia "
                + "SET tieu_de = ?, anh_url = ?, ngay_cap_nhat = NOW() "
                + "WHERE id = ?";
        } else {
            sql = "UPDATE giamgia "
                + "SET tieu_de = ?, ngay_cap_nhat = NOW() "
                + "WHERE id = ?";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, tieuDe);
            if (fileName != null && !fileName.isEmpty()) {
                ps.setString(2, fileName);
                ps.setInt(3, id);
            } else {
                ps.setInt(2, id);
            }

            ps.executeUpdate();

        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin_km");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                String sql = "DELETE FROM giamgia WHERE id = ?";

                try (Connection conn = DatabaseConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } catch (NumberFormatException | SQLException ex) {
                ex.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin_km");
    }

    // ====================== Utils ======================

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String getFileName(Part part) {
        if (part == null) return null;
        String cd = part.getHeader("content-disposition");
        if (cd == null) return null;
        for (String token : cd.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                // Chỉ lấy tên file (bỏ đường dẫn IE)
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1)
                               .substring(fileName.lastIndexOf("/") + 1);
            }
        }
        return null;
    }

    private void saveUploadedFile(Part filePart, String fileName, HttpServletRequest request)
            throws IOException {

        if (fileName == null || fileName.isEmpty()) return;

        String appPath = request.getServletContext().getRealPath("");
        if (appPath == null) return;

        String uploadPath = appPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        filePart.write(uploadPath + File.separator + fileName);
    }
}
