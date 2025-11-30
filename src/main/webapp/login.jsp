<%-- 
    Document   : dangnhap
    Created on : 13 Sept 2025, 12:30:45 pm
    Author     : hathuu24
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="<%= ctx %>/css/login.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css">
        <title>Đăng nhập</title>
    </head>
    <body>
        <div class="main">
            <section class="signin">
                <%
                    String loginError  = (String) request.getAttribute("loginError");
                    String enteredUser = (String) request.getAttribute("enteredUser");
                %>
                <div class="container">
                    <div class="signin-content">
                        <div class="signin-image">
                            <figure>
                                <img src="<%= ctx %>/images/logo.png" alt="ảnh">
                            </figure>
                            <a href="<%= ctx %>/register.jsp" class="signup-image-link">Chưa có tài khoản?</a>
                        </div>

                        <div class="signin-form">
                            <h2 class="form-title">Đăng nhập</h2>
                            <form method="post" action="<%= ctx %>/dangnhap" class="register-form" id="login-form" autocomplete="on">
                                <div class="form-group">
                                    <label for="username"><i class="fa-solid fa-user fa-fw"></i></label>
                                    <input type="text" name="username" id="username" placeholder="Tên đăng nhập" autocomplete="username" required autofocus value="<%= (enteredUser != null ? enteredUser : "") %>"/>
                                </div>
                                <div class="form-group">
                                    <label for="password"><i class="fa-solid fa-lock fa-fw"></i></label>
                                    <input type="password" name="password" id="password" placeholder="Mật khẩu" autocomplete="current-password" required/>
                                </div>
                                <div class="form-group">
                                    <input type="checkbox" name="remember-me" id="remember-me" class="agree-term"/>
                                    <label for="remember-me" class="label-agree-term">
                                        <span class="box" aria-hidden="true"></span>
                                        Lưu đăng nhập
                                    </label>
                                </div>
                                <div class="form-group form-button">
                                    <input type="submit" name="signin" id="signin" class="form-submit" value="Đăng nhập" />
                                </div>
                                <% if (loginError != null && !loginError.isEmpty()) { %>
                                    <div class="form-error" style="color:#d93025; margin-top:8px;">
                                        <%= loginError %>
                                    </div>
                                <% } %>
                            </form>
                            <div class="social-login">
                                <span class="social-label">Đăng nhập tài khoản mạng xã hội</span>
                                <ul class="socials">
                                    <li><a href="https://www.facebook.com" class="btn-social btn-fb" aria-label="Facebook" title="Facebook"><i class="fa-brands fa-facebook-f"></i></a></li>
                                    <li><a href="https://www.twitter.com" class="btn-social btn-tw" aria-label="Twitter/X" title="Twitter"><i class="fa-brands fa-x-twitter"></i></a></li>
                                    <li><a href="https://myaccount.google.com" class="btn-social btn-go" aria-label="Google" title="Google"><i class="fa-brands fa-google"></i></a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <% if (loginError != null && !loginError.isEmpty()) { %>
                    <script>
                      alert("<%= loginError.replace("\"","\\\"").replace("\n"," ") %>");
                    </script>
                <% } %>
            </section>
        </div>
        <script src="vendor/jquery/jquery.min.js"></script>
        <script src="<%= ctx %>/javascript/login.js"></script>
    </body>
</html>

