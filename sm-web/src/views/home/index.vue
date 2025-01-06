<script setup>
import request from '@/utils/request'
import {reactive, ref} from 'vue'
// const systemStore = useSystemStore()
// 系统参数
const systemInformation = reactive({})
// 用户总数
const userSize = ref(0)
// 角色总数
const roleSize = ref(0)
// 权限（菜单）总数
const permissionSize = ref(0)
// 公告内容
const notices = reactive({})
// 获取系统参数
const handleGetSystemInformation = async () => {
  const res = await request.get('/system')
  Object.assign(systemInformation, res.data)
}
handleGetSystemInformation()
// 获取用户总数
const handleGetUserSize = async () => {
  const res = await request.get('/user')
  userSize.value = ref(res.data.length)
}
handleGetUserSize()
// 获取角色总数
const handleGetRoleSize = async () => {
  const res = await request.get('/role')
  roleSize.value = ref(res.data.length)
}
handleGetRoleSize()
// 获取权限（菜单）总数
const handleGetPermissionSize = async () => {
  const res = await request.get('/permission')
  permissionSize.value = ref(res.data.length)
}
handleGetPermissionSize()
// 获取所有公告
const handleGetNotices = async () => {
  const res = await request.get('/notice')
  Object.assign(notices, res.data)
}
handleGetNotices()
</script>

<template>
  <el-row>
    <el-col :span="5" class="statistic">
      <el-statistic :value="userSize">
        <template #title>
          <div
            style="display: inline-flex; align-items: center; font-size: 16px; text-align: center"
          >
            <el-icon :size="16">
              <User />
            </el-icon>
            用户总数
          </div>
        </template>
      </el-statistic>
    </el-col>
    <el-col :span="5" class="statistic">
      <el-statistic :value="roleSize">
        <template #title>
          <div style="display: inline-flex; align-items: center; font-size: 16px">
            <el-icon :size="16">
              <UserFilled></UserFilled>
            </el-icon>
            角色总数
          </div>
        </template>
      </el-statistic>
    </el-col>
    <el-col :span="5" class="statistic">
      <el-statistic :value="permissionSize">
        <template #title>
          <div style="display: inline-flex; align-items: center; font-size: 16px">
            <el-icon :size="16">
              <Menu />
            </el-icon>
            权限总数
          </div>
        </template>
      </el-statistic>
    </el-col>
  </el-row>

  <el-row :gutter="20">



  </el-row>
  <el-divider />

  <el-row>
    <el-col>
      <h1><el-icon><Opportunity /></el-icon>欢迎来到sm-mall</h1>
      <el-divider />
      <div>
        <el-collapse accordion>
          <el-collapse-item v-for="item in notices" :title="item.name" :name="item.id">
            <div>{{ item.createTime }}</div>
            <div v-html="item.content"></div>
          </el-collapse-item>
        </el-collapse>
      </div>
    </el-col>
  </el-row>
</template>

<style scoped lang="scss">
h1 {
  color: #333;
  font-size: 24px;
  padding: 10px;
}

p {
  color: #666;
  font-size: 16px;
  margin: 10px;
  line-height: 1.5; /* 设置行间距为1.5倍字体大小 */
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.text {
  font-size: 14px;
}

.item {
  margin-bottom: 18px;
}

.box-card {
}
ul {
  list-style: none; /* 移除默认的列表符号 */
  margin: 0;
  padding: 0;
}

li {
  color: #666;
  font-size: 16px;
  line-height: 1.5; /* 设置行间距为1.5倍字体大小 */
  margin-left: 10px;
}
ul:not(:first-child) {
  margin-left: 40px; /* 后两个 ul 向左对齐 */
}

.statistic {
  text-align: center;
}
</style>
