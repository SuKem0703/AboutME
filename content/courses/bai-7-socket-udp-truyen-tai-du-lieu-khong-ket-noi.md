---
title: "Bài 7: Socket UDP - Giao thức 'Nhanh nhưng Ẩu'"
date: 2025-12-25
draft: false
weight: 8
summary: "Phân tích đặc điểm giao thức UDP, so sánh với TCP. Hướng dẫn lập trình Socket UDP bằng Java với DatagramPacket để xây dựng ứng dụng gửi tin nhắn Broadcast."
tags: ["Java", "Socket", "UDP", "Datagram"]
---

Nếu TCP là một nhân viên bưu điện cẩn thận (giao tận tay, xin chữ ký), thì UDP giống như một người phát tờ rơi: cứ ném đi và không quan tâm người nhận có nhặt được hay không. Nghe có vẻ "vô trách nhiệm", nhưng trong thế giới mạng, sự "vô trách nhiệm" này lại mang đến tốc độ tuyệt vời.

Hôm nay, chúng ta sẽ tìm hiểu về giao thức UDP và cách lập trình nó trong Java.

## 1. Tổng quan về UDP (User Datagram Protocol)

### 1.1. UDP là gì?
UDP là giao thức **không hướng kết nối (connectionless)**. Điều này có nghĩa là trước khi gửi dữ liệu, Client không cần bắt tay với Server. Nó cứ thế đóng gói dữ liệu và bắn đi.

### 1.2. Đặc điểm cốt lõi (So sánh với TCP)

| Đặc điểm | TCP (Transmission Control Protocol) | UDP (User Datagram Protocol) |
| :--- | :--- | :--- |
| **Kết nối** | Hướng kết nối (3-way handshake) | Không kết nối (Gửi ngay lập tức) |
| **Độ tin cậy** | Cao (Gửi lại nếu mất gói tin) | Thấp (Mất gói tin thì thôi) |
| **Thứ tự** | Đảm bảo đúng thứ tự | Không đảm bảo (Gói đến sau có thể nhận trước) |
| **Tốc độ** | Chậm hơn (do overhead kiểm tra lỗi) | Rất nhanh |
| **Ứng dụng** | Web (HTTP), Email (SMTP), File (FTP) | Video Streaming, Game Online, DNS, VoIP |

### 1.3. Tại sao Streaming/Game lại dùng UDP?
Khi bạn xem livestream bóng đá, nếu mất một vài khung hình (packet loss), bạn chỉ thấy hình bị giật nhẹ rồi thôi. Nếu dùng TCP, video sẽ bị dừng lại (buffering) để chờ tải lại khung hình đã mất đó, làm trễ trải nghiệm thực tế. Với Game hay Video, **thời gian thực (real-time)** quan trọng hơn sự hoàn hảo của dữ liệu.

## 2. Các lớp Java hỗ trợ UDP

Trong UDP, chúng ta không dùng `Socket` hay `ServerSocket`. Thay vào đó, Java cung cấp cặp đôi: `DatagramSocket` và `DatagramPacket`.

### 2.1. DatagramSocket
Đóng vai trò như cái "bưu điện" để gửi và nhận thư.
* `send(DatagramPacket p)`: Gửi gói tin đi.
* `receive(DatagramPacket p)`: Nhận gói tin về (Hàm này cũng **block** chương trình cho đến khi có dữ liệu đến).

### 2.2. DatagramPacket
Đóng vai trò như cái "phong bì thư", chứa:
* **Data:** Dữ liệu thực (mảng byte).
* **Length:** Độ dài dữ liệu.
* **Address & Port:** Địa chỉ người nhận (khi gửi) hoặc địa chỉ người gửi (khi nhận).

## 3. Demo: Ứng dụng Gửi tin nhắn (Sender - Receiver)

Khác với mô hình Client-Server của TCP, trong UDP các bên thường được gọi là Sender (Người gửi) và Receiver (Người nhận) vì vai trò của chúng bình đẳng và độc lập hơn.

### 3.1. Phía Người nhận (UDPServer.java)
Người nhận phải chạy trước để mở cổng lắng nghe.

