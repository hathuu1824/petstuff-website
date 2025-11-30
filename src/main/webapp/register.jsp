<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="stylesheet" href="<%= ctx %>/css/register.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <title>Đăng ký</title>
    </head>

    <body>
        <div class="main">
            <section class="signup">
                <div class="container">
                    <div class="signup-content">

                        <!-- FORM -->
                        <div class="signup-form">

                            <%
                                String regError     = (String) request.getAttribute("regError");
                                String enteredUser  = (String) request.getAttribute("enteredUser");
                                String enteredEmail = (String) request.getAttribute("enteredEmail");
                            %>

                            <h2 class="form-title">Đăng ký</h2>

                            <form method="post"
                                  action="<%= ctx %>/dangky"
                                  class="register-form"
                                  id="register-form"
                                  autocomplete="on">

                                <div class="form-group">
                                    <label for="username"><i class="fa-solid fa-user fa-fw"></i></label>
                                    <input type="text"
                                           name="username"
                                           id="username"
                                           placeholder="Tên đăng nhập"
                                           required
                                           autocomplete="username"
                                           value="<%= enteredUser != null ? enteredUser : "" %>"/>
                                </div>

                                <div class="form-group">
                                    <label for="email"><i class="fa-solid fa-envelope fa-fw"></i></label>
                                    <input type="email"
                                           name="email"
                                           id="email"
                                           placeholder="Email"
                                           required
                                           autocomplete="email"
                                           value="<%= enteredEmail != null ? enteredEmail : "" %>"/>
                                </div>

                                <div class="form-group">
                                    <label for="password"><i class="fa-solid fa-lock fa-fw"></i></label>
                                    <input type="password"
                                           name="password"
                                           id="password"
                                           placeholder="Mật khẩu"
                                           required
                                           minlength="6"
                                           autocomplete="new-password"/>
                                </div>

                                <div class="form-group">
                                    <label for="confirm"><i class="fa-solid fa-key fa-fw"></i></label>
                                    <input type="password"
                                           name="confirm"
                                           id="confirm"
                                           placeholder="Nhập lại mật khẩu"
                                           required
                                           minlength="6"
                                           autocomplete="new-password"/>
                                </div>

                                <div class="form-group">
                                    <input type="checkbox" id="agree-term" name="agree" class="agree-term">
                                    <label for="agree-term" class="label-agree-term">
                                        <span class="box"></span>
                                        Tôi đồng ý với điều khoản & dịch vụ
                                    </label>
                                </div>

                                <div class="form-group form-button">
                                    <input type="submit"
                                           name="signup"
                                           id="signup"
                                           class="form-submit"
                                           value="Đăng ký"/>
                                </div>

                            </form>

                            <% if (regError != null && !regError.isEmpty()) { %>
                                <script>
                                    alert("<%= regError.replace("\"", "\\\"") %>");
                                </script>
                            <% } %>

                        </div>

                        <!-- IMAGE -->
                        <div class="signup-image">
                            <figure>
                                <img src="<%= ctx %>/images/logo.png" alt="ảnh">
                            </figure>
                            <a href="<%= ctx %>/login.jsp" class="signup-image-link">Đã có tài khoản</a>
                        </div>

                    </div>
                </div>
            </section>
        </div>

        <!-- Nếu không dùng jQuery thì comment hoặc xoá -->
        <!-- <script src="<%= ctx %>/vendor/jquery/jquery.min.js"></script> -->

    </body>
</html>
