import { RegisterDto } from '../common/commonInterface';
import Back from './component/back';
import { HashMap } from '@kit.ArkTS';
import Result from '../utils/result'
import request from '../utils/request'
import Elmessage from '../utils/elmessage';
import { router } from '@kit.ArkUI';
import { inputMethod } from '@kit.IMEKit';

@Entry
@Component
struct Balance {
  @State message: string = '账户余额页面';
  @State value: number | string = '';
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
  };

  aboutToAppear(): void {
    this.load()
  }

  load = async () => {
    const res: Result<HashMap<string, object>> = await request.get(`/auth/authInfo`)
    this.form = res.data['userInfo'] as RegisterDto

    if (!this.form.applyPassword||this.form.applyPassword==='0') {

      Elmessage.error('请先设置支付密码!')
      router.replaceUrl({url:'pages/ApplyPassword'})
    }
  }
  submit = async () => {
    if (this.value < 0 || this.value == '') {
      return
    }
    this.controller.open()
    // this.form.balance+=Number(this.value)
    // await request.put(`/user`,this.form)
    // Elmessage.success('充值成功')
    // router.replaceUrl({url:'pages/Index'})

  }
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomApplyDialog({
      cancel: this.load,
      form: this.form,
      value: this.value
    }), // 弹框的构造器
    alignment: DialogAlignment.BottomStart,
    cancel: () => {
      // 点击蒙层的回调
    },
    autoCancel: false, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  build() {

    Column() {
      Back({ url: 'pages/Index' })
      Column() {
        Image($r('app.media.bag')).width(40)
        Text(`￥${this.form.balance}`).fontColor(Color.White).fontWeight(FontWeight.Bolder)
      }.width('100%').height('15%').backgroundColor('#2BAE6A').justifyContent(FlexAlign.Center)

      TextInput({ placeholder: '请输入充值金额', text: this.value.toString() })
        .onChange((value) => {
          this.value = value.toString()
        })
        .type(InputType.Number)
        .maxLength(5)
        .margin({ top: 10 })
        .fontSize(40)
        .width(
          '95%'
        )
        .focusable(true)
        .height(60)
        .borderRadius(0)
        .onSubmit(() => this.submit())

    }.width('100%').height('100%')
  }
}

@CustomDialog
struct CustomApplyDialog {
  private controller: CustomDialogController; // 定义controller
  @Link form: RegisterDto
  @Link value: string | number
  @State inputValue: string = ''
  @State inputController: inputMethod.InputMethodController = inputMethod.getController()
  //解除输入法事件
  offInputEvent() {
    this.inputController.off("insertText");
    this.inputController.off("deleteLeft");
  }

  //自绘控件解绑输入法
  async onDetachInput() {
    try {
      await this.inputController.detach()
    } catch (e) {
      console.log(JSON.stringify(e))
    }

  }

  //组件销毁解除所有绑定
  aboutToDisappear() {
    this.offInputEvent()
    this.onDetachInput()
  }

  cancel = () => {
  }
  confirm = () => {

  }

  build() {

    Column() {
      Column() {
        Image($r('app.media.delete')).width(30)
      }.width('100%').alignItems(HorizontalAlign.Start).onClick(() => {
        this.controller.close()
        this.offInputEvent()
        this.onDetachInput()
      })

      Column() {
        Text('*请输入支付密码').fontSize(30).fontColor(Color.Red)
      }.width('100%').height('8%').justifyContent(FlexAlign.Center)

      VerifyCodeInput({
        inputCode: this.inputValue,
        form: this.form,
        value: this.value,
        inputController:this.inputController,
        func: () => {
          this.controller.close()
        }
      })
      Column().width('100%').height('5%')
    }.width('100%').backgroundColor(Color.White)
  }
}

