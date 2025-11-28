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

@WebServlet(name = "OrderCreateServlet",
        urlPatterns = {"/OrderCreateServlet", "/order"})
public class OrderCreateServlet extends HttpServlet {

    private static final int DEFAULT_SHIP     = 30000;
    private static final int DEFAULT_DISCOUNT = 0;
    private static final String BANK_CODE     = "VCB";
    private static final String BANK_ACCOUNT  = "0123456789";
    private static final String ACCOUNT_NAME  = "CONG TY PETSTUFF";

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
        if (!phuongthuc.equals("BANK") && !phuongthuc.equals("COD")) {
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

            // ===== 4. Lấy danh sách sản phẩm trong GIỎ HÀNG =====
            String sqlCart =
                    "SELECT g.sanpham_id        AS masp, " +
                    "       g.soluong           AS so_luong, " +
                    "       g.gia               AS gia_san_pham, " +
                    "       s.tensp             AS ten_san_pham, " +
                    "       l.ten_loai          AS ten_loai " +
                    "FROM giohang g " +
                    "JOIN sanpham s      ON g.sanpham_id = s.masp " +
                    "LEFT JOIN sanpham_loai l ON g.loai_id = l.id " +
                    "WHERE g.user_id = ?";

            List<CartItem> items = new ArrayList<>();
            int tongSoLuong = 0;
            int tamTinh = 0; // tổng tiền hàng (chưa ship, chưa giảm giá)

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

            if (items.isEmpty()) {
                // Không có gì trong giỏ
                resp.setStatus(400);
                out.print("{\"status\":\"error\",\"success\":false," +
                          "\"message\":\"Giỏ hàng trống, không thể tạo đơn\"}");
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
            String sqlDonhang = "INSERT INTO donhang ("
                    + " madon, taikhoan_id, masp, tennguoinhan, sdt, diachi, "
                    + " soluong, phisp, phiship, giamgia, tongtien, tiendoisoat, "
                    + " phuongthuc, trangthai, manh, stk, tenctk, ngaytao"
                    + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, NOW())";

            long donhangId;
            try (PreparedStatement ps = c.prepareStatement(
                    sqlDonhang, Statement.RETURN_GENERATED_KEYS)) {

                int i = 1;
                ps.setLong(i++, madon);
                ps.setInt(i++, taikhoanId);
                ps.setInt(i++, first.masp);          // mã sp đại diện
                ps.setString(i++, tenNguoiNhan);
                ps.setString(i++, sdt);
                ps.setString(i++, diachi);

                ps.setInt(i++, tongSoLuong);        // tổng số lượng trong đơn
                ps.setInt(i++, first.gia);          // giá đại diện
                ps.setInt(i++, phiship);
                ps.setInt(i++, giamgia);
                ps.setInt(i++, tongtien);
                ps.setInt(i++, tiendoisoat);

                ps.setString(i++, phuongthuc);
                ps.setString(i++, "PENDING");
                ps.setString(i++, BANK_CODE);
                ps.setString(i++, BANK_ACCOUNT);
                ps.setString(i++, ACCOUNT_NAME);

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

            // ===== 9. Xóa giỏ hàng sau khi tạo đơn =====
            try (PreparedStatement psDel = c.prepareStatement(
                    "DELETE FROM giohang WHERE user_id = ?")) {
                psDel.setInt(1, taikhoanId);
                psDel.executeUpdate();
            }

            // ===== 10. Commit =====
            c.commit();

            // Lưu trạng thái tạm cho QR / theo dõi thanh toán theo mã đơn (madon)
            PaymentStatusStore.get().createPending(String.valueOf(madon));

            // ===== 11. Trả JSON cho client =====
            StringBuilder sb = new StringBuilder();
            sb.append("{");
            sb.append("\"status\":\"success\",");
            sb.append("\"success\":true,");
            sb.append("\"paymentStatus\":\"PENDING\",");
            sb.append("\"orderId\":").append(madon).append(",");
            sb.append("\"tongSoLuong\":").append(tongSoLuong).append(",");
            sb.append("\"tongtien\":").append(tongtien).append(",");
            sb.append("\"tiendoisoat\":").append(tiendoisoat).append(",");
            sb.append("\"manh\":\"").append(BANK_CODE).append("\",");
            sb.append("\"stk\":\"").append(BANK_ACCOUNT).append("\",");
            sb.append("\"tenctk\":\"").append(ACCOUNT_NAME).append("\"");
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

    private static int parseInt(String s, int def) {
        if (s == null) return def;
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static Integer parseInt(String s, Integer def) {
        if (s == null) return def;
        try {
            return Integer.valueOf(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static String escape(String s) {
        return (s == null) ? "" : s.replace("\"", "\\\"");
    }
}
