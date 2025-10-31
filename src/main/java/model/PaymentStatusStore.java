/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 *
 * @author hathuu24
 */
public class PaymentStatusStore {
    private static final PaymentStatusStore INSTANCE = new PaymentStatusStore();
    private final Map<String, Boolean> paidMap = new ConcurrentHashMap<>();
    private final Map<String, HttpServletResponse> clients = new ConcurrentHashMap<>();

    private PaymentStatusStore() {}

    public static PaymentStatusStore get() {
        return INSTANCE;
    }
    
    public void createPending(String orderId) {
        paidMap.put(orderId, false);
    }

    public void markPaid(String orderId) {
        paidMap.put(orderId, true);
        HttpServletResponse client = clients.remove(orderId);
        if (client != null) {
            try {
                client.getWriter().println("data: PAID\n\n");
                client.getWriter().flush();
                client.getWriter().close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean isPaid(String orderId) {
        return paidMap.getOrDefault(orderId, false);
    }

    public void registerClient(String orderId, HttpServletResponse resp) {
        clients.put(orderId, resp);
    }

    public void removeClient(String orderId) {
        clients.remove(orderId);
    }
}
