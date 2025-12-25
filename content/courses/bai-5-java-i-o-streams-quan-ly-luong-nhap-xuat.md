---
title: "Bài 5: Java I/O Streams - Quản lý luồng nhập xuất"
date: 2025-12-21
draft: false
weight: 6
summary: "Tìm hiểu kiến trúc I/O trong Java: Phân biệt Byte Stream và Character Stream, kỹ thuật Buffered để tối ưu hiệu suất và ứng dụng của chúng trong truyền tải dữ liệu mạng."
tags: ["Java", "Input/Output", "Stream", "Performance"]
---

Trong lập trình mạng, bản chất của việc giao tiếp giữa Client và Server chính là quá trình Nhập (Input) và Xuất (Output) dữ liệu. Dù dữ liệu đó là một tin nhắn văn bản, một bức ảnh hay một video, chúng đều phải được chuyển thành dòng dữ liệu (Stream) để di chuyển qua dây dẫn mạng.

Java cung cấp gói thư viện `java.io` rất mạnh mẽ để xử lý vấn đề này. Nếu bạn đến từ C#, bạn sẽ thấy sự tương đồng giữa `System.IO` của .NET và `java.io` của Java.

## 1. Khái niệm về Stream (Luồng)

Stream là một khái niệm trừu tượng biểu diễn một dòng dữ liệu chảy từ nguồn (Source) đến đích (Destination).

* **InputStream (Luồng nhập):** Dùng để đọc dữ liệu từ nguồn (bàn phím, file, mạng) vào chương trình.
* **OutputStream (Luồng xuất):** Dùng để ghi dữ liệu từ chương trình ra đích (màn hình, file, mạng).

Nguyên tắc vàng: Stream trong Java hoạt động theo cơ chế tuần tự (FIFO - First In First Out). Bạn đọc byte số 1, sau đó mới đến byte số 2, không thể nhảy cóc ngẫu nhiên (trừ khi dùng `RandomAccessFile`).

## 2. Phân loại Stream: Byte vs Character

Đây là sự phân biệt quan trọng nhất mà mọi lập trình viên Java cần nắm vững để tránh lỗi hiển thị ký tự (font lỗi).

### 2.1. Byte Stream (Luồng Byte)

Byte Stream làm việc với dữ liệu thô dạng nhị phân, xử lý từng byte (8-bit) một.
* **Lớp cha:** `InputStream` và `OutputStream`.
* **Các lớp cài đặt phổ biến:** `FileInputStream`, `FileOutputStream`, `BufferedInputStream`.
* **Ứng dụng:** Dùng để xử lý các dữ liệu không phải văn bản như: Hình ảnh (PNG, JPG), Video (MP4), File âm thanh, hoặc File thực thi (.exe).

Nếu bạn dùng Byte Stream để đọc file văn bản tiếng Việt có dấu, khả năng cao sẽ bị lỗi font vì một ký tự UTF-8 có thể tốn 2-3 byte, việc đọc từng byte rời rạc sẽ làm gãy mã ký tự.

### 2.2. Character Stream (Luồng Ký tự)

Character Stream được thiết kế để xử lý văn bản, tự động chuyển đổi các byte thành ký tự (16-bit Unicode) dựa trên bảng mã (encoding) của hệ thống.
* **Lớp cha:** `Reader` và `Writer`.
* **Các lớp cài đặt phổ biến:** `FileReader`, `FileWriter`, `BufferedReader`, `PrintWriter`.
* **Ứng dụng:** Chuyên dùng để đọc/ghi file text, log file, hoặc tin nhắn chat.

### 2.3. Bảng so sánh

| Đặc điểm | Byte Stream | Character Stream |
| :--- | :--- | :--- |
| **Đơn vị xử lý** | 1 byte (8-bit) | 1 char (16-bit Unicode) |
| **Lớp gốc** | InputStream / OutputStream | Reader / Writer |
| **Dữ liệu phù hợp** | Binary (Ảnh, Nhạc, Video) | Text (Văn bản, JSON, XML) |
| **Ví dụ** | FileInputStream | FileReader |

## 3. Kỹ thuật Buffered (Bộ đệm)

Trong thực tế, việc đọc/ghi từng byte trực tiếp vào ổ cứng hoặc card mạng là cực kỳ tốn kém về hiệu năng (do chi phí gọi hệ thống - system calls).

