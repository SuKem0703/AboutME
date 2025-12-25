---
title: "Bài 2: Hàm (Functions) và Cơ chế Xử lý sự kiện"
date: 2025-12-21
draft: false
weight: 3
summary: "Khám phá sức mạnh của First-class Functions, phân tích sâu về Arrow Function (ES6) và cơ chế Callback - nền tảng của lập trình bất đồng bộ."
tags: ["JavaScript", "ES6", "Callback", "Event Handling"]
---

Trong bài trước, chúng ta đã tìm hiểu về cách JavaScript lưu trữ dữ liệu. Ở bài này, chúng ta sẽ tìm hiểu cách JavaScript xử lý logic thông qua Hàm (Functions). Nếu bạn đến từ nền tảng C# hoặc Java, bạn sẽ thấy hàm trong JavaScript linh hoạt một cách đáng ngạc nhiên. Nó không chỉ là một phương thức (method) trong class, mà là một "công dân hạng nhất" (First-class citizen).

## 1. Hàm là "Công dân hạng nhất" (First-class Function)

Trong JavaScript, hàm được coi là một giá trị (value), giống như `Number` hay `String`. Điều này có nghĩa là:
1.  Hàm có thể được gán cho một biến.
2.  Hàm có thể được truyền vào hàm khác như một tham số (Callback).
3.  Hàm có thể được trả về từ một hàm khác (Higher-order Function).

Khả năng này mở ra các mô hình lập trình mạnh mẽ như Functional Programming, nhưng cũng dễ gây bối rối cho người mới bắt đầu về ngữ cảnh thực thi (Execution Context).

## 2. Các cách khai báo hàm và Sự tiến hóa

JavaScript cung cấp nhiều cách để định nghĩa hàm, mỗi cách có hành vi khác nhau về **Hoisting** và từ khóa **`this`**.

### 2.1. Function Declaration (Khai báo truyền thống)

Đây là cách cơ bản nhất, sử dụng từ khóa `function`.

```javascript
function sayHello(name) {
    return "Hello " + name;
}
```

* **Đặc điểm:** Được **Hoisted** (đẩy lên đầu phạm vi). Bạn có thể gọi hàm `sayHello` trước dòng khai báo hàm trong code mà không gặp lỗi.
* **Ngữ cảnh `this`:** Động (Dynamic). Giá trị của `this` phụ thuộc vào *cách hàm được gọi* (gọi trực tiếp, gọi thông qua object, v.v.).

### 2.2. Function Expression (Biểu thức hàm)

Gán một hàm (thường là vô danh - anonymous) cho một biến.

```javascript
const sayHello = function(name) {
    return "Hello " + name;
};
```

* **Đặc điểm:** Không được Hoisted. Nếu bạn gọi biến `sayHello` trước khi gán, chương trình sẽ báo lỗi (ReferenceError hoặc TypeError).
* **Ứng dụng:** Thường dùng khi cần truyền hàm làm tham số hoặc tạo Closure.

### 2.3. Arrow Function (Hàm mũi tên - ES6)

ES6 giới thiệu cú pháp ngắn gọn hơn, loại bỏ từ khóa `function` và `return` (trong trường hợp đơn giản).

```javascript
// Cú pháp đầy đủ
const add = (a, b) => {
    return a + b;
};

// Cú pháp rút gọn (Implicit return)
const multiple = (a, b) => a * b;
```

**Sự khác biệt cốt lõi về `this` (Lexical Scope):**
Trong C# hay Java, `this` luôn trỏ về đối tượng hiện tại. Trong JS truyền thống, `this` hay bị thay đổi ngữ cảnh (context) khi hàm được gọi trong callback.
Arrow Function **không** có `this` của riêng nó. Nó "mượn" `this` từ phạm vi bao quanh nó (Lexical Scope). Điều này giúp sửa lỗi phổ biến khi lập trình sự kiện hoặc gọi API trong class.

Ví dụ minh họa sự khác biệt:

