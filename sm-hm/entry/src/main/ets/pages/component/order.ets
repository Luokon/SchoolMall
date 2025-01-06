import Elmessage from '../../utils/elmessage';
import Loading from './loading';
import Ipage from '../../utils/ipage'
import request from '../../utils/request'
import Result from '../../utils/result'

import { router } from '@kit.ArkUI';


export interface OrderRecord {
  id: string,
  name: string,
  username: string,
  gid: string|undefined,
  scount: number
  goods: string,
  aid: string|undefined,
  address: string,
  statu: string,
  total: string,
}


@Component
export default struct Order {
  @State name: string = ''
  @State fid: number | undefined | string = undefined
  @State pageNum: number = 1
  @State pageSize: number = 10
  @State form: OrderRecord = {

    id: '',


    name: '',


    username: '',


    gid: '',


    scount: 0,


    goods: '',


    aid: '',


    address: '',


    statu: '',


    total: '',

  }
  @State formError: OrderRecord = {
    id: '',
    name: '',
    username: '',
    gid: '',
    scount: 0,
    goods: '',
    aid: '',
    address: '',
    statu: '',
    total: '',
  }
  @State tableData: OrderRecord [] = []
  @State currentAddOpacity: number = 1
  @State currentCancelOpacity: number = 0
  @State refreshing: boolean = false
  @State loading: boolean = false
  // 初始加载(上拉刷新)下滑加载部分依赖使用
  load = async () => {
    //发起分页请求
    const res: Result<Ipage<OrderRecord>> = await request.get(`/order/page`, {
      params: {
        pageSize: this.pageSize,
        pageNum: this.pageNum,
        name: this.name ? this.name : undefined,

      }
    })
    //进行赋值
    this.tableData = res.data.records
    this.pageNum = res.data.current
    this.pageSize = res.data.size
    this.fid = undefined
  }
  //上滑加载
  handleSizeChange = async () => {
    // pageSize+5 可以自定义

    this.loading = true
    this.pageSize = this.pageSize + 5
    try {

      await this.load()
    } catch (e) {

    } finally {
      this.loading = false
    }


  }
  //输入框控制器
  controller: TextInputController = new TextInputController()

  //加载页面初始化
  aboutToAppear() {
    this.load()
  }

  //删除请求方法
  delete = async () => {
    await request.delete(`/order/${this.fid}`)
    Elmessage.success('删除成功！')
    await this.load()
    this.deleteController.close()
  }
  //引用删除弹框
  deleteController: CustomDialogController = new CustomDialogController({
    builder: CustomDeleteConfirmDialog({
      cancel: this.load,
      confirm: this.delete,
    }),

    autoCancel: true, // 允许点击蒙层关闭弹窗
    customStyle: true // 使用自定义样式
  });

  build() {
    Column() {

      // 第一行搜索
      Column() {
        Row({ space: 5 }) {
          Image($r('app.media.save')).width(20).opacity(this.currentAddOpacity).onClick(() => {
            router.pushUrl({
              url: `pages/OrderAdd`,
              params: {
                id: ''
              }
            })
          })
          Stack({ alignContent: Alignment.End }) {
            TextInput({
              placeholder: `  点击进行搜索`,
              text: this.name,
              controller: this.controller
            })
              .enterKeyType(EnterKeyType.Search)
              .width('100%')
              .fontColor(Color.Black)
              .onFocus(() => {
                this.currentAddOpacity = 0
                this.currentCancelOpacity = 1
              })
              .onBlur(() => {
                this.currentAddOpacity = 1
                this.currentCancelOpacity = 0
              })
              .onChange((value) => this.name = value)
              .onSubmit(() => {
                this.load()
              })

            if (this.name) {
              Image($r('app.media.delete')).width(20).margin({
                right: 10
              }).onClick(async () => {
                this.name = ''
                await this.load()
              })
            }

          }.width('85%').animation({
            duration: 500
          })

          Text('取消').fontColor('#0D7BF8').onClick(async () => {
            this.name = ''
            this.currentAddOpacity = 1
            this.currentCancelOpacity = 0
            this.controller.stopEditing()
            await this.load()
          }).opacity(this.currentCancelOpacity)
        }.animation({
          duration: 1000
        })

      }
      .width('100%')
      .height('7%')
      .backgroundColor(Color.White)
      .padding({
        left: 10, right: 10, bottom: 10
      })
      .justifyContent(FlexAlign.End)
      .animation({
        duration: 200
      })

      //   第二层下滑刷新，上滑加载
      Column() {

        Refresh({ refreshing: $$this.refreshing }) {


          Scroll() {
            Column() {
              Divider().color('#C9C9C9').width('100%').strokeWidth(1)
              ForEach(this.tableData, (item: OrderRecord, index: number) => {
                //todo 此处需要自定义样式
                Column() {

                  Text(JSON.stringify(item))
                    .fontSize(12)
                    .margin({ top: 5 })
                    .fontColor('#878787')
                    .maxLines(3)
                    .textOverflow({
                      overflow: TextOverflow.Ellipsis
                    })
                  Row({ space: 5 }) {
                    //编辑示例
                    Text('编辑').fontColor('#0A59F7').onClick(() => {
                      router.pushUrl({ url: 'pages/OrderAdd', params: { id: item.id } })
                    })
                    //删除示例
                    Text('删除').fontColor('#FF0000').onClick(() => {
                      this.fid = item.id
                      this.deleteController.open()
                    })
                  }.width('100%').margin({ top: 5 }).justifyContent(FlexAlign.End)
                }
                .width('100%')
                .height('20%')
                .backgroundColor(Color.White)
                .padding({ left: 10, right: 10, top: 10 })
                .margin({ top: 1 })
                .alignItems(HorizontalAlign.Start)

                Divider().color('#C9C9C9').width('100%').strokeWidth(1)
              })
              //上拉加载组件
              if (this.loading) {
                Loading()
              }
            }
          }
          .width('100%')
          .height('100%')
          .align(Alignment.TopStart)
          .onScrollEdge((side: Edge) => {
            if (side == Edge.Bottom) {
              this.handleSizeChange()
            }
          })
        }.width('100%').height('100%')
        .onRefreshing(async () => {
          await this.load()
          this.refreshing = false
        })
      }.width('100%').height('93%')

    }.width('100%').height('100%').backgroundColor('#ededed')
  }
}


// 自定义删除弹窗
@CustomDialog
struct CustomDeleteConfirmDialog {
  private controller: CustomDialogController; // 定义controller
  cancel = () => {
  }
  confirm = () => {
  }

  build() {
    Stack() {
      Column() {
        // 显示主标题
        Text('确认删除吗？')
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
