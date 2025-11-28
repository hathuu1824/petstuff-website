package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession ss = request.getSession(false);
        Integer userId = (ss != null) ? (Integer) ss.getAttribute("userId") : null;

        // Chưa đăng nhập -> bắt login
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        // /cart?action=remove&id=...
        if ("remove".equalsIgnoreCase(action)) {
            handleRemove(request, response, userId);
            return;
        }

        // ============= LOAD GIỎ HÀNG =============
        List<Map<String, Object>> cartItems = new ArrayList<>();
        long subtotal = 0L;   // tổng tiền sau KM (dựa trên giá đã lưu trong giohang)
        long discount = 0L;   // sau này dùng voucher
        long saved    = 0L;   // tổng số tiền “đã tiết kiệm”
        long shipping;

        String sql =
            "SELECT g.id          AS cart_id, " +
            "       g.soluong     AS so_luong, " +
            "       g.gia         AS gia_san_pham, " +   // giá đã KM lưu trong giỏ
            "       s.masp        AS sanpham_id, " +
            "       s.tensp       AS ten_san_pham, " +
            "       l.ten_loai    AS ten_loai, " +
            "       l.gia         AS loai_gia, " +       // giá gốc theo loại (nếu có)
            "       s.giatien     AS sp_gia            " + // giá gốc sản phẩm
            "FROM giohang g " +
            "JOIN sanpham s       ON g.sanpham_id = s.masp " +
            "LEFT JOIN sanpham_loai l  ON g.loai_id = l.id " +
            "WHERE g.user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();

                    int qty = rs.getInt("so_luong");

                    BigDecimal giaSaleBD = rs.getBigDecimal("gia_san_pham");
                    if (giaSaleBD == null) giaSaleBD = BigDecimal.ZERO;

                    long giaSale   = giaSaleBD.longValue();      // giá đã giảm / đã KM
                    long lineTotal = giaSale * qty;
                    subtotal      += lineTotal;

                    // Giá gốc để tính “tiết kiệm được”
                    BigDecimal loaiGiaBD = rs.getBigDecimal("loai_gia");
                    BigDecimal spGiaBD   = rs.getBigDecimal("sp_gia");
                    BigDecimal giaGocBD  = (loaiGiaBD != null) ? loaiGiaBD : spGiaBD;
                    if (giaGocBD == null) giaGocBD = giaSaleBD;

                    long giaGoc = giaGocBD.longValue();
                    long savePerUnit = Math.max(0L, giaGoc - giaSale);
                    saved += savePerUnit * qty;

                    item.put("cartId",    rs.getInt("cart_id"));
                    item.put("sanphamId", rs.getInt("sanpham_id"));
                    item.put("tenSP",     rs.getString("ten_san_pham"));
                    item.put("loai",      rs.getString("ten_loai"));
                    item.put("gia",       giaSale);
                    item.put("soLuong",   qty);
                    item.put("thanhTien", lineTotal);

                    cartItems.add(item);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Lỗi lấy dữ liệu giỏ hàng", e);
        }

        // Phí ship cố định (nếu giỏ có sản phẩm)
        shipping = subtotal > 0 ? 30000L : 0L;

        long total = subtotal - discount + shipping;

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("discount", discount);
        request.setAttribute("shipping", shipping);
        request.setAttribute("saved",    saved);
        request.setAttribute("total",    total);

        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    // ================== POST /cart ==================
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession ss = request.getSession(false);
        Integer userId = (ss != null) ? (Integer) ss.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("updateQty".equalsIgnoreCase(action)) {
            // Cập nhật số lượng + / -
            handleUpdateQty(request, response, userId);
            return;
        }

        if ("checkout".equalsIgnoreCase(action)) {
            // Sau khi tạo đơn xong, xóa các cartId đã chọn khỏi bảng giohang
            handleCheckout(request, response, userId);
            return;
        }

        // Mặc định quay lại trang giỏ
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    // ================== HELPERS ==================

    /** Xóa 1 bản ghi khỏi bảng giohang rồi quay lại /cart */
    private void handleRemove(HttpServletRequest request,
                              HttpServletResponse response,
                              int userId) throws IOException, ServletException {

        String idStr = request.getParameter("id");
        int cartId;

        try {
            cartId = Integer.parseInt(idStr);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        String sql = "DELETE FROM giohang WHERE id = ? AND user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, cartId);
            ps.setInt(2, userId);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException("Lỗi xóa sản phẩm khỏi giỏ hàng", e);
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    /** Cộng / trừ số lượng (nhưng không cho nhỏ hơn 1) */
    private void handleUpdateQty(HttpServletRequest request,
                                 HttpServletResponse response,
                                 int userId) throws IOException, ServletException {

        String idStr  = request.getParameter("id");
        String op     = request.getParameter("op"); // plus / minus

        int cartId;
        try {
            cartId = Integer.parseInt(idStr);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        int delta = "minus".equalsIgnoreCase(op) ? -1 : 1;

        String sql =
            "UPDATE giohang " +
            "SET soluong = GREATEST(1, soluong + ?) " +
            "WHERE id = ? AND user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, delta);
            ps.setInt(2, cartId);
            ps.setInt(3, userId);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException("Lỗi cập nhật số lượng giỏ hàng", e);
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    /**
     * Sau khi đặt hàng thành công (tạo đơn bên /order),
     * JS sẽ gọi POST /cart?action=checkout với nhiều tham số selected=cartId
     * -> Xóa đúng những bản ghi đó trong bảng giohang.
     */
    private void handleCheckout(HttpServletRequest request,
                                HttpServletResponse response,
                                int userId) throws IOException, ServletException {

        String[] selected = request.getParameterValues("selected");
        if (selected == null || selected.length == 0) {
            // Không có gì để xóa, trả về OK
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        // Parse sang int, bỏ qua cái nào lỗi
        List<Integer> cartIds = new ArrayList<>();
        for (String s : selected) {
            try {
                cartIds.add(Integer.parseInt(s));
            } catch (NumberFormatException ignored) {
            }
        }

        if (cartIds.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        // Tạo chuỗi ? ? ? cho IN (...)
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < cartIds.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("?");
        }

        String sql = "DELETE FROM giohang WHERE user_id = ? AND id IN (" + sb + ")";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            for (int i = 0; i < cartIds.size(); i++) {
                ps.setInt(i + 2, cartIds.get(i));
            }

            ps.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException("Lỗi checkout giỏ hàng", e);
        }

        // Trả về 200 + text đơn giản cho fetch() (JS không cần JSON ở đây)
        response.setStatus(HttpServletResponse.SC_OK);
        try (PrintWriter out = response.getWriter()) {
            out.write("OK");
        }
    }
}
