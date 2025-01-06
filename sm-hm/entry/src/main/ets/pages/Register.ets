import { router, window } from '@kit.ArkUI';
import log from '../utils/log';
import { Captcha,RegisterDto } from '../common/commonInterface'
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
function commonColumnStyle(){
  .alignItems(HorizontalAlign.Start).width('100%').height('9%')
}

@Entry
@Component
struct Register {
  @State message: string = 'Hello World';
  @State fields: boolean = false
  @State form: RegisterDto = {
    username: '',
    password: '',
    checkPass: '',
    nickname: '',
    avatar: 'https://wpimg.wallstcn.com/f778738c-e4f8-4870-b634-56703b4acafe.gif',
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
  @State captchaImg: string = ''
  // 创建一个页面栈对象并传入Navigation
  pageStack: NavPathStack = new NavPathStack()
  /**
   *获取验证码
   */
  getCaptcha = async () => {
    const res: Result<Captcha> = await request.get(`/auth/captcha`)
    this.form.token = res.data.token
    this.form.code = ''
    this.captchaImg = res.data.captchaImg
  }

  /**
   * 当页面加载
   */
  onPageShow(): void {
    this.getCaptcha()
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
  /*
  校验昵称
   */
  validateNickName = (): boolean => {
    if (this.form.nickname === '') {
      this.formerror.nickname = '*用户昵称不能为空'
      return false

    } else {
      this.formerror.nickname = ''
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
   * 校验手机号
   *
   */
  validatePhone = (): boolean => {
    const phonePattern = /^1[3-9]\d{9}$/; // 中国大陆手机号码正则表达式
    if (!phonePattern.test(this.form.phone)) {
      this.formerror.phone = '*手机号码格式不正确'
      return false
    } else {
      this.formerror.phone = ''
      return true
    }
  }
  /**
   * 校验邮箱
   */
  validateEmall = (): boolean => {
    log.info(this.form.email)
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // 常见邮箱格式正则表达式
    if (!emailPattern.test(this.form.email)) {
      this.formerror.email = '*邮箱格式不正确'
      return false
    } else {
      this.formerror.email = ''
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
   * 校验表单
   */
  validateForm = (): void => {
    // 整体校验
    const vUserName: boolean = this.validateUserName()
    const vNickName: boolean = this.validateNickName()
    const vPhone: boolean = this.validatePhone()
    const vPass: boolean = this.validatePass()
    const vCheckPass: boolean = this.validateCheckPass()
    const vEmall: boolean = this.validateEmall()
    const vCode: boolean = this.validateCode()
    //   整体判断
    if (vUserName && vNickName && vPhone && vPass && vCheckPass && vEmall && vCode) {
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
  register = async () => {
    this.validateForm()
    if (this.fields) {
      await request.post(`/auth/register`, this.form)
      Elmessage.success('注册成功,请登录！')
      router.back({ url: 'pages/Login' })
    } else {
      this.getCaptcha()
    }
  }

  build() {
    Column() {
      /**
       * 第一行返回图标
       */
     Back({
       url:'pages/Login'
     })

      /**
       * 第二行注册图片
       */
      Column() {
        Image($r("app.media.add")).width(100)
      }.width('100%').height('10%')

      /**
       * 第三行注册表单
       * 不指定高度
       */
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
        // 昵称
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入昵称',
            text: this.form.nickname
          }).maxLength(5).onChange((value) => this.form.nickname = value).onBlur(() => {
            this.validateNickName()
          })
          if (this.formerror.nickname) {
            Text(this.formerror.nickname).commonTextValidate()
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
        // 手机号码
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入手机号码',
            text: this.form.phone
          }).maxLength(11).type(InputType.PhoneNumber).onChange((value) => this.form.phone = value).onBlur(() => {
            this.validatePhone()
          })
          if (this.formerror.phone) {
            Text(this.formerror.phone).commonTextValidate()
          }
        }.commonColumnStyle()
        // 邮箱
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入邮箱',
            text: this.form.email
          }).type(InputType.Email).onChange((value) => this.form.email = value).onBlur(() => {
            this.validateEmall()
          })
          if (this.formerror.email) {
            Text(this.formerror.email).commonTextValidate()
          }
        }.commonColumnStyle()
        // 验证码
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
                this.register()
              })
            Image(this.captchaImg)
              .width('40%')
              .height(40)
              .borderRadius(20)
              .margin({ left: '5%' })
              .onClick(() => {
                this.getCaptcha()
              })
          }.width('100%')

          if (this.formerror.code) {
            Text(this.formerror.code).commonTextValidate()
          }
        }.commonColumnStyle()

        // 立即登录
        Button('立即注册').width('100%').onClick(() => {
          this.register()
        })
      }.width('100%').height('80%').padding(20)
    }.width('100%').height('100%').backgroundColor('#ededed')
  }
}