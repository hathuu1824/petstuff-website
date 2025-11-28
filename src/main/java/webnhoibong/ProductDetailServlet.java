package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/chitiet"})
public class ProductDetailServlet extends HttpServlet {

    // =============== HIỂN THỊ CHI TIẾT SẢN PHẨM (GET /chitiet?id=...) ===============
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String idStr = req.getParameter("id"); // masp
        if (idStr == null || idStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/sanpham");
            return;
        }

        int masp;
        try {
            masp = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/sanpham");
            return;
        }

        Map<String, Object> product = new HashMap<>();
        List<Map<String, Object>> options = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ===== sản phẩm gốc =====
            final String SQL_SP =
                "SELECT masp, tensp, mota, anhsp, " +
                "       giatien, giakm, giam_pt, giam_tien " +
                "FROM sanpham WHERE masp = ? AND COALESCE(kich_hoat,1)=1";

            BigDecimal giatien = null;
            BigDecimal giakm = null;
            int giamPt = 0;
            BigDecimal giamTien = null;

            try (PreparedStatement ps = conn.prepareStatement(SQL_SP)) {
                ps.setInt(1, masp);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        resp.sendRedirect(req.getContextPath() + "/sanpham");
                        return;
                    }
                    product.put("id", rs.getInt("masp"));
                    product.put("name", rs.getString("tensp"));
                    product.put("description", rs.getString("mota"));
                    product.put("imageMain", rs.getString("anhsp"));

