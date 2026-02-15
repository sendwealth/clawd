# GitHub Actions 部署配置说明

## 📋 需要配置的 GitHub Secrets

访问：https://github.com/sendwealth/clawd/settings/secrets/actions

### 必需的 Secrets

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `SERVER_HOST` | 服务器 IP 地址 | `123.456.789.0` |
| `SERVER_USER` | SSH 登录用户名 | `root` 或 `ubuntu` |
| `SSH_PRIVATE_KEY` | SSH 私钥（完整内容，包括 BEGIN/END 行） | 见下方 |
| `SSH_PORT` | SSH 端口 | `22`（默认） |
| `ZHIPUAI_API_KEY` | 智谱 AI API Key | `818473db986a4583aae63b3120adbab7.s8uKoMk5wSykoHGO` |

### SSH_PRIVATE_KEY 值

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACD3HHrQ8iAyrLDPAKcPB8x3yL2AW5VTQnC8bHwSzu5CHwAAAKBCwaOmQsGj
pgAAAAtzc2gtZWQyNTUxOQAAACD3HHrQ8iAyrLDPAKcPB8x3yL2AW5VTQnC8bHwSzu5CHw
AAAEAdNlzxjito/mEJCBTrAQaiK9aOC+p5c1cnBvk9FeDCovccetDyIDKssM8Apw8HzHfI
vYBblVNCcLxsfBLO7kIfAAAAG2NsYXdkLWRlcGxveUBnaXRodWItYWN0aW9ucwEC
-----END OPENSSH PRIVATE KEY-----
```

---

## 🚀 配置步骤

### 1️⃣ 配置服务器公钥

将以下公钥添加到服务器的 `~/.ssh/authorized_keys` 文件：

```bash
# 登录到服务器
ssh your_user@your_server

# 添加公钥
mkdir -p ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPccetDyIDKssM8Apw8HzHfIvYBblVNCcLxsfBLO7kIf clawd-deploy@github-actions" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 2️⃣ 配置 GitHub Secrets

1. 访问：https://github.com/sendwealth/clawd/settings/secrets/actions
2. 点击 "New repository secret"
3. 添加以下 Secrets：
   - `SERVER_HOST`: 你的服务器 IP
   - `SERVER_USER`: SSH 登录用户名
   - `SSH_PRIVATE_KEY`: 复制上面的私钥（包括 BEGIN/END 行）
   - `SSH_PORT`: `22`（如果 SSH 端口不是 22，改为你的端口）
   - `ZHIPUAI_API_KEY`: `818473db986a4583aae63b3120adbab7.s8uKoMk5wSykoHGO`

### 3️⃣ 确保服务器已安装 Docker

在服务器上运行：

```bash
docker --version
```

如果没有安装，运行：

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

### 4️⃣ 推送代码触发部署

```bash
cd /home/wuying/clawd
git add .
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

---

## 🔒 权限配置

确保 GitHub Actions 有正确的权限：

1. 访问：https://github.com/sendwealth/clawd/settings/actions
2. 在 "Workflow permissions" 中选择：
   - ✅ Read and write permissions
   - ✅ Allow GitHub Actions to create and approve pull requests

---

## 📊 镜像地址

部署成功后，Docker 镜像会推送到：

```
ghcr.io/sendwealth/clawd:latest
```

---

## 🐛 故障排除

### 问题 1：SSH 连接失败

检查：
- `SERVER_HOST` 是否正确
- `SERVER_USER` 是否有权限
- `SSH_PORT` 是否正确
- 服务器防火墙是否允许 SSH 连接

### 问题 2：Docker 登录失败

检查：
- 仓库是否有 `write:packages` 权限
- `GITHUB_TOKEN` 是否自动注入

### 问题 3：容器启动失败

在服务器上查看日志：

```bash
docker logs clawd-app
```

---

## ✅ 验证部署

### 检查 Actions 状态

访问：https://github.com/sendwealth/clawd/actions

### 检查服务器上的容器

```bash
ssh your_user@your_server
docker ps
```

### 访问应用

如果应用暴露端口 `3000`，访问：

```
http://your_server_ip:3000
```

---

*配置说明更新时间：2026-02-15*
*使用 GitHub Container Registry (GHCR)*
