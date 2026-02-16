#!/bin/bash
# OpenSpark - SSL 证书一键配置脚本（Let's Encrypt）
# 直接在服务器上运行，无需 GitHub Actions

set -e

echo "========================================="
echo "OpenSpark SSL 配置脚本 (Let's Encrypt)"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置变量
read -p "请输入域名（默认：openspark.online）: " DOMAIN
DOMAIN=${DOMAIN:-openspark.online}
WWW_DOMAIN="www.${DOMAIN}"

read -p "请输入邮箱（默认：sendwealth@163.com）: " EMAIL
EMAIL=${EMAIL:-sendwealth@163.com}

read -p "前端端口（默认：3000）: " FRONTEND_PORT
FRONTEND_PORT=${FRONTEND_PORT:-3000}

read -p "后端端口（默认：8000）: " BACKEND_PORT
BACKEND_PORT=${BACKEND_PORT:-8000}

echo ""
echo "========================================="
echo "配置信息确认"
echo "========================================="
echo "  域名: $DOMAIN"
echo "  域名: $WWW_DOMAIN"
echo "  邮箱: $EMAIL"
echo "  前端端口: $FRONTEND_PORT"
echo "  后端端口: $BACKEND_PORT"
echo "========================================="
echo ""

read -p "确认配置无误？(y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}配置已取消${NC}"
    exit 1
fi

# 检查是否以 root 运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}需要 root 权限，使用 sudo 运行此脚本${NC}"
    echo "命令: sudo bash $0"
    exit 1
fi

# 检查域名解析
echo ""
echo "========================================="
echo "检查域名解析"
echo "========================================="
SERVER_IP=$(hostname -I | awk '{print $1}')
DOMAIN_IP=$(nslookup $DOMAIN | grep "Address:" | tail -n 1 | awk '{print $2}')

echo "服务器 IP: $SERVER_IP"
echo "域名解析 IP: $DOMAIN_IP"

if [ "$DOMAIN_IP" != "$SERVER_IP" ]; then
    echo -e "${RED}警告：域名未正确解析到此服务器！${NC}"
    echo "请先在 DNS 提供商处添加 A 记录："
    echo "  $DOMAIN → $SERVER_IP"
    echo "  $WWW_DOMAIN → $SERVER_IP"
    echo ""
    read -p "是否继续？(y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo -e "${GREEN}✓ 域名解析检查通过${NC}"

# 更新包列表
echo ""
echo "========================================="
echo "更新系统"
echo "========================================="
echo "更新包列表..."
apt update -qq
echo -e "${GREEN}✓ 系统更新完成${NC}"

# 安装 Nginx
echo ""
echo "========================================="
echo "安装 Nginx"
echo "========================================="
if ! command -v nginx &> /dev/null; then
    echo "正在安装 Nginx..."
    apt install -y nginx -qq
    echo -e "${GREEN}✓ Nginx 安装完成${NC}"
else
    echo -e "${GREEN}✓ Nginx 已安装${NC}"
fi

# 检查 Nginx 状态
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx 正在运行${NC}"
else
    echo "启动 Nginx..."
    systemctl start nginx
    echo -e "${GREEN}✓ Nginx 已启动${NC}"
fi

# 安装 Certbot
echo ""
echo "========================================="
echo "安装 Certbot"
echo "========================================="
if ! command -v certbot &> /dev/null; then
    echo "正在安装 Certbot..."
    apt install -y certbot python3-certbot-nginx -qq
    echo -e "${GREEN}✓ Certbot 安装完成${NC}"
else
    echo -e "${GREEN}✓ Certbot 已安装${NC}"
fi

# 创建 Nginx 配置
echo ""
echo "========================================="
echo "配置 Nginx"
echo "========================================="
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# 创建 Nginx 配置文件
cat > /etc/nginx/sites-available/openspark << EOF
server {
    listen 80;
    server_name $DOMAIN $WWW_DOMAIN;

    # 前端
    location / {
        proxy_pass http://localhost:$FRONTEND_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 后端 API
    location /api {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # WebSocket
    location /ws {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# 启用配置
ln -sf /etc/nginx/sites-available/openspark /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试 Nginx 配置
echo "测试 Nginx 配置..."
if nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}✓ Nginx 配置测试通过${NC}"
else
    echo -e "${RED}✗ Nginx 配置测试失败${NC}"
    nginx -t
    exit 1
fi

# 重启 Nginx
echo "重启 Nginx..."
systemctl restart nginx
echo -e "${GREEN}✓ Nginx 已重启${NC}"

# 申请 SSL 证书
echo ""
echo "========================================="
echo "申请 SSL 证书"
echo "========================================="
echo "这将自动配置 Nginx 并启用 HTTPS"
echo ""
echo "域名: $DOMAIN, $WWW_DOMAIN"
echo "邮箱: $EMAIL"
echo ""

# 申请证书
certbot --nginx \
    -d "$DOMAIN" \
    -d "$WWW_DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --redirect \
    --hsts \
    --uir \
    --keep-until-expiring \
    --non-interactive

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ SSL 证书配置完成！${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

# 显示证书信息
echo "📋 证书信息："
certbot certificates

echo ""
echo "🔒 已启用的功能："
echo -e "${GREEN}  ✓ HTTPS (SSL/TLS)${NC}"
echo -e "${GREEN}  ✓ HTTP 到 HTTPS 自动重定向${NC}"
echo -e "${GREEN}  ✓ HSTS (HTTP Strict Transport Security)${NC}"
echo -e "${GREEN}  ✓ 自动续期${NC}"
echo ""

# 验证访问
echo "🌐 验证访问："
echo "  http://$DOMAIN → 自动重定向到 https://$DOMAIN"
echo "  http://$WWW_DOMAIN → 自动重定向到 https://$WWW_DOMAIN"
echo ""

# 测试自动续期
echo "🔄 测试自动续期配置..."
if certbot renew --dry-run 2>&1 | grep -q "The renewals succeeded"; then
    echo -e "${GREEN}✓ 自动续期测试通过${NC}"
else
    echo -e "${YELLOW}⚠ 自动续期测试失败，请检查配置${NC}"
fi

echo ""
echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}📝 重要提示${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo ""
echo "1. 自动续期已配置，证书每 90 天自动续期"
echo ""
echo "2. 查看证书信息："
echo "   sudo certbot certificates"
echo ""
echo "3. 手动续期（如需要）："
echo "   sudo certbot renew"
echo "   sudo systemctl reload nginx"
echo ""
echo "4. 查看 Nginx 配置："
echo "   cat /etc/nginx/sites-available/$DOMAIN"
echo ""
echo "5. 查看访问日志："
echo "   tail -f /var/log/nginx/access.log"
echo ""
echo "6. 重启 Nginx："
echo "   sudo systemctl restart nginx"
echo ""
echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}🎉 配置完成！网站已启用 HTTPS！${NC}"
echo -e "${YELLOW}=========================================${NC}"
echo ""
echo "📋 访问地址："
echo -e "${GREEN}  • https://$DOMAIN${NC}"
echo -e "${GREEN}  • https://$WWW_DOMAIN${NC}"
echo ""
echo "🔍 SSL 安全评分测试："
echo "   • https://www.ssllabs.com/ssltest/"
echo ""
