#!/bin/bash

# Script triển khai hệ thống quản lý cửa hàng điện thoại
# Từ GitHub: https://github.com/Rouyea/Erp-DT

# Kiểm tra quyền root
if [ "$(id -u)" != "0" ]; then
   echo "Script này cần chạy với quyền root. Hãy sử dụng sudo!" 1>&2
   exit 1
fi

# Cài đặt các phụ thuộc
echo "⚙️ Đang cài đặt các gói cần thiết..."
apt update -y
apt install -y nginx wget git

# Tạo thư mục ứng dụng
echo "⚙️ Đang thiết lập ứng dụng..."
mkdir -p /var/www/phone_store/html
cd /var/www/phone_store/html

# Tải file HTML từ GitHub
echo "⚙️ Đang tải file từ GitHub..."
wget https://raw.githubusercontent.com/Rouyea/Erp-DT/main/Index.html -O index.html

# Kiểm tra xem tải file có thành công không
if [ ! -f "index.html" ]; then
    echo "❌ Lỗi: Không thể tải file từ GitHub. Vui lòng kiểm tra URL và thử lại."
    exit 1
fi

# Tải file CSS nếu có
wget https://raw.githubusercontent.com/Rouyea/Erp-DT/main/styles.css -O styles.css || true
# Tải file JS nếu có
wget https://raw.githubusercontent.com/Rouyea/Erp-DT/main/scripts.js -O scripts.js || true

# Cấu hình Nginx
echo "⚙️ Đang cấu hình Nginx..."
cat > /etc/nginx/sites-available/phone_store << 'NGINX'
server {
    listen 80;
    server_name 103.45.234.45;
    
    root /var/www/phone_store/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Bật nén gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_min_length 1000;
    gzip_proxied any;
    
    # Cache tài nguyên tĩnh
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 365d;
    }
    
    # Cấu hình bảo mật
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # Chỉ định charset UTF-8
    charset utf-8;
    
    # Cấu hình cho phép truy cập từ các thiết bị di động
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
}
NGINX

# Kích hoạt cấu hình Nginx
ln -s /etc/nginx/sites-available/phone_store /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Cấu hình bổ sung
echo "⚙️ Đang tối ưu hóa hiệu suất..."
sed -i 's/# server_tokens off;/server_tokens off;/g' /etc/nginx/nginx.conf
echo "client_max_body_size 100M;" >> /etc/nginx/nginx.conf
echo "server_names_hash_bucket_size 128;" >> /etc/nginx/nginx.conf

# Cấp quyền
chown -R www-data:www-data /var/www/phone_store/html
chmod -R 755 /var/www/phone_store

# Mở firewall
echo "⚙️ Đang cấu hình firewall..."
ufw allow 'Nginx HTTP'
ufw --force enable

# Khởi động lại Nginx
systemctl restart nginx

# Hiển thị thông báo hoàn thành
echo ""
echo "✨✨✨ TRIỂN KHAI THÀNH CÔNG ✨✨✨"
echo "----------------------------------------"
echo "Hệ thống Quản lý Cửa hàng Điện thoại đã được triển khai"
echo "Truy cập ngay: http://103.45.234.45"
echo ""
echo "Thông tin hệ thống:"
echo "- Địa chỉ IP: 103.45.234.45"
echo "- Thư mục ứng dụng: /var/www/phone_store/html"
echo "- File chính: /var/www/phone_store/html/index.html"
echo "- File cấu hình Nginx: /etc/nginx/sites-available/phone_store"
echo "----------------------------------------"
echo "Để cập nhật hệ thống, chỉ cần cập nhật file trên GitHub và chạy lại script"
