<script setup>
import {reactive, ref} from 'vue'
import {
  CircleCloseFilled,
  Delete,
  Download,
  Edit,
  InfoFilled,
  Plus,
  Refresh,
  Search,
  Upload, View
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import {ElMessage, ElMessageBox} from 'element-plus'

import downloadExcel from '@/utils/downloads'
import {MdEditor} from 'md-editor-v3';
import 'md-editor-v3/lib/style.css';
// 名称
const name = ref('')
// 弹框头部名称
const headerTitle = ref()
// 当前页数
const pageNum = ref(1)
// 每页展示量
const pageSize = ref(10)
// 分页数据总数
const total = ref(0)
const statu = ref(0)
// 表格数据
const tableData = ref([])
// 批量选择的数组
const multipleSelection = ref([])
// 是否禁用按钮
const disabled = ref(true)
// 是否展示弹框
const dialogVisible = ref(false)


// 表单数据定义
const form = reactive({
  id: undefined,
  name: undefined,
  username: undefined,
  gid: undefined,
  scount: 0,
  goods: undefined,
  aid: undefined,
  address: undefined,
  statu: 0,
  total: 0,
})

// 表单样式
const formSize = ref('default')
// 表单ref标识数据
const ruleFormRef = ref()
// 自定义校验规则

// 表单校验规则
const rules = reactive({

  id: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  name: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  username: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  gid: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  scount: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  goods: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  aid: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  address: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  statu: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  total: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
})

//新增方法
const handleAdd = async () => {
  headerTitle.value = reactive('新增数据')
  dialogVisible.value = true
}
// 修改方法
const handleUpdate = async (id) => {

  const res = await request.get(`/order/${id}`)
  const entity = res.data
  entity.statu = 3
  await request.put(`/order/${id}`, entity)
  ElMessage({
    showClose: true,
    message: '发货成功',
    type: 'success'
  })
  await load()
}
// 单个删除方法
const handleDel = async (id) => {
  await request.delete(`/order/${id}`)
  ElMessage({
    showClose: true,
    message: '删除成功',
    type: 'success'
  })
  await load()
}
// 批量删除方法
const handleBatchDel = async () => {
  const ids = []
  multipleSelection.value.forEach((row) => {
    ids.push(row.id)
  })
  await request.delete(`/order/batch/${ids}`)
  ElMessage({
    showClose: true,
    message: '批量删除成功',
    type: 'success'
  })
  await load()
}

// 分页查询方法（初始化方法，页面加载成功以后就调用的方法）
const load = async () => {
  const res = await request.get('/order/page', {
    params: {
      name: name.value,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      statu: statu.value
    }
  })
  pageNum.value = res.data.current
  pageSize.value = res.data.size
  total.value = res.data.total
  tableData.value = res.data.records
}
// 加载页面初始化调用load方法
load()

// 清空查询数据重置方法
const handleReset = () => {
  name.value = ''
  statu.value = 0
  load()
}
// 修改每页展示的数据量方法
const handleSizeChange = (size) => {
  pageSize.value = size
  load()
}
// 翻页方法
const handleCurrentChange = (current) => {
  pageNum.value = current
  load()
}
// 多选按钮处理方法
const handleSelectionChange = (val) => {
  multipleSelection.value = val
  disabled.value = val.length === 0
}

// 关闭弹框提示方法
const handleClose = (done) => {
  ElMessageBox.confirm('确定关闭窗口?')
      .then(() => {
        handleResetForm(ruleFormRef.value)
      })
      .then(() => {
        done()
      })
      .catch(() => {
        // catch error
      })
}
// 提交表单校验方法
const handleSubmitForm = async (formEl) => {
  if (!formEl) return
  await formEl.validate(async (valid, fields) => {
    if (valid) {
      await request({
        method: form.id ? 'put' : 'post',
        url: form.id ? `/order/${form.id}` : '/order',
        data: form
      })
      ElMessage({
        showClose: true,
        message: '操作成功',
        type: 'success'
      })
      await handleResetForm(formEl)
    } else {
      console.log('error submit!', fields)
    }
  })
}
// 批量导入读数据写到后端数据库中
const beforeBatchUpload = async (file) => {
  let fd = new FormData()
  fd.append('file', file)
  await request.post('/order/batch/upload', fd, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
  ElMessage({
    showClose: true,
    message: '上传成功',
    type: 'success'
  })
  await load()
}
// 批量导出方法
const handleBatchExport = async () => {
  const ids = multipleSelection.value.map((row) => row.id)
  const res = await request(
      {
        url: `/order/batch/export/${ids}`,
        method: 'get',
        responseType: 'blob'
      } //在请求中加上这一行，特别重要
  )
  downloadExcel(res, '导出数据表')
}
// 取消弹框方法
const handleResetForm = async (formEl) => {
  if (!formEl) return
  formEl.resetFields()
  Object.assign(form,
      {
        id: undefined,
        name: undefined,
        username: undefined,
        gid: undefined,
        scount: 0,
        goods: undefined,
        aid: undefined,
        address: undefined,
        statu: 0,
        total: 0,
      }
  )
  // formEl.clearValidate("img")
  dialogVisible.value = false
  await load()
}

// 文件上传方法


// 文件下载
const dowload = async (url) => {
  window.open(url)
}
// 富文本文件上传
const onUploadImg = async (files, callback) => {
  let i = 0;
  const res = await Promise.all(
      files.map((file) => {

        if (i > 0) {

          return false
        }
        return new Promise((rev, rej) => {
          const formdata = new FormData();
          formdata.append('file', file);

          request
              .post('/file/upload', formdata, {
                headers: {
                  'Content-Type': 'multipart/form-data',
                }
              })
              .then((res) => {
                i++
                rev(res.data)
              })
              .catch((error) => rej(error));
        });

      })
  );
  callback(res);
};

</script>
<template>


  <el-row>
    <!--  分页查询表单按钮-->
    <el-col>
      <el-form :inline="true">
        <!--        查询输入框-->
        <el-form-item>
          <el-input v-model="name" placeholder="点击输入名称"></el-input>
        </el-form-item>
        <el-form-item>
          <el-radio-group v-model="statu" @change="load">
            <el-radio-button label="1" :value="1">未付款</el-radio-button>
            <el-radio-button label="2" :value="2">已支付</el-radio-button>
            <el-radio-button label="3" :value="3">已发货</el-radio-button>
            <el-radio-button label="4" :value="4">已收货</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <!--        查询按钮 and 重置按钮-->
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
          <el-button type="warning" :icon="Refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-col>
    <!-- 新增和批量按钮 -->
    <el-col style="margin-bottom: 10px; display: flex; gap: 10px">
      <!--      &lt;!&ndash;   新增   &ndash;&gt;-->
      <!--      <div v-permission="'sys:order:add'">-->
      <!--        <el-button type="primary" :icon="Plus" @click="handleAdd" size="small" plain-->
      <!--        >新增-->
      <!--        </el-button>-->
      <!--      </div>-->
      <!--   批量导入   -->
      <!--      <div v-permission="'sys:order:batch:upload'">-->
      <!--        <el-upload action="" :before-upload="beforeBatchUpload" :show-file-list="true">-->
      <!--          <el-button type="success" :icon="Upload" size="small" plain>批量导入</el-button>-->
      <!--        </el-upload>-->
      <!--      </div>-->
      <!--   批量删除   -->
      <div v-permission="'sys:order:batch:delete'">
        <el-popconfirm
            confirm-button-text="确定"
            cancel-button-text="取消"
            :icon="InfoFilled"
            icon-color="#626AEF"
            title="确认要批量删除吗？"
            @confirm="handleBatchDel"
            @cancel="load"
        >
          <template #reference>
            <el-button type="danger" :disabled="disabled" :icon="Delete" size="small" plain
            >批量删除
            </el-button>
          </template>
        </el-popconfirm>
      </div>

      <div v-permission="'sys:order:batch:export'">
        <el-button
            type="warning"
            :icon="Download"
            :disabled="disabled"
            size="small"
            @click="handleBatchExport"
            plain
        >批量导出
        </el-button>
      </div>
    </el-col>
    <!--  表格页面-->
    <el-col>
      <el-table
          :data="tableData"
          style="width: 100%"
          :header-cell-style="{ background: '#eef1f6', color: '#606266' }"
          @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55"/>
        <!--        <el-table-column prop="id" label="ID" align="center"/>-->
        <el-table-column prop="name" label="订单编号" align="center"/>
        <el-table-column prop="username" label="创建账户" align="center"/>
        <el-table-column prop="img" label="商品信息" align="center">
          <template #default="scope">
            <el-image
                style="width: 50px; height: 50px"
                :src="JSON.parse(JSON.parse(scope.row.goods).img).map(item=>item.url)[0]"
                :preview-src-list="JSON.parse(JSON.parse(scope.row.goods).img).map(item=>item.url)"
                :zoom-rate="1.2"
                :max-scale="7"
                :preview-teleported="true"
                :min-scale="0.2"
                :initial-index="0"
                fit="contain"
            />

          </template>
        </el-table-column>
        <el-table-column prop="goods" label="商品名称" align="center">
          <template #default="scope">
<span
    style="color: red; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis;">
  {{ JSON.parse(scope.row.goods).name }}
</span>
          </template>
        </el-table-column>
        <el-table-column prop="scount" label="订单数量" align="center"/>

        <el-table-column prop="address" label="地址信息" align="center">
          <template #default="scope">

            <p>姓名：<span style="color: #555;">{{ JSON.parse(scope.row.address).name }}</span></p>
            <p>电话：<span style="color: #555;">{{ JSON.parse(scope.row.address).phone }}</span></p>
            <p>地址：<span style="color: #555;">{{ JSON.parse(scope.row.address).content }}</span></p>

          </template>
        </el-table-column>
        <el-table-column prop="statu" label="当前状态" align="center">
          <template #default="scope">
            <div>
              <el-button
                  v-if="scope.row.statu === 1"
                  type="warning"
              >
                未支付
              </el-button>
              <el-button
                  v-else-if="scope.row.statu === 2"
                  type="success"
              >
                已支付
              </el-button>
              <el-button
                  v-else-if="scope.row.statu === 3"
                  type="info"
              >
                已发货
              </el-button>
              <el-button
                  v-else-if="scope.row.statu === 4"
                  type="primary"
              >
                已收货
              </el-button>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="total" label="订单金额" align="center"/>

        <el-table-column label="操作" align="center">
          <template #default="scope">
            <div style="display: flex; justify-content: center; gap: 10px">
              <div>
                <el-button
                    type="warning"
                    :icon="View"
                    size="small"
                    @click="handleUpdate(scope.row.id)"
                    v-permission="'sys:order:update'"
                    v-if="scope.row.statu===2"
                >发货
                </el-button>
              </div>
              <div v-permission="'sys:order:delete'">
                <el-popconfirm
                    confirm-button-text="确定"
                    cancel-button-text="取消"
                    :icon="InfoFilled"
                    icon-color="#626AEF"
                    title="确认要删除吗？"
                    @confirm="handleDel(scope.row.id)"
                    @cancel="load"
                >
                  <template #reference>
                    <el-button type="danger" :icon="Delete" size="small">删除</el-button>
                  </template>
                </el-popconfirm>
              </div>
            </div>
          </template>
        </el-table-column>
      </el-table>
      <!--      分页按钮-->
      <div class="pagination">
        <el-pagination
            :current-page="pageNum"
            :page-size="pageSize"
            :page-sizes="[10, 20, 30, 50, 100, 500, 1000]"
            small="small"
            layout="total, sizes, prev, pager, next, jumper"
            :total="Number(total)"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
        />
      </div>
    </el-col>
  </el-row>
</template>

<style scoped lang="scss">
.el-form--inline .el-form-item {
  margin-right: 10px;
}

.form_header {
  background-color: #666666;
}

.pagination {
  margin-top: 10px;
}

.el-button {
  height: 28px;
  border-radius: 3px;
}

.my-header {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}
</style>
