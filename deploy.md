# GitHub Actions 自动部署指南

> ✅ **已实现**: 每次 `git push` 自动部署到服务器

---

## 🚀 三步完成配置

### 第 1 步：配置 SSH 密钥

```bash
# 本地生成密钥对（一路回车）
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions

# 公钥上传到服务器（让服务器信任 GitHub Actions）
ssh-copy-id -i ~/.ssh/github_actions.pub root@你的服务器IP
```

| 文件 | 存放位置 |
|------|---------|
| `~/.ssh/github_actions`（私钥） | 下一步添加到 GitHub Secrets |
| `~/.ssh/github_actions.pub`（公钥） | 已自动添加到服务器的 `~/.ssh/authorized_keys` |

---

### 第 2 步：配置 GitHub Secrets

进入 **GitHub 仓库 → Settings → Secrets and variables → Actions**，添加：

| Secret 名称 | 值 |
|------------|-----|
| `SERVER_HOST` | 服务器 IP 或域名 |
| `SERVER_USER` | 登录用户名（如 root） |
| `SSH_PRIVATE_KEY` | 私钥文件内容 `cat ~/.ssh/github_actions` |
| `DEPLOY_PATH` | 项目路径（如 `/var/www/back-master`） |

---

### 第 3 步：推送代码，自动部署

```bash
git add .
git commit -m "feat: 新功能"
git push origin main    # ← 推送后自动触发部署
```

去 **GitHub 仓库 → Actions** 标签页查看部署进度。

---

## 📁 配置文件说明

| 文件 | 作用 |
|------|------|
| `.github/workflows/deploy.yml` | GitHub Actions 工作流配置 |
| `ecosystem.config.js` | PM2 进程管理配置 |

---

## 🔍 常见问题

**Q: 服务器需要提前做什么？**
确保服务器已有：
- Node.js 环境
- PM2 进程管理器
- Git 仓库（`git clone` 过项目）
- 公钥已添加到 `~/.ssh/authorized_keys`

**Q: 如何查看部署日志？**
```bash
# 服务器上查看
pm2 logs back-master
```

**Q: 部署失败怎么办？**
1. 检查 GitHub Actions 日志（仓库 → Actions）
2. 确认 Secrets 配置正确
3. 确保服务器 SSH 端口开放
