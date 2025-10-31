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

@WebServlet(name = "PaymentMarkPaidServlet", urlPatterns = {"/payments/mark-paid"})
public class PaymentMarkPaidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String orderId = req.getParameter("orderId");
        if (orderId == null || orderId.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().println("Missing orderId");
            return;
        }

        PaymentStatusStore.get().markPaid(orderId);
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().println("Marked as PAID: " + orderId);
    }
}