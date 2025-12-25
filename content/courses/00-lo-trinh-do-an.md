---
title: "Lộ trình thực hiện đồ án: Java & JavaScript"
date: 2025-12-20
draft: false
weight: 1
pinned: true
summary: "Dàn ý chi tiết 9 bài viết cốt lõi về Frontend (JS) và Backend (Java Network) nhằm đáp ứng yêu cầu đồ án học phần."
tags: ["Roadmap", "Project", "Java", "JavaScript"]
---

Dựa trên yêu cầu của đồ án học phần, chuỗi bài viết này được xây dựng để chia sẻ kiến thức về hai ngôn ngữ chính là **Java** và **JavaScript**, với mục tiêu hoàn thành tối thiểu 9 bài viết trước hạn chót.

Dưới đây là checklist theo dõi tiến độ thực hiện:

### Phần 1: JavaScript & Nền tảng Web
*(Kiến thức nền tảng dựa trên khóa học Cisco JavaScript Essentials)*

- [ ] **Bài 1: Khởi động với JavaScript - Biến và Kiểu dữ liệu**
    * *Nội dung:* Các kiểu dữ liệu cơ bản, Dynamic typing. Sự khác biệt giữa `var`, `let`, `const`.
    * *Liên hệ:* Vai trò của JS trong trình duyệt và sự trỗi dậy của Node.js.
- [ ] **Bài 2: Hàm (Functions) và Xử lý sự kiện**
    * *Nội dung:* Cấu trúc hàm, Arrow Function (ES6), và Callback function.
    * *Liên hệ:* Bước đệm quan trọng để hiểu về lập trình bất đồng bộ.
- [ ] **Bài 3: Xử lý Bất đồng bộ: Promise và Async/Await**
    * *Nội dung:* Giải quyết vấn đề "Callback hell". Cơ chế `Promise` và cú pháp `async/await`.
    * *Liên hệ:* Kỹ thuật bắt buộc khi làm việc với các tác vụ mạng tốn thời gian.
- [ ] **Bài 4: JSON và Fetch API - Giao tiếp Client-Server**
    * *Nội dung:* Cấu trúc JSON. Sử dụng `Fetch API` để gửi request HTTP (GET, POST).
    * *Liên hệ:* Mô phỏng Client gửi yêu cầu và nhận dữ liệu từ Server.

---

### Phần 2: Java & Lập trình mạng (Socket)
*(Kiến thức cốt lõi từ các buổi học Lập trình mạng)*

- [ ] **Bài 5: Java I/O Streams - Quản lý luồng nhập xuất**
    * *Nội dung:* Phân biệt Byte Stream và Character Stream. Kỹ thuật Buffered.
    * *Liên hệ:* Cơ sở để truyền tải dữ liệu qua mạng.
- [ ] **Bài 6: Lập trình Socket TCP (Mô hình Client-Server)**
    * *Nội dung:* Giao thức TCP, `ServerSocket`, quy trình Bind -> Listen -> Accept.
    * *Demo:* Ứng dụng Chat đơn giản (1-1).
- [ ] **Bài 7: Socket UDP - Truyền tải dữ liệu không kết nối**
    * *Nội dung:* Đặc điểm của UDP. Sử dụng `DatagramPacket` và `DatagramSocket`.
    * *Demo:* Ứng dụng gửi tin nhắn Broadcast hoặc Streaming.
- [ ] **Bài 8: Đa luồng (Multithreading) trong Lập trình mạng**
    * *Nội dung:* Tại sao Server cần đa luồng? Sử dụng `Thread`/`Runnable` để xử lý nhiều Client.
    * *Nâng cấp:* Tối ưu bài toán TCP Server để phục vụ nhiều người dùng cùng lúc.
- [ ] **Bài 9: Tổng quan về RMI (Remote Method Invocation)**
    * *Nội dung:* Cơ chế gọi phương thức từ xa, kiến trúc Stub và Skeleton.
    * *Liên hệ:* Bước chuyển từ Socket sang các kiến trúc phân tán hiện đại.

---

> *Trạng thái cập nhật lần cuối: 25/12/2025*
> *Tiến độ hiện tại: 0/9 bài viết.*