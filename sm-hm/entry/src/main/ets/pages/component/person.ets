import Result from '../../utils/result'
import request from '../../utils/request'
import Ipage from '../../utils/ipage'
import Elemessage from '../../utils/elmessage'
import { McPieChart, Options } from '@mcui/mccharts'
import log from '../../utils/log'
import { HashMap } from '@kit.ArkTS'
import { router } from '@kit.ArkUI'
import { MMKV } from '@tencent/mmkv';
import ImageUploadDialog from './imageUploadDialog'
import Constant from '../../common/Constant'

let mmkv = MMKV.defaultMMKV();

interface User {
  // 序号
  id: number;

  // 账户名
  username: string;

  // 密码 (忽略处理)
  password: string;

  // 昵称
  nickname: string;

  // 头像
  avatar: string;

  // 手机号
  phone: string;

  // 邮箱
  email: string;

  // 个人简介
  content: string;

  // 创建时间
  createTime: string; // 采用字符串格式存储时间
  // 更新时间
  updateTime: string; // 同样采用字符串格式
  // 当前状态
  statu: number;

}

@Component
export default struct Person {
  @State user: User = {
    id: 0,
    username: '',
    password: '',
    nickname: '',
    avatar: '',
    phone: '',
    email: '',
    content: '',
    createTime: '',
    updateTime: '',
    statu: 0
  }
  @State textValue: string = ''
  @State refreshing: boolean = false
  @State dialogController: CustomDialogController | null = null

  // 组件初始化
  aboutToAppear(): void {
    this.load()
    this.dialogController = new CustomDialogController({
      builder: ImageUploadDialog({
        uploadURL: `${Constant.ipAddress}/file/upload`, //上传地址
        success: async e => { //上传成功回调，e上传成功接口返回数据
          let res = JSON.parse(e.body) as Result<string> //接口上传成功返回数据
          this.user.avatar = res.data
          await request.put(`/user`, this.user)
          Elemessage.success('上传成功')
        },
        fail: e => { //上传失败回调
          Elemessage.error('上传失败')
        },
        complete: e => { //上传完成回调
          Elemessage.error('上传完成')
        }
      }),
      alignment: DialogAlignment.Bottom, //弹窗居于底部
      customStyle: true, //自定义样式
    })

  }

  // 默认加载
  load = async () => {
    const res: Result<HashMap<string, object>> = await request.get(`/auth/authInfo`)
    this.user = res.data['userInfo'] as User
  }
  // 退出登录
  logout = async () => {
    await request.post(`/auth/logout`)
    Elemessage.success('退出成功')
    mmkv.removeValueForKey('Authorization');
    router.clear()
    router.replaceUrl({
      url: 'pages/Login' // 目标url
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke replaceUrl succeeded.');
    })
    AppStorage.setOrCreate<number>('index', 0)

  }
  // 找回密码
  findpassword = async () => {
    await request.post(`/auth/logout`)

    mmkv.removeValueForKey('Authorization');
    router.replaceUrl({
      url: 'pages/Forget' // 目标url
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke replaceUrl succeeded.');
    })
    AppStorage.setOrCreate<number>('index', 0)

  }
  // 创建一个controller
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomBatteryDialog({
      cancel: this.load,
      confirm: this.logout,
      textValue: this.textValue
    }), // 弹框的构造器
    cancel: () => {
      // 点击蒙层的回调
    },


