import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import Pages from 'vite-plugin-pages'
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 5173, // 可以选择你希望的端口号
    cors: true, // 如果需要支持跨域请求，可以设置为true
  },
  base:'./',
  plugins: [
    vue(),
    Pages({
      dirs: 'src/views',  // 需要生成路由的文件的目录
      exclude: ['**/components/*.vue']  // 排除在外的目录，将所有 components 目录下的 .vue 文件排除
    })

  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