                    giatien  = rs.getBigDecimal("giatien");
                    giakm    = rs.getBigDecimal("giakm");
                    giamPt   = rs.getInt("giam_pt");
                    giamTien = rs.getBigDecimal("giam_tien");
                }
            }

            // ===== option / loại =====
            final String SQL_LOAI =
                "SELECT id, ten_loai, gia, soluong, anh, is_default " +
                "FROM sanpham_loai " +
                "WHERE sanpham_id = ? " +
                "ORDER BY is_default DESC, id ASC";

            BigDecimal giaChinhDeTinh = giatien;

            try (PreparedStatement ps = conn.prepareStatement(SQL_LOAI)) {
                ps.setInt(1, masp);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> opt = new HashMap<>();
                        int optId = rs.getInt("id");
                        String tenLoai = rs.getString("ten_loai");
                        BigDecimal giaLoai = rs.getBigDecimal("gia");
                        int soluong = rs.getInt("soluong");
                        String anh = rs.getString("anh");
                        boolean isDefault = rs.getInt("is_default") == 1;

                        BigDecimal giaGoc = (giaLoai != null ? giaLoai : giatien);
                        if (giaGoc == null) giaGoc = BigDecimal.ZERO;

                        BigDecimal giaSale = giaGoc;

                        if (giakm != null && giakm.compareTo(BigDecimal.ZERO) > 0) {
                            giaSale = giakm;
                        } else if (giamPt > 0) {
                            giaSale = giaGoc
                                .multiply(BigDecimal.valueOf(100 - giamPt))
                                .divide(BigDecimal.valueOf(100));
                        } else if (giamTien != null && giamTien.compareTo(BigDecimal.ZERO) > 0) {
                            giaSale = giaGoc.subtract(giamTien);
                        }

                        boolean hasDiscount = giaSale.compareTo(giaGoc) < 0;

                        opt.put("id",         optId);
                        opt.put("ten_loai",   tenLoai);
                        opt.put("giaOriginal",giaGoc);
                        opt.put("giaSale",    giaSale);
                        opt.put("soluong",    soluong);
                        opt.put("anh",        anh);
                        opt.put("isDefault",  isDefault);
                        opt.put("hasDiscount",hasDiscount);

                        if (isDefault) {
                            giaChinhDeTinh = giaGoc;
                        }

                        options.add(opt);
                    }
                }
            }

            BigDecimal giaGocChinh = giaChinhDeTinh != null ? giaChinhDeTinh : giatien;
            if (giaGocChinh == null) giaGocChinh = BigDecimal.ZERO;

            BigDecimal giaSaleChinh = giaGocChinh;

            if (giakm != null && giakm.compareTo(BigDecimal.ZERO) > 0) {
                giaSaleChinh = giakm;
            } else if (giamPt > 0) {
                giaSaleChinh = giaGocChinh
                    .multiply(BigDecimal.valueOf(100 - giamPt))
                    .divide(BigDecimal.valueOf(100));
            } else if (giamTien != null && giamTien.compareTo(BigDecimal.ZERO) > 0) {
                giaSaleChinh = giaGocChinh.subtract(giamTien);
            }

            boolean productHasDiscount = giaSaleChinh.compareTo(giaGocChinh) < 0;

            product.put("priceOriginal", giaGocChinh);
            product.put("priceSale",     giaSaleChinh);
            product.put("hasDiscount",   productHasDiscount);

        } catch (Exception e) {
            throw new ServletException("Lỗi nạp chi tiết sản phẩm", e);
        }

        req.setAttribute("product", product);
        req.setAttribute("options", options);

        req.getRequestDispatcher("/detail.jsp").forward(req, resp);
    }

    // =============== Thêm vào giỏ hàng (POST /chitiet) =================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        String ctx = req.getContextPath();

        HttpSession ss = req.getSession(false);
        Integer userId = (ss != null) ? (Integer) ss.getAttribute("userId") : null;

        if (userId == null) {
            resp.sendRedirect(ctx + "/login.jsp");
            return;
        }

        String spStr   = req.getParameter("sanpham_id");
        String loaiStr = req.getParameter("loai_id");
        String qtyStr  = req.getParameter("soluong");

        int sanphamId;
        int loaiId = 0;
        int qty    = 1;

        try {
            sanphamId = Integer.parseInt(spStr);
        } catch (Exception e) {
            resp.sendRedirect(ctx + "/sanpham");
            return;
        }
        try { loaiId = Integer.parseInt(loaiStr); } catch (Exception ignored) {}
        try { qty    = Integer.parseInt(qtyStr); } catch (Exception ignored) {}
        if (qty <= 0) qty = 1;

        try (Connection conn = DatabaseConnection.getConnection()) {

            // ===== Lấy GIÁ KM để lưu vào giohang.gia =====
            BigDecimal gia = null;

            if (loaiId > 0) {
                String sqlGiaLoai =
                    "SELECT COALESCE(sl.gia, s.giatien) AS gia_goc, " +
                    "       s.giakm, s.giam_pt, s.giam_tien " +
                    "FROM sanpham_loai sl " +
                    "JOIN sanpham s ON sl.sanpham_id = s.masp " +
                    "WHERE sl.id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlGiaLoai)) {
                    ps.setInt(1, loaiId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            BigDecimal giaGoc   = rs.getBigDecimal("gia_goc");
                            BigDecimal giakm    = rs.getBigDecimal("giakm");
                            int        giamPt   = rs.getInt("giam_pt");
                            BigDecimal giamTien = rs.getBigDecimal("giam_tien");

                            gia = tinhGiaKhuyenMai(giaGoc, giakm, giamPt, giamTien);
                        }
                    }
                }
            }

            if (gia == null) {
                String sqlGiaSp =
                    "SELECT giatien AS gia_goc, giakm, giam_pt, giam_tien " +
                    "FROM sanpham WHERE masp = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlGiaSp)) {
                    ps.setInt(1, sanphamId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            BigDecimal giaGoc   = rs.getBigDecimal("gia_goc");
                            BigDecimal giakm    = rs.getBigDecimal("giakm");
                            int        giamPt   = rs.getInt("giam_pt");
                            BigDecimal giamTien = rs.getBigDecimal("giam_tien");

                            gia = tinhGiaKhuyenMai(giaGoc, giakm, giamPt, giamTien);
                        }
                    }
                }
            }
            if (gia == null) gia = BigDecimal.ZERO;

            // ===== Nếu đã có trong giỏ -> cộng số lượng, ngược lại insert mới =====
            String checkSql =
                "SELECT id, soluong FROM giohang " +
                "WHERE user_id = ? AND sanpham_id = ? " +
                (loaiId > 0 ? "AND loai_id = ?" : "AND loai_id IS NULL");

            Integer cartId = null;
            int oldQty = 0;

            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, sanphamId);
                if (loaiId > 0) ps.setInt(3, loaiId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        cartId = rs.getInt("id");
                        oldQty = rs.getInt("soluong");
                    }
                }
            }

            if (cartId != null) {
                String updateSql = "UPDATE giohang SET soluong = ?, gia = ? WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, oldQty + qty);
                    ps.setBigDecimal(2, gia);
                    ps.setInt(3, cartId);
                    ps.executeUpdate();
                }
            } else {
                String insertSql =
                    "INSERT INTO giohang(user_id, sanpham_id, loai_id, gia, soluong) " +
                    "VALUES(?,?,?,?,?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, sanphamId);
                    if (loaiId > 0) {
                        ps.setInt(3, loaiId);
                    } else {
                        ps.setNull(3, Types.INTEGER);
                    }
                    ps.setBigDecimal(4, gia);
                    ps.setInt(5, qty);
                    ps.executeUpdate();
                }
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi thêm vào giỏ hàng", e);
        }

        resp.sendRedirect(ctx + "/cart");
    }

    /** Hàm phụ tính giá khuyến mại */
    private BigDecimal tinhGiaKhuyenMai(BigDecimal giaGoc,
                                        BigDecimal giakm,
                                        int giamPt,
                                        BigDecimal giamTien) {

        if (giaGoc == null) giaGoc = BigDecimal.ZERO;

        BigDecimal giaSale = giaGoc;

        if (giakm != null && giakm.compareTo(BigDecimal.ZERO) > 0) {
            giaSale = giakm;
        } else if (giamPt > 0) {
            giaSale = giaGoc
                .multiply(BigDecimal.valueOf(100 - giamPt))
                .divide(BigDecimal.valueOf(100));
        } else if (giamTien != null && giamTien.compareTo(BigDecimal.ZERO) > 0) {
            giaSale = giaGoc.subtract(giamTien);
        }

        return giaSale;
    }
}
