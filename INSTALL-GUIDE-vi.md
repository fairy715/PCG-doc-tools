# Công cụ tài liệu PCG: hướng dẫn cài đặt

[中文](安裝說明.md) · [English](INSTALL-GUIDE-en.md) · [Bahasa Indonesia](INSTALL-GUIDE-id.md) · [Tiếng Việt](INSTALL-GUIDE-vi.md)

Phiên bản mới nhất: **https://github.com/fairy715/PCG-doc-tools/releases/latest**

## 1. Tải về

Ở mục "Assets" trên trang phát hành, bấm `PCG-DocTools-Setup-<phiên bản>.exe`. Nếu trình duyệt cảnh báo tệp "không thường được tải xuống", chọn "Giữ lại" / "Keep". IT cũng có thể đặt tệp vào thư mục dùng chung.

## 2. Cài đặt

1. Bấm đúp vào tệp exe.
2. Nếu xuất hiện "Windows đã bảo vệ PC của bạn" ("Windows protected your PC"), bấm "Thông tin thêm" ("More info") → "Vẫn chạy" ("Run anyway"). Bộ cài không có chứng chỉ ký mã.
3. Vị trí: mặc định `D:\PCG-doc-tools` (nếu không có ổ D thì là `C:\PCG-doc-tools`). Bấm nút tiếp theo rồi bấm cài đặt. Không cần mạng internet hay quyền quản trị viên.
4. Hoàn tất: đánh dấu "Mở Công cụ tài liệu PCG ngay" rồi bấm nút hoàn tất. Màn hình desktop sẽ có lối tắt "Công cụ tài liệu PCG".

## 3. Sử dụng

1. Bấm đúp vào lối tắt trên desktop. Trình duyệt mở `http://127.0.0.1:8765/` (lần đầu khoảng 10–30 giây).
2. Chọn công cụ → tải tệp lên → tải kết quả về. Tệp chỉ được xử lý trên máy này, không gửi ra ngoài.
3. Mô hình nhận dạng chữ (OCR) đã có sẵn (tiếng Trung phồn thể/giản thể, tiếng Anh, tiếng Việt, tiếng Indonesia); không cần tải thêm.

## Dành cho IT: khu vực quản trị

- Trên máy đó, mở `http://127.0.0.1:8765/admin` (hoặc mục "Quản trị"/"Admin" trong ứng dụng).
- Mặc định là **chế độ một người dùng**: không cần tài khoản hay mật khẩu; ai dùng máy đó chính là quản trị viên. Có thể bật/tắt công cụ, đặt thời gian lưu tệp, cài đặt OCR, v.v.
- Có thể bật đăng nhập tài khoản (vai trò, `jtdt-admin`) trong khu vực quản trị khi dùng chung. Với máy một người dùng, nên giữ chế độ một người dùng: bản ngoại tuyến này không có lệnh `jtdt`, nên quên mật khẩu sẽ khó khôi phục hơn.

## 4. Cập nhật

Không cần gỡ phiên bản cũ; không gian làm việc, con dấu và cài đặt (thư mục `data`) đều được giữ lại.

- **Cập nhật một lần bấm (đơn giản nhất)**: trên máy có internet, hoặc khi IT đã thiết lập thư mục dùng chung, khi mở lối tắt trên desktop sẽ hiện "Có phiên bản mới. Cập nhật ngay?". Bấm "Có"; ứng dụng tự mở sau khoảng 1 phút.

Hoặc cập nhật thủ công: đóng Công cụ tài liệu PCG trước, rồi:

- **Gói cập nhật nhỏ** (`PCG-DocTools-Update-….exe`, nhỏ hơn nhiều): bấm đúp; xong trong khoảng 1 phút. Nếu thông báo cần thành phần mới, hãy dùng bộ cài đầy đủ.
- **Bộ cài đầy đủ**: cài đè lên phiên bản cũ.
- Bảng ở đầu mỗi trang phát hành cho biết nên dùng tệp nào. IT triển khai hàng loạt: thêm `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART` sau tên tệp exe.

## 5. Khi gặp sự cố

- Không mở được: gửi hai tệp trong `D:\PCG-doc-tools\data\pcg-logs\` cho IT.
- Bị phần mềm diệt virus chặn: nhờ IT thêm thư mục cài đặt vào danh sách ngoại lệ.
- Gỡ cài đặt: Windows "Cài đặt" → "Ứng dụng" → "PCG Document Tools" → "Gỡ cài đặt". Thư mục `data` vẫn được giữ; xóa thủ công nếu không cần.
