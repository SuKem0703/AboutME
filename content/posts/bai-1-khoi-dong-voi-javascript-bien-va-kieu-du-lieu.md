---
title: "Bài 1: Khởi động với JavaScript - Biến và Kiểu dữ liệu"
date: 2025-12-25
draft: false
weight: 2
summary: "Phân tích chuyên sâu về cơ chế quản lý bộ nhớ, dynamic typing, Scope Chain và sự tiến hóa từ ES5 (var) sang ES6 (let, const) trong JavaScript."
tags: ["JavaScript", "Frontend", "CS Fundamentals"]
---

Trong ngữ cảnh của môn Lập trình mạng, việc hiểu rõ JavaScript không chỉ dừng lại ở việc tạo hiệu ứng trên giao diện web. JavaScript ngày nay đóng vai trò quan trọng trong việc xử lý dữ liệu JSON, giao tiếp API bất đồng bộ và thậm chí là lập trình phía Server (Node.js). Bài viết này sẽ phân tích nền tảng cốt lõi của ngôn ngữ: Biến và Kiểu dữ liệu dưới góc độ khoa học máy tính.

## 1. Tổng quan về JavaScript và ECMAScript

JavaScript (JS) là một ngôn ngữ lập trình kịch bản (scripting language), thông dịch (interpreted), và hỗ trợ đa mô hình (multi-paradigm): hướng sự kiện, hướng chức năng và hướng đối tượng (prototype-based).

Khác với các ngôn ngữ biên dịch tĩnh (statically compiled) như Java hay C# - nơi mã nguồn phải được biên dịch thành bytecode hoặc mã máy trước khi chạy, JavaScript thường được thực thi bởi một trình thông dịch (engine) ngay tại thời điểm chạy (runtime). Các engine nổi tiếng bao gồm V8 (Google Chrome, Node.js), SpiderMonkey (Firefox) và JavaScriptCore (Safari).

Tiêu chuẩn kỹ thuật của JavaScript được gọi là ECMAScript (viết tắt là ES). Sự ra đời của ES6 (ECMAScript 2015) là một bước ngoặt lớn, mang lại các tính năng hiện đại giúp việc quản lý code trở nên chặt chẽ hơn.

## 2. Biến và Phạm vi (Scope)

Biến trong lập trình là tên gọi tượng trưng cho một vùng nhớ máy tính nơi lưu trữ giá trị. Trong JavaScript, cách chúng ta khai báo biến sẽ quyết định "vòng đời" và "phạm vi truy cập" của biến đó.

### 2.1. Cơ chế Hoisting và từ khóa `var`

Trước phiên bản ES6, `var` là cách duy nhất để khai báo biến. Tuy nhiên, `var` tồn tại nhiều vấn đề liên quan đến cơ chế **Hoisting**.

Hoisting là hành vi mặc định của JavaScript, trong đó việc khai báo biến (declaration) được đưa lên đầu phạm vi (scope) của nó trước khi code được thực thi.

Ví dụ:

```javascript
console.log(x); // Kết quả: undefined (Không báo lỗi)
var x = 5;
```

Trong ví dụ trên, trình biên dịch hiểu đoạn code như sau:
1. `var x;` (Đưa lên đầu, khởi tạo giá trị mặc định là undefined).
2. `console.log(x);`
3. `x = 5;`

Điều này gây ra sự khó hiểu và các lỗi tiềm ẩn (bug) khó phát hiện. Ngoài ra, `var` có phạm vi là **Function Scope** (phạm vi hàm), nghĩa là nếu khai báo trong một khối lệnh `if` hoặc `for`, biến đó vẫn rò rỉ ra ngoài khối lệnh.

### 2.2. Sự ra đời của `let` và `const` (Block Scope)

ES6 giới thiệu `let` và `const` để khắc phục nhược điểm của `var`. Cả hai từ khóa này đều tuân thủ **Block Scope** (Phạm vi khối), nghĩa là biến chỉ tồn tại trong cặp ngoặc nhọn `{}` bao quanh nó.

#### Temporal Dead Zone (TDZ)
Khác với `var`, biến khai báo bằng `let` và `const` cũng được hoisting nhưng chúng rơi vào trạng thái "Vùng chết tạm thời" (TDZ). Nếu truy cập trước khi khai báo, chương trình sẽ báo lỗi `ReferenceError` thay vì trả về `undefined`.

#### Phân biệt let và const
* `let`: Cho phép gán lại giá trị (Reassignable). Dùng cho các biến đếm, biến tích lũy.
* `const`: Không cho phép gán lại giá trị (Immutable binding). Tuy nhiên, cần lưu ý với kiểu dữ liệu đối tượng (Object), `const` chỉ ngăn cản việc gán biến sang một địa chỉ bộ nhớ khác, chứ không ngăn cản việc thay đổi thuộc tính bên trong đối tượng đó.

Ví dụ minh họa:

```javascript
const student = { name: "An", age: 20 };
student.age = 21; // Hợp lệ (Thay đổi giá trị tại vùng nhớ Heap)
// student = { name: "Binh" }; // Báo lỗi: Assignment to constant variable.
```

## 3. Hệ thống Kiểu dữ liệu (Data Types)

JavaScript là ngôn ngữ **Dynamic Typing** (Kiểu động), nghĩa là biến không bị ràng buộc kiểu dữ liệu, chỉ có giá trị mới có kiểu. Theo tiêu chuẩn ECMAScript mới nhất, có 8 kiểu dữ liệu chia làm 2 nhóm chính.

### 3.1. Kiểu dữ liệu nguyên thủy (Primitive Types)

Các kiểu dữ liệu này được lưu trữ trực tiếp trong vùng nhớ **Stack** (Ngăn xếp), có kích thước cố định và truy xuất nhanh.

1.  **Undefined**: Một biến đã khai báo nhưng chưa được gán giá trị.
2.  **Null**: Đại diện cho một giá trị rỗng hoặc không tồn tại một cách có chủ đích. (Lưu ý: `typeof null` trả về `'object'` do một lỗi lịch sử của JS).
3.  **Boolean**: Chỉ có hai giá trị `true` hoặc `false`.
4.  **Number**: Trong JS, tất cả các số (nguyên hay thực) đều là số thực dấu phẩy động 64-bit (IEEE 754). Điều này dẫn đến sai số khi tính toán thập phân (Ví dụ: `0.1 + 0.2 !== 0.3`).
5.  **String**: Chuỗi ký tự, bất biến (immutable).
6.  **Symbol** (ES6): Giá trị duy nhất, thường dùng làm key cho Object để tránh xung đột.
7.  **BigInt** (ES2020): Dùng để lưu trữ các số nguyên lớn vượt quá giới hạn an toàn của kiểu Number (`2^53 - 1`).

### 3.2. Kiểu dữ liệu tham chiếu (Reference Types)

Bao gồm **Object**, **Array**, **Function**, **Date**, **RegExp**.
Các kiểu này được lưu trữ trong vùng nhớ **Heap** (Vùng nhớ động). Biến chỉ lưu địa chỉ tham chiếu (memory address) trỏ đến vùng nhớ đó trong Heap.

Sự khác biệt quan trọng giữa tham chiếu và nguyên thủy thể hiện khi sao chép biến:

```javascript
// Nguyên thủy (Copy giá trị)
let a = 10;
let b = a;
b = 20;
// Kết quả: a = 10 (Không đổi)

// Tham chiếu (Copy địa chỉ)
let obj1 = { value: 10 };
let obj2 = obj1;
obj2.value = 20;
// Kết quả: obj1.value = 20 (Bị thay đổi theo)
```

## 4. Dynamic Typing và Type Coercion (Ép kiểu)

Sự linh hoạt của JavaScript đến từ việc nó tự động chuyển đổi kiểu dữ liệu (Type Coercion) khi cần thiết.

### 4.1. Implicit Coercion (Ép kiểu ngầm định)
Trình thông dịch tự động chuyển đổi kiểu để thực hiện phép toán.
* Chuỗi + Số = Chuỗi: `'5' + 1` kết quả là `'51'`.
* Chuỗi - Số = Số: `'5' - 1` kết quả là `4`.

### 4.2. Explicit Coercion (Ép kiểu tường minh)
Lập trình viên chủ động chuyển đổi kiểu để tránh lỗi logic.
* `Number('5')` -> 5
* `String(123)` -> '123'
* `Boolean(1)` -> true

Trong lập trình mạng, khi nhận dữ liệu từ API (thường ở dạng JSON string), việc ép kiểu tường minh là bắt buộc để đảm bảo tính toàn vẹn dữ liệu trước khi xử lý logic nghiệp vụ.

## 5. Kết luận

Hiểu sâu về cách JavaScript quản lý bộ nhớ thông qua các loại biến và kiểu dữ liệu giúp lập trình viên tránh được những lỗi phổ biến như tham chiếu vòng, rò rỉ bộ nhớ (memory leak) hay sai lệch tính toán.

Trong bài tiếp theo, chúng ta sẽ áp dụng các kiểu dữ liệu này vào cấu trúc **Hàm (Function)** và tìm hiểu về **Cơ chế xử lý sự kiện**, nền tảng cho lập trình bất đồng bộ sau này.

---

## Tài liệu tham khảo

1.  Mozilla Developer Network (MDN). "JavaScript Data Structures". Truy cập ngày 25/12/2025.
2.  ECMA International. "ECMAScript 2015 Language Specification (ES6)".
3.  W3Schools. "JavaScript Variables, Let and Const".
4.  Cisco Networking Academy. "JavaScript Essentials 1 Course Materials".
5.  Kyle Simpson. "You Don't Know JS: Types & Grammar". O'Reilly Media.