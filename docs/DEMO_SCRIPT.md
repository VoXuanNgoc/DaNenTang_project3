# KỊCH BẢN QUAY VIDEO DEMO (DEMO SCRIPT)
## Mini-Project 3: Receipt OCR & Expense Tracker
### Thời lượng dự kiến: 2–3 phút

---

## Chuẩn bị trước khi quay
1. Thiết bị Android thực tế hoặc máy ảo Android / Desktop đã cài đặt ứng dụng `VKU Expense OCR`.
2. Chuẩn bị sẵn 1-2 hóa đơn thực tế (hoặc ảnh hóa đơn mẫu trên màn hình máy tính) như hóa đơn Highlands Coffee, WinMart hoặc Circle K.
3. Phần mềm quay màn hình (OBS Studio hoặc trình ghi màn hình tích hợp của Android).

---

## Kịch bản chi tiết từng bước (Timeline Sequence)

### 0:00 – 0:25 | Bước 1: Mở ứng dụng & Khám phá Dashboard
- **Hành động:** Chạm vào biểu tượng ứng dụng **VKU Expense OCR** trên màn hình chính.
- **Lời thuyết minh:** 
  > "Xin chào thầy và các bạn. Đây là ứng dụng VKU Expense OCR — Trình theo dõi chi tiêu và quét hóa đơn thông minh cho môn học Lập trình Di động Flutter tại VKU. Khi mở ứng dụng, màn hình Dashboard hiển thị tổng chi tiêu, số lượng hóa đơn đã lưu và các thẻ tóm tắt chi tiêu nhanh."
- **Thao tác:** 
  - Cuộn nhẹ xem danh sách lịch sử hóa đơn gần đây.
  - Chỉ vào các thẻ `ExpenseSummaryCard` với icon danh mục tròn, tên cửa hàng, ngày tháng và số tiền định dạng chuẩn Việt Nam (`65.000 đ`).

---

### 0:25 – 1:00 | Bước 2: Quét hóa đơn thực tế bằng Camera / Thư viện
- **Hành động:** Nhấn vào nút **"Quét hóa đơn OCR"** trên thanh tác vụ nhanh hoặc chuyển sang tab **Quét hóa đơn** ở thanh điều hướng dưới.
- **Thao tác:** 
  - Nhấn nút **"Chụp ảnh"** (hoặc **"Chọn từ thư viện"**).
  - Chọn ảnh hóa đơn (ví dụ: Hóa đơn Highlands Coffee).
- **Lời thuyết minh:** 
  > "Bây giờ chúng ta sẽ quét một hóa đơn thật. Ứng dụng ngay lập tức nạp ảnh và kích hoạt mô hình Google ML Kit Text Recognition chạy ngoại tuyến hoàn toàn trên máy mà không cần mạng Internet."
- **Ghi chú trên màn hình:** Vòng xoay tải hiển thị thông báo: *"Đang nhận diện văn bản OCR..."*.

---

### 1:00 – 1:35 | Bước 3: Xem lại & Xác thực (Review & Verification Screen)
- **Hành động:** Màn hình **"Xem lại hóa đơn"** tự động mở ra.
- **Lời thuyết minh:** 
  > "Do hóa đơn thực tế có thể bị nhàu hoặc có tạp âm quang học, ứng dụng dẫn người dùng vào màn hình Review & Verification bắt buộc. Tại đây, bộ parser heuristics đã tự động trích xuất tên cửa hàng Highlands Coffee, số tiền 65.000 đ và ngày lập hóa đơn."
- **Thao tác:**
  - Nhấn mở phần **"Văn bản OCR gốc (Debug/Kiểm tra)"** để người xem thấy chuỗi text thô mà ML Kit đã đọc được.
  - Thực hiện chỉnh sửa một trường (ví dụ: thêm ghi chú *"Cà phê cùng bạn bè"* hoặc điều chỉnh lại danh mục nếu cần).
  - Nhấn nút **"Lưu hóa đơn"**.
- **Hiệu ứng:** SnackBar thông báo màu xanh xuất hiện: *"Đã lưu hóa đơn thành công!"*, màn hình tự động chuyển về Dashboard.

---

### 1:35 – 2:05 | Bước 4: Kiểm tra Lịch sử & Chi tiết hóa đơn
- **Thao tác:**
  - Hóa đơn mới lập tức xuất hiện ở đầu danh sách trên Dashboard (nhờ Riverpod AsyncNotifier cập nhật trạng thái tức thì).
  - Chạm vào hóa đơn để vào màn hình **"Chi tiết hóa đơn"** (`/expense/:id`).
- **Lời thuyết minh:** 
  > "Hóa đơn vừa lưu đã xuất hiện ngay trên đầu lịch sử. Khi nhấn vào, chúng ta thấy toàn bộ thông tin chi tiết, ảnh chụp hóa đơn gốc và có thể chỉnh sửa hoặc xóa hóa đơn với hộp thoại xác nhận an toàn."

---

### 2:05 – 2:40 | Bước 5: Khám phá Màn hình Báo cáo & Biểu đồ CustomPainter
- **Hành động:** Chuyển sang tab **"Báo cáo"** trên NavigationBar.
- **Lời thuyết minh:** 
  > "Tiếp theo là màn hình Báo cáo và Thống kê. Toàn bộ biểu đồ ở đây được vẽ hoàn toàn bằng CustomPainter của Flutter kèm hoạt ảnh chuyển động mượt mà, không sử dụng thư viện biểu đồ bên ngoài."
- **Thao tác:**
  - Xem **Biểu đồ tròn Donut** phân bổ chi tiêu theo danh mục (Ăn uống, Mua sắm, Di chuyển...) với lỗ trung tâm hiển thị tổng chi tiêu.
  - Xem **Biểu đồ cột 7 ngày qua** với các cột gradient chuyển tiếp, hiển thị chi tiêu theo từng thứ trong tuần.
  - Cuộn xuống xem thẻ **"Demo MethodChannel (Week 8)"**: hiển thị mức pin thực tế của thiết bị (`Battery Level: 85%`) và tên mẫu máy Android nhận từ mã nguồn native Kotlin.

---

### 2:40 – 3:00 | Bước 6: Thử nghiệm Dark Mode & Kết thúc
- **Hành động:** Nhấn vào icon mặt trời/mặt trăng trên AppBar để chuyển đổi sang **Dark Mode**.
- **Lời thuyết minh:** 
  > "Ứng dụng hỗ trợ đầy đủ Material 3 Dark Mode với bảng màu trầm dịu mắt và được lưu bền vững vào bộ nhớ thiết bị. Cảm ơn thầy và các bạn đã theo dõi phần trình diễn ứng dụng VKU Expense OCR!"
- **Kết thúc video.**
