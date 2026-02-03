# GitHub Actions 自动部署指南

## 📋 前置要求

### 1. 服务器端准备

在你的服务器上执行以下操作：

```bash
# 1. 安装 Node.js 18+ 和 npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. 安装 PM2 进程管理器
sudo npm install -g pm2

# 3. 安装 MySQL（如果还没有安装）
sudo apt-get install -y mysql-server

# 4. 创建项目目录并克隆代码
mkdir -p /var/www/back-master
cd /var/www/back-master
git clone https://github.com/your-username/your-repo.git .

# 5. 安装依赖
npm ci --production

# 6. 配置环境变量
cp .env.example .env
nano .env  # 编辑配置

# 7. 初始化数据库
mysql -u root -p < back_system.sql

# 8. 首次启动应用
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup  # 设置开机自启
```

### 2. 配置 GitHub Secrets

在 GitHub 仓库页面，进入 **Settings → Secrets and variables → Actions**，添加以下 Secrets：

| Secret 名称 | 说明 | 示例 |
|------------|------|------|
| `SERVER_HOST` | 服务器 IP 或域名 | `192.168.1.100` |
| `SERVER_USER` | SSH 登录用户名 | `root` 或 `ubuntu` |
| `SERVER_PASSWORD` | SSH 登录密码 | `your_password` |
| `SERVER_PORT` | SSH 端口（可选） | `22` |
| `DEPLOY_PATH` | 项目部署路径 | `/var/www/back-master` |

**如果使用密钥登录（推荐）**：
- 删除 `SERVER_PASSWORD` secret
- 添加 `SSH_PRIVATE_KEY` secret，值为私钥内容
- 在服务器上添加对应的公钥到 `~/.ssh/authorized_keys`

## 🚀 部署流程

### 自动触发条件

工作流会在以下情况自动触发：
1. 推送到 `main` 或 `master` 分支
2. PR 被合并到 `main` 或 `master` 分支

### 部署步骤

1. 代码推送到 GitHub
2. GitHub Actions 自动运行
3. SSH 连接到服务器
4. 在服务器上拉取最新代码
5. 安装依赖
6. 使用 PM2 重启应用（平滑重启，不中断服务）

## 🔧 手动部署

如果需要手动部署，可以在 GitHub 页面：
1. 进入 **Actions** 标签
2. 选择 **Deploy to Server** 工作流
3. 点击 **Run workflow**

## 📝 注意事项

### 1. 数据库配置

确保服务器上的 `.env` 文件已正确配置数据库连接信息。

### 2. 防火墙设置

确保服务器防火墙允许：
- SSH 连接（默认 22 端口）
- 应用端口（默认 3007）

```bash
# 示例：开放 3007 端口
sudo ufw allow 3007
```

### 3. Nginx 反向代理（推荐）

如果需要使用域名和 HTTPS，建议配置 Nginx：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:3007;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 4. 日志查看

```bash
# 查看 PM2 日志
pm2 logs back-master

# 查看应用日志
tail -f logs/out.log
tail -f logs/error.log
```

## 🔍 故障排查

### 部署失败

1. 检查 GitHub Actions 日志
2. 确认 Secrets 配置正确
3. 检查服务器 SSH 连接是否正常

### 应用启动失败

1. 检查 `.env` 配置
2. 检查数据库连接
3. 查看 PM2 日志：`pm2 logs`

### 端口占用

```bash
# 查看端口占用
sudo lsof -i :3007

# 杀死进程
sudo kill -9 <PID>
```

## 📚 相关文档

- [PM2 文档](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [GitHub Actions 文档](https://docs.github.com/cn/actions)
