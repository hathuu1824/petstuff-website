/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 *
 * @author hathuu24
 */

@WebServlet(name = "DangXuatServlet", urlPatterns = {"/dangxuat"})
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();

        Cookie js = new Cookie("JSESSIONID", "");
        js.setMaxAge(0);
        js.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
        resp.addCookie(js);

        resp.sendRedirect(req.getContextPath() + "/dangnhap");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doGet(req, resp);
    }
}