```java
import java.io.*;
import java.net.*;

public class UDPServer {
    public static void main(String[] args) {
        int port = 9876;
        try (DatagramSocket socket = new DatagramSocket(port)) {
            System.out.println("UDP Server đang lắng nghe tại port " + port);

            byte[] receiveBuffer = new byte[1024]; // Chuẩn bị thùng chứa 1KB

            while (true) {
                // 1. Tạo gói tin rỗng để hứng dữ liệu
                DatagramPacket receivePacket = new DatagramPacket(receiveBuffer, receiveBuffer.length);

                // 2. Chờ nhận (Block)
                socket.receive(receivePacket);

                // 3. Xử lý dữ liệu nhận được
                String message = new String(receivePacket.getData(), 0, receivePacket.getLength());
                InetAddress senderIP = receivePacket.getAddress();
                int senderPort = receivePacket.getPort();

                System.out.println("Từ " + senderIP + ":" + senderPort + " -> " + message);

                // 4. (Tùy chọn) Gửi phản hồi lại
                String response = "Đã nhận: " + message.toUpperCase();
                byte[] sendData = response.getBytes();
                DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, senderIP, senderPort);
                socket.send(sendPacket);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### 3.2. Phía Người gửi (UDPClient.java)
Người gửi không cần bind port cố định (hệ điều hành sẽ tự cấp), chỉ cần biết đích đến.

```java
import java.io.*;
import java.net.*;
import java.util.Scanner;

public class UDPClient {
    public static void main(String[] args) {
        String serverHost = "localhost";
        int serverPort = 9876;

        try (DatagramSocket socket = new DatagramSocket();
             Scanner scanner = new Scanner(System.in)) {

            InetAddress serverIP = InetAddress.getByName(serverHost);
            byte[] receiveBuffer = new byte[1024];

            System.out.println("Đã sẵn sàng gửi tin nhắn qua UDP...");
            while (true) {
                System.out.print("Client: ");
                String message = scanner.nextLine();
                if ("exit".equalsIgnoreCase(message)) break;

                // 1. Đóng gói dữ liệu
                byte[] sendData = message.getBytes();
                DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, serverIP, serverPort);

                // 2. Bắn đi
                socket.send(sendPacket);

                // 3. Chờ phản hồi (Nếu Server có gửi lại)
                DatagramPacket receivePacket = new DatagramPacket(receiveBuffer, receiveBuffer.length);
                socket.receive(receivePacket);
                String response = new String(receivePacket.getData(), 0, receivePacket.getLength());
                System.out.println("Server: " + response);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## 4. UDP Broadcast (Gửi quảng bá)

Một tính năng mạnh mẽ của UDP mà TCP khó làm được là **Broadcast**. Bạn có thể gửi 1 tin nhắn duy nhất và tất cả các máy tính trong cùng mạng LAN đều nhận được.

Để làm điều này, bạn chỉ cần thay đổi địa chỉ IP đích thành địa chỉ Broadcast của mạng (thường là `255.255.255.255` hoặc địa chỉ cuối cùng của dải mạng, ví dụ `192.168.1.255`).

**Code thay đổi ở phía Sender:**
```java
socket.setBroadcast(true); // Bắt buộc bật cờ Broadcast
InetAddress broadcastIP = InetAddress.getByName("255.255.255.255");
DatagramPacket packet = new DatagramPacket(data, data.length, broadcastIP, 9876);
socket.send(packet);
```

Ứng dụng: Dùng để server "quảng cáo" sự hiện diện của mình (Service Discovery). Ví dụ: Khi bạn mở app tìm máy in trong mạng LAN, app sẽ bắn gói UDP Broadcast hỏi "Ai là máy in?", và các máy in sẽ trả lời lại.

## 5. Kết luận

UDP là công cụ tuyệt vời khi bạn cần tốc độ và hiệu suất, chấp nhận hy sinh một chút độ tin cậy.
* **TCP:** Chat, gửi file, web (cần chính xác).
* **UDP:** Gọi video, game, stream nhạc (cần nhanh).

Tuy nhiên, trong các bài trước (Bài 6) và bài này, Server của chúng ta mới chỉ phục vụ được **1 người tại 1 thời điểm** (do cơ chế Blocking I/O). Trong bài tiếp theo (Bài 8), chúng ta sẽ giải quyết vấn đề này bằng **Đa luồng (Multithreading)** để Server có thể tiếp hàng ngàn Client cùng lúc.

---

## Tài liệu tham khảo
1.  Oracle Java Docs. "DatagramSocket & DatagramPacket".
2.  Baeldung. "UDP in Java".
3.  Giáo trình Lập trình mạng - Hutech.