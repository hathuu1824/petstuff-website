package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import model.PaymentStatusStore;

@WebServlet(
        name = "OrderCreateServlet",
        urlPatterns = {"/OrderCreateServlet", "/order"}
)
public class OrderCreateServlet extends HttpServlet {

    private static final int DEFAULT_SHIP     = 30000;
    private static final int DEFAULT_DISCOUNT = 0;

    // Dùng cho chi tiết đơn hàng
    private static class CartItem {
        int masp;
        int soluong;
        int gia;          // giá 1 sản phẩm tại thời điểm đặt (đã giảm nếu có)
        String tensp;
        String loai;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // ===== 1. Lấy user từ session =====
        HttpSession ss = req.getSession(false);
        Integer taikhoanId = null;
        if (ss != null) {
            Object uid = ss.getAttribute("userId");
            if (uid == null) uid = ss.getAttribute("taikhoan_id");
            if (uid instanceof Integer) {
                taikhoanId = (Integer) uid;
            } else if (uid instanceof String) {
                taikhoanId = parseInt((String) uid, (Integer) null);
            }
        }

        if (taikhoanId == null) {
            resp.setStatus(401);
            out.print("{\"status\":\"error\",\"success\":false,"
                    + "\"message\":\"Bạn chưa đăng nhập\"}");
            return;
        }

        // ===== 2. Tham số chung (phí ship, giảm giá, thanh toán) =====
        String phishipStr = firstNonEmpty(
                req.getParameter("phiship"),
                req.getParameter("ship")
        );
        String giamgiaStr = firstNonEmpty(
                req.getParameter("giamgia"),
                req.getParameter("discount")
        );
        String phuongthuc = firstNonEmpty(
                req.getParameter("phuongthuc"),
                req.getParameter("paymentMethod")
        );
        String tongtienStr = firstNonEmpty(
                req.getParameter("tongtien"),
                req.getParameter("total")
        );

        if (phuongthuc == null) phuongthuc = "COD";
        phuongthuc = phuongthuc.toUpperCase();
        if (!"BANK".equals(phuongthuc) && !"COD".equals(phuongthuc)) {
            phuongthuc = "COD";
        }

        // Có thể nhập tay
        String tenNguoiNhan = req.getParameter("tennguoinhan");
        String sdt          = req.getParameter("sdt");
        String diachi       = req.getParameter("diachi");