```javascript
const obj = {
    name: "User A",
    
    // Function thường
    printRegular: function() {
        setTimeout(function() {
            // 'this' ở đây bị trôi về Global object hoặc undefined
            console.log("Regular:", this.name); 
        }, 100);
    },

    // Arrow function
    printArrow: function() {
        setTimeout(() => {
            // 'this' được giữ nguyên là obj
            console.log("Arrow:", this.name);
        }, 100);
    }
};

obj.printRegular(); // Kết quả: Regular: undefined
obj.printArrow();   // Kết quả: Arrow: User A
```

## 3. Callback Function và Xử lý sự kiện

Đây là khái niệm quan trọng nhất để chuẩn bị cho bài học về Lập trình bất đồng bộ (Asynchronous).

### 3.1. Callback là gì?

Callback đơn giản là một hàm được truyền vào một hàm khác như một tham số, và sẽ được "gọi lại" (executed) tại một thời điểm nào đó sau này.

```javascript
function processData(data, callback) {
    console.log("Đang xử lý dữ liệu: " + data);
    // Sau khi xử lý xong, gọi hàm callback
    callback();
}

processData("File.txt", function() {
    console.log("Đã xử lý xong!");
});
```

### 3.2. Tại sao cần Callback?

JavaScript là ngôn ngữ **đơn luồng (Single-threaded)**. Nó chỉ có một Call Stack để thực thi code. Nếu một tác vụ nặng (như đọc file, request mạng) chạy đồng bộ, nó sẽ chặn (block) toàn bộ giao diện, khiến web bị "đơ".

Để giải quyết, JS sử dụng mô hình **Bất đồng bộ (Asynchronous)** dựa trên Callback và Event Loop.
1.  Khi gặp sự kiện (click chuột, timer, request mạng), JS gửi tác vụ đó cho Web API xử lý nền.
2.  JS tiếp tục chạy các dòng code tiếp theo mà không chờ đợi.
3.  Khi tác vụ nền hoàn thành, Callback của nó được đẩy vào hàng đợi (Queue).
4.  Khi Call Stack rảnh, Callback được đưa vào thực thi.

Ví dụ về Event Handling (Xử lý sự kiện):

```javascript
const button = document.getElementById("btn-submit");

// Hàm (e) => {...} là một Callback
// Nó KHÔNG chạy ngay lập tức, mà chỉ chạy khi người dùng click
button.addEventListener("click", (e) => {
    console.log("Button clicked!");
    sendDataToServer();
});
```

## 4. Vấn đề "Callback Hell"

Mặc dù Callback rất mạnh mẽ, nhưng nếu lạm dụng lồng nhau quá nhiều, code sẽ trở nên khó đọc và khó bảo trì. Đây gọi là "Callback Hell" (Địa ngục Callback).

```javascript
// Ví dụ Callback Hell
getData(function(a) {
    getMoreData(a, function(b) {
        getMoreData(b, function(c) {
            getMoreData(c, function(d) {
                console.log(d);
            });
        });
    });
});
```

Để giải quyết vấn đề này, ES6 đã giới thiệu **Promise** và sau đó là **Async/Await** (chúng ta sẽ học kỹ ở Bài 3).

## 5. Tổng kết

* Hàm trong JS là đối tượng (Object), có thể gán, truyền và trả về linh hoạt.
* **Arrow Function** giúp code gọn hơn và giữ ngữ cảnh `this` ổn định, rất phù hợp cho các Callback.
* **Callback** là cơ chế nền tảng để JS xử lý các tác vụ tốn thời gian mà không làm treo giao diện.

Hiểu rõ Callback là chìa khóa để bạn chinh phục các kỹ thuật nâng cao như `fetch` API hay lập trình Socket trong các bài tiếp theo.

---

## Tài liệu tham khảo
1.  MDN Web Docs. "Functions - JavaScript".
2.  MDN Web Docs. "Arrow function expressions".
3.  Cisco Networking Academy. "JavaScript Essentials 1: Functions & Events".
4.  W3Schools. "JavaScript Callbacks".