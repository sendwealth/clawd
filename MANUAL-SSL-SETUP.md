# OpenSpark - SSL 证书手动部署指南

> **简单方案**：直接在服务器上运行脚本，无需 GitHub Actions
> **适用场景**：GitHub Actions SSH 配置复杂时使用此方案

---

## 📋 前提条件

### 1. 域名解析

**必须先将域名解析到服务器 IP：**

在腾讯云 DNS 控制台添加 A 记录：
```
记录类型: A
主机记录: openspark
记录值: 你的服务器IP

记录类型: A
主机记录: www
记录值: 你的服务器IP
```

**验证 DNS 解析：**
```bash
# 在本地终端执行
nslookup openspark.online
nslookup www.openspark.online
```

**预期输出：**
```
Server:         你的DNS服务器
Address:        你的DNS服务器IP

Name:   openspark.online
Address: 你的服务器IP
```

---

## 🚀 一键部署步骤

### 第 1 步：SSH 登录服务器

```bash
# 使用你的服务器信息
ssh root@你的服务器IP
# 或
ssh ubuntu@你的服务器IP

# 如果使用自定义 SSH 端口
ssh -p 你的端口 root@你的服务器IP
```

### 第 2 步：下载并运行配置脚本

```bash
# 下载脚本
cd /tmp
curl -O https://raw.githubusercontent.com/sendwealth/clawd/main/ssl-setup-one-click.sh

# 添加执行权限
chmod +x ssl-setup-one-click.sh

# 使用 sudo 运行脚本
sudo bash ssl-setup-one-click.sh
```

### 第 3 步：按照提示填写信息

脚本会依次询问以下信息：

```
请输入域名（默认：openspark.online）: openspark.online
请输入邮箱（默认：sendwealth@163.com）: sendwealth@163.com
前端端口（默认：3000）: 3000
后端端口（默认：8000）: 8000
确认配置无误？(y/n): y
```

**直接按 Enter 使用默认值即可！**

### 第 4 步：等待自动配置

脚本会自动完成以下操作：

1. ✅ 检查域名解析
2. ✅ 更新系统
3. ✅ 安装 Nginx
4. ✅ 安装 Certbot
5. ✅ 配置 Nginx 反向代理
6. ✅ 申请 Let's Encrypt SSL 证书
7. ✅ 配置 HTTPS 自动重定向
8. ✅ 启用 HSTS 安全头
9. ✅ 配置自动续期
10. ✅ 验证部署结果

**预计时间：** 5-10 分钟

---

## ✅ 验证部署

### 1. 检查证书状态

```bash
# 在服务器上执行
sudo certbot certificates
```

**预期输出：**
```
Found the following certs:
  Certificate Name: openspark.online
    Domains: openspark.online www.openspark.online
    Expiry Date: 2026-05-17 (VALID: 90 days)
    Certificate Path: /etc/letsencrypt/live/openspark.online/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/openspark.online/privkey.pem
```

### 2. 测试 HTTPS 访问

**在浏览器中访问：**
- https://openspark.online
- https://www.openspark.online

**预期结果：**
- 浏览器地址栏显示 🔒 图标
- 自动从 HTTP 重定向到 HTTPS
- 无证书警告

**使用 curl 测试（在本地终端）：**
```bash
curl -I https://openspark.online
curl -I https://www.openspark.online
```

**预期输出：**
```
HTTP/2 200
server: nginx
strict-transport-security: max-age=31536000; includeSubDomains
location: https://openspark.online/
```

### 3. SSL 安全评分测试

访问：https://www.ssllabs.com/ssltest/

**目标评分：** A+

---

## 📝 日常维护

### 查看证书信息

```bash
sudo certbot certificates
```

### 手动续期（如需要）

```bash
# 续期证书
sudo certbot renew

# 重启 Nginx
sudo systemctl reload nginx
```

### 测试自动续期

```bash
sudo certbot renew --dry-run
```

### 查看 Nginx 日志

```bash
# 访问日志
sudo tail -f /var/log/nginx/access.log

# 错误日志
sudo tail -f /var/log/nginx/error.log
```

### 重启 Nginx

```bash
sudo systemctl restart nginx
```

---

## 📊 Nginx 配置说明

配置文件位置：`/etc/nginx/sites-available/openspark`

**配置内容：**
```nginx
server {
    listen 80;
    server_name openspark.online www.openspark.online;

    # 前端 (React 应用)
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 后端 API (FastAPI)
    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebSocket
    location /ws {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

**HTTPS 配置（由 Certbot 自动添加）：**
```nginx
server {
    listen 443 ssl;
    server_name openspark.online www.openspark.online;

    # SSL 证书（由 Certbot 配置）
    ssl_certificate /etc/letsencrypt/live/openspark.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/openspark.online/privkey.pem;

    # 安全头（由 Certbot 配置）
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

---

## ⚠️ 常见问题

### 问题 1：域名未解析

**错误信息：**
```
警告：域名未正确解析到此服务器！
```

**解决方法：**
1. 检查 DNS 配置
2. 等待 DNS 生效（可能需要 10 分钟 - 24 小时）
3. 验证 DNS 解析：
   ```bash
   nslookup openspark.online
   ```

### 问题 2：证书申请失败

**错误信息：**
```
The requested openspark.online domain does not appear to be managed by certbot
```

**解决方法：**
1. 确保 DNS 已解析到服务器
2. 确保 80 端口可访问
3. 检查防火墙：
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

### 问题 3：Nginx 配置错误

**错误信息：**
```
Nginx 配置测试失败
```

**解决方法：**
1. 检查端口是否被占用：
   ```bash
   sudo netstat -tlnp | grep :80
   ```
2. 停止占用 80 端口的服务：
   ```bash
   sudo systemctl stop apache2
   ```

### 问题 4：前端或后端服务未启动

**错误信息：**
```
502 Bad Gateway
```

**解决方法：**
1. 检查前端服务（端口 3000）：
   ```bash
   curl http://localhost:3000
   ```
2. 检查后端服务（端口 8000）：
   ```bash
   curl http://localhost:8000/health
   ```
3. 启动 Docker 容器或服务

---

## 🎯 成功标志

部署成功后，你应该看到：

✅ **浏览器显示：**
- 地址栏 🔒 图标
- HTTPS 协议
- 无证书警告

✅ **SSL 评分：** A+

✅ **证书信息：**
```
证书名称: openspark.online
域名: openspark.online www.openspark.online
有效期: 90 天
自动续期: 启用
```

✅ **访问正常：**
- https://openspark.online
- https://www.openspark.online

---

## 📞 获取帮助

如果遇到问题：

1. **查看日志：**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   sudo journalctl -u nginx
   ```

2. **重启服务：**
   ```bash
   sudo systemctl restart nginx
   ```

3. **联系我：** 把错误信息发给我，我会协助解决

---

## 🎉 总结

这个一键配置脚本的优势：

✅ **无需 GitHub Actions**：直接在服务器上运行
✅ **交互式配置**：按照提示填写信息即可
✅ **自动验证**：检查域名解析和端口状态
✅ **彩色输出**：清晰显示每个步骤的状态
✅ **自动续期**：证书每 90 天自动续期
✅ **安全加固**：启用 HSTS 和其他安全头

**现在就可以开始部署了！** 🚀

---

**部署完成后，请访问以下 URL 验证：**
- https://openspark.online
- https://www.openspark.online
- https://www.ssllabs.com/ssltest/ (SSL 安全评分)