        try (Connection c = DatabaseConnection.getConnection()) {
            c.setAutoCommit(false);

            // ===== 3. Bổ sung thông tin người nhận nếu thiếu =====
            if (isBlank(tenNguoiNhan) || isBlank(sdt) || isBlank(diachi)) {
                String sqlUser =
                        "SELECT hoten, sdt, diachi " +
                        "FROM tt_user " +
                        "WHERE id = ?";

                try (PreparedStatement psUser = c.prepareStatement(sqlUser)) {
                    psUser.setInt(1, taikhoanId);
                    try (ResultSet rs = psUser.executeQuery()) {
                        if (rs.next()) {
                            if (isBlank(tenNguoiNhan))
                                tenNguoiNhan = rs.getString("hoten");
                            if (isBlank(sdt))
                                sdt = rs.getString("sdt");
                            if (isBlank(diachi))
                                diachi = rs.getString("diachi");
                        }
                    }
                }
            }

            if (tenNguoiNhan == null) tenNguoiNhan = "";
            if (sdt == null)          sdt          = "";
            if (diachi == null)       diachi       = "";

            // ===== 4. Xác định nguồn tạo đơn: từ giỏ hay từ trang chi tiết =====
            String sourceRaw = firstNonEmpty(
                    req.getParameter("source"),
                    req.getParameter("from")
            );
            boolean fromDetail = (sourceRaw != null
                    && "detail".equalsIgnoreCase(sourceRaw));

            // Nếu không set source nhưng có masp/sanpham_id/productId => coi là từ chi tiết
            if (!fromDetail) {
                if (req.getParameter("masp") != null
                        || req.getParameter("sanpham_id") != null
                        || req.getParameter("productId") != null) {
                    fromDetail = true;
                }
            }

            List<CartItem> items = new ArrayList<>();
            int tongSoLuong = 0;
            int tamTinh     = 0; // tổng tiền hàng (chưa ship, chưa giảm giá)

            if (fromDetail) {
                // ===== 4A. Tạo đơn từ TRANG CHI TIẾT SẢN PHẨM (Mua ngay) =====
                String maspStr = firstNonEmpty(
                        req.getParameter("masp"),
                        req.getParameter("sanpham_id"),
                        req.getParameter("productId")
                );
                String slStr = firstNonEmpty(
                        req.getParameter("soluong"),
                        req.getParameter("quantity"),
                        req.getParameter("qty")
                );
                String giaStr = firstNonEmpty(
                        req.getParameter("gia"),
                        req.getParameter("gia_san_pham"),
                        req.getParameter("price"),
                        req.getParameter("dongia")
                );

                int masp    = parseIntLoose(maspStr, 0);
                int soluong = parseIntLoose(slStr, 1);
                int gia     = parseIntLoose(giaStr, 0);

                // Bắt buộc có masp + số lượng; giá có thể lấy từ DB
                if (masp <= 0 || soluong <= 0) {
                    resp.setStatus(400);
                    out.print("{\"status\":\"error\",\"success\":false,"
                            + "\"message\":\"Không có sản phẩm hợp lệ để tạo đơn\"}");
                    c.rollback();
                    return;
                }

                String tensp = "";
                String loai  = "";
                int giaHienTai = 0;

                String sqlOne =
                        "SELECT s.tensp, " +
                        "       COALESCE(l.ten_loai, '') AS ten_loai, " +
                        "       COALESCE(l.gia, " +
                        "                CASE WHEN s.giakm IS NOT NULL AND s.giakm > 0 " +
                        "                     THEN s.giakm " +
                        "                     ELSE s.giatien END) AS gia_hien_tai " +
                        "FROM sanpham s " +
                        "LEFT JOIN sanpham_loai l " +
                        "       ON l.sanpham_id = s.masp AND l.is_default = 1 " +
                        "WHERE s.masp = ?";

                try (PreparedStatement psOne = c.prepareStatement(sqlOne)) {
                    psOne.setInt(1, masp);
                    try (ResultSet rsOne = psOne.executeQuery()) {
                        if (rsOne.next()) {
                            tensp      = rsOne.getString("tensp");
                            loai       = rsOne.getString("ten_loai");
                            giaHienTai = rsOne.getInt("gia_hien_tai");
                        }
                    }
                }

                if (tensp == null) tensp = "";
                if (loai == null)  loai  = "";

                // Nếu client không gửi giá hoặc gửi sai, dùng giá trong DB
                if (gia <= 0) gia = giaHienTai;

                if (gia <= 0) {
                    resp.setStatus(400);
                    out.print("{\"status\":\"error\",\"success\":false,"
                            + "\"message\":\"Không xác định được giá sản phẩm\"}");
                    c.rollback();
                    return;
                }

                CartItem it = new CartItem();
                it.masp    = masp;
                it.soluong = soluong;
                it.gia     = gia;
                it.tensp   = tensp;
                it.loai    = loai;

                items.add(it);
                tongSoLuong = soluong;
                tamTinh     = gia * soluong;

            } else {
                // ===== 4B. Tạo đơn từ GIỎ HÀNG =====
                String sqlCart =
                        "SELECT g.sanpham_id        AS masp, " +
                        "       g.soluong           AS so_luong, " +
                        "       g.gia               AS gia_san_pham, " +
                        "       s.tensp             AS ten_san_pham, " +
                        "       l.ten_loai          AS ten_loai " +
                        "FROM giohang g " +
                        "JOIN sanpham s         ON g.sanpham_id = s.masp " +
                        "LEFT JOIN sanpham_loai l ON g.loai_id = l.id " +
                        "WHERE g.user_id = ?";

                try (PreparedStatement psCart = c.prepareStatement(sqlCart)) {
                    psCart.setInt(1, taikhoanId);
                    try (ResultSet rs = psCart.executeQuery()) {
                        while (rs.next()) {
                            CartItem it = new CartItem();
                            it.masp     = rs.getInt("masp");
                            it.soluong  = rs.getInt("so_luong");
                            it.gia      = rs.getInt("gia_san_pham");
                            it.tensp    = rs.getString("ten_san_pham");
                            it.loai     = rs.getString("ten_loai");

                            if (it.loai == null) it.loai = "";

                            items.add(it);

                            tongSoLuong += it.soluong;
                            tamTinh     += it.gia * it.soluong;
                        }
                    }
                }
            }

            if (items.isEmpty()) {
                resp.setStatus(400);
                String msg = fromDetail
                        ? "Không có sản phẩm trong đơn hàng"
                        : "Giỏ hàng trống, không thể tạo đơn";
                out.print("{\"status\":\"error\",\"success\":false,"
                        + "\"message\":\"" + escape(msg) + "\"}");
                c.rollback();
                return;
            }

            // ===== 5. Phí ship & giảm giá + tổng tiền =====
            int phiship = (phishipStr != null)
                    ? parseInt(phishipStr, DEFAULT_SHIP)
                    : DEFAULT_SHIP;
            int giamgia = (giamgiaStr != null)
                    ? parseInt(giamgiaStr, DEFAULT_DISCOUNT)
                    : DEFAULT_DISCOUNT;

            int tongtien      = tamTinh + phiship - giamgia;
            int tongtienParam = parseInt(tongtienStr, 0);
            if (tongtienParam > 0) {
                tongtien = tongtienParam;
            }
            int tiendoisoat = tongtien;

            // ===== 6. Sinh mã đơn (madon) mới cho người dùng xem =====
            long madon;
            try (PreparedStatement psNext = c.prepareStatement(
                    "SELECT COALESCE(MAX(madon),0) + 1 AS next_madon FROM donhang");
                 ResultSet rsNext = psNext.executeQuery()) {
                if (rsNext.next()) {
                    madon = rsNext.getLong("next_madon");
                } else {
                    madon = 1L;
                }
            }

            // Lấy sản phẩm đầu tiên để lưu “đại diện” trong bảng donhang
            CartItem first = items.get(0);

            // ===== 7. INSERT donhang (tổng quan) =====
            int tongTienHang = tamTinh; // phisp = tổng tiền hàng

            String sqlDonhang = "INSERT INTO donhang ("
                    + " madon, taikhoan_id, masp, tennguoinhan, sdt, diachi, "
                    + " soluong, phisp, phiship, giamgia, tongtien, tiendoisoat, "
                    + " phuongthuc, trangthai, ngaytao, ngaycapnhat, lydo_huy, lydo_hoan"
                    + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),NOW(),?,?)";

