---
title: "Bài 4: JSON và Fetch API - Giao tiếp Client-Server"
date: 2025-12-21
draft: false
weight: 5
summary: "Tìm hiểu cấu trúc JSON, cơ chế Serialization và cách sử dụng Fetch API để thực hiện các yêu cầu HTTP (GET, POST) trong mô hình Client-Server."
tags: ["JSON", "Fetch API", "HTTP", "RESTful"]
---

Trong các bài trước, chúng ta đã học cách xử lý logic bất đồng bộ. Tuy nhiên, một ứng dụng mạng thực thụ cần phải giao tiếp với thế giới bên ngoài: gửi dữ liệu lên Server và nhận kết quả trả về. Để làm được điều này, Client và Server cần thống nhất hai việc:
1.  **Định dạng dữ liệu:** Chúng ta nói chuyện bằng ngôn ngữ gì? (JSON).
2.  **Giao thức vận chuyển:** Chúng ta gửi dữ liệu đi như thế nào? (HTTP/Fetch API).

Bài viết này sẽ giải quyết tường tận hai vấn đề trên.

## 1. JSON (JavaScript Object Notation)

### 1.1. JSON là gì?

JSON là một định dạng hoán đổi dữ liệu văn bản nhẹ (lightweight text-based data interchange format). Mặc dù tên gọi có chữ "JavaScript", JSON hiện nay độc lập với ngôn ngữ và được hỗ trợ bởi hầu hết các ngôn ngữ lập trình (C#, Java, Python, Go...).

Trong lập trình mạng, JSON đóng vai trò là "payload" (hàng hóa) được đóng gói trong các gói tin HTTP để truyền qua lại giữa Client và Server.

### 1.2. Cấu trúc và Quy tắc cú pháp

JSON được xây dựng dựa trên hai cấu trúc:
* Một tập hợp các cặp key/value (tương đương Object trong JS).
* Một danh sách các giá trị có thứ tự (tương đương Array trong JS).

**Quy tắc nghiêm ngặt của JSON:**
1.  Dữ liệu nằm trong các cặp name/value.
2.  Key (tên trường) **bắt buộc** phải đặt trong dấu nháy kép `""`. (Đây là điểm khác biệt lớn nhất so với JS Object).
3.  Chuỗi (String) phải dùng nháy kép `""`. Không được dùng nháy đơn `''`.
4.  Không được phép có dấu phẩy `,` ở phần tử cuối cùng (trailing comma).

Ví dụ một đoạn JSON hợp lệ:

```json
{
  "id": 101,
  "username": "nguyenvana",
  "isActive": true,
  "roles": ["admin", "editor"],
  "metadata": {
    "lastLogin": "2025-12-28T10:00:00Z"
  }
}
```

### 1.3. Serialization và Deserialization

Khi truyền dữ liệu qua mạng (Socket hoặc HTTP), chúng ta chỉ có thể truyền chuỗi văn bản (String) hoặc byte. Chúng ta không thể truyền nguyên cả một Object đang nằm trong bộ nhớ RAM. Do đó, cần có quy trình chuyển đổi:

1.  **Serialization (Tuần tự hóa):** Chuyển Object JavaScript thành chuỗi JSON để gửi đi.
    * Phương thức: `JSON.stringify(object)`
2.  **Deserialization (Giải tuần tự hóa):** Nhận chuỗi JSON từ mạng và chuyển lại thành Object JavaScript để xử lý.
    * Phương thức: `JSON.parse(string)`

Ví dụ:

```javascript
const user = { id: 1, name: "An" };

// 1. Client gửi đi (Serialize)
const dataToSend = JSON.stringify(user);
console.log(typeof dataToSend); // "string" -> '{"id":1,"name":"An"}'

// 2. Server gửi về (Deserialize)
const jsonString = '{"id":2, "name":"Binh"}';
const receivedUser = JSON.parse(jsonString);
console.log(receivedUser.name); // "Binh"
```

## 2. Giao thức HTTP cơ bản

Trước khi dùng Fetch API, cần hiểu Client và Server giao tiếp qua HTTP (Hypertext Transfer Protocol) như thế nào.

Một HTTP Request bao gồm:
* **URL:** Địa chỉ tài nguyên (VD: `https://api.example.com/users`).
* **Method (Phương thức):** Hành động muốn thực hiện.
    * `GET`: Lấy dữ liệu.
    * `POST`: Tạo mới dữ liệu.
    * `PUT`: Cập nhật toàn bộ dữ liệu.
    * `PATCH`: Cập nhật một phần dữ liệu.
    * `DELETE`: Xóa dữ liệu.
* **Headers:** Thông tin bổ sung (VD: `Content-Type: application/json`, `Authorization: Bearer token...`).
* **Body:** Dữ liệu gửi đi (thường là chuỗi JSON), chỉ có trong POST/PUT/PATCH.

## 3. Fetch API

Fetch API là chuẩn mới thay thế cho `XMLHttpRequest` cũ kỹ, cung cấp giao diện lập trình mạnh mẽ và linh hoạt hơn để thao tác với HTTP Pipeline. Fetch sử dụng **Promise** (và tương thích hoàn toàn với Async/Await).

### 3.1. Cú pháp cơ bản

```javascript
fetch(url, options)
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error(error));
```

### 3.2. Quy trình xử lý Response 2 giai đoạn

Một điểm cần lưu ý đặc biệt khi dùng Fetch là nó trả về Promise qua 2 bước:
1.  **Bước 1:** Nhận Headers và trạng thái kết nối (Response Object). Lúc này body chưa được tải về hoàn toàn.
2.  **Bước 2:** Đọc luồng dữ liệu (Stream) từ body và parse nó (thường dùng `.json()` hoặc `.text()`).

Đó là lý do tại sao chúng ta thường thấy 2 lần `await`.

## 4. Thực hành: Client-Server Simulation

Chúng ta sẽ sử dụng `JSONPlaceholder` - một dịch vụ REST API miễn phí để thực hành giả lập.

### 4.1. Kịch bản 1: Lấy danh sách (GET Request)

```javascript
const API_URL = '[https://jsonplaceholder.typicode.com/posts](https://jsonplaceholder.typicode.com/posts)';

async function getPosts() {
    try {
        // Mặc định fetch dùng method GET
        const response = await fetch(API_URL);

        // Kiểm tra mã trạng thái HTTP (200-299 là thành công)
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        // Chuyển đổi stream body sang JSON
        const posts = await response.json();
        
        console.log(`Đã tải ${posts.length} bài viết.`);
        console.log("Bài đầu tiên:", posts[0].title);
        
    } catch (error) {
        console.error("Lỗi tải dữ liệu:", error.message);
    }
}

getPosts();
```

### 4.2. Kịch bản 2: Gửi dữ liệu mới (POST Request)

Khi gửi dữ liệu (POST), chúng ta cần cấu hình tham số `options` kỹ hơn: khai báo method, headers và body.

```javascript
async function createPost(title, body, userId) {
    const newPost = {
        title: title,
        body: body,
        userId: userId
    };

    try {
        const response = await fetch('[https://jsonplaceholder.typicode.com/posts](https://jsonplaceholder.typicode.com/posts)', {
            method: 'POST', // Chỉ định phương thức
            headers: {
                // Báo cho Server biết ta đang gửi JSON
                'Content-Type': 'application/json; charset=UTF-8',
            },
            // Quan trọng: Phải chuyển Object sang chuỗi JSON
            body: JSON.stringify(newPost),
        });

        if (!response.ok) {
            throw new Error('Gửi dữ liệu thất bại');
        }

        const data = await response.json();
        console.log("Đăng bài thành công! ID mới:", data.id);
        
    } catch (error) {
        console.error("Lỗi:", error);
    }
}

createPost("Học Lập trình mạng", "Fetch API rất thú vị", 1);
```

## 5. Các vấn đề thường gặp trong Lập trình mạng

### 5.1. CORS (Cross-Origin Resource Sharing)
Đây là lỗi kinh điển nhất. Trình duyệt có cơ chế bảo mật chặn các request từ domain này (ví dụ `localhost:3000`) sang domain khác (ví dụ `api.server.com`) nếu Server không cho phép.
* **Dấu hiệu:** Console báo lỗi đỏ lòm có chữ "Access-Control-Allow-Origin".
* **Cách sửa:** Cấu hình tại Server (Backend) để cho phép Origin của Client.

### 5.2. Quên Serialize Body
Nếu bạn gửi trực tiếp Object (`body: newPost`) thay vì `JSON.stringify(newPost)`, Server sẽ nhận được dữ liệu rác `[object Object]` và không xử lý được.

### 5.3. Không kiểm tra `response.ok`
Fetch API chỉ reject Promise khi mất mạng (network failure). Nếu Server trả về lỗi 404 hay 500, Fetch vẫn coi là "thành công" (fulfilled). Do đó, lập trình viên phải thủ công kiểm tra `if (!response.ok)`.

## 6. Kết luận

Hiểu về JSON và Fetch API là bạn đã nắm được cách Client "trò chuyện" với Server.
* **JSON** là định dạng tin nhắn.
* **Fetch API** là người đưa thư.

Kiến thức này sẽ được áp dụng trực tiếp khi chúng ta xây dựng ứng dụng Chat Client-Server bằng Java Socket ở các bài sau, nơi bạn sẽ phải tự tay đóng gói chuỗi JSON và gửi qua luồng TCP.

---

## Tài liệu tham khảo
1.  MDN Web Docs. "Fetch API - Web APIs".
2.  MDN Web Docs. "Working with JSON".
3.  JSON.org. "Introducing JSON".
4.  W3Schools. "JSON Data Types".