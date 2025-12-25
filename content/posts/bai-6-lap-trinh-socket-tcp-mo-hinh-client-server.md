---
title: "Bài 6: Lập trình Socket TCP - Xây dựng ứng dụng Chat"
date: 2025-12-21
draft: false
weight: 7
summary: "Hướng dẫn lập trình mạng cơ bản với giao thức TCP trong Java. Tìm hiểu về ServerSocket, Socket và quy trình bắt tay 3 bước để xây dựng ứng dụng Chat Client-Server."
tags: ["Java", "Socket", "TCP", "Client-Server"]
---

Trong các bài trước, chúng ta đã chuẩn bị đầy đủ hành trang: hiểu về biến/hàm (JS), cơ chế bất đồng bộ, và cách quản lý luồng dữ liệu (Java I/O). Hôm nay, chúng ta sẽ ghép nối tất cả để xây dựng ứng dụng mạng đầu tiên sử dụng giao thức TCP.

Đây là bài học quan trọng nhất, vì 90% các ứng dụng mạng bạn sử dụng hàng ngày (Web, Email, File Transfer) đều chạy trên nền tảng TCP.

## 1. Tổng quan về Giao thức TCP

### 1.1. TCP là gì?

TCP (Transmission Control Protocol) là giao thức hướng kết nối (connection-oriented). Trước khi hai máy tính có thể trao đổi dữ liệu, chúng phải thiết lập một "đường ống" ảo thông qua quy trình **Bắt tay 3 bước (3-way Handshake)**.

### 1.2. Đặc điểm cốt lõi
1.  **Tin cậy (Reliable):** TCP đảm bảo gói tin gửi đi chắc chắn đến đích. Nếu gói tin bị mất trên đường truyền, TCP sẽ tự động gửi lại (retransmission).
2.  **Có thứ tự (Ordered):** Nếu bạn gửi A rồi gửi B, bên nhận chắc chắn sẽ nhận A trước rồi mới đến B.
3.  **Luồng dữ liệu (Byte Stream):** TCP không giới hạn kích thước gói tin, dữ liệu được truyền đi như một dòng chảy liên tục (Stream).

### 1.3. Mô hình Client-Server
* **Server (Máy chủ):** Đóng vai trò thụ động. Nó mở một cổng (Port) và lắng nghe, chờ đợi ai đó kết nối đến.
* **Client (Máy khách):** Đóng vai trò chủ động. Nó biết địa chỉ IP và Port của Server để khởi tạo kết nối.

## 2. Các lớp Java hỗ trợ TCP Socket

Java cung cấp gói `java.net` để làm việc với tầng giao vận này.

### 2.1. Lớp `java.net.ServerSocket`
Lớp này chỉ được sử dụng ở phía **Server**. Nhiệm vụ duy nhất của nó là chờ đợi các yêu cầu kết nối từ Client.

* `ServerSocket(int port)`: Tạo server lắng nghe tại port chỉ định.
* `Socket accept()`: Phương thức quan trọng nhất. Khi gọi lệnh này, chương trình sẽ **dừng lại (block)** và chờ cho đến khi có một Client kết nối đến. Khi có kết nối, nó trả về một đối tượng `Socket` để giao tiếp với Client đó.

### 2.2. Lớp `java.net.Socket`
Lớp này được sử dụng ở cả hai phía (nhưng thường được khởi tạo chủ động từ phía Client). Nó đại diện cho một đầu mối kết nối (endpoint).

* `Socket(String host, int port)`: Tạo socket và thử kết nối đến Server tại địa chỉ host:port.
* `getInputStream()`: Lấy luồng nhập để đọc dữ liệu đối phương gửi sang.
* `getOutputStream()`: Lấy luồng xuất để gửi dữ liệu sang đối phương.

## 3. Quy trình hoạt động (Workflow)

Để xây dựng một ứng dụng chat đơn giản, quy trình diễn ra như sau:

1.  **Server:** Khởi tạo `ServerSocket` tại port 5000.
2.  **Server:** Gọi `accept()` và đi vào trạng thái chờ (Listening).
3.  **Client:** Khởi tạo `Socket` kết nối đến IP Server tại port 5000.
4.  **Kết nối thiết lập:** Server thoát khỏi trạng thái chờ, trả về một `Socket` riêng biệt để quản lý kết nối này.
5.  **Trao đổi dữ liệu:**
    * Cả hai bên lấy `InputStream` và `OutputStream` từ Socket.
    * Client viết vào OutputStream -> Server đọc từ InputStream (và ngược lại).
6.  **Đóng kết nối:** Gọi `close()` để giải phóng tài nguyên.

## 4. Demo: Ứng dụng Console Chat (1-1)

Chúng ta sẽ viết hai chương trình riêng biệt: `SimpleServer.java` và `SimpleClient.java`.

### 4.1. Mã nguồn Server (SimpleServer.java)

