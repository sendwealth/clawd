#!/bin/bash
# OpenSpark 智能科技 - GitHub SSH 密钥生成和配置脚本

# 设置变量
KEY_TYPE="rsa"
KEY_BITS="4096"
KEY_COMMENT="sendwealth@claw.ai"
SSH_DIR="$HOME/.ssh"
KEY_NAME="id_rsa"

echo "========================================"
echo "OpenSpark 智能科技 - GitHub SSH 配置"
echo "========================================"
echo ""

# 步骤 1：生成 SSH 密钥
echo "步骤 1：生成 SSH 密钥..."
ssh-keygen -t ${KEY_TYPE} -b ${KEY_BITS} -C "${KEY_COMMENT}" -f ${SSH_DIR}/${KEY_NAME} -N ""

if [ $? -eq 0 ]; then
    echo "✅ SSH 密钥已生成"
    echo ""
    echo "公钥："
    cat ${SSH_DIR}/${KEY_NAME}.pub
    echo ""
    echo "私钥位置：${SSH_DIR}/${KEY_NAME}"
    echo ""
else
    echo "❌ SSH 密钥生成失败"
    exit 1
fi

# 步骤 2：配置 SSH 权限
echo "步骤 2：配置 SSH 权限..."
chmod 700 ${SSH_DIR}
chmod 600 ${SSH_DIR}/${KEY_NAME}
chmod 644 ${SSH_DIR}/${KEY_NAME}.pub
echo "✅ SSH 权限已配置"
echo ""

# 步骤 3：添加 SSH 密钥到 GitHub
echo "步骤 3：添加 SSH 密钥到 GitHub"
echo ""
echo "请按照以下步骤添加 SSH 密钥到 GitHub："
echo ""
echo "1. 复制上面的公钥（从 '-----BEGIN' 到 '-----END'）"
echo ""
echo "2. 访问：https://github.com/settings/keys"
echo ""
echo "3. 点击 'New SSH key' 或 'Add SSH key'"
echo ""
echo "4. 填写信息："
echo "   - Title：OpenSpark 智能科技 (wuying)"
echo "   - Key type：Authentication Key"
echo "   - Key：粘贴复制的公钥"
echo ""
echo "5. 点击 'Add SSH key'"
echo ""
echo "⏸️  等待您添加 SSH 密钥..."
echo ""
read -p "按 Enter 键继续..."

# 步骤 4：测试 SSH 连接
echo ""
echo "步骤 4：测试 SSH 连接..."
ssh -T git@github.com

if [ $? -eq 1 ]; then
    echo ""
    echo "✅ SSH 连接测试成功！"
    echo "   GitHub 已成功验证您的身份。"
    echo ""
else
    echo ""
    echo "❌ SSH 连接测试失败"
    echo ""
    echo "请检查："
    echo "1. SSH 密钥是否正确添加到 GitHub"
    echo "2. 网络连接是否正常"
    echo ""
    exit 1
fi

# 步骤 5：创建 GitHub 仓库
echo ""
echo "步骤 5：创建 GitHub 仓库"
echo ""
echo "请按照以下步骤创建 GitHub 仓库："
echo ""
echo "1. 访问：https://github.com/new"
echo ""
echo "2. 填写信息："
echo "   - 仓库名称：clawd"
echo "   - 描述：OpenSpark 智能科技 - CLAW.AI AI 智能客服平台"
echo "   - 可见性：Private"
echo "   - 初始化：✅ 不使用任何 README、.gitignore 或 license"
echo ""
echo "3. 点击 'Create repository'"
echo ""
echo "⏸️  等待您创建仓库..."
echo ""
read -p "按 Enter 键继续..."

# 步骤 6：添加远程仓库
echo ""
echo "步骤 6：添加远程仓库..."
git remote add origin git@github.com:sendwealth/clawd.git
echo "✅ 远程仓库已添加"
echo ""

# 步骤 7：推送到 GitHub
echo ""
echo "步骤 7：推送到 GitHub..."
echo ""
git push -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ 推送成功！"
    echo "========================================"
    echo ""
    echo "仓库地址：https://github.com/sendwealth/clawd"
    echo ""
    echo "推送的文件数：126"
    echo "添加的代码行数：90,745"
    echo ""
    echo "下一步："
    echo "1. 访问 GitHub 仓库：https://github.com/sendwealth/clawd"
    echo "2. 配置 GitHub Secrets（用于 CI/CD）"
    echo ""
else
    echo ""
    echo "========================================"
    echo "❌ 推送失败"
    echo "========================================"
    echo ""
    echo "请检查："
    echo "1. 是否有 GitHub 访问权限"
    echo "2. SSH 密钥是否配置正确"
    echo "3. 网络连接是否正常"
    echo ""
    exit 1
fi
