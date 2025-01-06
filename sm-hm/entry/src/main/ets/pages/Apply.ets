import request from '../utils/request';
import { AddressRecord } from './Address';
import Result from '../utils/result'
import Elmessage from '../utils/elmessage';
import { router } from '@kit.ArkUI';
import Back from './component/back';
import { GoodsRecord, ImgRecord } from './component/goods';
import { it } from '@ohos/hypium';
import { CartRecord } from './component/cart';
import { RegisterDto } from '../common/commonInterface';
import { inputMethod } from '@kit.IMEKit';
import { HashMap, url } from '@kit.ArkTS';
import { OrderRecord } from './component/order';

@Entry
@Component
struct Apply {
  @State message: string = '结算画面';
  @State AddressList: AddressRecord[] = []
  @State goods: GoodsRecord = {
    id: '',
    name: '',
    img: '',
    price: '',
    store: '',
    sales: '',
    isShow: '',
    isRecommand: '',
    cid: '',
    content: '',
    createTime: '',
    updateTime: '',
    username: '',
    imgList: [],
    contentList: []
  }
  @State cartList: CartRecord[] = []
  @State total: number = 0
  @State address: AddressRecord | undefined = {
    id: '',
    name: '',
    phone: '',
    content: '',
    username: '',
    isDefault: 0
  }
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
  @State scount: number = 1;
  @State gids: string = ''
  @State url: string = ''
  load = async () => {




    const rev: Result<GoodsRecord> = await request.get(`/goods/${ AppStorage.get<number>('ids') as number}`)
    // Elmessage.success(JSON.stringify(rev.data.img))
    this.goods = rev.data

    this.goods.imgList = JSON.parse(this.goods.img)
    this.url = this.goods.imgList[0].url


    const res: Result<AddressRecord[]> = await request.get(`/address`)
    this.AddressList = res.data
    if (this.AddressList.length === 0) {
      Elmessage.warn('您没有添加地址，正在为您跳转地址页面')
      router.replaceUrl({ url: 'pages/Address' })
    }

    if (AppStorage.get<number>('aid')=== 0) {
      this.address = this.AddressList.find(address => address.isDefault === 1)
    } else {
      this.address = this.AddressList.find(address => Number(address.id) === AppStorage.get<number>('aid'))
    }

    const ref: Result<HashMap<string, object>> = await request.get(`/auth/authInfo`)
    this.form = ref.data['userInfo'] as RegisterDto

    if (!this.form.applyPassword || this.form.applyPassword === '0') {
      Elmessage.error('请先设置支付密码!')
      router.replaceUrl({ url: 'pages/ApplyPassword' })
    }
  }

  aboutToAppear(): void {
    const inputController: inputMethod.InputMethodController = inputMethod.getController();
    inputController.off("insertText");
    inputController.off("deleteLeft");
    this.load()
  }

  controller: CustomDialogController = new CustomDialogController({
    builder: CustomApplyDialog({
      cancel: this.load,
      form: this.form,
      value: this.total,
      gids: this.gids,
      scount: this.scount

    },), // 弹框的构造器
    alignment: DialogAlignment.BottomStart,
    cancel: () => {
      router.replaceUrl({ url: 'pages/Index' })
    },
    autoCancel: false, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  build() {
    Column() {
      //   第一行back
      Back({ url: 'pages/Index' })
      //   第二行地址
      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
      //todo 此处需要自定义样式
      Column() {
        Row({ space: 5 }) {
          Text(`${this.address?.name},`).fontSize(14)
          Text(`${this.address?.phone}`).fontSize(14)
        }.width('100%').height('20%')

        Row({ space: 5 }) {
          Text(`${this.address?.content}`).fontSize(16).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Image($r('app.media.right')).width(30).onClick(() => {

            router.pushUrl({ url: 'pages/SelectAddress' })
          })
        }.width('100%').height('20%').justifyContent(FlexAlign.SpaceBetween)

      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ left: 10, right: 10, top: 10 })
      .margin({ top: 1 })
      .height('10%')

      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround)

      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
      Scroll() {
        Column() {

          Column() {
            Row() {
              Image(this.url).width('30%').aspectRatio(1).objectFit(ImageFit.Contain).borderRadius(5)
              // Text(JSON.stringify(this.goods.imgList[0].url))
              Column() {
                Text(`  ${this.goods.name}`)
                  .fontSize(12)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontWeight(FontWeight.Bolder)
                  .height('25%')
                  .margin({ top: 10 })
                Row() {
                  Text(`  ￥${this.goods.price}`).fontColor(Color.Red)
                  Counter() { // 包含一个子组件
                    Text(this.scount.toString())// Text 默认值为 1
                      .fontSize(18) // Text 字体大小
                  }.margin({ left: 5 }).onInc(() => { // 自增操作
                    this.scount++;
                  })
                  .onDec(() => { // 自减操作
                    if (this.scount <= 1) {
                      this.scount = 1
                      return
                    } else {
                      this.scount--
                    }
                  })

                  // Text(JSON.stringify(this.cartList[index]?.scount))
                }

                Text(`  合计:￥ ${(Number(this.goods.price) * this.scount).toFixed(2)}`)

              }
              .width('70%')
              .height('100%')
              .alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceAround)
            }
            .width('100%')
            .height('20%')
            .borderRadius(5)
            .backgroundColor(Color.White)

            Divider().color('#C9C9C9').width('100%').strokeWidth(1)
          }

        }
      }
      .align(Alignment.TopStart)
      .width('100%')
      .height('75%')

      Column() {
        Button(`合计:${(Number(this.goods.price) * this.scount).toFixed(2)} 立即支付`)
          .onClick(() => {
            this.controller.open()
          })
          .type(ButtonType.Normal)
          .borderRadius(5)
          .backgroundColor('#F85620')
          .fontColor(Color.White)
          .width('90%')
      }.width('100%').height('10%')

    }