Để giải quyết, Java cung cấp các lớp Wrapper có chức năng đệm: `BufferedInputStream`, `BufferedOutputStream`, `BufferedReader`, `BufferedWriter`.

**Cơ chế hoạt động:**
Thay vì ghi từng byte ngay lập tức, Buffered Stream sẽ gom dữ liệu vào một mảng bộ nhớ đệm (buffer array, mặc định thường là 8KB). Khi bộ đệm đầy (hoặc khi gọi lệnh `flush()`), nó mới thực hiện ghi một lần xuống thiết bị vật lý. Điều này giúp giảm số lần truy xuất I/O, tăng tốc độ chương trình lên hàng trăm lần.

## 4. Cầu nối: InputStreamReader và OutputStreamWriter

Trong lập trình Socket (mà chúng ta sẽ học ở Bài 6), luồng dữ liệu nhận được từ mạng luôn là **Byte Stream** (`socket.getInputStream()`). Để xử lý tin nhắn chat (văn bản), chúng ta cần chuyển đổi nó sang **Character Stream**.

Lớp `InputStreamReader` đóng vai trò là cầu nối: Nó đọc các byte và giải mã chúng thành ký tự.

**Mô hình wrapper thường thấy trong lập trình mạng:**

```java
// 1. Lấy luồng byte từ Socket
InputStream is = socket.getInputStream();

// 2. Chuyển đổi sang luồng ký tự (Bridge)
InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);

// 3. Đưa vào bộ đệm để đọc từng dòng (Performance)
BufferedReader reader = new BufferedReader(isr);

// 4. Đọc dữ liệu
String message = reader.readLine();
```

## 5. Ví dụ thực hành

### 5.1. Copy file dùng Byte Stream (Buffered)

Đoạn code này có thể copy bất kỳ loại file nào (ảnh, nhạc, text).

```java
import java.io.*;

public class FileCopyDemo {
    public static void main(String[] args) {
        // Sử dụng try-with-resources để tự động đóng stream (Java 7+)
        try (
            BufferedInputStream bis = new BufferedInputStream(new FileInputStream("source.jpg"));
            BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("dest.jpg"))
        ) {
            byte[] buffer = new byte[1024]; // Đọc mỗi lần 1KB
            int bytesRead;
            while ((bytesRead = bis.read(buffer)) != -1) {
                bos.write(buffer, 0, bytesRead);
            }
            System.out.println("Copy file thành công!");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

### 5.2. Đọc ghi văn bản dùng Character Stream

```java
import java.io.*;

public class TextReadWriteDemo {
    public static void main(String[] args) {
        try (
            BufferedReader reader = new BufferedReader(new FileReader("input.txt"));
            BufferedWriter writer = new BufferedWriter(new FileWriter("output.txt"))
        ) {
            String line;
            // Đọc từng dòng cho đến hết file
            while ((line = reader.readLine()) != null) {
                System.out.println("Đọc được: " + line);
                writer.write("Copy: " + line);
                writer.newLine(); // Xuống dòng
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## 6. Kết luận và Liên hệ Lập trình mạng

Kiến thức về I/O Stream là nền móng bắt buộc. Khi làm việc với mạng (Network Programming):
1.  **Socket** chỉ cung cấp hai luồng cơ bản: `InputStream` và `OutputStream`.
2.  Bạn phải tự quyết định bọc (wrap) chúng thành `DataInputStream` (nếu gửi dữ liệu nguyên thủy như int, float), `ObjectInputStream` (nếu gửi đối tượng Java) hay `BufferedReader` (nếu gửi văn bản chat).
3.  Luôn nhớ **flush()** dữ liệu khi gửi qua mạng để đảm bảo gói tin được đẩy đi ngay lập tức.

Trong bài tiếp theo, chúng ta sẽ áp dụng trực tiếp các kiến thức này để xây dựng một chương trình Chat Client-Server bằng giao thức TCP.

---

## Tài liệu tham khảo
1.  Oracle Java Documentation. "Basic I/O".
2.  GeeksforGeeks. "Difference between Byte Stream and Character Stream Class in Java".
3.  Baeldung. "Java InputStreamReader and OutputStreamWriter".
4.  Giáo trình Lập trình mạng - Hutech.