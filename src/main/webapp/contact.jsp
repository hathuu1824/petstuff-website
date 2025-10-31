<%-- 
    Document   : contact
    Created on : 16 Apr 2025, 2:06:08 pm
    Author     : hathuu24
--%>
<%-- <%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="webnhoibong.DatabaseConnection" %>
<%
    HttpSession sessionUser = request.getSession(false);
    if (sessionUser == null || sessionUser.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%> --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/contact.css">
        <link rel="stylesheet" href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Liên hệ</title>
    </head>
    <body>
        <div class="container">
            <!-- Phản hồi -->
            <div class="left-column">
                <div class="contact">
                    <h2>Phản hồi</h2>
                    <%
                        String success = request.getParameter("success");
                        String error = request.getParameter("error");
                    %>
                    <% if ("true".equals(success)) { %>
                        <p style="color: green;">Phản hồi của bạn đã được gửi đến admin!</p>
                    <% } else if ("duplicate".equals(success)) { %>
                        <p style="color: orange;">Phản hồi này đã tồn tại!</p>
                    <% } else if ("true".equals(error)) { %>
                        <p style="color: red;">Có lỗi xảy ra khi gửi phản hồi.</p>
                    <% } %>
                    <form action="${pageContext.request.contextPath}/ContactServlet" method="post">
                        <label for="name">Tên đăng nhập:</label>
                        <input type="text" name="name" required>
                        <label for="email">Email:</label>
                        <input type="text" name="email" required>
                        <label for="message">Phản hồi:</label>
                        <textarea name="message" required></textarea>
                        <div class="button-group">
                            <button type="submit">Gửi</button>
                            <button class="back"><a href="home.jsp">Quay lại</a></button>
                        </div>
                    </form>
                </div>
            </div>
                        
            <!-- Liên hệ -->            
            <div class="right-column">
                <div class="content">
                    <h1>Liên hệ</h1>
                    <p>Nếu bạn có phản hồi, đóng góp ý kiến hay thấy lỗi trong website này, xin hãy liên hệ qua:</p>
                    <h2>Thông tin liên hệ</h2>
                    <div class="social-link">
                        <a href="https://www.facebook.com" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                        <a href="https://www.tiktok.com" aria-label="TikTok"><i class="fab fa-tiktok"></i></a>
                        <a href="https://www.instagram.com" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                        <a href="https://www.twitter.com" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    </div>
                </div>
            </div>
        </div>
        <script>
            window.onload = function () {
                if (window.location.href.includes("success=true")) {
                    document.querySelector("form").reset();
                    setTimeout(() => {
                        window.history.replaceState(null, "", window.location.pathname);
                    }, 2000);
                }
            };
        </script>
    </body>
</html>
