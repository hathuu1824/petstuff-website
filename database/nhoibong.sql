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
  `madon` bigint unsigned NOT NULL AUTO_INCREMENT,
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
  `trangthai` enum('PENDING','PAID','CANCELLED','FAILED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `manh` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stk` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tenctk` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `noidung` varchar(140) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `magiaodich` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thoigianthanhtoan` datetime DEFAULT NULL,
  `thoigianhuy` datetime DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngaycapnhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`madon`),
  KEY `idx_taikhoan` (`taikhoan_id`),
  KEY `idx_masp` (`masp`),
  KEY `idx_trangthai_tien` (`trangthai`,`tiendoisoat`,`ngaytao`),
  CONSTRAINT `fk_donhang_sanpham` FOREIGN KEY (`masp`) REFERENCES `sanpham` (`masp`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_donhang_tt_user` FOREIGN KEY (`taikhoan_id`) REFERENCES `tt_user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table nhoibong.donhang: ~0 rows (approximately)

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.giamgia: ~2 rows (approximately)
INSERT INTO `giamgia` (`id`, `anh_url`, `tieu_de`, `link`, `thu_tu`, `kich_hoat`, `ngay_tao`, `ngay_cap_nhat`) VALUES
	(1, 'slide2.png', 'TƯNG BỪNG MỪNG KHAI TRƯƠNG', 'sanpham?sort=discount', 1, 1, '2025-10-30 08:56:22', '2025-10-30 09:35:24'),
	(2, 'slide1.png', 'SIÊU SALE CUỐI NĂM', 'sanpham?deal=plus400', 2, 1, '2025-10-30 08:56:22', '2025-10-30 09:35:30');

-- Dumping structure for table nhoibong.sanpham
CREATE TABLE IF NOT EXISTS `sanpham` (
  `masp` int NOT NULL AUTO_INCREMENT,
  `tensp` varchar(255) NOT NULL,
  `giatien` decimal(12,2) NOT NULL,
  `mota` text,
  `anhsp` varchar(255) DEFAULT NULL,
  `noibat` tinyint NOT NULL DEFAULT '0',
  `bst` varchar(50) DEFAULT NULL,
  `loai` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`masp`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.sanpham: ~9 rows (approximately)
INSERT INTO `sanpham` (`masp`, `tensp`, `giatien`, `mota`, `anhsp`, `noibat`, `bst`, `loai`) VALUES
	(1, 'Gấu bông có kèm chăn', 90000.00, 'Chăn gối văn phòng 3 trong 1', 'c5c9e4e3dfeece6a7f9aaac418e1086e.jfif', 0, 'khong', 'changoi'),
	(2, 'Thú nhồi bông Sanrio', 105000.00, 'Thú nhồi bông Sanrio (Kuromi, Cinnamoroll, MyMelody,...) lông mịn', '20230116_G5nEiVQo5U5UQaRo.jpg', 1, 'sanrio', 'tnb'),
	(3, 'Móc khóa gấu trúc đỏ dễ thương', 65000.00, 'Móc khóa gấu trúc đỏ nhồi bông kéo được đuôi dễ thương', 'sg-11134201-7ren6-m1qdnfz1sgug03.jfif', 1, 'khong', 'mockhoa'),
	(4, 'Thú nhồi bông Doraemon mặc trang phục Rock cỡ vừa', 110500.00, 'Thú nhồi bông Doraemon mặc trang phục Rock cỡ vừa', 'images.jfif', 0, 'doraemon', 'tnb'),
	(5, 'Gấu bông trắng cỡ lớn kèm gấu cỡ nhỏ', 120000.00, 'Gấu bông trắng đeo nơ cổ cỡ lớn kèm gấu trắng cỡ nhỏ', 'gau-bong-dep-tn.jpg', 1, 'khong', 'tnb'),
	(6, 'Thú nhồi bông Capybara gõ mõ', 85000.00, 'Thú nhồi bông Capybara gõ mõ ngộ nghĩnh - Size 35cm', '4384959201a0a8bfeec9dff8f1e6e8c6.jpeg', 0, 'capybara', 'tnb'),
	(7, 'Dây buộc rèm gắn hình thú', 55000.00, 'Dây buộc rèm gắn hình thú nhồi bông đáng yêu', 'Day-buoc-rem-gan-hinh-thu-nhoi-bong-dang-yeu-FSH7454-14.jpg', 0, 'khong', 'khac'),
	(8, 'Thú nhồi bông Baby Three', 195500.00, 'Thú nhồi bông Baby Three với các loại mắt khác nhau', 'san-pham-1-1-1738991026-3249-1-2791-1254-1739035001.jpg', 0, 'babythree', 'tnb'),
	(9, 'Thú nhồi bông bạch tuộc 2 cảm xúc', 130000.00, 'Thú nhồi bông bạch tuộc 2 cảm xúc lông mịn 3D nhiều kích thước', 'unnamed.jpg', 1, 'khong', 'tnb');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
  `email` varchar(150) DEFAULT NULL,
  `ngaysinh` date DEFAULT NULL,
  `sdt` varchar(20) DEFAULT NULL,
  `diachi` varchar(255) DEFAULT NULL,
  `anh` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_userprofile_account` (`taikhoan_id`),
  CONSTRAINT `fk_userprofile_account` FOREIGN KEY (`taikhoan_id`) REFERENCES `taikhoan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table nhoibong.tt_user: ~5 rows (approximately)
INSERT INTO `tt_user` (`id`, `taikhoan_id`, `hoten`, `email`, `ngaysinh`, `sdt`, `diachi`, `anh`) VALUES
	(1, 1, 'Nguyễn Văn A', 'admin@example.com', '1990-04-15', '0901234567', '68 Nguyễn Chí Thanh, Đống Đa, Hà Nội', 'uploads/avatars/admin.jpg'),
	(2, 2, 'Trần Thị B', 'user@example.com', '1995-08-21', '0912345678', '12 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'uploads/avatars/user.jpg'),
	(3, 3, 'Phạm Hữu C', 'suabien@gmail.com', '1998-11-02', '0933456789', '22 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'uploads/avatars/suabien.jpg'),
	(4, 4, 'Lê Hoàng D', 'acc@gmail.com', '2000-01-10', '0944567890', '45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 'uploads/avatars/acc.jpg'),
	(5, 5, 'Đỗ Minh E', 'acctest@gmail.com', '1999-06-25', '0965678901', '8 Trần Phú, Nha Trang, Khánh Hòa', 'uploads/avatars/acctest.jpg');

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table nhoibong.vouchers: ~6 rows (approximately)
INSERT INTO `vouchers` (`id`, `loai`, `ma`, `tieu_de`, `phan_tram`, `so_tien_giam`, `don_toi_thieu`, `giam_toi_da`, `het_han`, `san_pham_nhat_dinh`, `kich_hoat`, `thu_tu`, `ngay_tao`, `ngay_cap_nhat`) VALUES
	(1, 'NHAP_MA', 'GIAM8', 'Giảm 8%', 8.00, 0, 169000, 20000, '2025-11-02 12:00:02', 0, 1, 1, '2025-10-31 05:00:02', '2025-10-31 06:56:32'),
	(2, 'NHAP_MA', 'GIAM10', 'Giảm 10%', 10.00, 0, 50000, 100000, '2025-11-02 12:00:02', 0, 1, 2, '2025-10-31 05:00:02', '2025-10-31 06:56:29'),
	(3, 'LUU', NULL, 'Giảm 5% đơn bất kỳ', 5.00, 0, 0, 20000, '2025-11-02 12:00:02', 0, 1, 3, '2025-10-31 05:00:02', '2025-10-31 07:51:15'),
	(4, 'LUU', NULL, 'Giảm 10% đơn bất kỳ', 10.00, 0, 0, 55000, '2025-11-02 12:00:02', 0, 1, 4, '2025-10-31 05:00:02', '2025-10-31 07:51:38'),
	(5, 'LUU', NULL, 'Giảm 50% đơn bất kỳ', 50.00, 0, 0, 25000, '2025-11-02 12:00:02', 1, 1, 5, '2025-10-31 05:00:02', '2025-10-31 07:51:24'),
	(6, 'LUU', NULL, 'Giảm 50.000đ cho đơn bất kỳ', 0.00, 50000, 0, 50000, '2025-11-02 12:00:02', 1, 1, 6, '2025-10-31 05:00:02', '2025-10-31 07:50:53');

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
