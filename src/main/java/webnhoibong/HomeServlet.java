/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.math.BigDecimal;
import java.math.RoundingMode;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "trangchu", urlPatterns = {"/trangchu"})
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("user") : null;
        boolean isLoggedIn = (username != null);

        request.setAttribute("isLoggedIn", isLoggedIn);
        if (isLoggedIn) {
            request.setAttribute("username", username);
        }

        List<Map<String, Object>> featured = new ArrayList<>();
        List<String> slideUrls = new ArrayList<>();

        // ===== Sản phẩm nổi bật =====
        final String sqlFeatured =
                "SELECT masp, anhsp, tensp, giatien, giakm, giam_pt, giam_tien, mota " +
                "FROM sanpham " +
                "WHERE noibat = 1";

        // ===== Banner slide (giữ nguyên theo CSDL hiện tại) =====
        final String sqlSlides =
                "SELECT url_anh FROM banners WHERE an_hien=1 ORDER BY thu_tu, id";

        try (Connection conn = DatabaseConnection.getConnection()) {

            // --------- LOAD FEATURED ---------
            try (PreparedStatement ps = conn.prepareStatement(sqlFeatured);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("masp",  rs.getInt("masp"));
                    row.put("anhsp", rs.getString("anhsp"));
                    row.put("tensp", rs.getString("tensp"));
                    row.put("mota",  rs.getString("mota"));

                    BigDecimal giaTien   = rs.getBigDecimal("giatien");
                    BigDecimal giaKmDb   = rs.getBigDecimal("giakm");
                    BigDecimal giamTien  = rs.getBigDecimal("giam_tien");

                    Integer giamPt = null;
                    Object ptObj   = rs.getObject("giam_pt");
                    if (ptObj != null) {
                        giamPt = ((Number) ptObj).intValue();
                    }

                    // Tính giá khuyến mại hiển thị (nếu có)
                    BigDecimal giaKm = tinhGiaKmHienThi(giaTien, giaKmDb, giamTien, giamPt);

                    row.put("giatien", giaTien); // giá gốc
                    row.put("giakm",   giaKm);   // giá sau KM (có thể null)
                    row.put("ptkm",    giamPt);  // % giảm để show badge

                    featured.add(row);
                }
            }

            // --------- LOAD SLIDE ---------
            try (PreparedStatement ps2 = conn.prepareStatement(sqlSlides);
                 ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) {
                    slideUrls.add(rs2.getString(1));
                }
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi truy vấn dữ liệu trang chủ", e);
        }

        request.setAttribute("featured",  featured);
        request.setAttribute("slideUrls", slideUrls);
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ===== HÀM TÍNH GIÁ KM HIỂN THỊ (giống bên BST) =====
    private BigDecimal tinhGiaKmHienThi(BigDecimal giaTien,
                                        BigDecimal giaKmDb,
                                        BigDecimal giamTien,
                                        Integer giamPt) {
        if (giaTien == null) return null;

        BigDecimal giaKm = giaKmDb;

        // 1. Nếu giakm trong DB đã hợp lệ (< giá gốc) thì dùng luôn
        if (giaKm != null && giaKm.compareTo(BigDecimal.ZERO) > 0
                && giaKm.compareTo(giaTien) < 0) {
            return giaKm;
        }

        // 2. Nếu có giảm theo số tiền
        if (giamTien != null && giamTien.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal tmp = giaTien.subtract(giamTien);
            if (tmp.compareTo(BigDecimal.ZERO) > 0 && tmp.compareTo(giaTien) < 0) {
                giaKm = tmp;
            }
        }

        // 3. Nếu vẫn chưa có và có giảm theo %
        if ((giaKm == null || giaKm.compareTo(BigDecimal.ZERO) <= 0)
                && giamPt != null && giamPt > 0) {

            BigDecimal hundred = BigDecimal.valueOf(100);
            BigDecimal percent = hundred.subtract(BigDecimal.valueOf(giamPt));
            BigDecimal tmp = giaTien.multiply(percent)
                                    .divide(hundred, 0, RoundingMode.HALF_UP);
            if (tmp.compareTo(BigDecimal.ZERO) > 0 && tmp.compareTo(giaTien) < 0) {
                giaKm = tmp;
            }
        }

        return giaKm; // có thể null → JSP sẽ chỉ show giá gốc
    }
}
