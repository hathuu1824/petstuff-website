/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.PaymentStatusStore;

@WebServlet(name = "PaymentSseServlet", urlPatterns = {"/payments/stream"})
public class PaymentSseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/event-stream");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-cache");
        resp.setHeader("Connection", "keep-alive");

        String orderId = req.getParameter("orderId");
        if (orderId == null || orderId.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().println("data: INVALID_ORDER\n\n");
            return;
        }

        PaymentStatusStore store = PaymentStatusStore.get();

        if (store.isPaid(orderId)) {
            resp.getWriter().println("data: PAID\n\n");
            resp.getWriter().flush();
            return;
        }

        store.registerClient(orderId, resp);
        try {
            Thread.sleep(5 * 60 * 1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            store.removeClient(orderId);
        }
    }
}