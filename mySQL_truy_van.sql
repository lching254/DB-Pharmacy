-- 1) Liệt kê tất cả các MaThuoc, TenThuoc được cung cấp bởi nhà cung cấp “ Nhà Phân phối thuốc Minh Châu“.
SELECT MaThuoc, TenThuoc
FROM thuoc
WHERE MaNCC = (SELECT MaNCC FROM nhacungcap WHERE TenNCC = 'Nhà Phân phối thuốc Minh Châu');

-- 2 ) Tìm ra thuốc (MaThuoc, TenThuoc) đã hết hạn tính đến ngày 26/7/2023 mà vẫn đang còn trong kho.
SELECT MaThuoc, TenThuoc
FROM thuoc
WHERE NgayHetHan < '2023-07-26' AND SoLuongThuocCon > 0;

-- 3 ) Liệt kê tất cả các loại thuốc có giá lớn hơn 25 và số lượng còn lớn hơn 50.
SELECT MaThuoc, TenThuoc
FROM thuoc
WHERE Gia > 25 AND SoLuongThuocCon > 50;

-- 4 )	Tìm ra MaNCC, TenNCC cung cấp thuốc trong danh mục “Thuốc trị ho”.
SELECT MaNCC, TenNCC
FROM nhacungcap
WHERE MaNCC IN (SELECT MaNCC 
               FROM thuoc 
               INNER JOIN danhmuc ON thuoc.MaDanhMuc = danhmuc.MaDanhMuc
               WHERE TenDanhMuc = 'Thuốc trị ho');

-- 5 ) Liệt kê các nhân viên (MaNV, TenNV) đã bán thuốc cho khách hàng có MaKH = “KH017” trong tháng 5/2023.

SELECT nhanvien.MaNV, nhanvien.TenNV
FROM nhanvien  
INNER JOIN hoadon ON hoadon.MaNV = nhanvien.MaNV
WHERE MaKH = 'KH017' AND MONTH(NgayBan) = 5 AND YEAR(NgayBan) = 2022; 
               


-- 6) Liệt kê tất cả các KH (MaKH, TenKH) mua thuốc trong tháng 6/2023 được bán bởi nhân viên có mã NV là “NV001”.
SELECT MaKH, TenKH
FROM khachhang
WHERE MaKH IN (SELECT MaKH FROM hoadon WHERE MONTH(NgayBan) = 6 AND YEAR(NgayBan) = 2023 AND MaNV = 'NV001');

-- 7) Lấy ra tất cả các thuốc (MaThuoc, TenThuoc) trong mã hóa đơn "HD035" và thuộc danh mục "Thuốc hạ sốt".
SELECT thuoc.MaThuoc, thuoc.TenThuoc
FROM thuoc
INNER JOIN danhmuc ON danhmuc.MaDanhMuc = thuoc.MaDanhMuc
WHERE TenDanhMuc = 'Thuốc hạ sốt' AND MaThuoc IN (SELECT MaThuoc 
                                                 FROM chi_tiet_hoadon
                                                 WHERE MaHD = 'HD035');

-- 8) Liệt kê tất cả các khách hàng (MaKH, TenKH) mua thuốc trong tháng 5/2023.
-- Cách 1: 
SELECT MaKH,TenKH
FROM khachhang
WHERE MaKH IN (SELECT MaKH
               FROM hoadon
               WHERE  MONTH(NgayBan) = 5 AND YEAR(NgayBan) = 2023);
-- Cách 2:                
SELECT KH.MaKH,KH.TenKH
FROM khachhang KH
INNER JOIN hoadon ON hoadon.MaKH = KH.MaKH
WHERE MONTH(NgayBan) = 5 AND YEAR(NgayBan) = 2023;



