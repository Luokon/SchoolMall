import Back from './component/back';
import { MessageRecord } from './component/message'
import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import request from '../utils/request';
import Result from '../utils/result'
import {OrderRecord} from './component/Order'
@Extend(Text)
function commonTextValidate() {
  .fontColor(Color.Red)
  .fontSize(10)
}
@Extend(Column)
function commonColumnStyle() {
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}
//todo 需要将路由信息添加到main_pages.json文件中:"pages/OrderAdd"
@Entry
@Component
struct OrderAdd {
  @State fields: boolean = false
  @State form: OrderRecord = {
    id:'',
    name:'',
    username:'',
    gid:'',
    scount:'',
    goods:'',
    aid:'',
    address:'',
    statu:'',
    total:'',
  }
  @State formError: OrderRecord = {
    id:'',
    name:'',
    username:'',
    gid:'',
    scount:'',
    goods:'',
    aid:'',
    address:'',
    statu:'',
    total:'',
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
    const res:Result<OrderRecord>=  await request.get(`/order/${id}`)
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
        validateusername= (): boolean => {
      if (this.form.username === '') {
      this.formError.username = '*必选项不能为空'
      return false
      } else {
      this.formError.username = ''
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
        validatescount= (): boolean => {
      if (this.form.scount === '') {
      this.formError.scount = '*必选项不能为空'
      return false
      } else {
      this.formError.scount = ''
      return true
      }
      }
        validategoods= (): boolean => {
      if (this.form.goods === '') {
      this.formError.goods = '*必选项不能为空'
      return false
      } else {
      this.formError.goods = ''
      return true
      }
      }
        validateaid= (): boolean => {
      if (this.form.aid === '') {
      this.formError.aid = '*必选项不能为空'
      return false
      } else {
      this.formError.aid = ''
      return true
      }
      }
        validateaddress= (): boolean => {
      if (this.form.address === '') {
      this.formError.address = '*必选项不能为空'
      return false
      } else {
      this.formError.address = ''
      return true
      }
      }
        validatestatu= (): boolean => {
      if (this.form.statu === '') {
      this.formError.statu = '*必选项不能为空'
      return false
      } else {
      this.formError.statu = ''
      return true
      }
      }
        validatetotal= (): boolean => {
      if (this.form.total === '') {
      this.formError.total = '*必选项不能为空'
      return false
      } else {
      this.formError.total = ''
      return true
      }
      }

  validateForm = () => {
      const vname=this.validatename()
      const vusername=this.validateusername()
      const vgid=this.validategid()
      const vscount=this.validatescount()
      const vgoods=this.validategoods()
      const vaid=this.validateaid()
      const vaddress=this.validateaddress()
      const vstatu=this.validatestatu()
      const vtotal=this.validatetotal()
    if (vname && vusername && vgid && vscount && vgoods && vaid && vaddress && vstatu && vtotal)
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
      url: this.form.id ? `/order/${this.form.id}` : `/order`,
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
    placeholder:   '请输入订单编号',
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
    placeholder:   '请输入创建账户',
    text: this.form.username
    }).onChange((value) => this.form.username = value).onBlur(() => {
      this.validateusername()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入所属商品',
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
    placeholder:   '请输入订单数量',
    text: this.form.scount
    }).onChange((value) => this.form.scount = value).onBlur(() => {
      this.validatescount()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入商品信息',
    text: this.form.goods
    }).onChange((value) => this.form.goods = value).onBlur(() => {
      this.validategoods()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入所属订单',
    text: this.form.aid
    }).onChange((value) => this.form.aid = value).onBlur(() => {
      this.validateaid()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入地址信息',
    text: this.form.address
    }).onChange((value) => this.form.address = value).onBlur(() => {
      this.validateaddress()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入当前状态',
    text: this.form.statu
    }).onChange((value) => this.form.statu = value).onBlur(() => {
      this.validatestatu()
    })
    if (this.formError.name) {
    Text(this.formError.name).commonTextValidate()
    }
    }.commonColumnStyle()



    Column({ space: 5 }) {
    TextInput({
    placeholder:   '请输入订单金额',
    text: this.form.total
    }).onChange((value) => this.form.total = value).onBlur(() => {
      this.validatetotal()
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