---
title: "Bài 3: Xử lý Bất đồng bộ - Từ Promise đến Async/Await"
date: 2025-12-21
draft: false
weight: 4
summary: "Giải quyết vấn đề Callback Hell, tìm hiểu cơ chế Promise trong ES6 và cú pháp Async/Await trong ES8 để xử lý các tác vụ mạng hiệu quả."
tags: ["JavaScript", "Async/Await", "Promise", "Network Programming"]
---

Trong lập trình mạng, hầu hết các tác vụ đều là **bất đồng bộ (asynchronous)**. Khi Client gửi một request đến Server, nó không thể biết chắc chắn bao lâu sau Server sẽ phản hồi (vài mili giây hay vài phút).

Nếu dùng tư duy đồng bộ (synchronous) như lập trình C thuần túy, chương trình sẽ bị "đơ" (block) cho đến khi nhận được phản hồi. JavaScript giải quyết vấn đề này bằng cơ chế Event Loop và các mô hình xử lý bất đồng bộ.

## 1. Vấn đề: "Callback Hell"

Ở bài trước, ta đã biết Callback dùng để xử lý kết quả trả về sau một tác vụ. Tuy nhiên, khi các tác vụ phụ thuộc lẫn nhau (Task B cần kết quả của Task A, Task C cần kết quả của Task B...), ta buộc phải lồng các callback vào nhau.

Ví dụ mô phỏng quy trình đăng nhập và lấy dữ liệu người dùng:

```javascript
// Mô hình Callback Hell (Pyramid of Doom)
login(username, password, (user) => {
    console.log("Logged in:", user.id);
    
    getUserDetails(user.id, (details) => {
        console.log("Got details:", details);
        
        getFriends(details.friendListId, (friends) => {
            console.log("Friend list loaded:", friends);
            // Cứ thế lồng tiếp...
        }, (error) => console.error(error));
        
    }, (error) => console.error(error));
    
}, (error) => console.error(error));
```

**Nhược điểm:**
* **Khó đọc:** Code bị thụt lề quá sâu hình tháp.
* **Khó xử lý lỗi:** Phải viết hàm xử lý lỗi cho từng tầng callback riêng biệt.

## 2. Giải pháp 1: Promise (ES6)

ES6 giới thiệu **Promise** - một đối tượng đại diện cho sự hoàn thành (hoặc thất bại) của một tác vụ bất đồng bộ trong tương lai.

### 2.1. Ba trạng thái của Promise
Một Promise luôn ở trong một trong ba trạng thái:
1.  **Pending (Đang chờ):** Trạng thái khởi tạo, chưa có kết quả.
2.  **Fulfilled (Thành công):** Tác vụ hoàn thành, trả về giá trị (value).
3.  **Rejected (Thất bại):** Tác vụ lỗi, trả về lý do (reason/error).

### 2.2. Chaining (Chuỗi hóa)
Promise giúp "làm phẳng" cấu trúc callback bằng phương thức `.then()`.

Ví dụ viết lại quy trình trên bằng Promise:

```javascript
login(username, password)
    .then((user) => {
        console.log("Logged in:", user.id);
        // Return một Promise mới để tiếp tục chuỗi
        return getUserDetails(user.id);
    })
    .then((details) => {
        console.log("Got details:", details);
        return getFriends(details.friendListId);
    })
    .then((friends) => {
        console.log("Friend list loaded:", friends);
    })
    .catch((error) => {
        // Chỉ cần một hàm catch duy nhất cho toàn bộ chuỗi
        console.error("Lỗi xảy ra:", error);
    });
```

Cơ chế này giúp luồng code chạy từ trên xuống dưới, dễ đọc hơn hẳn so với Callback Hell.

## 3. Giải pháp 2: Async/Await (ES8)

Dù Promise đã tốt, nhưng cú pháp `.then()` vẫn còn mang hơi hướng của lập trình hàm. Những lập trình viên quen với C# hay Java mong muốn viết code bất đồng bộ trông giống như code đồng bộ (tuần tự). Đó là lý do **Async/Await** ra đời trong ES2017 (ES8).

### 3.1. Cú pháp
* `async`: Đặt trước khai báo hàm, báo hiệu hàm này sẽ trả về một Promise.
* `await`: Chỉ dùng được trong hàm `async`. Nó tạm dừng việc thực thi hàm cho đến khi Promise được giải quyết (resolve).

### 3.2. Ví dụ chuyển đổi
Đoạn code trên được viết lại bằng Async/Await:

```javascript
async function mainFlow() {
    try {
        // Code chạy tuần tự, trông rất giống C#
        const user = await login(username, password);
        console.log("Logged in:", user.id);

        const details = await getUserDetails(user.id);
        console.log("Got details:", details);

        const friends = await getFriends(details.friendListId);
        console.log("Friend list loaded:", friends);

    } catch (error) {
        // Dùng try/catch truyền thống để bắt lỗi
        console.error("Lỗi xảy ra:", error);
    }
}

mainFlow();
```

### 3.3. So sánh với C#
Nếu bạn đã học C#, bạn sẽ thấy sự tương đồng rất lớn:
* JS `async function` ≈ C# `async Task`.
* JS `await` ≈ C# `await`.
* JS `Promise` ≈ C# `Task`.

Sự khác biệt chính là JavaScript chạy đơn luồng (Single-thread) dựa trên Event Loop, trong khi C# có thể sử dụng đa luồng (Multi-thread) thực sự. Tuy nhiên, về mặt cú pháp và tư duy lập trình, chúng tương tự nhau 90%.

## 4. Thực hành: Giả lập gọi API mạng

Dưới đây là một ví dụ thực tế mô phỏng việc lấy dữ liệu từ Server với độ trễ ngẫu nhiên.

```javascript
// Hàm giả lập gọi Server, trả về Promise
function fetchUserData(userId) {
    return new Promise((resolve, reject) => {
        console.log("Đang kết nối đến Server...");
        
        setTimeout(() => {
            const isSuccess = Math.random() > 0.2; // 80% thành công
            if (isSuccess) {
                resolve({ id: userId, name: "Nguyen Van A", role: "Admin" });
            } else {
                reject("Lỗi 500: Server quá tải!");
            }
        }, 2000); // Giả lập độ trễ 2 giây
    });
}

// Client sử dụng Async/Await
const showProfile = async () => {
    try {
        const data = await fetchUserData(101);
        console.log("Dữ liệu nhận được:", data);
    } catch (err) {
        console.log("Thất bại:", err);
    } finally {
        console.log("Kết thúc phiên làm việc.");
    }
};

showProfile();
```

## 5. Kết luận

* **Callback:** Cơ bản nhưng dễ gây rối rắm (Callback Hell).
* **Promise:** Giải quyết vấn đề lồng nhau, quản lý lỗi tập trung.
* **Async/Await:** Cú pháp hiện đại nhất, giúp code sạch, dễ đọc và dễ bảo trì, đặc biệt phù hợp cho các tác vụ gọi API mạng phức tạp.

Trong bài tiếp theo, chúng ta sẽ áp dụng ngay kiến thức này với **Fetch API** để thực hiện các kết nối mạng thực tế.

---

## Tài liệu tham khảo
1.  MDN Web Docs. "Using Promises".
2.  MDN Web Docs. "async function".
3.  JavaScript.info. "Async/await".
4.  Cisco Networking Academy. "JavaScript Essentials 1: Module 4".