-- 9) Liệt kê tổng số thuốc trong mỗi danh mục thuốc. 
SELECT DM.MaDanhMuc, DM.TenDanhMuc, COUNT(T.MaThuoc) AS TongSoThuoc
FROM danhmuc DM
INNER JOIN thuoc T ON T.MaDanhMuc = DM.MaDanhMuc
GROUP BY DM.MaDanhMuc, DM.TenDanhMuc;


-- 10) Cho biết khách hàng (MaKH, TenKH) đã mua cả hai loại thuốc “Paracetamol” và "Philatop” trên cùng một hoá đơn.
SELECT KH.MaKH, KH.TenKH
FROM khachhang KH             
INNER JOIN hoadon ON hoadon.MaKH = KH.MaKH
WHERE hoadon.MaHD IN (SELECT MaHD 
                     FROM chi_tiet_hoadon 
                     INNER JOIN thuoc ON chi_tiet_hoadon.MaThuoc = thuoc.MaThuoc
                     WHERE TenThuoc = 'Paracetamol')
	 AND 
     hoadon.MaHD IN (SELECT MaHD 
					 FROM chi_tiet_hoadon 
					 INNER JOIN thuoc ON chi_tiet_hoadon.MaThuoc = thuoc.MaThuoc
					 WHERE TenThuoc = 'Philatop');
                     

-- 11) Lấy ra Khách hàng (MaKH, TenKH) có TongGia trong một hóa đơn nhiều nhất.
SELECT KH.MaKH, KH.TenKH
FROM khachhang KH
INNER JOIN hoadon ON hoadon.MaKH = KH.MaKH
WHERE MaHD = ( SELECT MaHD 
			   FROM hoadon 
               WHERE TongGia = (SELECT Max(TongGia) AS MAX FROM hoadon));

-- 12) Liệt kê các thuốc (MaThuoc, TenThuoc) trong thời gian tháng 6/2023 không có khách hàng nào mua. 
SELECT MaThuoc, TenThuoc
FROM thuoc
WHERE mathuoc NOT IN (SELECT MaThuoc
                      FROM chi_tiet_hoadon
                      INNER JOIN hoadon ON hoadon.MaHD = chi_tiet_hoadon.MaHD
                      WHERE MONTH(NgayBan) = 6 AND YEAR(NgayBan) = 2023);
                      
-- 13 ) Liệt kê các KH (MaKH, TenKH) đã mua thuốc trong danh mục “Thực phẩm chức năng” trong tháng 3/2023.
SELECT KH.MaKH, KH.TenKH
FROM khachhang KH
INNER JOIN hoadon ON hoadon.MaKH = KH.MaKH
WHERE MONTH(NgayBan) = 3 AND YEAR(NgayBan) = 2023 
	  AND hoadon.MaHD IN (SELECT MaHD 
	                      FROM chi_tiet_hoadon
                          WHERE mathuoc IN (SELECT mathuoc
                                            FROM thuoc
                                            INNER JOIN danhmuc ON thuoc.MaDanhMuc = danhmuc.MaDanhMuc
                                            WHERE TenDanhMuc = 'Thực phẩm chức năng'));


-- 14 )	Liệt kê những loại thuốc (MaThuoc, TenThuoc) có trong danh mục “Thực phẩm chức năng” 
-- có giá cao hơn giá trung bình của các loại thuốc thuộc danh mục đó.
SELECT T.MaThuoc, T.TenThuoc
FROM thuoc T
INNER JOIN danhmuc DM ON DM.MaDanhMuc = T.MaDanhMuc
WHERE DM.TenDanhMuc = "Thực phẩm chức năng"
      AND T.Gia > (SELECT AVG(Gia)
                   FROM thuoc
                   WHERE MaDanhMuc = DM.MaDanhMuc);
                   
                   