            long donhangId;
            try (PreparedStatement ps = c.prepareStatement(
                    sqlDonhang, Statement.RETURN_GENERATED_KEYS)) {

                int i = 1;
                ps.setLong(i++, madon);
                ps.setInt(i++, taikhoanId);
                ps.setInt(i++, first.masp);
                ps.setString(i++, tenNguoiNhan);
                ps.setString(i++, sdt);
                ps.setString(i++, diachi);

                ps.setInt(i++, tongSoLuong);
                ps.setInt(i++, tongTienHang);
                ps.setInt(i++, phiship);
                ps.setInt(i++, giamgia);
                ps.setInt(i++, tongtien);
                ps.setInt(i++, tiendoisoat);

                ps.setString(i++, phuongthuc);
                ps.setString(i++, "PENDING");          // trạng thái khởi tạo

                // lydo_huy, lydo_hoan: NULL khi mới tạo đơn
                ps.setNull(i++, Types.VARCHAR);
                ps.setNull(i++, Types.VARCHAR);

                ps.executeUpdate();

                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (!gk.next()) {
                        throw new SQLException("Không lấy được id đơn hàng");
                    }
                    donhangId = gk.getLong(1);
                }
            }

            // ===== 8. INSERT donhang_ct cho TỪNG SẢN PHẨM =====
            String sqlCt = "INSERT INTO donhang_ct ("
                    + " donhang_id, masp, soluong, gia, thanhtien, loai, tensp"
                    + ") VALUES (?,?,?,?,?,?,?)";

            try (PreparedStatement psCt = c.prepareStatement(sqlCt)) {
                for (CartItem it : items) {
                    int thanhtien = it.gia * it.soluong;

                    int j = 1;
                    psCt.setLong(j++, donhangId);
                    psCt.setInt(j++, it.masp);
                    psCt.setInt(j++, it.soluong);
                    psCt.setInt(j++, it.gia);
                    psCt.setInt(j++, thanhtien);
                    psCt.setString(j++, it.loai);
                    psCt.setString(j++, it.tensp);

                    psCt.addBatch();
                }
                psCt.executeBatch();
            }

            // ===== 9. Xóa giỏ hàng sau khi tạo đơn (chỉ khi đặt từ giỏ) =====
            if (!fromDetail) {
                try (PreparedStatement psDel = c.prepareStatement(
                        "DELETE FROM giohang WHERE user_id = ?")) {
                    psDel.setInt(1, taikhoanId);
                    psDel.executeUpdate();
                }
            }

            // ===== 10. Commit =====
            c.commit();

            // Lưu trạng thái tạm cho QR / theo dõi thanh toán theo mã đơn (madon)
            if ("BANK".equals(phuongthuc)) {
                PaymentStatusStore.get().createPending(String.valueOf(madon));
            }

            // ===== 11. Chuẩn bị message & paymentStatus cho client =====
            String paymentStatus;
            String message;

            if ("COD".equals(phuongthuc)) {
                paymentStatus = "COD";
                message = "Tạo đơn hàng thành công";
            } else {
                paymentStatus = "PENDING";
                message = "Tạo đơn thành công, vui lòng thanh toán và đợi hệ thống duyệt đơn";
            }

            // ===== 12. Trả JSON cho client =====
            StringBuilder sb = new StringBuilder();
            sb.append("{");
            sb.append("\"status\":\"success\",");
            sb.append("\"success\":true,");
            sb.append("\"paymentStatus\":\"").append(paymentStatus).append("\",");
            sb.append("\"message\":\"").append(escape(message)).append("\",");
            sb.append("\"orderId\":").append(madon).append(",");
            sb.append("\"tongSoLuong\":").append(tongSoLuong).append(",");
            sb.append("\"tongtien\":").append(tongtien).append(",");
            sb.append("\"tiendoisoat\":").append(tiendoisoat);
            sb.append("}");

            out.print(sb.toString());

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            out.print("{\"status\":\"error\",\"success\":false,"
                    + "\"message\":\"Lỗi tạo đơn: " + escape(e.getMessage()) + "\"}");
        }
    }

    // ===== Helper =====
    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String firstNonEmpty(String... arr) {
        if (arr == null) return null;
        for (String s : arr) {
            if (s != null && !s.trim().isEmpty()) return s.trim();
        }
        return null;
    }

    // parseInt "mềm" cho số có dấu . , đ ...
    private static int parseIntLoose(String s, int def) {
        if (s == null) return def;
        try {
            String cleaned = s.replaceAll("[^0-9-]", "");
            if (cleaned.isEmpty() || cleaned.equals("-")) return def;
            return Integer.parseInt(cleaned);
        } catch (Exception e) {
            return def;
        }
    }

    private static int parseInt(String s, int def) {
        return parseIntLoose(s, def);
    }

    private static Integer parseInt(String s, Integer def) {
        if (s == null) return def;
        try {
            String cleaned = s.replaceAll("[^0-9-]", "");
            if (cleaned.isEmpty() || cleaned.equals("-")) return def;
            return Integer.valueOf(cleaned);
        } catch (Exception e) {
            return def;
        }
    }

    private static String escape(String s) {
        return (s == null) ? "" : s.replace("\"", "\\\"");
    }
}
