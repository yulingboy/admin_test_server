#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置项
PROJECT_NAME="back-master"
DEPLOY_PATH="/var/www/${PROJECT_NAME}"
NODE_VERSION="18"
PM2_APP_NAME="back-master"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  后端项目一键部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    echo "示例: sudo bash deploy.sh"
    exit 1
fi

# 1. 安装 Node.js
echo -e "${YELLOW}[1/6] 安装 Node.js ${NODE_VERSION}...${NC}"
if ! command -v node &> /dev/null || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" != "$NODE_VERSION" ]; then
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt-get install -y nodejs
    echo -e "${GREEN}✓ Node.js $(node -v) 安装完成${NC}"
else
    echo -e "${GREEN}✓ Node.js $(node -v) 已存在${NC}"
fi

# 2. 安装 PM2
echo -e "${YELLOW}[2/6] 安装 PM2...${NC}"
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
    echo -e "${GREEN}✓ PM2 安装完成${NC}"
else
    echo -e "${GREEN}✓ PM2 已存在 ($(pm2 -v))${NC}"
fi

# 3. 创建项目目录
echo -e "${YELLOW}[3/6] 创建项目目录...${NC}"
mkdir -p ${DEPLOY_PATH}
cd ${DEPLOY_PATH}
echo -e "${GREEN}✓ 项目目录: ${DEPLOY_PATH}${NC}"

# 4. 检查/克隆代码
echo -e "${YELLOW}[4/6] 检查项目代码...${NC}"
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}未检测到 Git 仓库，请提供仓库地址:${NC}"
    read -r repo_url
    git clone ${repo_url} .
    echo -e "${GREEN}✓ 代码克隆完成${NC}"
else
    echo -e "${GREEN}✓ 已有 Git 仓库${NC}"
fi

# 5. 安装依赖
echo -e "${YELLOW}[5/6] 安装项目依赖...${NC}"
npm ci --production
echo -e "${GREEN}✓ 依赖安装完成${NC}"

# 6. 配置环境变量
echo -e "${YELLOW}[6/6] 配置环境变量...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${YELLOW}已创建 .env 文件，请编辑配置:${NC}"
        echo -e "  ${YELLOW}nano ${DEPLOY_PATH}/.env${NC}"
        echo ""
        echo -e "${YELLOW}按 Enter 继续...${NC}"
        read
    fi
fi

# 创建日志目录
mkdir -p logs

# 启动应用
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  启动应用...${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查是否已有进程
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}重启应用...${NC}"
    pm2 reload ecosystem.config.js --env production
else
    echo -e "${YELLOW}启动应用...${NC}"
    pm2 start ecosystem.config.js --env production
fi

# 保存配置
pm2 save
pm2 startup systemd -u ${SUDO_USER:-root} --hp /home/${SUDO_USER:-root}

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  部署完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "项目路径: ${YELLOW}${DEPLOY_PATH}${NC}"
echo -e "日志查看: ${YELLOW}pm2 logs ${PM2_APP_NAME}${NC}"
echo -e "状态查看: ${YELLOW}pm2 status${NC}"
echo -e "重启应用: ${YELLOW}pm2 restart ${PM2_APP_NAME}${NC}"
echo ""
echo -e "${YELLOW}提示: 如果这是首次部署，请确保:${NC}"
echo -e "  1. 已编辑 ${DEPLOY_PATH}/.env 文件配置数据库"
echo -e "  2. 已在 GitHub 添加 SSH 公钥"
echo -e "  3. 已在 GitHub Secrets 配置部署密钥"
echo ""
