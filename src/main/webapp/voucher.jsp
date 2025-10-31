<%-- 
    Document   : voucher
    Created on : 31 Oct 2025, 10:26:10 am
    Author     : hathuu24
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <main class="main">
            <!-- Voucher -->
            <section class="voucher-wrap">
                <h1 class="heading">VOUCHER</h1>
                <div class="voucher-scroller" id="voucherScroller">
                    <article class="coupon">
                        <div class="coupon-left">
                            <h3 class="coupon-title"></h3>
                            <p class="coupon-sub"></p>
                            <p class="coupon-exp"></p>
                        </div>
                        <div class="coupon-sep"></div>
                        <div class="coupon-right">
                            <button class="btn-save">Lưu</button>
                            <!-- Nếu có tag “Sản phẩm nhất định” -->
                            <!-- <span class="badge-outline">Sản phẩm nhất định</span> -->
                        </div>
                        <span class="coupon-edge left"></span>
                        <span class="coupon-edge right"></span>
                    </article>
                </div>
                <button class="v-nav v-prev" type="button" aria-label="Prev">‹</button>
                <button class="v-nav v-next" type="button" aria-label="Next">›</button>
            </section>
        </main>
    </body>
</html>
