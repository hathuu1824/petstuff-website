/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/**
 *
 * @author hathuu24
 */
@WebServlet(name = "AdminVoucherServlet", urlPatterns = {"/admin_voucher"})
public class AdminVoucherServlet extends HttpServlet {

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
            response.sendRedirect(request.getContextPath() + "/admin_voucher");
        }
    }

    // ====================== GET helpers ======================

    private void handleEditGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            loadAndForwardList(request, response, "Thiếu ID voucher cần sửa.");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException ex) {
            loadAndForwardList(request, response, "ID voucher không hợp lệ.");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            Map<String, Object> editTarget = null;

            String sql = "SELECT id, loai, ma, tieu_de, phan_tram, so_tien_giam, " +
                         "don_toi_thieu, giam_toi_da, het_han, san_pham_nhat_dinh " +
                         "FROM vouchers WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        editTarget = mapVoucherRow(rs);
                    }
                }
            }

            if (editTarget == null) {
                loadAndForwardList(request, response, "Không tìm thấy voucher #" + id);
                return;
            }

            request.setAttribute("editTarget", editTarget);
            loadAndForwardList(request, response, null, conn); // dùng lại connection

        } catch (SQLException ex) {
            ex.printStackTrace();
            loadAndForwardList(request, response, "Lỗi tải dữ liệu voucher: " + ex.getMessage());
        }
    }

    /**
     * Load danh sách voucher và forward sang vouchers.jsp
     */
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage)
            throws ServletException, IOException {

        try (Connection conn = DatabaseConnection.getConnection()) {
            loadAndForwardList(request, response, errorMessage, conn);
        } catch (SQLException ex) {
            ex.printStackTrace();
            request.setAttribute("loadError", "Không kết nối được CSDL: " + ex.getMessage());
            request.getRequestDispatcher("/vouchers.jsp").forward(request, response);
        }
    }

    // Overload: dùng connection có sẵn (khi đang trong handleEditGet)
    private void loadAndForwardList(HttpServletRequest request, HttpServletResponse response,
                                    String errorMessage, Connection conn)
            throws ServletException, IOException {

        List<Map<String, Object>> vouchers = new ArrayList<>();

        String sql = "SELECT id, loai, ma, tieu_de, phan_tram, so_tien_giam, " +
                     "don_toi_thieu, giam_toi_da, het_han, san_pham_nhat_dinh " +
                     "FROM vouchers ORDER BY id ASC ";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                vouchers.add(mapVoucherRow(rs));
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            errorMessage = "Lỗi tải danh sách voucher: " + ex.getMessage();
        }

        if (errorMessage != null) {
            request.setAttribute("loadError", errorMessage);
        }
        request.setAttribute("vouchers", vouchers);

        request.getRequestDispatcher("/admin/voucher.jsp").forward(request, response);
    }

    // Ánh xạ 1 dòng ResultSet -> Map
    private Map<String, Object> mapVoucherRow(ResultSet rs) throws SQLException {
        Map<String, Object> m = new HashMap<>();
        m.put("id", rs.getInt("id"));
        m.put("loai", rs.getString("loai"));
        m.put("ma", rs.getString("ma"));
        m.put("tieu_de", rs.getString("tieu_de"));
        m.put("phan_tram", rs.getBigDecimal("phan_tram"));
        m.put("so_tien_giam", rs.getBigDecimal("so_tien_giam"));
        m.put("don_toi_thieu", rs.getBigDecimal("don_toi_thieu"));
        m.put("giam_toi_da", rs.getBigDecimal("giam_toi_da"));
        m.put("het_han", rs.getTimestamp("het_han"));
        m.put("san_pham_nhat_dinh", rs.getObject("san_pham_nhat_dinh")); // Number
        return m;
    }

    // ====================== POST: ADD / UPDATE / DELETE ======================

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String loai        = trimOrNull(request.getParameter("loai"));
        String ma          = trimOrNull(request.getParameter("ma"));
        String tieuDe      = trimOrNull(request.getParameter("tieu_de"));
        BigDecimal phanTram    = parseBigDecimal(request.getParameter("phan_tram"));
        BigDecimal soTienGiam  = parseBigDecimal(request.getParameter("so_tien_giam"));
        BigDecimal donToiThieu = parseBigDecimal(request.getParameter("don_toi_thieu"));
        BigDecimal giamToiDa   = parseBigDecimal(request.getParameter("giam_toi_da"));
        Timestamp  hetHan      = parseDateTimeLocal(request.getParameter("het_han"));

        // checkbox: null = 0, khác null = 1
        int sanPhamNhatDinh = (request.getParameter("san_pham_nhat_dinh") != null) ? 1 : 0;

        String sql = "INSERT INTO vouchers " +
                     "(loai, ma, tieu_de, phan_tram, so_tien_giam, don_toi_thieu, " +
                     " giam_toi_da, het_han, san_pham_nhat_dinh, kich_hoat, thu_tu) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, loai);
            ps.setString(2, ma);
            ps.setString(3, tieuDe);

            if (phanTram != null) ps.setBigDecimal(4, phanTram);
            else ps.setBigDecimal(4, BigDecimal.ZERO);

            if (soTienGiam != null) ps.setBigDecimal(5, soTienGiam);
            else ps.setBigDecimal(5, BigDecimal.ZERO);

            if (donToiThieu != null) ps.setBigDecimal(6, donToiThieu);
            else ps.setBigDecimal(6, BigDecimal.ZERO);

            if (giamToiDa != null) ps.setBigDecimal(7, giamToiDa);
            else ps.setBigDecimal(7, BigDecimal.ZERO);

            if (hetHan != null) ps.setTimestamp(8, hetHan);
            else ps.setNull(8, Types.TIMESTAMP);

            ps.setInt(9, sanPhamNhatDinh);
            ps.setInt(10, 1);  // kich_hoat mặc định 1
            ps.setInt(11, 0);  // thu_tu mặc định 0

            ps.executeUpdate();

        } catch (SQLException ex) {
            ex.printStackTrace();
            // Có thể set session error nếu muốn
        }

        response.sendRedirect(request.getContextPath() + "/admin_voucher");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin_voucher");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/admin_voucher");
            return;
        }

        String loai        = trimOrNull(request.getParameter("loai"));
        String ma          = trimOrNull(request.getParameter("ma"));
        String tieuDe      = trimOrNull(request.getParameter("tieu_de"));
        BigDecimal phanTram    = parseBigDecimal(request.getParameter("phan_tram"));
        BigDecimal soTienGiam  = parseBigDecimal(request.getParameter("so_tien_giam"));
        BigDecimal donToiThieu = parseBigDecimal(request.getParameter("don_toi_thieu"));
        BigDecimal giamToiDa   = parseBigDecimal(request.getParameter("giam_toi_da"));
        Timestamp  hetHan      = parseDateTimeLocal(request.getParameter("het_han"));
        int sanPhamNhatDinh    = (request.getParameter("san_pham_nhat_dinh") != null) ? 1 : 0;

        String sql = "UPDATE vouchers SET loai=?, ma=?, tieu_de=?, phan_tram=?, so_tien_giam=?, " +
                     "don_toi_thieu=?, giam_toi_da=?, het_han=?, san_pham_nhat_dinh=? " +
                     "WHERE id=?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, loai);
            ps.setString(2, ma);
            ps.setString(3, tieuDe);

            if (phanTram != null) ps.setBigDecimal(4, phanTram);
            else ps.setBigDecimal(4, BigDecimal.ZERO);

            if (soTienGiam != null) ps.setBigDecimal(5, soTienGiam);
            else ps.setBigDecimal(5, BigDecimal.ZERO);

            if (donToiThieu != null) ps.setBigDecimal(6, donToiThieu);
            else ps.setBigDecimal(6, BigDecimal.ZERO);

            if (giamToiDa != null) ps.setBigDecimal(7, giamToiDa);
            else ps.setBigDecimal(7, BigDecimal.ZERO);

            if (hetHan != null) ps.setTimestamp(8, hetHan);
            else ps.setNull(8, Types.TIMESTAMP);

            ps.setInt(9, sanPhamNhatDinh);
            ps.setInt(10, id);

            ps.executeUpdate();

        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin_voucher");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                String sql = "DELETE FROM vouchers WHERE id = ?";

                try (Connection conn = DatabaseConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
            } catch (NumberFormatException | SQLException ex) {
                ex.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin_voucher");
    }

    // ====================== Utils ======================

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private BigDecimal parseBigDecimal(String s) {
        if (s == null) return null;
        s = s.trim();
        if (s.isEmpty()) return null;
        try {
            return new BigDecimal(s);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    /**
     * Parse từ input datetime-local (VD: 2025-11-24T10:30)
     */
    private Timestamp parseDateTimeLocal(String s) {
        if (s == null) return null;
        s = s.trim();
        if (s.isEmpty()) return null;
        // chuẩn thành "yyyy-MM-dd HH:mm:ss"
        String v = s.replace('T', ' ');
        if (v.length() == 16) {        // yyyy-MM-dd HH:mm
            v = v + ":00";
        }
        try {
            return Timestamp.valueOf(v);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}