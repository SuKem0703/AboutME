---
title: "Bài 8: Đa luồng (Multithreading) - Nâng cấp Server phục vụ nhiều Client"
date: 2025-12-25
draft: false
weight: 9
summary: "Giải quyết vấn đề Blocking I/O bằng đa luồng. Hướng dẫn sử dụng Interface Runnable để xây dựng Multithreaded Server xử lý đồng thời nhiều kết nối."
tags: ["Java", "Multithreading", "Socket", "Concurrency"]
---

Trong Bài 6, chúng ta đã xây dựng thành công một TCP Server. Tuy nhiên, nó có một điểm yếu chí mạng: **Chỉ phục vụ được 1 người tại một thời điểm**. Nếu Client A đang kết nối, Client B kết nối đến sẽ bị "treo" cho đến khi A thoát.

Tại sao lại như vậy? Đó là do cơ chế **Blocking I/O**. Khi chương trình chạy lệnh đọc dữ liệu (`in.readLine()`), nó sẽ dừng toàn bộ hoạt động để chờ. Hôm nay, chúng ta sẽ giải quyết vấn đề này bằng **Đa luồng (Multithreading)**.

## 1. Tại sao Server cần Đa luồng?

Hãy tưởng tượng Server giống như một nhân viên ngân hàng.
* **Mô hình Đơn luồng (Single-threaded):** Chỉ có 1 nhân viên. Nếu khách hàng A đang điền giấy tờ (tốn 10 phút), nhân viên ngồi chờ và khách hàng B xếp hàng phía sau cũng phải chờ.
* **Mô hình Đa luồng (Multi-threaded):** Ngân hàng có 1 quản lý và nhiều nhân viên.
    * **Quản lý (Main Thread):** Chỉ đứng cửa chào khách và chỉ định nhân viên phục vụ.
    * **Nhân viên (Worker Thread):** Mỗi nhân viên phục vụ riêng một khách hàng.

Trong lập trình Socket, Main Thread sẽ chạy vòng lặp vô tận để đón kết nối (`accept()`). Ngay khi có kết nối, nó giao `Socket` đó cho một Thread con xử lý, rồi quay lại tiếp tục đón khách mới.

## 2. Cách tạo luồng trong Java

Java cung cấp 2 cách cơ bản để tạo luồng: kế thừa lớp `Thread` hoặc hiện thực interface `Runnable`. Trong thực tế, cách dùng `Runnable` được ưu tiên hơn vì tính linh hoạt (Java không hỗ trợ đa kế thừa).

### Cấu trúc cơ bản của Runnable

```java
public class ClientHandler implements Runnable {
    private Socket socket;

    public ClientHandler(Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        // Code xử lý giao tiếp với Client nằm ở đây
        // Đọc/Ghi dữ liệu...
    }
}
```

## 3. Nâng cấp: Multithreaded Chat Server

Chúng ta sẽ tách code Server thành 2 phần:
1.  **ServerMain:** Chịu trách nhiệm lắng nghe cổng 5000.
2.  **ClientHandler:** Chịu trách nhiệm chat với từng Client riêng biệt.

### 3.1. ClientHandler.java (Nhân viên phục vụ)

```java
import java.io.*;
import java.net.*;

public class ClientHandler implements Runnable {
    private Socket clientSocket;

    public ClientHandler(Socket socket) {
        this.clientSocket = socket;
    }

    @Override
    public void run() {
        try {
            // Tạo luồng Input/Output
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);

            out.println("Xin chào! Bạn đang được phục vụ bởi Thread: " + Thread.currentThread().getName());

            String request;
            while ((request = in.readLine()) != null) {
                System.out.println("Client nói: " + request);
                
                // Giả lập xử lý chậm để test đa luồng
                if (request.equalsIgnoreCase("sleep")) {
                    Thread.sleep(5000); 
                    out.println("Server vừa ngủ dậy sau 5s");
                } else {
                    out.println("Server phản hồi: " + request.toUpperCase());
                }
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        } finally {
            try {
                // Luôn đóng socket khi hoàn thành
                clientSocket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
```

### 3.2. MultiThreadServer.java (Quản lý)

```java
import java.io.*;
import java.net.*;

public class MultiThreadServer {
    public static void main(String[] args) {
        int port = 5000;
        System.out.println("Server đa luồng đang chạy tại port " + port);

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            while (true) {
                // 1. Chờ kết nối (Block tại đây)
                Socket clientSocket = serverSocket.accept();
                System.out.println("Client mới kết nối: " + clientSocket.getInetAddress());

                // 2. Tạo đối tượng xử lý (Handler)
                ClientHandler handler = new ClientHandler(clientSocket);

                // 3. Tạo luồng mới và khởi chạy
                Thread thread = new Thread(handler);
                thread.start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## 4. Kiểm thử

1.  Chạy `MultiThreadServer`.
2.  Chạy `SimpleClient` (code bài 6) ở Terminal 1 -> Gửi tin nhắn "Hello".
3.  Chạy thêm một `SimpleClient` nữa ở Terminal 2 -> Gửi tin nhắn "Hi".
4.  **Kết quả:** Cả hai Client đều nhận được phản hồi ngay lập tức mà không phải chờ nhau. Nếu là Server cũ, Terminal 2 sẽ bị treo.

## 5. Tối ưu hóa với Thread Pool

Việc tạo mới một Thread (`new Thread()`) cho mỗi Client là rất tốn kém tài nguyên. Nếu có 10.000 Client kết nối cùng lúc, Server sẽ bị sập vì hết bộ nhớ (Out of Memory).

Giải pháp chuyên nghiệp là sử dụng **Thread Pool** (Hồ chứa luồng) thông qua `ExecutorService`. Nó giới hạn số lượng Thread cố định, các Client đến sau sẽ được đưa vào hàng đợi (Queue).

```java
// Thay thế đoạn code trong main:
ExecutorService pool = Executors.newFixedThreadPool(10); // Chỉ cho phép 10 luồng chạy đồng thời

while (true) {
    Socket clientSocket = serverSocket.accept();
    ClientHandler handler = new ClientHandler(clientSocket);
    pool.execute(handler); // Giao việc cho Pool quản lý
}
```

## 6. Kết luận

Đa luồng là chìa khóa để xây dựng các hệ thống mạng hiệu năng cao.
* **Main Thread:** Chỉ làm nhiệm vụ `accept`.
* **Worker Thread:** Làm nhiệm vụ I/O (`read`/`write`).

Tuy nhiên, đa luồng cũng sinh ra các vấn đề phức tạp về đồng bộ hóa dữ liệu (Synchronization) khi nhiều luồng cùng truy cập một biến chung (ví dụ: danh sách người đang online).

Trong bài cuối cùng (Bài 9), chúng ta sẽ tìm hiểu về RMI - một công nghệ cho phép gọi hàm từ xa như thể nó đang nằm trên máy cục bộ, giúp đơn giản hóa việc lập trình phân tán.

---

## Tài liệu tham khảo
1.  Oracle Java Docs. "Defining and Starting a Thread".
2.  Baeldung. "Java ExecutorService".
3.  Giáo trình Lập trình mạng - Hutech.