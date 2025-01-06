import Back from './component/back';
import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import request from '../utils/request';
import Result from '../utils/result'
import {GoodsRecord} from './component/goods'
@Extend(Text)
function commonTextValidate() {
  .fontColor(Color.Red)
  .fontSize(10)
}
@Extend(Column)
function commonColumnStyle() {
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}
//todo 需要将路由信息添加到main_pages.json文件中:"pages/GoodsAdd"
@Entry
@Component
struct GoodsAdd {
  @State fields: boolean = false
  @State form: GoodsRecord = {
    id:'',
    name:'',
    img:'',
    price:'',
    store:'',
    sales:'',
    isShow:'',
    isRecommand:'',
    cid:'',
    content:'',
    createTime:'',
    updateTime:'',
    username:'',
  }
  @State formError: GoodsRecord = {
    id:'',
    name:'',
    img:'',
    price:'',
    store:'',
    sales:'',
    isShow:'',
    isRecommand:'',
    cid:'',
    content:'',
    createTime:'',
    updateTime:'',
    username:'',
  }
//   初始加载
onPageShow():void{
    const params:object=router.getParams()
    const fid:undefined|number|string=params['id'] as number
    if(fid){
     this.load(fid)
    }
  }
  load=async (id:number|undefined)=>{
    const res:Result<GoodsRecord>=  await request.get(`/goods/${id}`)
    this.form=res.data
  }
        validatename= (): boolean => {
      if (this.form.name === '') {
      this.formError.name = '*必选项不能为空'
      return false
      } else {
      this.formError.name = ''
      return true
      }
      }
        validateimg= (): boolean => {
      if (this.form.img === '') {
      this.formError.img = '*必选项不能为空'
      return false
      } else {
      this.formError.img = ''
      return true
      }
      }
        validateprice= (): boolean => {
      if (this.form.price === '') {
      this.formError.price = '*必选项不能为空'
      return false
      } else {
      this.formError.price = ''
      return true
      }
      }
        validatestore= (): boolean => {
      if (this.form.store === '') {
      this.formError.store = '*必选项不能为空'
      return false
      } else {
      this.formError.store = ''
      return true
      }
      }
        validatesales= (): boolean => {
      if (this.form.sales === '') {
      this.formError.sales = '*必选项不能为空'
      return false
      } else {
      this.formError.sales = ''
      return true
      }
      }
        validateisShow= (): boolean => {
      if (this.form.isShow === '') {
      this.formError.isShow = '*必选项不能为空'
      return false
      } else {
      this.formError.isShow = ''
      return true
      }
      }
        validateisRecommand= (): boolean => {
      if (this.form.isRecommand === '') {
      this.formError.isRecommand = '*必选项不能为空'
      return false
      } else {
      this.formError.isRecommand = ''
      return true
      }
      }
        validatecid= (): boolean => {
      if (this.form.cid === '') {
      this.formError.cid = '*必选项不能为空'
      return false
      } else {
      this.formError.cid = ''
      return true
      }
      }
        validatecontent= (): boolean => {
      if (this.form.content === '') {
      this.formError.content = '*必选项不能为空'
      return false
      } else {
      this.formError.content = ''
      return true
      }
      }
        validatecreateTime= (): boolean => {
      if (this.form.createTime === '') {
      this.formError.createTime = '*必选项不能为空'
      return false
      } else {
      this.formError.createTime = ''
      return true
      }
      }
        validateupdateTime= (): boolean => {
      if (this.form.updateTime === '') {
      this.formError.updateTime = '*必选项不能为空'
      return false
      } else {
      this.formError.updateTime = ''
      return true
      }
      }
        validateusername= (): boolean => {
      if (this.form.username === '') {
      this.formError.username = '*必选项不能为空'
      return false
      } else {
      this.formError.username = ''
      return true
      }
      }

  validateForm = () => {
      const vname=this.validatename()
      const vimg=this.validateimg()
      const vprice=this.validateprice()
      const vstore=this.validatestore()
      const vsales=this.validatesales()
      const visShow=this.validateisShow()
      const visRecommand=this.validateisRecommand()
      const vcid=this.validatecid()
      const vcontent=this.validatecontent()
      const vcreateTime=this.validatecreateTime()
      const vupdateTime=this.validateupdateTime()
      const vusername=this.validateusername()
    if (vname && vimg && vprice && vstore && vsales && visShow && visRecommand && vcid && vcontent && vcreateTime && vupdateTime && vusername)
    {
      this.fields = true
    }
   else
    {
      this.fields = false
    }

}
  // 提交事件方法
  submit = async () => {
    this.validateForm()
    if (!this.fields) {
      return
    }
    await request({
      url: this.form.id ? `/goods/${this.form.id}` : `/goods`,
      method: this.form.id ? 'put' : 'post',
      data: this.form
    })
    router.replaceUrl({ url: 'pages/Index' })
    Elmessage.success('操作成功！')

  }

  build() {
    Column() {
      Back({ url: 'pages/Index' })
Scroll() {
Column() {
Column() {
//此处开始遍历



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品名称',
    text: this.form.name
    }).onChange((value) => this.form.name = value).onBlur(() => {
      this.validatename()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品图片',
    text: this.form.img
    }).onChange((value) => this.form.img = value).onBlur(() => {
      this.validateimg()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品单价',
    text: this.form.price
    }).onChange((value) => this.form.price = value).onBlur(() => {
      this.validateprice()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品库存',
    text: this.form.store
    }).onChange((value) => this.form.store = value).onBlur(() => {
      this.validatestore()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品销量',
    text: this.form.sales
    }).onChange((value) => this.form.sales = value).onBlur(() => {
      this.validatesales()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入是否上架',
    text: this.form.isShow
    }).onChange((value) => this.form.isShow = value).onBlur(() => {
      this.validateisShow()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入是否推荐',
    text: this.form.isRecommand
    }).onChange((value) => this.form.isRecommand = value).onBlur(() => {
      this.validateisRecommand()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入所属类型',
    text: this.form.cid
    }).onChange((value) => this.form.cid = value).onBlur(() => {
      this.validatecid()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品详情',
    text: this.form.content
    }).onChange((value) => this.form.content = value).onBlur(() => {
      this.validatecontent()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入创建时间',
    text: this.form.createTime
    }).onChange((value) => this.form.createTime = value).onBlur(() => {
      this.validatecreateTime()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入修改时间',
    text: this.form.updateTime
    }).onChange((value) => this.form.updateTime = value).onBlur(() => {
      this.validateupdateTime()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入创建账户',
    text: this.form.username
    }).onChange((value) => this.form.username = value).onBlur(() => {
      this.validateusername()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()


Row({ space: 5 }) {
Button('取消').width('30%').onClick(() => {
router.replaceUrl({ url: 'pages/Index' })
}).backgroundColor(Color.Gray)
Button('提交').width('30%').onClick(() => {
this.submit()
})
}.justifyContent(FlexAlign.Center)
}.padding(20)
}
}.width('100%').height('93%').align(Alignment.TopStart)
    }.width('100%').height('100%')
  }
}