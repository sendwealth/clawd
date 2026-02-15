# OpenSpark 智能科技 - GitHub 推送指南

**创建时间：** 2026-02-15 16:10
**创建人：** CTO OpenClaw

---

## 📋 推送前的准备工作

### ✅ 已完成的工作

**Git 提交已创建：**
- 提交哈希：fb50091
- 文件数：126 个
- 添加的代码行数：90,745 行
- 删除的代码行数：381 行
- 提交信息：M1 Week 2 完成：6/9 任务完成，整体进度 84%

**包含的内容：**
- CLAW.AI 后端代码（claw-ai-backend）
- CLAW.AI 前端代码（claw-ai-frontend）
- CI/CD 配置（.github/workflows/）
- 部署文档（DEPLOYMENT.md）
- 监控配置（prometheus/、grafana/、alertmanager/）
- 文档专家任务文档（memory/ 目录）
- 客户支持文档（customer-support/）

---

## 🚀 推送到 GitHub 的步骤

### 方法 1：使用 SSH 推送（推荐）

#### 步骤 1：创建 GitHub 仓库

1. 访问 GitHub：https://github.com/new
2. 仓库名称：`clawd`
3. 描述：`OpenSpark 智能科技 - CLAW.AI AI 智能客服平台`
4. 可见性：`Private`（私有）
5. 初始化仓库：✅ 不使用任何 README、.gitignore 或 license
6. 点击 "Create repository"

#### 步骤 2：推送到 GitHub

```bash
cd /home/wuying/clawd
git remote add origin git@github.com:sendwealth/clawd.git
git push -u origin master
```

### 方法 2：使用 HTTPS 推送

#### 步骤 1：创建 GitHub 仓库

同方法 1 的步骤 1

#### 步骤 2：推送到 GitHub

```bash
cd /home/wuying/clawd
git remote add origin https://github.com/sendwealth/clawd.git
git push -u origin master
```

---

## ⚠️ 可能遇到的问题

### 问题 1：SSH 密钥未配置

**症状：**
```
Permission denied (publickey).
fatal: Could not read from remote repository.
```

**解决方案：**
1. 生成 SSH 密钥：
```bash
ssh-keygen -t rsa -b 4096 -C "sendwealth@claw.ai"
```

2. 添加 SSH 密钥到 GitHub：
   - 复制公钥：`cat ~/.ssh/id_rsa.pub`
   - 访问：https://github.com/settings/keys
   - 点击 "New SSH key"
   - 粘贴公钥
   - 点击 "Add SSH key"

### 问题 2：HTTPS 认证失败

**症状：**
```
Username for 'https://github.com': sendwealth
Password for 'https://sendwealth@github.com':
remote: Invalid username or password.
```

**解决方案：**
1. 使用 Personal Access Token 替代密码
2. 生成 Token：
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token"
   - 选择权限：repo, workflow
   - 点击 "Generate token"
3. 使用 Token 推送：
```bash
git push https://sendwealth:YOUR_TOKEN@github.com/sendwealth/clawd.git master
```

---

## 📊 推送后的工作

### 推送成功后

**仓库地址：** https://github.com/sendwealth/clawd

**包含的内容：**
- CLAW.AI 后端代码（claw-ai-backend）
- CLAW.AI 前端代码（claw-ai-frontend）
- CI/CD 配置（.github/workflows/）
- 部署文档（DEPLOYMENT.md）
- 监控配置（prometheus/、grafana/、alertmanager/）
- 文档（memory/）

**下一步：**

1. **配置 GitHub Secrets**
   - 访问：https://github.com/sendwealth/clawd/settings/secrets/actions
   - 添加以下 Secrets：
     - DOCKER_USERNAME
     - DOCKER_PASSWORD
     - SERVER_HOST
     - SERVER_USER
     - SSH_PRIVATE_KEY
     - SSH_PORT
     - ZHIPUAI_API_KEY
     - PINECONE_API_KEY
     - SNYK_TOKEN

2. **配置 GitHub Pages（可选）**
   - 访问：https://github.com/sendwealth/clawd/settings/pages
   - 选择源分支：master
   - 选择目录：claw-ai-frontend
   - 点击 Save

3. **邀请团队成员**
   - 访问：https://github.com/sendwealth/clawd/settings/collaboration
   - 添加团队成员
   - 设置权限（Admin/Write/Read）

---

## 🎯 GitHub 仓库结构

```
clawd/
├── .github/
│   └── workflows/
│       ├── cd.yml
│       ├── ci.yml
│       ├── security.yml
│       └── test.yml
├── claw-ai-backend/
├── claw-ai-frontend/
├── claw-intelligence/
├── customer-support/
├── memory/
├── DEPLOYMENT.md
├── push-to-github.sh
├── push-to-github-guide.md
└── README.md
```

---

## 📝 备注

### 推送完成后

1. **验证推送成功**
   - 访问：https://github.com/sendwealth/clawd
   - 检查文件是否都已推送

2. **配置 GitHub Secrets**
   - 这是 CI/CD 流水线必须的配置
   - 详见上面的步骤

3. **启动 CI/CD 流水线**
   - 自动运行：推送代码后自动触发
   - 手动触发：访问 Actions 页面手动运行

4. **监控 CI/CD 执行**
   - 访问：https://github.com/sendwealth/clawd/actions
   - 查看 Workflow 执行状态

---

*推送指南创建时间：2026-02-15 16:10*
*创建人：CTO OpenClaw*
*状态：Git 提交已创建，等待推送到 GitHub*
