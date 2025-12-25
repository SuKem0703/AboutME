# --- Stage 1: Build website với Hugo ---
# Sử dụng phiên bản "extended" để hỗ trợ tốt nhất cho PaperMod (xử lý SCSS/Assets)
FROM klakegg/hugo:ext-alpine AS builder

# Đặt thư mục làm việc
WORKDIR /src

# Copy toàn bộ code vào container
COPY . .

# Chạy lệnh build (tối ưu hóa code với --minify)
# Render sẽ tự nhận baseURL từ file hugo.toml của bạn
RUN hugo --minify

# --- Stage 2: Chạy Web Server với Nginx ---
FROM nginx:alpine

# Copy file cấu hình Nginx (ta sẽ tạo ở bước 2) vào vị trí mặc định
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy kết quả build từ Stage 1 sang thư mục chạy web của Nginx
COPY --from=builder /src/public /usr/share/nginx/html

# Mở port 80 cho web
EXPOSE 80

# Khởi chạy Nginx
CMD ["nginx", "-g", "daemon off;"]