-- 15) Liệt kê các loại thuốc (MaThuoc, TenThuoc) thuộc danh mục “Thuốc hạ sốt” được bán trong ngày “7/2023”.
SELECT T.MaThuoc, T.TenThuoc
FROM thuoc T
INNER JOIN danhmuc ON danhmuc.MaDanhMuc = T.MaDanhMuc
WHERE TenDanhMuc = 'Thuốc hạ sốt' AND MaThuoc IN (SELECT MaThuoc
                                                    FROM chi_tiet_hoadon
                                                    INNER JOIN hoadon ON hoadon.MaHD = chi_tiet_hoadon.MaHD
                                                    WHERE MONTH(NgayBan) = 7 AND YEAR(NgayBan) = 2023);
                                                    
-- 16) Lấy ra Tên NV có doanh thu cao nhất trong tháng 6/2023.
SELECT NV.MaNV, NV.TenNV, SUM(hoadon.TongGia) AS TongDoanhThu
FROM nhanvien NV
INNER JOIN hoadon ON hoadon.MaNV = NV.MaNV
GROUP BY NV.MaNV, NV.TenNV
ORDER BY SUM(hoadon.TongGia) DESC
LIMIT 1;


-- 17) Tìm Thuốc (MaThuoc, TenThuoc) được bán chạy nhất có trong danh mục “Thuốc dành cho mắt”.

SELECT T.MaThuoc, T.TenThuoc, SUM(CTHD.SoLuongBan) AS TongSoLuongBan
FROM thuoc T
INNER JOIN danhmuc DM ON T.MaDanhMuc = DM.MaDanhMuc
INNER JOIN chi_tiet_hoadon CTHD ON CTHD.MaThuoc = T.MaThuoc
WHERE DM.TenDanhMuc = 'Thuốc dành cho mắt'
GROUP BY T.MaThuoc, T.TenThuoc
ORDER BY TongSoLuongBan DESC
LIMIT 1;


-- 18) Tìm ra thuốc đưa lại doanh thu cao nhất trong tháng 6/2023.
SELECT T.MaThuoc, T.TenThuoc, SUM(CTHD.SoLuongBan * T.Gia) AS TongDoanhThu
FROM thuoc T
INNER JOIN chi_tiet_hoadon CTHD ON CTHD.MaThuoc = T.MaThuoc
INNER JOIN hoadon HD ON CTHD.MaHD = HD.MaHD
WHERE MONTH(HD.NgayBan) = 6 AND YEAR(HD.NgayBan) = 2023
GROUP BY T.MaThuoc, T.TenThuoc
ORDER BY TongDoanhThu DESC
LIMIT 1;


                   
-- 19) Tìm ra NCC cung cấp nhiều loại thuốc nhất trong danh mục “Thuốc đặc trị tiểu đường”.
SELECT NCC.MaNCC, NCC.TenNCC, COUNT(T.MaThuoc) AS SoLuongLoaiThuoc
FROM thuoc T
INNER JOIN nhacungcap NCC ON NCC.MaNCC = T.MaNCC
INNER JOIN danhmuc DM ON DM.MaDanhMuc = T.MaDanhMuc
WHERE DM.TenDanhMuc = "Thuốc đặc trị tiểu đường"
GROUP BY NCC.MaNCC, NCC.TenNCC
ORDER BY SoLuongLoaiThuoc DESC
LIMIT 1;

-- 20) Tìm ra danh mục thuốc đưa lại doanh thu cao nhất trong tháng 6/2023.
SELECT DM.MaDanhMuc, DM.TenDanhMuc, SUM(CTHD.SoLuongBan * T.Gia) AS DoanhThu
FROM danhmuc DM
INNER JOIN thuoc T ON T.MaDanhMuc = DM.MaDanhMuc
INNER JOIN chi_tiet_hoadon CTHD ON CTHD.MaThuoc = T.MaThuoc
INNER JOIN hoadon HD ON HD.MaHD = CTHD.MaHD
WHERE MONTH(HD.NgayBan) = 6 AND YEAR(HD.NgayBan) = 2023
GROUP BY DM.MaDanhMuc, DM.TenDanhMuc
ORDER BY DoanhThu DESC
LIMIT 1;




