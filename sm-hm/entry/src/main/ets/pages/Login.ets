import Constant from '../common/Constant';
import Result from '../utils/result'
import request from '../utils/request'
import Elmessage from '../utils/elmessage';
import { promptAction, router, window } from '@kit.ArkUI';
import log from '../utils/log';
import { Captcha } from '../common/commonInterface'

import { MMKV } from '@tencent/mmkv';

let mmkv = MMKV.defaultMMKV();
/**
 * 登录接口
 */
interface LoginDto {
  /**
   * 用户名
   */
  username: string;

  /**
   * 密码
   */
  password: string;

  /**
   * 验证码
   */
  code: string;

  /**
   * 令牌
   */
  token: string;
}

/**
 * 登录成功返回体的数据结构
 */
interface LoginResponse {
  isLogin: boolean;
  loginDevice: string;
  loginId: string;
  loginType: string;
  sessionTimeout: number;
  tag: string | null;
  tokenActiveTimeout: number;
  tokenName: string;
  tokenSessionTimeout: number;
  tokenTimeout: number;
  tokenValue: string;
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

/**
 * 定义token持久化参数
 */


@Entry
@Component
struct Login {

  @State message: string = 'Hello World';
  @State currentOpacity: number = 0
  @State currentScaleX: number = 0
  @State currentScaleY: number = 0
  @State captchaImg: string = ''
  @State fields: boolean = false
  @State form: LoginDto = {
    username: '',
    password: '',
    code: '',
    token: ''
  }
  @State formerror: LoginDto = {
    username: '',
    password: '',
    code: '',
    token: ''
  }
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
   * 登录
   */
  login = async () => {
    this.validateForm()
    if (this.fields) {
      try {
        const res: Result<LoginResponse> = await request.post(`/auth/hm/login`, this.form)


        mmkv.encodeString('Authorization', res.data.tokenValue);

        Elmessage.success(`欢迎您!${this.form.username}`)
        router.replaceUrl({
          url: 'pages/Index' // 目标url
        }, router.RouterMode.Standard, (err) => {
          if (err) {
            console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
            return;
          }
          console.info('Invoke replaceUrl succeeded.');
        })

      } catch (e) {

        await this.getCaptcha()
      }
    } else {
      return
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
   * 当页面加载
   */
  onPageShow(): void {
    this.getCaptcha()
    setTimeout(() => {
      this.currentOpacity = 1
      this.currentScaleX = 1
      this.currentScaleY = 1
    }, 100)
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
  validatePassword = (): boolean => {
    if (this.form.password.length < 5 || this.form.password === '') {
      this.formerror.password = '*密码为5到10位的字符串'
      return false
    } else {
      this.formerror.password = ''
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
   * validateform验证表单
   */
  validateForm = () => {
    const vusername: boolean = this.validateUserName()
    const vpassword: boolean = this.validatePassword()
    const vcode: boolean = this.validateCode()
    if (vusername && vpassword && vcode) {
      this.fields = true
    } else {
      this.fields = false
    }
  }

  build() {
    Column() {

      // 上层区域
      Column({ space: 10 }) {
        Image($r('app.media.hm_logo')).width(80).height(80).backgroundColor(Color.White).borderRadius(50)
        Text(Constant.systemName).fontSize(30).fontWeight(FontWeight.Bolder)
      }.height('25%').width('100%')

      .justifyContent(FlexAlign.Center)

      // 中层区域
      Column({ space: 10 }) {
        // 输入账户
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
        }.alignItems(HorizontalAlign.Start).width('100%').height('11%')

        // 输入密码
        Column({ space: 5 }) {
          TextInput({
            placeholder: '请输入密码',
            text: this.form.password
          }).type(InputType.Password).onChange((value) => this.form.password = value).onBlur(() => {
            this.validatePassword()
          }).onSubmit(() => {
            this.login()
          })
          if (this.formerror.password) {
            Text(this.formerror.password).commonTextValidate()
          }
        }.alignItems(HorizontalAlign.Start).width('100%').height('11%')

        // 输入验证码
        Column({ space: 5 }) {
          Row() {
            TextInput({
              placeholder: '请输入5位验证码',
              text: this.form.code
            }).width('55%').maxLength(5).onChange((value) => this.form.code = value).onBlur(() => {
              this.validateCode()
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
        }.alignItems(HorizontalAlign.Start).width('100%').height('11%')

        // 立即登录
        Button('立即登录').width('100%').onClick(() => {
          this.login()
        })

        // 注册和找回密码
        Row({ space: 20 }) {
          Text('立即注册').fontColor('#0a59f7').onClick(() => {
            router.pushUrl({
              url: 'pages/Register' // 目标url
            }, router.RouterMode.Standard, (err) => {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })
          Text('忘记密码？').fontColor('#0a59f7').onClick(() => {
            router.pushUrl({
              url: 'pages/Forget' // 目标url
            }, router.RouterMode.Standard, (err) => {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })
        }
      }.padding(30).width('100%').height('70%')

    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.bg'))
    .backgroundImageSize(ImageSize.Cover)
    .scale({
      x: this.currentScaleX,
      y: this.currentScaleY
    })
    .opacity(this.currentOpacity)
    .animation({
      duration: 500,
      tempo: 1,
      curve: Curve.EaseOut
    })
  }
}