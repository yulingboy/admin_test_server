module.exports = {
  apps: [{
    name: 'back-master',
    script: './app.js',
    instances: 1, // 或者 'max' 使用所有 CPU 核心
    exec_mode: 'fork', // 'cluster' 用于多核模式
    
    // 环境变量
    env: {
      NODE_ENV: 'development',
      PORT: 3007
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3007
    },
    
    // 日志配置
    log_file: './logs/combined.log',
    out_file: './logs/out.log',
    error_file: './logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // 自动重启配置
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s',
    
    // 内存限制
    max_memory_restart: '500M',
    
    // 监控
    watch: false, // 生产环境建议关闭
    ignore_watch: ['node_modules', 'logs', 'uploads'],
    
    // 健康检查
    kill_timeout: 5000,
    listen_timeout: 10000,
    
    // 启动配置
    wait_ready: true,
    max_restarts: 5
  }]
};
