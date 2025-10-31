# petstuff-website

## Giới thiệu:
- Website bán đồ nhồi bông (PetStuff)
- Trang chủ hiển thị sản phẩm nổi bật và banner quảng cáo động
- Hỗ trợ đăng ký, đăng nhập, đăng xuất tài khoản người dùng
- Hiển thị danh sách sản phẩm với chức năng lọc, sắp xếp và phân trang
- Cho phép xem chi tiết sản phẩm với hình ảnh, mô tả, giá và tùy chọn khác nhau
- Cập nhật tự động giá tiền và tổng tiền khi thay đổi số lượng hoặc option
- Hỗ trợ mua hàng qua VietQR hoặc thanh toán khi nhận hàng (hiển thị thông tin chuyển khoản)
- Quản lý khuyến mãi và voucher, hiển thị phần trăm giảm, đơn tối thiểu, ngày hết hạn
- Hiển thị thanh trượt các chương trình giảm giá đang diễn ra
- Hiển thị danh sách bộ sưu tập cùng hình ảnh và mô tả sản phẩm liên quan
- Cho phép xem chi tiết từng bộ sưu tập theo chủ đề
- Cung cấp giao diện liên hệ với thông tin cửa hàng và khung gửi phản hồi
- Kết nối cơ sở dữ liệu MySQL
- Chạy trên Apache Tomcat 10

---

## Công nghệ sử dụng:

### Backend:
- Java (JSP + Servlet)
- JDBC
- Maven
- Apache Tomcat 10

### Frontend:
- JSP + HTML + CSS
- Ảnh + File tĩnh đặt trong `webapp/`

### Database:
- MySQL / MariaDB

---

## Chạy dự án trên: http://localhost:8080/

## Run pjr:

### 1. Chuẩn bị môi trường:
- Cài **JDK 21**
- Cài **Apache Tomcat 10**
- Cài **MySQL**
- Cài **Apache NetBeans** 

---

### 2. Clone dự án:
```bash
git clone https://github.com/hathuu1824/petstuff-website.git
cd petstuff-website

