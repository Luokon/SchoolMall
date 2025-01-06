import { router, window } from '@kit.ArkUI';
import log from '../utils/log';
import { Captcha, RegisterDto } from '../common/commonInterface'
import Result from '../utils/result'
import request from '../utils/request'
import Elmessage from '../utils/elmessage';
import Back from './component/back'

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
function commonColumnStyle() {
  .alignItems(HorizontalAlign.Start).width('100%').height('10%')
}

@Entry
@Component
struct Forget {
  @State message: string = '找回密码页面';
  @State fields: boolean = false
  @State form: RegisterDto = {
    username: '',
    password: '',
    checkPass: '',
    nickname: '',
    avatar: '',
    phone: '',
    email: '',
    content: '',
    token: '',
    code: '',
    balance: 0,
    applyPassword: ''
  }
  @State formerror: RegisterDto = {
    username: '',
    password: '',
    checkPass: '',
    nickname: '',
    avatar: '',
    phone: '',
    email: '',
    content: '',
    token: '',
    code: '',
    balance: 0,
    applyPassword: ''
  }
  /**
   * 校验账户名
   */
  validateUserName = (): boolean => {
    if (this.form.username.length < 5 || this.form.username === '') {
      this.formerror.username = '*账户名为5到10位的字符串'
      return false

    } else {
      this.formerror.username = ''
      return true
    }
  }
  /**
   * 校验密码
   */
  validateCheckPass = (): boolean => {
    if (this.form.checkPass.length < 5 || this.form.checkPass === '') {
      this.formerror.checkPass = '*密码为5到10位字符串'
      return false
    } else {
      this.formerror.checkPass = ''
      return true
    }
  }
  /**
   * 校验验证码
   */
  validateCode = (): boolean => {
    if (this.form.code.length != 5 || this.form.code === '') {
      this.formerror.code = '*验证码为5位数字'
      return false
    } else {
      this.formerror.code = ''
      return true
    }
  }
  /**
   * 校验密码
   */
  validatePass = (): boolean => {
    if (this.form.password.length < 5 || this.form.password === '') {
      this.formerror.password = '*密码为5到10位字符串'
      return false

    } else {
      this.formerror.password = ''
      return true
    }
  }
  /**
   * 发送邮箱验证码
   */
  sendcode = async () => {
    const vUserName: boolean = this.validateUserName()

    const vPass: boolean = this.validatePass()
    const vCheckPass: boolean = this.validateCheckPass()
    if (vUserName && vPass && vCheckPass) {
      if (this.form.password != this.form.checkPass) {
        this.formerror.checkPass = '*两次密码输入不一致'
        return
      }
      await request.get(`/auth/email/${this.form.username}`)
      Elmessage.success('发送成功，有效时间为5分钟！')
    }

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
   * 校验表单
   */
  validateForm = (): void => {
    // 整体校验
    const vUserName: boolean = this.validateUserName()

    const vPass: boolean = this.validatePass()
    const vCheckPass: boolean = this.validateCheckPass()

    const vCode: boolean = this.validateCode()
    //   整体判断
    if (vUserName &&  vPass && vCheckPass  && vCode) {
      //   确认密码校验
      if (this.form.checkPass != this.form.password) {
        this.formerror.checkPass = '*两次密码输入不一致'
        this.fields = false
        return
      } else {
        this.fields = true
      }
    } else {
      this.fields = false
    }
  }
  /**
   * 提交表单
   */

  submit=async ()=> {
   this.validateForm()
    if (this.fields) {
      await request.post(`/auth/findpassword`,this.form)
      Elmessage.success('重置成功，请登录！')
    }else{
      return
    }
  }

  build() {
    Column() {
      // 01返回组件
      Back({ url: 'pages/Login' })
      //   02forget图标
      Column() {
        Image($r("app.media.forget")).width(100)
      }.width('100%').height('10%')

      //   03忘记密码(账户名、新密码、确认密码、邮箱验证码、立即修改)
      Column() {
        // 账户名
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入账户名',
            text: this.form.username
          }).maxLength(10).onChange((value) => this.form.username = value).onBlur(() => {
            this.validateUserName()
          })
          if (this.formerror.username) {
            Text(this.formerror.username).commonTextValidate()
          }
        }.commonColumnStyle()

        // 密码
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入密码',
            text: this.form.password
          }).maxLength(10).type(InputType.Password).onChange((value) => this.form.password = value).onBlur(() => {
            this.validatePass()
          })
          if (this.formerror.password) {
            Text(this.formerror.password).commonTextValidate()
          }
        }.commonColumnStyle()

        // 确认密码
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请确认密码',
            text: this.form.checkPass
          }).maxLength(10).type(InputType.Password).onChange((value) => this.form.checkPass = value).onBlur(() => {
            this.validateCheckPass()
          })
          if (this.formerror.checkPass) {
            Text(this.formerror.checkPass).commonTextValidate()
          }
        }.commonColumnStyle()

        // 邮箱验证码
        Column({ space: 5 }) {
          Row() {
            TextInput({
              placeholder: '请输入5位验证码',
              text: this.form.code
            })
              .width('55%')
              .maxLength(5)
              .onChange((value) => this.form.code = value)
              .onBlur(() => {
                this.validateCode()
              })
              .onSubmit(() => {
                this.submit()
              })
            Button('发送验证码').backgroundColor('#c1ff0000').fontColor(Color.Black)
              .margin({ left: '5%' })
              .onClick(() => {
                this.sendcode()
              })
          }.width('100%')

          if (this.formerror.code) {
            Text(this.formerror.code).commonTextValidate()
          }
        }.commonColumnStyle()

        //立即重置
        Button('立即重置').width('100%').backgroundColor('#626aef').onClick(()=>{this.submit()})
      }.width('100%').height('80%').padding(20)

    }
    .height('100%')
    .width('100%').backgroundColor('#ededed')
  }
}