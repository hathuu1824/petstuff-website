package webnhoibong;

import java.io.File;
import java.io.IOException;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "InfoServlet", urlPatterns = {"/profile"})
@MultipartConfig
public class InfoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession ss = request.getSession(false);
        Integer userId = (ss != null) ? (Integer) ss.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String username = (String) ss.getAttribute("username");
        String role     = (String) ss.getAttribute("vaitro");

        String fullName  = "";
        String dobStr    = "";
        String phone     = "";
        String address   = "";
        String imagePath = "";
        String email     = "";
        String roleLabel = (role != null ? role : "");

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Lấy email + role từ bảng taikhoan
            String sqlAcc = "SELECT email, vaitro FROM taikhoan WHERE id = ?";
            try (PreparedStatement psAcc = conn.prepareStatement(sqlAcc)) {
                psAcc.setInt(1, userId);
                try (ResultSet rsAcc = psAcc.executeQuery()) {
                    if (rsAcc.next()) {
                        email = rsAcc.getString("email");
                        String roleDb = rsAcc.getString("vaitro");
                        if (roleDb != null && !roleDb.isEmpty()) {
                            roleLabel = roleDb;
                        }
                    }
                }
            }

            // Lấy hồ sơ từ bảng tt_user
            String sqlProfile =
                    "SELECT hoten, ngaysinh, sdt, diachi, anh FROM tt_user WHERE taikhoan_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlProfile)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        fullName  = rs.getString("hoten");
                        java.sql.Date d = rs.getDate("ngaysinh");
                        dobStr    = (d != null ? d.toString() : "");
                        phone     = rs.getString("sdt");
                        address   = rs.getString("diachi");
                        imagePath = rs.getString("anh");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Đẩy sang JSP
        request.setAttribute("username",  username);
        request.setAttribute("roleLabel", roleLabel);
        request.setAttribute("fullName",  fullName);
        request.setAttribute("dobStr",    dobStr);
        request.setAttribute("phone",     phone);
        request.setAttribute("address",   address);
        request.setAttribute("imagePath", imagePath);
        request.setAttribute("email",     email);

        request.getRequestDispatcher("/information.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession ss = request.getSession(false);
        Integer userId = (ss != null) ? (Integer) ss.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String fullname = request.getParameter("fullname");
        String email    = request.getParameter("email");
        String dob      = request.getParameter("dob");
        String phone    = request.getParameter("phone");
        String address  = request.getParameter("address");

        Part avatarPart = request.getPart("avatar");
        String avatarFile = null;

        if (avatarPart != null && avatarPart.getSize() > 0) {
            String fileName   = System.currentTimeMillis() + "_" + avatarPart.getSubmittedFileName();
            String uploadPath = request.getServletContext().getRealPath("/uploads/avatars");

            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            avatarPart.write(uploadPath + File.separator + fileName);
            avatarFile = "uploads/avatars/" + fileName;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {

            // INSERT / UPDATE tt_user
            String checkSql = "SELECT id FROM tt_user WHERE taikhoan_id = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, userId);
                ResultSet rs = psCheck.executeQuery();

                if (rs.next()) {
                    String sql = "UPDATE tt_user "
                               + "SET hoten = ?, ngaysinh = ?, sdt = ?, diachi = ?"
                               + (avatarFile != null ? ", anh = ?" : "")
                               + " WHERE taikhoan_id = ?";

                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, fullname);

                        if (dob != null && !dob.isEmpty()) {
                            ps.setDate(2, java.sql.Date.valueOf(dob));
                        } else {
                            ps.setNull(2, Types.DATE);
                        }

                        ps.setString(3, phone);
                        ps.setString(4, address);

                        int idx = 5;
                        if (avatarFile != null) {
                            ps.setString(idx++, avatarFile);
                        }
                        ps.setInt(idx, userId);
                        ps.executeUpdate();
                    }

                } else {
                    String sql = "INSERT INTO tt_user "
                               + "(taikhoan_id, hoten, ngaysinh, sdt, diachi, anh) "
                               + "VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, userId);
                        ps.setString(2, fullname);

                        if (dob != null && !dob.isEmpty()) {
                            ps.setDate(3, java.sql.Date.valueOf(dob));
                        } else {
                            ps.setNull(3, Types.DATE);
                        }

                        ps.setString(4, phone);
                        ps.setString(5, address);
                        ps.setString(6, avatarFile);
                        ps.executeUpdate();
                    }
                }
            }

            // Cập nhật email trong taikhoan
            String sqlEmail = "UPDATE taikhoan SET email = ? WHERE id = ?";
            try (PreparedStatement psEmail = conn.prepareStatement(sqlEmail)) {
                psEmail.setString(1, email);
                psEmail.setInt(2, userId);
                psEmail.executeUpdate();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi SQL: " + e.getMessage());
            return;
        }

        // Quay lại trang profile (GET) để load dữ liệu mới
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
