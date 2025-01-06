import Back from './component/back';

import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import request from '../utils/request';
import Result from '../utils/result'
import { AddressRecord } from './Address'
import { MenuItemModifier } from '@ohos.arkui.modifier'
@Extend(Text)
function commonTextValidate() {
  .fontColor(Color.Red)
  .fontSize(10)
}

@Extend(Column)
function commonColumnStyle() {
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}
export interface AddressList{
  value:string
  children:AddressList[]|undefined
}
//todo 需要将路由信息添加到main_pages.json文件中:"pages/AddressAdd"
@Entry
@Component
struct AddressAdd {
  @State fields: boolean = false
  @State form: AddressRecord = {
    id: '',
    name: '',
    phone: '',

    content: '',
    username: '',
    isDefault: 0
  }
  @State formError: AddressRecord = {
    id: '',
    name: '',
    phone: '',

    content: '',
    username: '',
    isDefault: 0
  }

  //   初始加载
  onPageShow(): void {
    const params: object = router.getParams()
    const fid: undefined | number | string = params['id'] as number
    if (fid) {
      this.load(fid)
    }
  }

  load = async (id: number | undefined) => {
    const res: Result<AddressRecord> = await request.get(`/address/${id}`)
    this.form = res.data
  }
  validatename = (): boolean => {
    if (this.form.name === '') {
      this.formError.name = '*必选项不能为空'
      return false
    } else {
      this.formError.name = ''
      return true
    }
  }
  validatephone = (): boolean => {
    if (this.form.phone === '') {
      this.formError.phone = '*必选项不能为空'
      return false
    } else {
      this.formError.phone = ''
      return true
    }
  }


  validatecontent = (): boolean => {
    if (this.form.content === '') {
      this.formError.content = '*必选项不能为空'
      return false
    } else {
      this.formError.content = ''
      return true
    }
  }

  validateForm = () => {
    const vname = this.validatename()
    const vphone = this.validatephone()

    const vcontent = this.validatecontent()

    if (vname && vphone && vcontent ) {
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
      url: this.form.id ? `/address/${this.form.id}` : `/address`,
      method: this.form.id ? 'put' : 'post',
      data: this.form
    })
    router.replaceUrl({ url: 'pages/Address' })
    Elmessage.success('操作成功！')

  }

  build() {
    Column() {
      Back({ url: 'pages/Address' })
      Scroll() {
        Column() {
          Column() {
            //此处开始遍历
            Column({ space: 5 }) {
              TextInput({
                placeholder: '请输入姓名',
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
                placeholder: '请输入手机号',
                text: this.form.phone
              }).onChange((value) => this.form.phone = value).onBlur(() => {
                this.validatephone()
              })
              if (this.formError.name) {
                Text(this.formError.name).commonTextValidate()
              }
            }.commonColumnStyle()










            Column({ space: 5 }) {
              TextArea({
                placeholder: '请输入详细地址',
                text: this.form.content
              }).height('80').onChange((value) => this.form.content = value).onBlur(() => {
                this.validatecontent()
              })
              if (this.formError.name) {
                Text(this.formError.name).commonTextValidate()
              }
            }.alignItems(HorizontalAlign.Start).height('13%')




            Row({ space: 5 }) {
              Button('取消').width('30%').onClick(() => {
                router.replaceUrl({ url: 'pages/Address' })
              }).backgroundColor(Color.Gray)
              Button('提交').width('30%').onClick(() => {
                this.submit()
              })
            }.justifyContent(FlexAlign.Center)
          }.padding(20).margin({top:5})
        }
      }.width('100%').height('93%').align(Alignment.TopStart)
    }.width('100%').height('100%')
  }
}




