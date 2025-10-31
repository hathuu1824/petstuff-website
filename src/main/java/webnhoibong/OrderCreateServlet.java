/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import model.PaymentStatusStore;

/**
 *
 * @author hathuu24
 */
@WebServlet(name = "OrderCreateServlet", urlPatterns = {"/OrderCreateServlet"})
public class OrderCreateServlet extends HttpServlet {
private static final int DEFAULT_SHIP = 30000;
    private static final int DEFAULT_DISCOUNT = 0;
    private static final String BANK_CODE = "VCB";
    private static final String BANK_ACCOUNT = "0123456789";
    private static final String ACCOUNT_NAME = "CONG TY PETSTUFF";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        // input từ form/UI
        String maspStr       = req.getParameter("masp");
        String taikhoanIdStr = req.getParameter("taikhoan_id"); // có thể null
        String tenNguoiNhan  = req.getParameter("tennguoinhan");
        String sdt           = req.getParameter("sdt");
        String diachi        = req.getParameter("diachi");
        String phuongthuc    = req.getParameter("phuongthuc"); // "BANK" | "COD"
        String soluongStr    = req.getParameter("soluong");

        int masp      = parseInt(maspStr, 0);
        int soluong   = Math.max(1, parseInt(soluongStr, 1));
        Integer taikhoanId = (taikhoanIdStr == null || taikhoanIdStr.isBlank()) ? null : parseInt(taikhoanIdStr, null);

        if (masp <= 0) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu hoặc sai mã sản phẩm\"}");
            return;
        }
        if (phuongthuc == null || (!phuongthuc.equals("BANK") && !phuongthuc.equals("COD"))) {
            phuongthuc = "BANK";
        }

        try (Connection c = DatabaseConnection.getConnection()) {
            c.setAutoCommit(false);

            // Lấy giá từ sanpham
            int donGia = 0;
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT COALESCE(ROUND(giatien,0),0) AS gia FROM sanpham WHERE masp=?")) {
                ps.setInt(1, masp);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) donGia = rs.getInt("gia");
                }
            }

            int phiship = DEFAULT_SHIP;
            int giamgia = DEFAULT_DISCOUNT;
            int tongtien = donGia * soluong + phiship - giamgia;

            // Nếu bạn muốn “mã lẻ” đối soát thì cộng thêm vào tiendoisoat, còn không thì để = tongtien
            int tiendoisoat = tongtien; // + rand(100..999) nếu muốn Unique Amount

            // INSERT donhang
            String sql = "INSERT INTO donhang (" +
                    " taikhoan_id, masp, tennguoinhan, sdt, diachi, " +
                    " soluong, phisp, phiship, giamgia, tongtien, tiendoisoat, " +
                    " phuongthuc, trangthai, manh, stk, tenctk, ngaytao" +
                    ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?, ?, NOW())";

            long madon;
            try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int i = 1;
                if (taikhoanId == null) ps.setNull(i++, Types.INTEGER); else ps.setInt(i++, taikhoanId);
                ps.setInt(i++, masp);
                ps.setString(i++, tenNguoiNhan);
                ps.setString(i++, sdt);
                ps.setString(i++, diachi);

                ps.setInt(i++, soluong);
                ps.setInt(i++, donGia);
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
                    if (!gk.next()) throw new SQLException("Không lấy được madon");
                    madon = gk.getLong(1);
                }
            }

            c.commit();

            // Đăng ký trạng thái PENDING cho SSE (dùng chuỗi madon)
            PaymentStatusStore.get().createPending(String.valueOf(madon));

            // trả JSON cho JS
            try (PrintWriter out = resp.getWriter()) {
                out.write("{");
                out.write("\"madon\":" + madon + ",");
                out.write("\"status\":\"PENDING\",");
                out.write("\"phisp\":" + donGia + ",");
                out.write("\"soluong\":" + soluong + ",");
                out.write("\"tongtien\":" + tongtien + ",");
                out.write("\"tiendoisoat\":" + tiendoisoat + ",");
                out.write("\"manh\":\"" + BANK_CODE + "\",");
                out.write("\"stk\":\"" + BANK_ACCOUNT + "\",");
                out.write("\"tenctk\":\"" + ACCOUNT_NAME + "\"");
                out.write("}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Lỗi tạo đơn: " + escape(e.getMessage()) + "\"}");
        }
    }

    private static int parseInt(String s, int def) {
        try { 
            return Integer.parseInt(s); 
        } 
        catch (Exception e) { 
            return def; 
        }
    }
    private static Integer parseInt(String s, Integer def) {
        try { 
            return Integer.valueOf(s); 
        } 
        catch (Exception e) { 
            return def; 
        }
    }
    private static String escape(String s){ 
        return s==null?"":s.replace("\"","\\\""); 
    }
}