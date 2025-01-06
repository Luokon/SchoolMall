<script setup>
import {onBeforeMount, onBeforeUnmount, reactive, ref, shallowRef} from 'vue'
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

import {Editor, Toolbar} from "@wangeditor/editor-for-vue";
import '@wangeditor/editor/dist/css/style.css'

const $route=router
const editorRef = shallowRef()
const toolbarConfig = {}
const editorConfig = { placeholder: '请自行添加详情...',
  MENU_CONF: {}
}
editorConfig.MENU_CONF['uploadImage'] = {
  server: 'http://localhost:9090/api/file/wangupload',
  fieldName: 'file'
  // 继续写其他配置...

  //【注意】不需要修改的不用写，wangEditor 会去 merge 当前其他配置
}
onBeforeUnmount(() => {
  const editor = editorRef.value
  if (editor == null) return
  editor.destroy()
})
onBeforeMount((async () => {
  if ($route.currentRoute.value.query.id) {
    await handleUpdate($route.currentRoute.value.query.id)
  }
}))
const handleCreated = async (editor) => {
  editorRef.value = editor // 记录 editor 实例，重要！


}

// 是否展示弹框
const dialogVisible = ref(false)

const categoryList = ref([])

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


// 修改方法
const handleUpdate = async (id) => {
  dialogVisible.value = true

  const res = await request.get(`/goods/${id}`)
  Object.assign(form, res.data)
  fileList.value=JSON.parse(form.img)
  fileList1.value=JSON.parse(form.content)
}


// 分页查询方法（初始化方法，页面加载成功以后就调用的方法）
const load = async () => {
  const res = await request.get('/category')
  categoryList.value = res.data
}
// 加载页面初始化调用load方法
load()


// 提交表单校验方法
const handleSubmitForm = async (formEl) => {
  if (!formEl) return
  if (fileList.value.length>0){
    form.img=JSON.stringify(fileList.value)
  }
  if (fileList1.value.length>0){
    form.content=JSON.stringify(fileList1.value)
  }
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
      $route.go(-1)
      await handleResetForm(formEl)
    } else {
      console.log('error submit!', fields)
    }
  })
}


// 取消弹框方法
const handleResetForm = async (formEl) => {
  if (!formEl) return
  formEl.resetFields()
  fileList.value=[]
  fileList1.value=[]
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

  await load()
}

// 文件上传方法



const fileList = ref([


])

const fileList1 = ref([


])



const handleRemove = (uploadFile, uploadFiles) => {
  console.log(uploadFile, uploadFiles)

}
const handleRemove1 = (uploadFile, uploadFiles) => {
  console.log(uploadFile, uploadFiles)

}


const handlePreview= (file) => {
  console.log(file)
}
const handlePreview1= (file) => {
  console.log(file)
}
const handleSucess=(res)=>{
  fileList.value[fileList.value.length-1].url=res.data
  console.log(fileList.value)

}
const handleSucess1=(res)=>{
  fileList1.value[fileList1.value.length-1].url=res.data
  console.log(fileList1.value)

}
</script>
<template>


  <el-card style="width: 750px;">
    <el-page-header @back="$route.go(-1)">

    </el-page-header>
    <el-form
        ref="ruleFormRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        class="ruleForm"
        :size="formSize"
        status-icon
    >

      <el-form-item label="商品名称" prop="name">
        <el-input v-model="form.name"/>
      </el-form-item>
      <el-form-item label="商品图片" prop="img">
        <el-upload
            v-model:file-list="fileList"
            class="upload-demo"
            action="http://localhost:9090/api/file/upload"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :on-success="handleSucess"
            list-type="picture"
        >
          <el-button type="primary">点击上传</el-button>
          <template #tip>
            <div class="el-upload__tip">

            </div>
          </template>
        </el-upload>
      </el-form-item>
      <el-row>
        <el-col :span="8">
          <el-form-item label="商品单价" prop="price">
            <el-input-number v-model="form.price" step="0.1" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="商品库存" prop="store">
            <el-input-number v-model="form.store"/>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row>
        <el-col :span="6">
          <el-form-item label="是否上架" prop="isShow">

            <el-switch
                v-model="form.isShow"
                :active-value="1"
                :inactive-value="0"
                inline-prompt
                active-text="上架"
                inactive-text="下架"
                style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
            />

          </el-form-item>

        </el-col>
        <el-col :span="12">
          <el-form-item label="是否推荐" prop="isRecommand">
            <el-switch
                v-model="form.isRecommand"
                :active-value="1"
                :inactive-value="0"
                inline-prompt
                active-text="推荐"
                inactive-text="不推荐"
                style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
            />
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="所属类型" prop="cid">
        <el-select v-model="form.cid" placeholder="选择分类">
          <el-option
              v-for="(item,index) in categoryList"
              :label="item.name"
              :value="item.id"
              :key="index.toString()"
          ></el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="商品详情" prop="content">
        <el-upload
            v-model:file-list="fileList1"
            class="upload-demo"
            action="http://localhost:9090/api/file/upload"
            :on-preview="handlePreview1"
            :on-remove="handleRemove1"
            :on-success="handleSucess1"
            list-type="picture"
        >
          <el-button type="primary">点击上传</el-button>
          <template #tip>
            <div class="el-upload__tip">

            </div>
          </template>
        </el-upload>
      </el-form-item>


    </el-form>

    <div style="width: 100%;display: flex;justify-content: center">

      <el-button type="primary" @click="handleSubmitForm(ruleFormRef)"> 立即提交</el-button>
      <el-button @click="handleResetForm(ruleFormRef)">取消添加</el-button>
    </div>
  </el-card>


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
