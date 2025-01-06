import Back from './component/back';
import { MessageRecord } from './component/message'
import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import request from '../utils/request';
import Result from '../utils/result'
import {CartRecord} from './component/Cart'
@Extend(Text)
function commonTextValidate() {
  .fontColor(Color.Red)
  .fontSize(10)
}
@Extend(Column)
function commonColumnStyle() {
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}
//todo 需要将路由信息添加到main_pages.json文件中:"pages/CartAdd"
@Entry
@Component
struct CartAdd {
  @State fields: boolean = false
  @State form: CartRecord = {
    id:'',
    name:'',
    gid:'',
    time:'',
  }
  @State formError: CartRecord = {
    id:'',
    name:'',
    gid:'',
    time:'',
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
    const res:Result<CartRecord>=  await request.get(`/cart/${id}`)
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
        validategid= (): boolean => {
      if (this.form.gid === '') {
      this.formError.gid = '*必选项不能为空'
      return false
      } else {
      this.formError.gid = ''
      return true
      }
      }
        validatetime= (): boolean => {
      if (this.form.time === '') {
      this.formError.time = '*必选项不能为空'
      return false
      } else {
      this.formError.time = ''
      return true
      }
      }

  validateForm = () => {
      const vname=this.validatename()
      const vgid=this.validategid()
      const vtime=this.validatetime()
    if (vname && vgid && vtime)
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
      url: this.form.id ? `/cart/${this.form.id}` : `/cart`,
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
    placeholder:   '请输入创建账户',
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
    placeholder:   '请输入商品编号',
    text: this.form.gid
    }).onChange((value) => this.form.gid = value).onBlur(() => {
      this.validategid()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入创建时间',
    text: this.form.time
    }).onChange((value) => this.form.time = value).onBlur(() => {
      this.validatetime()
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