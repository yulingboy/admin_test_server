// 导入mysql2数据库（兼容mysql API，支持MySQL 8.0认证）
const mysql = require('mysql2')

// 加载环境变量（开发环境从.env文件加载，生产环境从系统环境变量读取）
if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config()
}

// 创建与数据库的连接
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'back_system',
    port: process.env.DB_PORT || 3306
})

// 对外暴露数据库
module.exports = db
