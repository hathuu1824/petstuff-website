/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "sanpham", urlPatterns = {"/sanpham"})
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int size = parseInt(req.getParameter("size"), 9);   
        if (size <= 0) size = 9;

        int page = parseInt(req.getParameter("page"), 1);
        if (page <= 0) page = 1;

        String[] loaiArr = req.getParameterValues("loai");  
        String[] bstArr  = req.getParameterValues("bst");   
        String sort      = req.getParameter("sort");      

        List<String> whereParts   = new ArrayList<>();
        List<Object> whereParams  = new ArrayList<>();

        if (loaiArr != null && loaiArr.length > 0) {
            whereParts.add("loai IN (" + placeholders(loaiArr.length) + ")");
            Collections.addAll(whereParams, (Object[]) loaiArr);
        }
        if (bstArr != null && bstArr.length > 0) {
            whereParts.add("bst IN (" + placeholders(bstArr.length) + ")");
            Collections.addAll(whereParams, (Object[]) bstArr);
        }

        String whereSql = whereParts.isEmpty() ? "" : (" WHERE " + String.join(" AND ", whereParts));

        String orderSql;
        if ("price_asc".equalsIgnoreCase(sort)) {
            orderSql = " ORDER BY giatien ASC";
        } else if ("price_desc".equalsIgnoreCase(sort)) {
            orderSql = " ORDER BY giatien DESC";
        } else if ("newest".equalsIgnoreCase(sort)) {
            orderSql = " ORDER BY masp DESC";
        } else {
            orderSql = " ORDER BY masp DESC";
        }

        long totalCount = 0;
        int totalPages  = 1;
        List<Map<String, Object>> products = new ArrayList<>();

        final String SQL_COUNT =
            "SELECT COUNT(*) FROM sanpham" + whereSql;

        final String SQL_PAGE  =
            "SELECT masp, tensp, anhsp, giatien " +
            "FROM sanpham" + whereSql +
            orderSql +
            " LIMIT ? OFFSET ?";

        try (Connection c = DatabaseConnection.getConnection()) {

            try (PreparedStatement ps = c.prepareStatement(SQL_COUNT)) {
                bindParams(ps, whereParams);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getLong(1);
                }
            }

            totalPages = (int) Math.ceil(totalCount / (double) size);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;
            int offset = (page - 1) * size;

            try (PreparedStatement ps = c.prepareStatement(SQL_PAGE)) {
                int idx = bindParams(ps, whereParams); 
                ps.setInt(idx++, size);                
                ps.setInt(idx,   offset);           

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> p = new HashMap<>();
                        p.put("masp",    rs.getInt("masp"));
                        p.put("tensp",   rs.getString("tensp"));
                        p.put("anhsp",   rs.getString("anhsp"));
                        p.put("giatien", rs.getBigDecimal("giatien"));
                        products.add(p);
                    }
                }
            }

        } catch (Exception e) {
            throw new ServletException("Lỗi lấy danh sách sản phẩm (lọc/sắp xếp/phân trang)", e);
        }

        req.setAttribute("products", products);
        req.setAttribute("page", page);
        req.setAttribute("size", size);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);

        req.getRequestDispatcher("/product.jsp").forward(req, resp);
        
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private static String placeholders(int n) {
        if (n <= 0) return "";
        return String.join(",", java.util.Collections.nCopies(n, "?"));
    }

    private static int bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        if (params != null) {
            for (Object o : params) ps.setObject(idx++, o);
        }
        return idx;
    }
}