import { router, window } from '@kit.ArkUI';
import log from '../utils/log';
import { Captcha,RegisterDto } from '../common/commonInterface'
import Result from '../utils/result'
import request from '../utils/request'
import Elmessage from '../utils/elmessage';
import Back from './component/back'
import { HashMap } from '@kit.ArkTS';


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
  getUserInfo = async () => {
    const res: Result<HashMap<string, object>> = await request.get(`/auth/authInfo`)
    this.form = res.data['userInfo'] as RegisterDto

  }

  /**
   * 当页面加载
   */
  onPageShow(): void {
    this.getUserInfo()
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
  validateContent=():boolean=>{

      if (this.form.content === '') {
        this.formerror.content = '*用户简介不能为空'
        return false

      } else {
        this.formerror.content = ''
        return true
      }
}
  /**
   * 校验表单
   */
  validateForm = (): void => {
    // 整体校验

    const vNickName: boolean = this.validateNickName()
    const vPhone: boolean = this.validatePhone()

    const vContent:boolean=this.validateContent()
    const vEmall: boolean = this.validateEmall()

    //   整体判断
    if ( vNickName && vPhone  && vEmall &&vContent) {
      //   确认密码校验

        this.fields = true

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
      await request.put(`/user`, this.form)
      AppStorage.setOrCreate('index',3)
      router.clear()
      router.replaceUrl({ url: 'pages/Index' })
      Elmessage.success('修改成功！')

    } else {
      this.getUserInfo()
    }
  }

  build() {
    Column() {
      /**
       * 第一行返回图标
       */
      Back({
        url:'pages/Index'
      })



      /**
       * 第三行注册表单
       * 不指定高度
       */
      Column() {


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
        // 个人简介
        Column({ space: 5 }) {
          TextArea({
            placeholder: '请输入个人简介',
            text: this.form.content
          }).onChange((value) => this.form.content = value).onBlur(() => {
            this.validateContent()
          }).height(100)
          if (this.formerror.content) {
            Text(this.formerror.content).commonTextValidate()
          }
        }.alignItems(HorizontalAlign.Start)
        // 立即修改
        Button('立即修改').width('100%').onClick(() => {
          this.register()
        }).margin({top:10})
      }.width('100%').height('80%').padding(20)
    }.width('100%').height('100%').backgroundColor('#ededed')
  }
}