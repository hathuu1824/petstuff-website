-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               9.2.0 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for nhoibong
CREATE DATABASE IF NOT EXISTS `nhoibong` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `nhoibong`;

-- Dumping structure for table nhoibong.baiviet
CREATE TABLE IF NOT EXISTS `baiviet` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tieu_de` varchar(255) NOT NULL,
  `tom_tat` text,
  `noi_dung` longtext,
  `anh_dai_dien` varchar(255) DEFAULT NULL,
  `noi_bat` tinyint(1) DEFAULT '0',
  `kich_hoat` tinyint(1) DEFAULT '1',
  `hien_slide` tinyint(1) NOT NULL DEFAULT '0',
  `thu_tu` int DEFAULT NULL,
  `ngay_dang` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.baiviet: ~6 rows (approximately)
INSERT INTO `baiviet` (`id`, `tieu_de`, `tom_tat`, `noi_dung`, `anh_dai_dien`, `noi_bat`, `kich_hoat`, `hien_slide`, `thu_tu`, `ngay_dang`) VALUES
	(1, 'Bộ sưu tập Baby Three chính thức ra mắt', 'Dòng sản phẩm “Baby Three” lấy cảm hứng từ nhân vật hoạt hình nổi tiếng, với thiết kế đáng yêu và chất liệu cao cấp.', 'Hôm nay, PetStuff chính thức ra mắt bộ sưu tập “Baby Three”. Sản phẩm được thiết kế bởi đội ngũ sáng tạo trong nước...', 'bb3-400.jpg', 1, 1, 1, 3, '2025-11-07 10:47:58'),
	(2, 'Ưu đãi 20% dành cho khách hàng mới trong tháng 11', 'PetStuff triển khai chương trình ưu đãi đặc biệt: giảm 20% cho tất cả khách hàng mới khi mua lần đầu.', 'Từ ngày 1 đến 30/11, PetStuff gửi tặng mã giảm 20% cho tất cả đơn hàng đầu tiên. Áp dụng trên toàn bộ sản phẩm...', 'giamgia20.jpg', 1, 1, 1, 2, '2025-11-07 10:47:58'),
	(3, 'Workshop làm thú bông miễn phí tại Hà Nội', 'Sự kiện miễn phí giúp bạn tự tay tạo nên thú bông đáng yêu cùng PetStuff, diễn ra vào cuối tuần này.', 'Cuối tuần này, PetStuff phối hợp cùng CLB Handmade Việt tổ chức workshop làm thú nhồi bông miễn phí tại Nguyễn Chí Thanh...', 'workshop.png', 0, 1, 1, 4, '2025-11-07 10:47:58'),
	(4, 'Mẹo giữ thú nhồi bông luôn mềm mại và thơm lâu', 'Chia sẻ 5 mẹo đơn giản để thú nhồi bông của bạn luôn như mới.', 'Thú nhồi bông sau thời gian sử dụng dễ bị bám bụi và mất mùi hương. PetStuff mách bạn 5 mẹo giữ thú bông mềm mại như mới...', 'capyslide.jpg', 0, 1, 0, NULL, '2025-11-07 10:47:58'),
	(5, 'PetStuff đồng hành cùng chiến dịch “Green Gift 2025”', 'Chương trình quyên góp thú bông cũ để tái chế tặng trẻ em vùng cao.', 'PetStuff khởi động chiến dịch “Green Gift 2025” nhằm lan tỏa thông điệp yêu thương và bảo vệ môi trường...', 'volunteer.jpg', 0, 1, 0, NULL, '2025-11-07 10:47:58'),
	(6, 'Tổng hợp các mẫu thú bông bán chạy nhất 2024', 'Cùng xem qua top 5 mẫu thú bông được yêu thích nhất năm 2024 theo thống kê của PetStuff.', 'Trong năm 2024, PetStuff ghi nhận hơn 10.000 sản phẩm bán ra. Dưới đây là top 5 mẫu được yêu thích nhất...', 'fluffy-toy-texture-close-up_23-2149686894.avif', 0, 1, 1, 1, '2025-11-07 10:47:58');

-- Dumping structure for table nhoibong.banners
CREATE TABLE IF NOT EXISTS `banners` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url_anh` varchar(255) NOT NULL,
  `an_hien` tinyint(1) DEFAULT '1',
  `thu_tu` int DEFAULT '0',
  `banner_anh` varchar(25) DEFAULT NULL,
  `hien_slide` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.banners: ~4 rows (approximately)
