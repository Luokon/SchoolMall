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
  checkPass:string
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
struct Register {
  @State message: string = 'Hello World';
  @State fields: boolean = false
  @State form: PasswordDto = {
    oldpass: '',
    password: '',
    checkPass: ''
  }
  @State formerror: PasswordDto = {
    oldpass: '',
    password: '',
    checkPass: ''
  }
  @State captchaImg: string = ''
  // 创建一个页面栈对象并传入Navigation
  pageStack: NavPathStack = new NavPathStack()
  /**
   *获取验证码
   */



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
    if (this.form.password.length < 5 || this.form.password === '') {
      this.formerror.password = '*密码为5到10位字符串'
      return false

    } else {
      this.formerror.password = ''
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
   * 校验表单
   */
  validateForm = (): void => {
    // 整体校验

    const vPass: boolean = this.validatePass()
    const vOldPass: boolean = this.validateOldPass()
    const vCheckPass: boolean = this.validateCheckPass()

    //   整体判断
    if ( vPass && vCheckPass&&vOldPass ) {
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
   * 注册方法
   */
  submit = async () => {
    this.validateForm()
    if (this.fields) {
      await request.post(`/auth/repassword`, this.form)
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
            placeholder: '请输入原密码',
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
            placeholder: '请输入新密码',
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
            placeholder: '请确认新密码',
            text: this.form.checkPass
          }).maxLength(10).type(InputType.Password).onChange((value) => this.form.checkPass = value).onBlur(() => {
            this.validateCheckPass()
          })
          if (this.formerror.checkPass) {
            Text(this.formerror.checkPass).commonTextValidate()
          }
        }.commonColumnStyle()




        // 立即登录
        Button('立即修改').width('100%').onClick(() => {
          this.submit()
        })
      }.width('100%').height('80%').padding(20)
    }.width('100%').height('100%').backgroundColor('#ededed')
  }
}