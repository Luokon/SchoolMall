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
  Upload
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import {ElMessage, ElMessageBox} from 'element-plus'

import downloadExcel from '@/utils/downloads'
import {MdEditor} from 'md-editor-v3';
import 'md-editor-v3/lib/style.css';
import router from "@/router";
// 名称
const name = ref('')
const cid = ref('')
const isShow = ref('')
const isRecommand= ref('')
const categoryList=ref([])
// 弹框头部名称
const headerTitle = ref()
// 当前页数
const pageNum = ref(1)
// 每页展示量
const pageSize = ref(10)
// 分页数据总数
const total = ref(0)
// 表格数据
const tableData = ref([])
// 批量选择的数组
const multipleSelection = ref([])
// 是否禁用按钮
const disabled = ref(true)
// 是否展示弹框
const dialogVisible = ref(false)
const $route = router


// 表单数据定义
const form = reactive({
  id: undefined,
  name: undefined,
  img: undefined,
  price: 1,
  store: 0,
  sales: 0,
  isShow: 0,
  isRecommand: 0,
  cid: undefined,
  content: undefined,
  createTime: undefined,
  updateTime: undefined,
  username: undefined,
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
  img: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  price: [{required: true, message: '必选项不能为空', trigger: 'change'}],
  store: [{required: true, message: '必选项不能为空', trigger: 'change'}],
  sales: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  isShow: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  isRecommand: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  cid: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  content: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  createTime: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  updateTime: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
  username: [{required: true, message: '必选项不能为空', trigger: 'blur'}],
})

//新增方法
const handleAdd = async () => {
  $route.push('/goods/edit')
}
// 修改方法
const handleUpdate = async (id) => {
  $route.push(`/goods/edit?id=${id}`)
}
// 单个删除方法
const handleDel = async (id) => {
  await request.delete(`/goods/${id}`)
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
  await request.delete(`/goods/batch/${ids}`)
  ElMessage({
    showClose: true,
    message: '批量删除成功',
    type: 'success'
  })
  await load()
}

// 分页查询方法（初始化方法，页面加载成功以后就调用的方法）
const load = async () => {
  const res = await request.get('/goods/page', {
    params: {
      name: name.value,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      cid:cid.value,
      isShow:isShow.value,
      isRecommand:isRecommand.value
    }
  })
  pageNum.value = res.data.current
  pageSize.value = res.data.size
  total.value = res.data.total
  tableData.value = res.data.records
  const rew= await  request.get('/category')
  categoryList.value=rew.data
}
// 加载页面初始化调用load方法
load()

// 清空查询数据重置方法
const handleReset = () => {
  name.value = ''
  cid.value=''
  isShow.value=''
  isRecommand.value=''
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
        url: form.id ? `/goods/${form.id}` : '/goods',
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
  await request.post('/goods/batch/upload', fd, {
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
        url: `/goods/batch/export/${ids}`,
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
        img: undefined,
        price: 1,
        store: 0,
        sales: 0,
        isShow: 0,
        isRecommand: 0,
        cid: undefined,
        content: undefined,
        createTime: undefined,
        updateTime: undefined,
        username: undefined,
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
const change=async (entity)=>{
  await request.put(`/goods/${entity.id}`,entity)
  await load()
}
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
          <el-select v-model="cid" placeholder="选择分类">
            <el-option
                v-for="(item,index) in categoryList"
                :label="item.name"
                :value="item.id"
                :key="index.toString()"
                @change="load"
            ></el-option>
          </el-select>
        </el-form-item>
<!--        <el-form-item>-->
<!--          <el-switch-->
<!--              v-model="isShow"-->
<!--              :active-value="1"-->
<!--              :inactive-value="0"-->
<!--              inline-prompt-->
<!--              active-text="上架"-->
<!--              inactive-text="下架"-->
<!--              @change="load"-->
<!--          />-->
<!--        </el-form-item>-->
<!--        <el-form-item>-->
<!--          <el-switch-->
<!--              v-model="isRecommand"-->
<!--              :active-value="1"-->
<!--              :inactive-value="0"-->
<!--              inline-prompt-->
<!--              active-text="推荐"-->
<!--              inactive-text="不推荐"-->
<!--              @change="load"-->
<!--          />-->
<!--        </el-form-item>-->
        <!--        查询按钮 and 重置按钮-->
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
          <el-button type="warning" :icon="Refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-col>
    <!-- 新增和批量按钮 -->
    <el-col style="margin-bottom: 10px; display: flex; gap: 10px">
      <!--   新增   -->
      <div v-permission="'sys:goods:add'">
        <el-button type="primary" :icon="Plus" @click="handleAdd" size="small" plain
        >新增商品
        </el-button>
      </div>
      <!--   批量导入   -->
      <div v-permission="'sys:goods:batch:upload'">
        <el-upload action="" :before-upload="beforeBatchUpload" :show-file-list="true">
          <el-button type="success" :icon="Upload" size="small" plain>批量导入</el-button>
        </el-upload>
      </div>
      <!--   批量删除   -->
      <div v-permission="'sys:goods:batch:delete'">
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

      <div v-permission="'sys:goods:batch:export'">
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

        <el-table-column prop="name" label="商品名称" align="center"/>
        <el-table-column prop="img" label="商品图片" align="center">
         <template #default="scope">
           <el-image
               style="width: 50px; height: 50px"
               :src="JSON.parse(scope.row.img).map(item=>item.url)[0]"
               :preview-src-list="JSON.parse(scope.row.img).map(item=>item.url)"
               :zoom-rate="1.2"
               :max-scale="7"
               :preview-teleported="true"
               :min-scale="0.2"
               :initial-index="0"
               fit="contain"
           />
         </template>
        </el-table-column>
        <el-table-column prop="price" sortable label="商品单价" align="center"/>
        <el-table-column prop="store" sortable label="商品库存" align="center"/>
        <el-table-column prop="sales" sortable label="商品销量" align="center"/>
        <el-table-column prop="isShow" label="是否上架" align="center">
          <template #default="scope">
            <el-switch
                v-model="scope.row.isShow"
                :active-value="1"
                :inactive-value="0"
                inline-prompt
                active-text="上架"
                inactive-text="下架"
                style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
                @change="change(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="isRecommand" label="是否推荐" align="center">
          <template #default="scope">
            <el-switch
                v-model="scope.row.isRecommand"
                :active-value="1"
                :inactive-value="0"
                inline-prompt
                active-text="推荐"
                inactive-text="不推荐"
                style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
                @change="change(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="cid" label="所属类型" align="center">
          <template #default="scope">
            <el-tag>{{scope.row.category.name}}</el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="createTime" label="创建时间" align="center"/>
        <el-table-column prop="updateTime" label="修改时间" align="center"/>
        <el-table-column prop="username" label="创建账户" align="center"/>

        <el-table-column label="操作" align="center" width="200">
          <template #default="scope">
            <div style="display: flex; justify-content: center; gap: 10px">
              <div>
                <el-button
                    type="primary"
                    :icon="Edit"
                    size="small"
                    @click="handleUpdate(scope.row.id)"
                    v-permission="'sys:goods:update'"
                >编辑
                </el-button>
              </div>
              <div v-permission="'sys:goods:delete'">
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