INSERT INTO `banners` (`id`, `url_anh`, `an_hien`, `thu_tu`, `banner_anh`, `hien_slide`) VALUES
	(1, 'slide4.png', 1, 1, 'bb3.png', 1),
	(2, 'slide3.png', 1, 2, 'capy.png', 1),
	(3, 'slide2.png', 1, 3, 'doremon.png', 1),
	(4, 'slide1.png', 1, 4, 'sanrioo.png', 1);

-- Dumping structure for table nhoibong.donhang
CREATE TABLE IF NOT EXISTS `donhang` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `madon` bigint NOT NULL,
  `taikhoan_id` int DEFAULT NULL,
  `masp` int NOT NULL,
  `tennguoinhan` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sdt` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diachi` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `soluong` int NOT NULL DEFAULT '1',
  `phisp` int NOT NULL DEFAULT '0',
  `phiship` int NOT NULL DEFAULT '0',
  `giamgia` int NOT NULL DEFAULT '0',
  `tongtien` int NOT NULL DEFAULT '0',
  `tiendoisoat` int NOT NULL DEFAULT '0',
  `phuongthuc` enum('COD','BANK') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BANK',
  `trangthai` enum('PENDING','WAIT_PACK','WAIT_SHIP','DELIVERED','RETURNED','CANCELED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `manh` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stk` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tenctk` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `noidung` varchar(140) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `magiaodich` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thoigianthanhtoan` datetime DEFAULT NULL,
  `thoigianhuy` datetime DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngaycapnhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_taikhoan` (`taikhoan_id`),
  KEY `idx_masp` (`masp`),
  KEY `idx_trangthai_tien` (`trangthai`,`tiendoisoat`,`ngaytao`),
  KEY `idx_donhang_madon` (`madon`),
  CONSTRAINT `fk_donhang_sanpham` FOREIGN KEY (`masp`) REFERENCES `sanpham` (`masp`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_donhang_tt_user` FOREIGN KEY (`taikhoan_id`) REFERENCES `tt_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table nhoibong.donhang: ~10 rows (approximately)
INSERT INTO `donhang` (`id`, `madon`, `taikhoan_id`, `masp`, `tennguoinhan`, `sdt`, `diachi`, `soluong`, `phisp`, `phiship`, `giamgia`, `tongtien`, `tiendoisoat`, `phuongthuc`, `trangthai`, `manh`, `stk`, `tenctk`, `noidung`, `magiaodich`, `thoigianthanhtoan`, `thoigianhuy`, `ngaytao`, `ngaycapnhat`) VALUES
	(1, 1, 4, 5, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 2, 76250, 30000, 0, 182500, 182500, 'COD', 'WAIT_SHIP', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 14:56:23', '2025-11-27 16:39:34'),
	(2, 2, 4, 9, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 2, 95000, 30000, 0, 177500, 177500, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 15:06:39', '2025-11-27 15:06:39'),
	(3, 3, 4, 2, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 3, 52500, 30000, 0, 187500, 187500, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 20:24:52', '2025-11-27 20:24:52'),
	(4, 4, 4, 9, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 1, 95000, 30000, 0, 125000, 125000, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 20:28:30', '2025-11-27 20:28:30'),
	(5, 5, 4, 2, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 2, 52500, 30000, 0, 82500, 82500, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 20:52:51', '2025-11-27 20:52:51'),
	(6, 6, 4, 5, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 3, 100000, 30000, 0, 130000, 130000, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 21:01:35', '2025-11-27 21:01:35'),
	(7, 7, 4, 9, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 2, 95000, 30000, 0, 125000, 125000, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 21:02:19', '2025-11-27 21:02:19'),
	(8, 8, 4, 5, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 2, 100000, 30000, 0, 82500, 82500, 'COD', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-27 21:29:42', '2025-11-27 21:29:42'),
	(9, 9, 4, 2, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 1, 52500, 30000, 0, 82500, 82500, 'BANK', 'WAIT_PACK', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-28 01:34:28', '2025-11-28 01:34:49'),
	(10, 10, 4, 9, 'Lê Hoàng D', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 1, 95000, 30000, 0, 125000, 125000, 'BANK', 'PENDING', 'VCB', '0123456789', 'CONG TY PETSTUFF', NULL, NULL, NULL, NULL, '2025-11-28 12:47:52', '2025-11-28 12:47:52');

-- Dumping structure for table nhoibong.donhang_ct
CREATE TABLE IF NOT EXISTS `donhang_ct` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `donhang_id` int unsigned NOT NULL,
  `masp` int NOT NULL,
  `soluong` int NOT NULL DEFAULT '1',
  `gia` int NOT NULL,
  `thanhtien` int NOT NULL,
  `loai` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tensp` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_donhang_ct_sanpham` (`masp`),
  KEY `fk_donhang_ct_donhang` (`donhang_id`),
  CONSTRAINT `fk_donhang_ct_donhang` FOREIGN KEY (`donhang_id`) REFERENCES `donhang` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_donhang_ct_sanpham` FOREIGN KEY (`masp`) REFERENCES `sanpham` (`masp`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table nhoibong.donhang_ct: ~17 rows (approximately)
INSERT INTO `donhang_ct` (`id`, `donhang_id`, `masp`, `soluong`, `gia`, `thanhtien`, `loai`, `tensp`) VALUES
	(2, 1, 5, 2, 76250, 152500, 'Kèm gấu nhỏ', 'Gấu bông trắng cỡ lớn kèm gấu cỡ nhỏ'),
	(3, 2, 9, 1, 95000, 95000, 'Xanh dương - Hồng', 'Thú nhồi bông bạch tuộc hai cảm xúc'),
	(4, 2, 2, 1, 52500, 52500, 'Cinamonroll', 'Thú nhồi bông Sanrio'),
	(5, 3, 2, 1, 52500, 52500, 'Kuromi', 'Thú nhồi bông Sanrio'),
	(6, 3, 2, 2, 52500, 105000, 'My Melody', 'Thú nhồi bông Sanrio'),
	(7, 4, 9, 1, 95000, 95000, 'Xanh dương - Hồng', 'Thú nhồi bông bạch tuộc hai cảm xúc'),
	(8, 5, 2, 1, 52500, 52500, 'Kuromi', 'Thú nhồi bông Sanrio'),
	(9, 5, 2, 1, 52500, 52500, 'Pochaco', 'Thú nhồi bông Sanrio'),
	(10, 6, 5, 1, 100000, 100000, 'Lẻ gấu lớn', 'Gấu bông trắng cỡ lớn kèm gấu cỡ nhỏ'),
	(11, 6, 2, 1, 52500, 52500, 'Pochaco', 'Thú nhồi bông Sanrio'),
	(12, 6, 9, 1, 95000, 95000, 'Xanh dương - Hồng', 'Thú nhồi bông bạch tuộc hai cảm xúc'),
	(13, 7, 9, 1, 95000, 95000, 'Xanh dương - Hồng', 'Thú nhồi bông bạch tuộc hai cảm xúc'),
	(14, 7, 5, 1, 100000, 100000, 'Kèm gấu nhỏ', 'Gấu bông trắng cỡ lớn kèm gấu cỡ nhỏ'),
	(15, 8, 5, 1, 100000, 100000, 'Kèm gấu nhỏ', 'Gấu bông trắng cỡ lớn kèm gấu cỡ nhỏ'),
	(16, 8, 2, 1, 52500, 52500, 'Pochaco', 'Thú nhồi bông Sanrio'),
	(17, 9, 2, 1, 52500, 52500, 'Pochaco', 'Thú nhồi bông Sanrio'),
	(18, 10, 9, 1, 95000, 95000, 'Xanh dương - Hồng', 'Thú nhồi bông bạch tuộc hai cảm xúc');

-- Dumping structure for table nhoibong.giamgia
CREATE TABLE IF NOT EXISTS `giamgia` (
  `id` int NOT NULL AUTO_INCREMENT,
  `anh_url` varchar(255) NOT NULL,
  `tieu_de` varchar(255) DEFAULT '',
  `link` varchar(255) DEFAULT NULL,
  `thu_tu` int DEFAULT '0',
  `kich_hoat` tinyint(1) DEFAULT '1',
  `ngay_tao` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.giamgia: ~6 rows (approximately)
INSERT INTO `giamgia` (`id`, `anh_url`, `tieu_de`, `link`, `thu_tu`, `kich_hoat`, `ngay_tao`, `ngay_cap_nhat`) VALUES
	(1, 'slide2.png', 'TƯNG BỪNG MỪNG KHAI TRƯƠNG', '', 1, 1, '2025-10-30 08:56:22', '2025-11-28 07:55:51'),
	(2, 'slide1.png', 'SIÊU SALE CUỐI NĂM', '', 2, 1, '2025-10-30 08:56:22', '2025-11-28 07:55:53'),
	(3, 'slide4.png', 'CHƯƠNG TRÌNH MỚI CẬP NHẬT', NULL, 3, 1, '2025-11-11 10:18:00', '2025-11-25 10:17:32'),
	(4, 'giamgia20.jpg', 'ƯU ĐÃI KHÁCH HÀNG MỚI', NULL, 4, 1, '2025-11-24 08:37:23', '2025-11-25 10:16:24'),
	(5, 'gift.png', 'ƯU ĐÃI KHÁCH HÀNG THÂN THIẾT', NULL, 5, 1, '2025-11-24 08:40:38', '2025-11-25 10:17:50'),
	(6, 'workshop.png', 'SIÊU SALE SINH NHẬT', NULL, 6, 1, '2025-11-24 08:41:01', '2025-11-24 08:41:01');

-- Dumping structure for table nhoibong.giohang
CREATE TABLE IF NOT EXISTS `giohang` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `sanpham_id` int NOT NULL,
  `loai_id` int NOT NULL,
  `gia` decimal(10,1) NOT NULL,
  `soluong` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_giohang_user` (`user_id`),
  KEY `fk_giohang_sanpham` (`sanpham_id`),
  KEY `fk_giohang_loai` (`loai_id`),
  CONSTRAINT `fk_giohang_loai` FOREIGN KEY (`loai_id`) REFERENCES `sanpham_loai` (`id`),
  CONSTRAINT `fk_giohang_sanpham` FOREIGN KEY (`sanpham_id`) REFERENCES `sanpham` (`masp`),
  CONSTRAINT `fk_giohang_user` FOREIGN KEY (`user_id`) REFERENCES `taikhoan` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.giohang: ~0 rows (approximately)

-- Dumping structure for table nhoibong.sanpham
CREATE TABLE IF NOT EXISTS `sanpham` (
  `masp` int NOT NULL AUTO_INCREMENT,
  `tensp` varchar(255) NOT NULL,
  `giatien` decimal(12,2) NOT NULL,
  `giakm` decimal(12,2) DEFAULT NULL,
  `giam_pt` tinyint unsigned DEFAULT NULL,
  `giam_tien` decimal(12,2) DEFAULT NULL,
  `km_tu` datetime DEFAULT NULL,
  `km_den` datetime DEFAULT NULL,
  `bogo` tinyint(1) NOT NULL DEFAULT '0',
  `qua_moi_don` tinyint(1) NOT NULL DEFAULT '0',
  `uu_tien` int DEFAULT NULL,
  `kich_hoat` tinyint(1) NOT NULL DEFAULT '1',
  `mota` text,
  `anhsp` varchar(255) DEFAULT NULL,
  `noibat` tinyint NOT NULL DEFAULT '0',
  `bst` varchar(50) DEFAULT NULL,
  `loai` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`masp`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.sanpham: ~10 rows (approximately)
INSERT INTO `sanpham` (`masp`, `tensp`, `giatien`, `giakm`, `giam_pt`, `giam_tien`, `km_tu`, `km_den`, `bogo`, `qua_moi_don`, `uu_tien`, `kich_hoat`, `mota`, `anhsp`, `noibat`, `bst`, `loai`) VALUES
	(1, 'Gấu bông có kèm chăn', 90000.00, NULL, NULL, 25000.00, NULL, NULL, 0, 0, NULL, 1, 'Chăn gối văn phòng 3 trong 1', 'c5c9e4e3dfeece6a7f9aaac418e1086e.jfif', 0, 'khong', 'changoi'),
	(2, 'Thú nhồi bông Sanrio', 105000.00, NULL, 50, NULL, NULL, NULL, 0, 0, 1, 1, 'Thú nhồi bông Sanrio (Kuromi, Cinnamoroll, MyMelody,...) lông mịn', '20230116_G5nEiVQo5U5UQaRo.jpg', 1, 'sanrio', 'tnb'),
	(3, 'Móc khóa gấu trúc đỏ dễ thương', 65000.00, NULL, NULL, 15000.00, NULL, NULL, 0, 0, 2, 1, 'Móc khóa gấu trúc đỏ nhồi bông kéo được đuôi dễ thương', 'sg-11134201-7ren6-m1qdnfz1sgug03.jfif', 1, 'khong', 'mockhoa'),
	(4, 'Thú nhồi bông Doraemon mặc trang phục Rock ', 110500.00, NULL, 50, NULL, NULL, NULL, 0, 0, 3, 1, 'Thú nhồi bông Doraemon mặc trang phục Rock cỡ vừa', 'images.jfif', 0, 'doraemon', 'tnb'),
	(5, 'Gấu bông trắng cỡ lớn kèm gấu cỡ nhỏ', 120000.00, 100000.00, NULL, NULL, NULL, NULL, 0, 0, 4, 1, 'Gấu bông trắng đeo nơ cổ cỡ lớn kèm gấu trắng cỡ nhỏ', 'gau-bong-dep-tn.jpg', 1, 'khong', 'tnb'),
	(6, 'Thú nhồi bông Capybara gõ mõ', 85000.00, NULL, 50, NULL, NULL, NULL, 0, 0, 5, 1, 'Thú nhồi bông Capybara gõ mõ ngộ nghĩnh - Size 35cm', '4384959201a0a8bfeec9dff8f1e6e8c6.jpeg', 0, 'capybara', 'tnb'),
	(7, 'Dây buộc rèm gắn hình thú', 55000.00, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, 1, 'Dây buộc rèm gắn hình thú nhồi bông đáng yêu', 'Day-buoc-rem-gan-hinh-thu-nhoi-bong-dang-yeu-FSH7454-14.jpg', 0, 'khong', 'khac'),
	(8, 'Thú nhồi bông Baby Three', 195500.00, NULL, 50, NULL, NULL, NULL, 0, 0, 6, 1, 'Thú nhồi bông Baby Three với các loại mắt khác nhau', 'san-pham-1-1-1738991026-3249-1-2791-1254-1739035001.jpg', 0, 'babythree', 'tnb'),
	(9, 'Thú nhồi bông bạch tuộc hai cảm xúc', 130000.00, 95000.00, NULL, NULL, NULL, NULL, 0, 0, 7, 1, 'Thú nhồi bông bạch tuộc 2 cảm xúc lông mịn 3D nhiều kích thước', 'unnamed.jpg', 1, 'khong', 'tnb'),
	(10, 'Móc khóa mèo máy Doraemon kèm nhiều charm khác nhau', 60000.00, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, 1, 'Móc khóa mèo máy Doraemon với đa dạng mẫu mã khác nhau', 'dr2.jpg', 0, 'doraemon', 'mockhoa');

-- Dumping structure for table nhoibong.sanpham_loai
CREATE TABLE IF NOT EXISTS `sanpham_loai` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sanpham_id` int NOT NULL,
  `ten_loai` varchar(100) NOT NULL,
  `gia` decimal(12,2) DEFAULT NULL,
  `soluong` int DEFAULT NULL,
  `anh` varchar(255) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_loai_sanpham` (`sanpham_id`),
  CONSTRAINT `fk_loai_sanpham` FOREIGN KEY (`sanpham_id`) REFERENCES `sanpham` (`masp`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.sanpham_loai: ~29 rows (approximately)
INSERT INTO `sanpham_loai` (`id`, `sanpham_id`, `ten_loai`, `gia`, `soluong`, `anh`, `is_default`) VALUES
	(1, 2, 'Cinamonroll', 105000.00, 100, NULL, 1),
	(2, 2, 'Kuromi', 105000.00, 100, NULL, 1),
	(3, 2, 'My Melody', 105000.00, 100, NULL, 1),
	(4, 2, 'Pochaco', 105000.00, 100, NULL, 1),
	(5, 5, 'Kèm gấu nhỏ', 120000.00, 100, NULL, 1),
	(6, 5, 'Lẻ gấu lớn', 120000.00, 100, NULL, 1),
	(7, 9, 'Xanh dương - Hồng', 130000.00, 100, NULL, 0),
	(9, 1, 'Thỏ - Cà rốt', 90000.00, 100, NULL, 0),
	(10, 1, 'Mèo - Cá', 90000.00, 100, NULL, 0),
	(11, 1, 'Chó - Thịt đùi', 90000.00, 100, NULL, 0),
	(12, 3, 'Gấu trúc đỏ', 65000.00, 100, NULL, 0),
	(13, 3, 'Gấu trúc', 65000.00, 100, NULL, 0),
	(14, 4, 'Nhỏ', 110500.00, 100, NULL, 0),
	(15, 4, 'Vừa', 110500.00, 100, NULL, 0),
	(16, 4, 'Lớn', 110500.00, 100, NULL, 0),
	(17, 6, 'Nhỏ', 85000.00, 100, NULL, 0),
	(18, 6, 'Vừa', 85000.00, 100, NULL, 0),
	(19, 6, 'Lớn', 85000.00, 100, NULL, 0),
	(20, 7, 'Bambi', 55000.00, 100, NULL, 0),
	(21, 7, 'Totoro', 55000.00, 100, NULL, 0),
	(22, 7, 'Pikachu', 55000.00, 100, NULL, 0),
	(23, 7, 'Cloud', 55000.00, 100, NULL, 0),
	(24, 8, 'Mắt lè khe', 195000.00, 100, NULL, 0),
	(25, 8, 'Mắt lấp lánh', 195000.00, 100, NULL, 0),
	(26, 9, 'Xanh lá - Vàng', 130000.00, 100, NULL, 0),
	(27, 9, 'Đỏ - Cam', 130000.00, 100, NULL, 0),
	(28, 10, 'Bồn tắm', 60000.00, 100, NULL, 0),
	(29, 10, 'Bình nước', 60000.00, 100, NULL, 0),
	(30, 10, 'Ngôi sao', 60000.00, 100, NULL, 0);

-- Dumping structure for table nhoibong.taikhoan
CREATE TABLE IF NOT EXISTS `taikhoan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tendangnhap` varchar(50) NOT NULL,
  `matkhau` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `vaitro` enum('user','admin') NOT NULL DEFAULT 'user',
  PRIMARY KEY (`id`),
  UNIQUE KEY `tendangnhap` (`tendangnhap`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.taikhoan: ~5 rows (approximately)
INSERT INTO `taikhoan` (`id`, `tendangnhap`, `matkhau`, `email`, `vaitro`) VALUES
	(1, 'admin', '123456', 'admin@example.com', 'admin'),
	(2, 'user', 'user123', 'user@example.com', 'user'),
	(3, 'suabien', 'suabien', 'suabien@gmail.com', 'user'),
	(4, 'acc', '1234567', 'acc@gmail.com', 'user'),
	(5, 'acctest', '12345678', 'acctest@gmail.com', 'user');

-- Dumping structure for table nhoibong.tt_user
CREATE TABLE IF NOT EXISTS `tt_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taikhoan_id` int DEFAULT NULL,
  `hoten` varchar(120) DEFAULT NULL,
  `ngaysinh` date DEFAULT NULL,
  `sdt` varchar(20) DEFAULT NULL,
  `diachi` varchar(255) DEFAULT NULL,
  `anh` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_userprofile_account` (`taikhoan_id`),
  CONSTRAINT `fk_userprofile_account` FOREIGN KEY (`taikhoan_id`) REFERENCES `taikhoan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.tt_user: ~5 rows (approximately)
INSERT INTO `tt_user` (`id`, `taikhoan_id`, `hoten`, `ngaysinh`, `sdt`, `diachi`, `anh`) VALUES
	(1, 1, 'Nguyễn Văn A', '1990-04-15', '0901234567', '68 Nguyễn Chí Thanh, Đống Đa, Hà Nội', 'logo - Copy.png'),
	(2, 2, 'Trần Thị B', '1995-08-21', '0912345678', '12 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'pink-flowers-blue-sky-pastel-desktop-wallpaper-preview.jpg'),
	(3, 3, 'Phạm Hữu C', '1998-11-02', '0933456789', '22 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'unnamed.jpg'),
	(4, 4, 'Lê Hoàng D', '2000-01-10', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 'uploads/avatars/1764007316681_capyslide.jpg'),
	(5, 5, 'Đỗ Minh E', '1999-06-25', '0965678901', '8 Trần Phú, Nha Trang, Khánh Hòa', '20230116_G5nEiVQo5U5UQaRo.jpg');

-- Dumping structure for table nhoibong.vouchers
CREATE TABLE IF NOT EXISTS `vouchers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `loai` enum('NHAP_MA','LUU') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NHAP_MA',
  `ma` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tieu_de` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phan_tram` decimal(5,2) NOT NULL DEFAULT '0.00',
  `so_tien_giam` decimal(15,0) NOT NULL DEFAULT '0',
  `don_toi_thieu` decimal(15,0) NOT NULL DEFAULT '0',
  `giam_toi_da` decimal(15,0) NOT NULL DEFAULT '0',
  `het_han` datetime DEFAULT NULL,
  `san_pham_nhat_dinh` tinyint(1) NOT NULL DEFAULT '0',
  `kich_hoat` tinyint(1) NOT NULL DEFAULT '1',
  `thu_tu` int NOT NULL DEFAULT '0',
  `ngay_tao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_cap_nhat` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ma` (`ma`),
  KEY `idx_v_active` (`kich_hoat`,`het_han`),
  KEY `idx_v_order` (`thu_tu`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table nhoibong.vouchers: ~6 rows (approximately)
INSERT INTO `vouchers` (`id`, `loai`, `ma`, `tieu_de`, `phan_tram`, `so_tien_giam`, `don_toi_thieu`, `giam_toi_da`, `het_han`, `san_pham_nhat_dinh`, `kich_hoat`, `thu_tu`, `ngay_tao`, `ngay_cap_nhat`) VALUES
	(1, 'NHAP_MA', 'GIAM8', 'Giảm 8%', 8.00, 0, 169000, 20000, '2025-12-12 12:00:00', 0, 1, 1, '2025-10-31 05:00:02', '2025-11-24 08:14:49'),
	(2, 'NHAP_MA', 'GIAM10', 'Giảm 10%', 10.00, 0, 50000, 100000, '2025-11-20 12:00:02', 0, 1, 2, '2025-10-31 05:00:02', '2025-11-06 08:24:03'),
	(3, 'LUU', NULL, 'Giảm 5% đơn bất kỳ', 5.00, 0, 0, 20000, '2025-11-20 12:00:02', 0, 1, 3, '2025-10-31 05:00:02', '2025-11-06 08:24:00'),
	(4, 'LUU', NULL, 'Giảm 10% đơn bất kỳ', 10.00, 0, 0, 55000, '2025-11-20 12:00:02', 0, 1, 4, '2025-10-31 05:00:02', '2025-11-06 08:23:57'),
	(5, 'LUU', NULL, 'Giảm 50% đơn bất kỳ', 50.00, 0, 0, 25000, '2025-11-20 12:00:02', 1, 1, 5, '2025-10-31 05:00:02', '2025-11-06 08:23:53'),
	(6, 'LUU', NULL, 'Giảm 50.000đ cho đơn bất kỳ', 0.00, 50000, 0, 50000, '2025-11-20 12:00:02', 1, 1, 6, '2025-10-31 05:00:02', '2025-11-06 08:23:48');

-- Dumping structure for trigger nhoibong.trg_taikhoan_email_to_ttuser
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_taikhoan_email_to_ttuser` AFTER UPDATE ON `taikhoan` FOR EACH ROW BEGIN
  IF NEW.email IS NOT NULL AND NEW.email <> OLD.email THEN
    UPDATE tt_user
       SET email = NEW.email
     WHERE taikhoan_id = NEW.id;
  END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger nhoibong.trg_ttnd_before_insert_email
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_ttnd_before_insert_email` BEFORE INSERT ON `tt_user` FOR EACH ROW BEGIN
  DECLARE v_email VARCHAR(150);
  SELECT email INTO v_email
  FROM taikhoan
  WHERE id = NEW.taikhoan_id
  LIMIT 1;

  IF v_email IS NOT NULL AND v_email <> '' THEN
    SET NEW.email = v_email;
  END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger nhoibong.trg_update_email_taikhoan_to_ttnd
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_update_email_taikhoan_to_ttnd` AFTER UPDATE ON `taikhoan` FOR EACH ROW BEGIN
  IF NEW.email IS NOT NULL AND NEW.email <> OLD.email THEN
    UPDATE tt_user
       SET email = NEW.email
     WHERE taikhoan_id = NEW.id;
  END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
