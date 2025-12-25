---
title: "Bài 9: Java RMI - Bước đệm tới Hệ thống phân tán"
date: 2025-12-25
draft: false
weight: 10
summary: "Khám phá Java RMI (Remote Method Invocation): Cơ chế cho phép gọi phương thức trên máy chủ từ xa như thể đang gọi hàm cục bộ. Tìm hiểu kiến trúc Stub, Skeleton và RMI Registry."
tags: ["Java", "RMI", "Distributed Systems", "RPC"]
---

Trong 8 bài trước, chúng ta đã làm việc với Socket. Mặc dù Socket rất mạnh mẽ, nhưng việc phải tự tay đóng gói dữ liệu (Marshalling) thành dòng byte rồi gửi đi, sau đó bên kia lại phải giải mã (Unmarshalling) rất tốn công sức và dễ sai sót.

Liệu có cách nào để Client gọi một hàm trên Server (ví dụ: `server.tinhTong(5, 10)`) đơn giản như đang gọi hàm trên chính máy mình không? Câu trả lời là **Java RMI**.

## 1. RMI là gì?

RMI (Remote Method Invocation) là một cơ chế cho phép một đối tượng đang chạy trên máy ảo Java này (Client) có thể gọi các phương thức của một đối tượng đang chạy trên máy ảo Java khác (Server).

**Triết lý:** "Làm cho việc gọi xa (remote call) trong suốt như gọi gần (local call)."

## 2. Kiến trúc RMI (Stub và Skeleton)

Để tạo ra sự "ảo thuật" này, RMI sử dụng hai lớp trung gian ẩn bên dưới:

1.  **Stub (Client-side proxy):**
    * Nằm ở phía Client.
    * Khi Client gọi hàm, thực chất là gọi vào Stub.
    * Stub đóng gói tham số, gửi yêu cầu qua mạng đến Server.
2.  **Skeleton (Server-side dispatcher):** (Trong các bản Java mới, Skeleton đã được tích hợp vào hệ thống RMI nhưng khái niệm vẫn còn giá trị).
    * Nằm ở phía Server.
    * Nhận yêu cầu từ mạng, giải mã tham số.
    * Gọi hàm thực sự trên Server Object.
    * Nhận kết quả trả về, đóng gói và gửi ngược lại cho Stub.

**RMI Registry:** Là một cuốn "danh bạ điện thoại". Server đăng ký tên dịch vụ của mình lên đây (ví dụ: "MayTinhToan"). Client tra cứu cái tên này để lấy về Stub tương ứng.

## 3. Quy trình xây dựng ứng dụng RMI

Chúng ta sẽ làm một ví dụ đơn giản: Máy tính cộng trừ nhân chia từ xa.

### Bước 1: Định nghĩa Interface (Remote Interface)
Cả Client và Server đều phải biết Interface này. Nó bắt buộc phải kế thừa `java.rmi.Remote` và mọi phương thức phải ném ra `RemoteException`.

```java
import java.rmi.Remote;
import java.rmi.RemoteException;

public interface CalculatorService extends Remote {
    int add(int a, int b) throws RemoteException;
    int subtract(int a, int b) throws RemoteException;
}
```

### Bước 2: Hiện thực Interface (Server Implementation)
Đây là logic nghiệp vụ thực sự nằm trên Server. Lớp này thường kế thừa `UnicastRemoteObject`.

```java
import java.rmi.server.UnicastRemoteObject;
import java.rmi.RemoteException;

public class CalculatorImpl extends UnicastRemoteObject implements CalculatorService {
    // Constructor bắt buộc phải ném RemoteException
    public CalculatorImpl() throws RemoteException {
        super();
    }

    @Override
    public int add(int a, int b) throws RemoteException {
        System.out.println("Client yêu cầu cộng: " + a + " + " + b);
        return a + b;
    }

    @Override
    public int subtract(int a, int b) throws RemoteException {
        return a - b;
    }
}
```

### Bước 3: Tạo Server và Đăng ký dịch vụ

```java
import java.rmi.registry.LocateRegistry;
import java.rmi.Naming;

public class RMIServer {
    public static void main(String[] args) {
        try {
            // 1. Khởi tạo Registry tại port 1099 (Port mặc định của RMI)
            LocateRegistry.createRegistry(1099);

            // 2. Tạo đối tượng dịch vụ
            CalculatorService service = new CalculatorImpl();

            // 3. Đăng ký tên dịch vụ vào danh bạ
            Naming.rebind("rmi://localhost:1099/MyCalculator", service);

            System.out.println("RMI Server đang chạy...");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### Bước 4: Tạo Client để gọi hàm

```java
import java.rmi.Naming;

public class RMIClient {
    public static void main(String[] args) {
        try {
            // 1. Tra cứu dịch vụ trong danh bạ
            // Kết quả trả về thực chất là cái STUB
            CalculatorService stub = (CalculatorService) Naming.lookup("rmi://localhost:1099/MyCalculator");

            // 2. Gọi hàm như thể nó đang ở local
            int sum = stub.add(10, 20);
            System.out.println("Kết quả cộng: " + sum);

            int sub = stub.subtract(50, 15);
            System.out.println("Kết quả trừ: " + sub);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## 4. So sánh Socket vs RMI

| Tiêu chí | Java Socket | Java RMI |
| :--- | :--- | :--- |
| **Mức độ** | Thấp (Low-level) | Cao (High-level) |
| **Giao thức** | TCP/UDP thuần túy | JRMP (Java Remote Method Protocol) |
| **Dữ liệu** | Phải tự đóng gói (byte/text) | Tự động đóng gói Object |
| **Hiệu năng** | Cao hơn (do ít overhead) | Thấp hơn một chút |
| **Đa ngôn ngữ** | Dễ dàng (Java nói chuyện với C# được) | Khó (Chỉ Java nói chuyện với Java) |

## 5. Kết luận và Hướng phát triển

RMI là bước tiến lớn giúp lập trình viên thoát khỏi sự phức tạp của Socket. Tuy nhiên, do hạn chế chỉ dùng được trong môi trường Java thuần túy, ngày nay RMI ít được dùng trực tiếp.

Thay vào đó, thế giới đã chuyển sang các chuẩn mở hơn nhưng có tư tưởng tương tự RMI:
* **Web Services (SOAP/REST):** Dùng HTTP và XML/JSON, cho phép mọi ngôn ngữ giao tiếp với nhau.
* **gRPC (Google):** Hiệu năng cực cao, dùng Protobuf.

Tuy nhiên, hiểu RMI chính là hiểu nền tảng của mọi hệ thống phân tán (Distributed Systems) hiện đại.

---

## Tài liệu tham khảo
1.  Oracle Java Docs. "Java RMI Tutorial".
2.  GeeksforGeeks. "Remote Method Invocation in Java".
3.  Giáo trình Lập trình mạng - Hutech.