    .height('100%')
    .width('100%')
  }
}


@CustomDialog
struct CustomApplyDialog {
  private controller: CustomDialogController; // 定义controller
  @Link form: RegisterDto
  @Link value: string | number
  @Link gids: string
  @Link scount: number
  @State inputValue: string = ''
  @State inputController: inputMethod.InputMethodController = inputMethod.getController()
  cancel = () => {

    this.offInputEvent()
    this.onDetachInput()
  }
  confirm = () => {

  }

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

  build() {

    Column() {
      Column() {
        Image($r('app.media.delete')).width(30)
      }.width('100%').alignItems(HorizontalAlign.Start).onClick(() => {
        this.controller.close()
        this.offInputEvent()
        this.onDetachInput()
        const entity: OrderRecord = {
          id: '',
          name: '',
          username: '',
          gid: '',
          scount: 0,
          goods: '',
          aid: '',
          address: '',
          statu: '',
          total: ''
        }

        entity.scount = this.scount
        entity.username = this.form.username
        entity.gid = AppStorage.get<string>('ids')
        entity.aid = AppStorage.get<number>('aid')?.toString()
        entity.statu = '1'


        request.post(`/order`,entity)
        Elmessage.success('取消成功')
        router.replaceUrl({url:'pages/OrderList'})
      })

      Column() {
        Text('*请输入支付密码').fontSize(30).fontColor(Color.Red)
      }.width('100%').height('8%').justifyContent(FlexAlign.Center)

      VerifyCodeInput({
        inputCode: this.inputValue,
        form: this.form,
        inputController: this.inputController,
        value: this.value,
        gids: this.gids,
        scount: this.scount,
        func: () => {
          this.controller.close()
          this.offInputEvent()
          this.onDetachInput()
          // router.replaceUrl({ url: 'pages/Index' })
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
  @Link gids: string
  @Link scount: number
  //验证码字体大小
  @Prop fontsize: number | string = '20fp'
  //验证码框个数
  @Prop count: number = 6
  //输入法客户端实例
  @Link inputController: inputMethod.InputMethodController;
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

          // Elmessage.success(JSON.stringify(params))


          if (!this.form.applyPassword) {
            Elmessage.error('请先设置支付密码!')
            this.func()
            this.aboutToDisappear()
          } else if (this.form.applyPassword != this.inputCode) {
            Elmessage.error('支付密码错误')
            this.inputCode = ''
          } else {

            this.form.balance -= Number(this.value)

            // this.form.balance+=Number(this.value)
            if (this.form.balance < 0) {
              Elmessage.error('余额不足请充值！')
              this.func()
              this.aboutToDisappear()
              return
            }
            this.func()
            this.aboutToDisappear()

            // await request.put(`/user`, this.form)
            // Elmessage.success('支付成功')
            // 支付完了以后，生成订单数据

            await request.put(`/order/apply/${AppStorage.get('ids')}/${AppStorage.get('aid')}/${this.scount}`)
            Elmessage.success('下单成功')
            router.clear()
            router.pushUrl({ url: 'pages/OrderList' })


            // router.replaceUrl({ url: 'pages/Index' })

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