    autoCancel: true, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });
  findcontroller: CustomDialogController = new CustomDialogController({
    builder: CustomBatteryDialog({
      cancel: this.load,
      confirm: this.findpassword,
      textValue: this.textValue
    }), // 弹框的构造器
    cancel: () => {
      // 点击蒙层的回调
    },

    autoCancel: true, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  build() {
    Column() {
      // 占位

      // 头像账户名
      Column({ space: 10 }) {
        Image(this.user.avatar).width(80).height(80).borderRadius(50).onClick(() => this.dialogController?.open())
        Text(this.user.nickname).fontSize(15)
        Text(`账户名:${this.user.username}`).fontSize(15).fontColor('#757575')
        Text(this.user.content).fontSize(12).maxLines(3)// 限制文本显示一行
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          }) // 超出显示省略号
      }
      .width('100%')
      .height('35%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .backgroundImage(this.user.avatar)
      .backgroundImageSize(ImageSize.Cover)
      .backdropBlur(50)

      Row() {
        // 我的订单
        Column() {
          Image($r('app.media.Order')).width('25')
          Text('我的订单').fontSize(12)
        }.width('25%').height('100%').justifyContent(FlexAlign.SpaceAround).onClick(()=>router.pushUrl({url:'pages/OrderList'}))

        // 我的地址
        Column() {
          Image($r('app.media.Address')).width('25')
          Text('我的地址').fontSize(12)
        }.width('25%').height('100%').justifyContent(FlexAlign.SpaceAround).onClick(()=>router.pushUrl({url:'pages/Address'}))

        // 留言记录
        Column() {
          Image($r('app.media.message')).width('25')
          Text('留言记录').fontSize(12)
        }.width('25%').height('100%').justifyContent(FlexAlign.SpaceAround).onClick(()=>{router.pushUrl({url:'pages/Message'})})

        // 账户余额
        Column() {
          Image($r('app.media.Money')).width('25')
          Text('账户余额').fontSize(12)
        }.width('25%').height('100%').justifyContent(FlexAlign.SpaceAround)
        .onClick(()=>router.pushUrl({url:'pages/Balance'}))
      }
      .width('100%')
      .height('8%')
      .margin({ top: 5})
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)


      Refresh({ refreshing: $$this.refreshing }) {
        Column() {
          //修改个人信息
          Column() {
            Row() {
              Image($r('app.media.info')).width(16).margin({
                left: 10, right: 10
              })
              Text('个人信息').layoutWeight(1)
              Image($r('app.media.right')).width(15).margin({
                right: 10
              })
            }.width('100%').height('100%')
          }
          .width('100%')
          .height('10%')
          .backgroundColor(Color.White)
          .margin({
            top: 5
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Info' // 目标url
            }, router.RouterMode.Standard, (err) => {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })

          //  修改密码
          Column() {
            Row() {
              Image($r('app.media.password')).width(16).margin({
                left: 10, right: 10
              })
              Text('修改密码').layoutWeight(1).border({})
              Image($r('app.media.right')).width(15).margin({
                right: 10
              })
            }.width('100%').height('100%')
          }
          .width('100%')
          .height('10%')
          .backgroundColor(Color.White)
          .margin({
            top: 1
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Password' // 目标url
            }, router.RouterMode.Standard, (err) => {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })
          // 支付密码
          Column() {
            Row() {
              Image($r('app.media.apply')).width(16).margin({
                left: 10, right: 10
              })
              Text('支付密码').layoutWeight(1).border({})
              Image($r('app.media.right')).width(15).margin({
                right: 10
              })
            }.width('100%').height('100%')
          }
          .width('100%')
          .height('10%')
          .backgroundColor(Color.White)
          .margin({
            top: 1
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ApplyPassword' // 目标url
            }, router.RouterMode.Standard, (err) => {
              if (err) {
                console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              console.info('Invoke replaceUrl succeeded.');
            })
          })
          //   找回密码
          Column() {
            Row() {
              Image($r('app.media.find')).width(16).margin({
                left: 10, right: 10
              })
              Text('找回密码').layoutWeight(1)
              Image($r('app.media.right')).width(15).margin({
                right: 10
              })
            }.width('100%').height('100%')
          }
          .width('100%')
          .height('10%')
          .backgroundColor(Color.White)
          .margin({
            top: 1
          })
          .onClick(() => {
            this.textValue = '将跳转到找回密码页面！'
            this.findcontroller.open() // 打开弹窗
          })

          //退出登录
          Column() {
            Text('退出登录').fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .height('10%')
          .backgroundColor(Color.White)
          .justifyContent(FlexAlign.Center)
          .margin({
            top: 5
          })
          .onClick(() => {
            this.textValue = '确认退出登录？'
            this.controller.open() // 打开弹窗
          })
        }
      }.width('100%').height('55%')
      .onRefreshing(async () => {
        await this.load()
        this.refreshing = false
      })
    }.width('100%').height('100%').backgroundColor('#ededed')
  }
}

@CustomDialog
struct CustomBatteryDialog {
  @Link textValue: string
  private controller: CustomDialogController; // 定义controller
  cancel = () => {
  }
  confirm = () => {
  }

  build() {
    Stack() {
      Column() {
        // 显示主标题
        Text(this.textValue)
          .fontSize(22)
          .fontWeight(600)// 加粗体，突出高级感
          .fontColor("#1a1a1a")// 更深的黑色
          .margin({ top: 25, bottom: 15 })// 更宽的上下间距
          .textAlign(TextAlign.Center) // 标题居中展示

        // 分割线
        Text()
          .size({ width: "100%", height: "1px" })// 线条细致
          .backgroundColor("#e0e0e0")// 极浅的灰色
          .margin({ top: 10, bottom: 20 }) // 增加与上下元素的距离

        Row() {
          // 取消按钮
          Text("取消")
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#ff6b6b")// 取消按钮使用更具动感的颜色
            .borderRadius(12)// 更大的圆角
            .padding({ top: 12, bottom: 12 })// 按钮内部增加一些填充
            .onClick(() => {
              this.controller.close(); // 关闭弹窗
              this.cancel()
            })


          // 按钮之间的分割线
          Text()
            .size({ width: "1px", height: "100%" })// 分割线细致
            .backgroundColor("#e0e0e0") // 使用更柔和的灰色

          // 确定按钮
          Text("确定")
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#4caf50")// 确定按钮采用高级的绿色
            .height("100%")
            .layoutWeight(1)
            .borderRadius(12)// 更大的圆角

            .padding({ top: 12, bottom: 12 })// 按钮内部增加一些填充
            .onClick(() => {
              this.controller.close(); // 关闭弹窗
              this.confirm()
            })


        }
        .height(50) // 调整按钮的高度
        .width('100%')
        .margin({ top: 20 }) // 调整顶部的间距
      }
      .backgroundColor("#f7f8fa") // 背景白色，带点灰
      .borderRadius(16) // 为整个弹窗添加更大的圆角

      .padding({ left: 25, right: 25, bottom: 25 }) // 整体增加内部填充，显得更宽松


    }
    .padding({ left: 40, right: 40 })
    .width("100%")
  }
}
