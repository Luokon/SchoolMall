import Back from './component/back';

import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import request from '../utils/request';
import Result from '../utils/result'
import {MessageRecord } from './Message'
@Extend(Text)
function commonTextValidate() {
  .fontColor(Color.Red)
  .fontSize(10)
}
@Extend(Column)
function commonColumnStyle() {
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}

@Entry
@Component
struct MessageAdd {

  @State fields: boolean = false
  @State form: MessageRecord = {
    id: undefined,
    name: '',
    des: '',
    createTime: '',
    username: '',
    reply: '',
    statu: 0
  };
  @State formError: MessageRecord = {
    id: undefined,
    name: '',
    des: '',
    createTime: '',
    username: '',
    reply: '',
    statu: 0
  }
//   初始加载
onPageShow():void{
    const params:object=router.getParams()
    const fid:undefined|number=params['id'] as number
    if(fid){
     this.load(fid)
    }
  }
  load=async (id:number|undefined)=>{
    const res:Result<MessageRecord>=  await request.get(`/message/${id}`)
    this.form=res.data
  }

  validateDes = (): boolean => {
    if (this.form.des === '') {
      this.formError.des = '*详情不能为空'
      return false

    } else {
      this.formError.des = ''
      return true
    }
  }
  validateName = (): boolean => {
    if (this.form.name === '') {
      this.formError.name = '*标题不能为空'
      return false

    } else {
      this.formError.name = ''
      return true
    }
  }
  validateForm = () => {
    const VName = this.validateName()
    const VDes = this.validateDes()
    if (VName==true &&  VDes==true  ) {
      this.fields = true

    } else {
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
      url: this.form.id ? `/message/${this.form.id}` : `/message`,
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
            // 标题
            Column({ space: 5 }) {
              TextInput({
                placeholder: '请输入标题',
                text: this.form.name
              }).maxLength(10).onChange((value) => this.form.name = value).onBlur(() => {
                this.validateName()
              })
              if (this.formError.name) {
                Text(this.formError.name).commonTextValidate()
              }
            }.commonColumnStyle()

            Column({ space: 5 }) {
              TextArea({
                placeholder: '请输入详情',
                text: this.form.des
              }).height('80').onChange((value) => this.form.des = value).onBlur(() => {
                this.validateDes()
              }).onSubmit(() => {
                this.submit()
              })
              if (this.formError.des) {
                Text(this.formError.des).commonTextValidate()
              }
            }.width('100%').height('14%').alignItems(HorizontalAlign.Start)

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