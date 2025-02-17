# SSH & Git Management Tools

Bộ công cụ quản lý SSH tunnels và Git hooks, giúp tự động hóa quy trình phát triển và theo dõi.

## Cấu trúc dự án

.
├── ssh/
│   ├── auto_docker_tunnel.sh
│   ├── list_tunnels.sh 
│   ├── start_ssh_tunnel.sh
│   └── stop_ssh_tunnels.sh
├── git-hooks/
│   ├── post-commit
│   ├── pre-push
│   ├── prepare-commit-msg
│   └── send_git_log.sh
└── base/
    ├── colors.sh
    └── helper.sh

## Tính năng chính

### 1. Quản lý SSH Tunnels

- **auto_docker_tunnel.sh**: Tự động tạo SSH tunnels cho các container Docker
- **list_tunnels.sh**: Hiển thị danh sách các SSH tunnels đang hoạt động
- **start_ssh_tunnel.sh**: Tạo SSH tunnel mới
- **stop_ssh_tunnels.sh**: Dừng SSH tunnels

### 2. Git Hooks

- **post-commit**: Tự động ghi log sau mỗi commit
- **pre-push**: Thông báo push events
- **prepare-commit-msg**: Kiểm tra format commit message
- **send_git_log.sh**: Gửi báo cáo commit

## Ví dụ sử dụng chi tiết

### SSH Tunnels

1. Tạo tunnel cho container Docker:

bash
Tạo tunnel cho container MySQL
./ssh/auto_docker_tunnel.sh mysql-container 3306
Kết quả:
✓ Created tunnel: localhost:3306 -> mysql-container:3306

2. Liệt kê tunnels đang chạy:
bash
./ssh/list_tunnels.sh
Kết quả:
PID LOCAL REMOTE STATUS
1234 3306 mysql:3306 ACTIVE
5678 8080 node:8080 ACTIVE

3. Tạo SSH tunnel tùy chỉnh:
bash
./ssh/start_ssh_tunnel.sh
Interactive prompt:
Select host (1-5):
1) dev-server
2) staging-server
3) prod-server
Enter local port: 8080
Enter remote port: 80

4. Dừng tunnel cụ thể:
bash
./ssh/stop_ssh_tunnels.sh 1234 # Dừng theo PID
./ssh/stop_ssh_tunnels.sh all # Dừng tất cả

### Git Hooks

1. Commit với conventional format:
bash
git commit -m "feat: add new login feature" # Hợp lệ
git commit -m "updated stuff" # Không hợp lệ, sẽ hiện hướng dẫn

2. Gửi báo cáo commit:
bash
./git-hooks/send_git_log.sh
Kết quả:
Sending commit log to Discord...
✓ Report sent successfully
Summary: 5 commits by 2 authors

## Xử lý sự cố (Troubleshooting)

### SSH Tunnels

1. **Tunnel không thể tạo được**
   - Kiểm tra quyền truy cập SSH: `ssh -T user@host`
   - Kiểm tra port đã được sử dụng: `lsof -i :port`
   - Đảm bảo container đang chạy: `docker ps`

2. **Tunnel bị ngắt kết nối**
   - Kiểm tra kết nối mạng
   - Thử tăng ServerAliveInterval trong ~/.ssh/config
   - Kiểm tra logs: `journalctl -u ssh`

3. **Permission denied**
   - Kiểm tra quyền thực thi của scripts: `chmod +x *.sh`
   - Kiểm tra SSH key: `ssh-add -l`

### Git Hooks

1. **Hook không tự động chạy**
   - Kiểm tra quyền thực thi: `chmod +x .git/hooks/*`
   - Kiểm tra tên file hook đúng chuẩn
   - Đảm bảo hook được copy vào `.git/hooks/`

2. **Discord webhook không hoạt động**
   - Kiểm tra webhook URL trong config
   - Kiểm tra kết nối internet
   - Xem logs của curl request

3. **Lỗi format commit message**
   - Xem lại hướng dẫn conventional commits
   - Sử dụng `git commit --amend` để sửa
   - Kiểm tra cấu hình trong prepare-commit-msg

## Đóng góp

### Quy trình đóng góp

1. Fork repository
2. Tạo branch mới: `git checkout -b feature/ten-tinh-nang`
3. Commit changes: `git commit -m "feat: mô tả tính năng"`
4. Push to branch: `git push origin feature/ten-tinh-nang`
5. Tạo Pull Request

### Hướng dẫn code

1. **Shell Script Style**
   - Sử dụng shellcheck để kiểm tra code
   - Thêm comments cho các hàm phức tạp
   - Sử dụng meaningful variable names

2. **Testing**
   - Thêm test cases cho tính năng mới
   - Đảm bảo không break existing features
   - Test trên nhiều môi trường khác nhau

3. **Documentation**
   - Cập nhật README.md
   - Thêm comments trong code
   - Tạo examples cho tính năng mới

### Báo cáo lỗi

- Sử dụng GitHub Issues
- Cung cấp chi tiết về môi trường
- Mô tả các bước tái hiện lỗi
- Đính kèm logs nếu có

## Yêu cầu hệ thống

- Bash 4.0+
- Git
- SSH client
- jq (cho xử lý JSON)
- curl (cho Discord webhooks)
- Docker (cho auto_docker_tunnel)

## License

[MIT License](LICENSE)

## Liên hệ

Nếu bạn có câu hỏi hoặc góp ý, vui lòng:
- Tạo issue trên GitHub
- Gửi email tới: [your-email@example.com]
- Tham gia Discord server: [link]