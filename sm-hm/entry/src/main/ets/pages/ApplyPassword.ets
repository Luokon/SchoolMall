import { router, window } from '@kit.ArkUI';
import log from '../utils/log';
import { Captcha,RegisterDto } from '../common/commonInterface'
import Result from '../utils/result'
import request from '../utils/request'
import Elmessage from '../utils/elmessage';
import Back from './component/back'

interface PasswordDto{
  oldpass:string,
  password:string,
  applyPassword:string
}

/**
 * 通用样式
 * commonvalidateStyle
 */

@Extend(Text)
function commonTextValidate() {
  .fontColor(Color.Red)
  .fontSize(10)
}

@Extend(Column)
function commonColumnStyle(){
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}

@Entry
@Component
struct ApplyPassword {

  @State fields: boolean = false
  @State form: PasswordDto = {
    oldpass: '',
    password: '',
    applyPassword: ''
  }
  @State formerror: PasswordDto = {
    oldpass: '',
    password: '',
    applyPassword: ''
  }





  /**
   * 全屏显示
   */
  aboutToAppear(): void {
    window.getLastWindow(getContext())
      .then(win => {
        win.setWindowLayoutFullScreen(true)
      })
  }
  /**
   * 校验老密码
   */
  validateOldPass = (): boolean => {

    if (this.form.oldpass.length < 5 || this.form.oldpass === '') {
      this.formerror.oldpass = '*密码为5到10位字符串'
      return false

    } else {
      this.formerror.oldpass = ''
      return true
    }
  }

  /**
   * 校验密码
   */
  validatePass = (): boolean => {
    if (this.form.applyPassword.length !=6) {
      this.formerror.applyPassword = '*支付密码为6位数字'
      return false

    } else {
      this.formerror.applyPassword = ''
      return true
    }
  }




  /**
   * 校验表单
   */
  validateForm = (): void => {
    // 整体校验

    const vPass: boolean = this.validatePass()
    const vOldPass: boolean = this.validateOldPass()


    //   整体判断
    if ( vPass &&vOldPass) {
        this.fields = true

    } else {
      this.fields = false
    }
  }
  /**
   * 注册方法
   */
  submit = async () => {
    this.validateForm()
    if (this.fields) {
      await request.post(`/auth/setApplyPassword`, this.form)
      Elmessage.success('修改成功')
      router.back({url:'pages/Index'})
    } else {

    }
  }

  build() {
    Column() {
      /**
       * 第一行返回图标
       */

      Back({url:'pages/Index'})

      /**
       * 第二行注册图片
       */
      Column() {
        Image($r("app.media.warn")).width(200)
      }.width('100%').height('20%')

      /**
       * 第三行注册表单
       * 不指定高度
       */
      Column() {
        // 原密码
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入登录密码',
            text: this.form.oldpass
          }).maxLength(10).type(InputType.Password).onChange((value) => this.form.oldpass = value).onBlur(() => {
            this.validateOldPass()
          })
          if (this.formerror.oldpass) {
            Text(this.formerror.oldpass).commonTextValidate()
          }
        }.commonColumnStyle()
        // 新密码
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入6位支付密码',
            text: this.form.applyPassword
          }).maxLength(6).type(InputType.NUMBER_PASSWORD).onChange((value) => this.form.applyPassword = value).onBlur(() => {
            this.validatePass()
          })
          if (this.formerror.applyPassword) {
            Text(this.formerror.applyPassword).commonTextValidate()
          }
        }.commonColumnStyle()





        // 立即登录
        Button('立即提交').width('50%').onClick(() => {
          this.submit()
        })
      }.width('100%').height('80%').padding(20)
    }.width('100%').height('100%').backgroundColor('#ededed')
  }
}