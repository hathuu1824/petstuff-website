package webnhoibong;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.RequestDispatcher;
import model.Product;
import model.OptionItem;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/chitiet"})
public class ProductDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số id");
            return;
        }

        int masp;
        try {
            masp = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "id không hợp lệ");
            return;
        }

        String sql =
            "SELECT masp, tensp, giatien, mota, anhsp, noibat, bst, loai " +
            "FROM sanpham " +
            "WHERE masp = ?";

        Product product = null;
        int price = 0;
        String mainImage = null;
        String description = null;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, masp);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String tensp = rs.getString("tensp");
                    BigDecimal giatien = rs.getBigDecimal("giatien");
                    description = rs.getString("mota");
                    String anhsp = rs.getString("anhsp");

                    price = (giatien != null)
                            ? giatien.setScale(0, BigDecimal.ROUND_HALF_UP).intValue()
                            : 0;
                    if (anhsp == null || anhsp.trim().isEmpty()) {
                        mainImage = "images/no-image.png";
                    } else {
                        mainImage = "images/" + anhsp;
                    }

                    product = new Product(masp, tensp, mainImage,
                            (description == null ? "" : description));
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Lỗi truy vấn sản phẩm", e);
        }

        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sản phẩm");
            return;
        }

        // ===== Tạo dữ liệu JSP cần =====
        List<String> optionImages = new ArrayList<>();
        optionImages.add(product.getImageUrl());

        List<OptionItem> optionList = new ArrayList<>();
        optionList.add(new OptionItem("Mặc định", price));

        List<String> optionNames = new ArrayList<>();
        optionNames.add("Mặc định");

        Map<String, Integer> optionPriceMap = new LinkedHashMap<>();
        optionPriceMap.put("Mặc định", price);

        int stock = 50; // giả định

        HttpSession ss = request.getSession(false);
        Integer userId = (ss != null && ss.getAttribute("userId") instanceof Integer)
                ? (Integer) ss.getAttribute("userId")
                : null;

        // ===== Gắn attribute cho JSP =====
        request.setAttribute("product", product);
        request.setAttribute("description", description);
        request.setAttribute("mainImage", mainImage);
        request.setAttribute("optionImages", optionImages);
        request.setAttribute("optionList", optionList);
        request.setAttribute("optionNames", optionNames);
        request.setAttribute("optionPriceMap", optionPriceMap);
        request.setAttribute("stock", stock);
        request.setAttribute("userId", userId);

        // Không cần gson, nên optionsStr có thể null hoặc chuỗi đơn giản
        request.setAttribute("optionsStr", "['Mặc định']");

        String orderId = java.util.UUID.randomUUID().toString();
        model.PaymentStatusStore.get().createPending(orderId);
        request.setAttribute("orderId", orderId);

        // ===== Forward =====
        RequestDispatcher rd = request.getRequestDispatcher("/detail.jsp");
        rd.forward(request, response);
    }
}