@Component
export default struct VerifyCodeInput {
  func = () => {
  }
  //单个输入框高
  @Prop iheight: number | string = 48
  @Prop iwidth: number | string = 48
  //验证码字体大小
  @Prop fontsize: number | string = '20fp'
  //验证码框个数
  @Prop count: number = 6
  //输入法客户端实例
  @Link inputController: inputMethod.InputMethodController
  //自绘编辑框配置
  private textConfig: inputMethod.TextConfig = {
    inputAttribute: {
      textInputType: inputMethod.TextInputType.NUMBER, //只能输入数字
      enterKeyType: inputMethod.EnterKeyType.GO
    },
  };
  //用户输入的验证码
  @Link inputCode: string
  @Link form: RegisterDto
  @Link value: string | number
  //验证码输入框个数数组
  @State countArr: number[] = new Array(this.count ?? 6).fill(' ') //count个空元素数组
  //是否第一次加载
  private isFirst: boolean = true

  //自绘控件绑定输入法 @params isFocus:是否聚焦拉起键盘
  async onAttachInput(isFocus?: boolean) {
    try {
      //绑定成功默认拉起键盘
      await this.inputController.attach(isFocus ?? true, this.textConfig);
    } catch (e) {
      console.log(JSON.stringify(e))
    }
  }

  //自绘控件解绑输入法
  async onDetachInput() {
    try {
      await this.inputController.detach()
    } catch (e) {
      console.log(JSON.stringify(e))
    }

  }

  //绑定输入法输入和删除事件
  onInputEvent() {
    //输入数字
    this.inputController.on("insertText", async (text: string) => {
      if (text && this.inputCode.length < this.count && !isNaN(Number(text))) {
        this.inputCode += text;
        if (this.inputCode.length === 6) {
          if (!this.form.applyPassword){
            Elmessage.error('请先设置支付密码!')
            this.func()
            this.aboutToDisappear()
          }
          if (this.form.applyPassword != this.inputCode) {
            Elmessage.error('支付密码错误')
            this.inputCode = ''
          } else {
            this.form.balance += Number(this.value)
            // this.form.balance+=Number(this.value)

            this.func()
            this.aboutToDisappear()
            await request.put(`/user`, this.form)
            Elmessage.success('充值成功')

            router.replaceUrl({ url: 'pages/Index' })

          }
        }
      }
    })
    //删除数字
    this.inputController.on("deleteLeft", (length: number) => {
      this.inputCode = this.inputCode.substring(0, this.inputCode.length - 1);
    })
  }

  //解除输入法事件
  offInputEvent() {
    this.inputController.off("insertText");
    this.inputController.off("deleteLeft");
  }

  //组件销毁解除所有绑定
  aboutToDisappear() {
    this.offInputEvent()
    this.onDetachInput()
  }

  build() {
    Column() {
      Row() {
        ForEach(this.countArr, (item: string, index: number) => {
          Text(this.inputCode[index] ? '*' : '')
            .width(this.iwidth)
            .height(this.iheight)
            .borderRadius('8')
            .backgroundColor('#ECF1F7')
            .fontSize(this.fontsize)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
            .margin({ left: index === 0 ? 0 : 5, right: index === 5 ? 0 : 5 })
            .flexGrow(1)
            .onClick(() => {
              //点击控件重新绑定弹出键盘
              this.onAttachInput()
            })

        }, (item: string, index: number) => index.toString())
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .onVisibleAreaChange([0.0, 1.0], async (isVisible: boolean, currentRatio: number) => {
        if (isVisible && currentRatio >= 1.0) { //页面显示
          //延迟200ms兼容绑定失效问题
          setTimeout(async () => {
            try {
              //绑定输入法和设置聚焦状态弹出键盘
              await this.onAttachInput(true)
            } catch (e) {
            }
            if (this.isFirst) { //首次加载
              //绑定输入事件
              this.onInputEvent()
              this.isFirst = false
            }

          }, 200)

        }

        if (!isVisible && currentRatio <= 0.0) { //页面隐藏
          //隐藏键盘
          this.onAttachInput(false)
        }

      })

    }.width('100%')
  }
}
