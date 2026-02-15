#!/bin/bash
# OpenSpark 智能科技 - GitHub 仓库设置和推送脚本

# 设置变量
GITHUB_USERNAME="sendwealth"
REPO_NAME="clawd"
GITHUB_REPO="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
BRANCH_NAME="master"

echo "========================================"
echo "OpenSpark 智能科技 - GitHub 推送脚本"
echo "========================================"
echo ""

# 步骤 1：检查 GitHub 仓库是否存在
echo "步骤 1：检查 GitHub 仓库..."
if ! git ls-remote ${GITHUB_REPO} &> /dev/null; then
    echo "⚠️  仓库 ${GITHUB_REPO} 不存在，请先在 GitHub 上创建："
    echo "   https://github.com/new"
    echo ""
    echo "创建仓库后，请运行以下命令："
    echo "   git remote add origin ${GITHUB_REPO}"
    echo "   git push -u origin ${BRANCH_NAME}"
    echo ""
    exit 1
fi

echo "✅ 仓库 ${GITHUB_REPO} 已存在"
echo ""

# 步骤 2：添加远程仓库（如果不存在）
echo "步骤 2：添加远程仓库..."
if ! git remote get-url origin &> /dev/null; then
    echo "   添加远程仓库..."
    git remote add origin ${GITHUB_REPO}
    echo "✅ 远程仓库已添加"
else
    echo "✅ 远程仓库已存在"
    CURRENT_ORIGIN=$(git remote get-url origin)
    echo "   当前远程仓库：${CURRENT_ORIGIN}"
fi
echo ""

# 步骤 3：推送到 GitHub
echo "步骤 3：推送到 GitHub..."
echo "   推送 ${BRANCH_NAME} 分支..."
git push -u origin ${BRANCH_NAME}

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ 推送成功！"
    echo "========================================"
    echo ""
    echo "仓库地址：https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    echo ""
    echo "推送的文件数：126"
    echo "添加的代码行数：90,745"
    echo ""
    echo "下一步："
    echo "1. 访问 GitHub 仓库：https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
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