Server này sẽ lắng nghe ở cổng 5000. Khi Client kết nối, nó sẽ cho phép chat qua lại trên màn hình Console.

```java
import java.io.*;
import java.net.*;

public class SimpleServer {
    public static void main(String[] args) {
        int port = 5000;
        System.out.println("Server đang khởi động tại port " + port);

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            // Chờ kết nối (Code sẽ dừng tại đây cho đến khi có Client)
            Socket socket = serverSocket.accept();
            System.out.println("Client đã kết nối: " + socket.getInetAddress());

            // Tạo luồng đọc/ghi dữ liệu
            // Sử dụng BufferedReader để đọc từng dòng text
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            // Sử dụng PrintWriter với autoFlush = true để gửi dữ liệu đi ngay lập tức
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
            
            // Luồng đọc từ bàn phím server để chat lại
            BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));

            String messageFromClient;
            while ((messageFromClient = in.readLine()) != null) {
                System.out.println("Client: " + messageFromClient);
                
                // Nhập tin nhắn từ bàn phím server và gửi lại
                System.out.print("Server: ");
                String response = stdIn.readLine();
                out.println(response);
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

### 4.2. Mã nguồn Client (SimpleClient.java)

Client kết nối đến `localhost` (chính máy hiện tại) cổng 5000.

```java
import java.io.*;
import java.net.*;

public class SimpleClient {
    public static void main(String[] args) {
        String hostname = "localhost";
        int port = 5000;

        try (Socket socket = new Socket(hostname, port)) {
            System.out.println("Đã kết nối đến Server!");

            // Thiết lập luồng gửi nhận tương tự Server
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            BufferedReader stdIn = new BufferedReader(new InputStreamReader(System.in));

            String userInput;
            System.out.print("Client: ");
            while ((userInput = stdIn.readLine()) != null) {
                // Gửi tin nhắn sang Server
                out.println(userInput);

                // Đọc phản hồi từ Server
                System.out.println("Server: " + in.readLine());
                System.out.print("Client: ");
            }

        } catch (UnknownHostException e) {
            System.err.println("Không tìm thấy Host: " + hostname);
        } catch (IOException e) {
            System.err.println("Lỗi I/O khi kết nối: " + e.getMessage());
        }
    }
}
```

### 4.3. Cách chạy chương trình

Để kiểm thử ứng dụng này, bạn cần mở 2 cửa sổ Terminal (hoặc CMD):

1.  **Terminal 1 (Chạy Server trước):**
    * Biên dịch: `javac SimpleServer.java`
    * Chạy: `java SimpleServer`
    * *Hiện trạng:* Màn hình sẽ hiện "Server đang khởi động..." và chờ đợi.
2.  **Terminal 2 (Chạy Client):**
    * Biên dịch: `javac SimpleClient.java`
    * Chạy: `java SimpleClient`
    * *Hiện trạng:* Màn hình báo "Đã kết nối đến Server!".
3.  **Thử nghiệm:**
    * Tại Terminal Client, gõ "Xin chào" -> Enter.
    * Nhìn sang Terminal Server, bạn sẽ thấy dòng chữ hiện lên.
    * Tại Terminal Server, gõ trả lời "Chào bạn" -> Enter.
    * Client sẽ nhận được tin nhắn.

## 5. Các lưu ý quan trọng

1.  **Cổng (Port):** Port 0-1023 là cổng hệ thống (well-known ports). Nên dùng port từ 1024 trở lên (ví dụ 3000, 5000, 8080) để tránh xung đột quyền hạn.
2.  **Firewall (Tường lửa):** Nếu bạn chạy Server và Client trên 2 máy khác nhau, Tường lửa của máy Server có thể chặn kết nối. Cần mở port hoặc tắt firewall tạm thời.
3.  **Blocking I/O:** Trong ví dụ trên, khi gọi `in.readLine()`, chương trình sẽ dừng lại chờ dữ liệu. Điều này dẫn đến việc Server chỉ có thể phục vụ 1 Client tại một thời điểm và phải đợi Client nói xong mới được trả lời (Chat kiểu bộ đàm). Để chat song song (Full-duplex) và phục vụ nhiều người, ta cần dùng **Đa luồng (Multithreading)** sẽ học ở Bài 8.

## 6. Kết luận

Chúng ta đã xây dựng thành công "xương sống" của một ứng dụng mạng. Mô hình Client-Server dùng Socket TCP đảm bảo dữ liệu truyền đi an toàn và chính xác.
Tuy nhiên, TCP có nhược điểm là tốc độ chậm hơn do quá trình kiểm tra lỗi và thiết lập kết nối chặt chẽ. Ở bài tiếp theo, chúng ta sẽ tìm hiểu về UDP - người anh em nhanh nhẹn nhưng "ẩu" hơn của TCP.

---

## Tài liệu tham khảo
1.  Oracle Java Docs. "Socket Programming".
2.  GeeksforGeeks. "Socket Programming in Java".
3.  Giáo trình Lập trình mạng - Hutech.