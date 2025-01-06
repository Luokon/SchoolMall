import Elmessage from '../utils/elmessage';
import Loading from './component/loading';
import Ipage from '../utils/ipage'
import request from '../utils/request'
import Result from '../utils/result'

import { router } from '@kit.ArkUI';
import Back from './component/back';
import { GoodsRecord } from './component/goods';
import { AddressRecord } from './Address';


export interface OrderRecord {
  id: string,
  name: string,
  username: string,
  gid: string,
  scount: string,
  goods: string,
  aid: string,
  address: string,
  statu: number,
  total: string,

}

@Entry
@Component
export default struct OrderList {
  @State name: string = ''
  @State fid: number | undefined | string = undefined
  @State pageNum: number = 1
  @State statu: number = 0
  @State pageSize: number = 10
  @State form: OrderRecord = {
    id: '',


    name: '',


    username: '',


    gid: '',


    scount: '',


    aid: '',


    total: '',
    goods: '',
    address: '',
    statu: 0
  }
  @State goodsList: GoodsRecord[] = []
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
        statu: this.statu

      }
    })
    //进行赋值
    this.tableData = res.data.records
    // 对goods进行赋值转换
    this.tableData.forEach((order: OrderRecord) => {
      const goods: GoodsRecord = JSON.parse(order.goods)
      goods.imgList = JSON.parse(goods.img)
      this.goodsList.push(goods)

    })
    // 对address进行赋值转换
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
      Back({ url: 'pages/Index' })

      //   第二层下滑刷新，上滑加载
      Column() {

        Refresh({ refreshing: $$this.refreshing }) {


          Tabs() {
            TabContent() {
              Scroll() {
                Column() {
                  Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                  ForEach(this.tableData, (item: OrderRecord, index: number) => {
                    Column() {
                      Row() {
                        Image(this.goodsList[index].imgList[0].url)
                          .width('20%')
                          .aspectRatio(1)
                          .margin({ left: 10 })
                          .borderRadius(5)

                        Column() {
                          Text(`      ${this.goodsList[index].name}`)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 5 })
                          Row() {
                            Text(`      ￥${this.goodsList[index].price}`)
                            Text(`  *`)
                            Text(`  ${item.scount}`)
                            Text(`  ${item.total}元`).fontWeight(FontWeight.Bolder).fontColor(Color.Red)
                            //todo
                          }.margin({ top: 10 })

                          Text(`      ${item.name}`).fontSize(12).margin({ top: 10, left: 10 })
                          Row({ space: 5 }) {
                            Button('订单详情')
                              .type(ButtonType.Normal)
                              .borderRadius(10)
                              .fontColor(Color.Black)
                              .backgroundColor(Color.White)
                              .border({ width: 1 })
                              .onClick(() => {
                                AppStorage.setOrCreate<number>('oid', Number(item.id))

                                router.pushUrl({
                                  url: 'pages/OrderDetail'
                                })
                              })
                            if (item.statu === 3) {
                              Button('确认收货')
                                .type(ButtonType.Normal)
                                .borderRadius(10)
                                .fontColor(Color.Black)
                                .backgroundColor(Color.White)
                                .border({ width: 1 })
                                .onClick(async () => {
                                  item.statu = 4
                                  await request.put(`/order/${item.id}`, item)
                                  await this.load()
                                })
                            }
                          }.margin({ top: 10, left: 20 })
                        }
                        .width('80%')
                        .height('100%')

                        .alignItems(HorizontalAlign.Start)
                      }.width('100%').height('20%')

                      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                    }.width('100%')
                  })
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
            }.tabBar('全部').align(Alignment.TopStart)

            TabContent() {
              Scroll() {
                Column() {
                  Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                  ForEach(this.tableData, (item: OrderRecord, index: number) => {
                    Column() {
                      Row() {
                        Image(this.goodsList[index].imgList[0].url)
                          .width('20%')
                          .aspectRatio(1)
                          .margin({ left: 10 })
                          .borderRadius(5)

                        Column() {
                          Text(`      ${this.goodsList[index].name}`)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 5 })
                          Row() {
                            Text(`      ￥${this.goodsList[index].price}`)
                            Text(`  *`)
                            Text(`  ${item.scount}`)
                            Text(`  ${item.total}元`).fontWeight(FontWeight.Bolder).fontColor(Color.Red)
                            //todo
                          }.margin({ top: 10 })

                          Text(`      ${item.name}`).fontSize(12).margin({ top: 10, left: 10 })
                          Row({ space: 5 }) {
                            Button('订单详情')
                              .type(ButtonType.Normal)
                              .borderRadius(10)
                              .fontColor(Color.Black)
                              .backgroundColor(Color.White)
                              .border({ width: 1 })
                              .onClick(() => {
                                AppStorage.setOrCreate<number>('oid', Number(item.id))

                                router.pushUrl({
                                  url: 'pages/OrderDetail'
                                })
                              })
                            if (item.statu === 3) {
                              Button('确认收货')
                                .type(ButtonType.Normal)
                                .borderRadius(10)
                                .fontColor(Color.Black)
                                .backgroundColor(Color.White)
                                .border({ width: 1 })
                            }
                          }.margin({ top: 10, left: 20 })
                        }
                        .width('80%')
                        .height('100%')

                        .alignItems(HorizontalAlign.Start)
                      }.width('100%').height('20%')

                      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                    }.width('100%')
                  })
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
            }.tabBar('未付款').align(Alignment.TopStart)

            TabContent() {
              Scroll() {
                Column() {
                  Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                  ForEach(this.tableData, (item: OrderRecord, index: number) => {
                    Column() {
                      Row() {
                        Image(this.goodsList[index].imgList[0].url)
                          .width('20%')
                          .aspectRatio(1)
                          .margin({ left: 10 })
                          .borderRadius(5)

                        Column() {
                          Text(`      ${this.goodsList[index].name}`)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 5 })
                          Row() {
                            Text(`      ￥${this.goodsList[index].price}`)
                            Text(`  *`)
                            Text(`  ${item.scount}`)
                            Text(`  ${item.total}元`).fontWeight(FontWeight.Bolder).fontColor(Color.Red)
                            //todo
                          }.margin({ top: 10 })

                          Text(`      ${item.name}`).fontSize(12).margin({ top: 10, left: 10 })
                          Row({ space: 5 }) {
                            Button('订单详情')
                              .type(ButtonType.Normal)
                              .borderRadius(10)
                              .fontColor(Color.Black)
                              .backgroundColor(Color.White)
                              .border({ width: 1 })
                              .onClick(() => {
                                AppStorage.setOrCreate<number>('oid', Number(item.id))



                                router.pushUrl({
                                  url: 'pages/OrderDetail'
                                })
                              })
                            if (item.statu === 3) {
                              Button('确认收货')
                                .type(ButtonType.Normal)
                                .borderRadius(10)
                                .fontColor(Color.Black)
                                .backgroundColor(Color.White)
                                .border({ width: 1 })
                                .onClick(async () => {
                                  item.statu = 4
                                  await request.put(`/order/${item.id}`, item)
                                  await this.load()
                                })
                            }

                          }.margin({ top: 10, left: 20 })
                        }
                        .width('80%')
                        .height('100%')

                        .alignItems(HorizontalAlign.Start)
                      }.width('100%').height('20%')

                      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                    }.width('100%')
                  })
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
            }.tabBar('已支付')

            TabContent() {
              Scroll() {
                Column() {
                  Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                  ForEach(this.tableData, (item: OrderRecord, index: number) => {
                    Column() {
                      Row() {
                        Image(this.goodsList[index].imgList[0].url)
                          .width('20%')
                          .aspectRatio(1)
                          .margin({ left: 10 })
                          .borderRadius(5)

                        Column() {
                          Text(`      ${this.goodsList[index].name}`)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 5 })
                          Row() {
                            Text(`      ￥${this.goodsList[index].price}`)
                            Text(`  *`)
                            Text(`  ${item.scount}`)
                            Text(`  ${item.total}元`).fontWeight(FontWeight.Bolder).fontColor(Color.Red)
                            //todo
                          }.margin({ top: 10 })

                          Text(`      ${item.name}`).fontSize(12).margin({ top: 10, left: 10 })
                          Row({ space: 5 }) {
                            Button('订单详情')
                              .type(ButtonType.Normal)
                              .borderRadius(10)
                              .fontColor(Color.Black)
                              .backgroundColor(Color.White)
                              .border({ width: 1 })
                              .onClick(() => {
                                AppStorage.setOrCreate<number>('oid', Number(item.id))

                                router.pushUrl({
                                  url: 'pages/OrderDetail'
                                })
                              })
                            if (item.statu === 3) {
                              Button('确认收货')
                                .type(ButtonType.Normal)
                                .borderRadius(10)
                                .fontColor(Color.Black)
                                .backgroundColor(Color.White)
                                .border({ width: 1 })
                                .onClick(async () => {
                                  item.statu = 4
                                  await request.put(`/order/${item.id}`, item)
                                  await this.load()
                                })
                            }
                          }.margin({ top: 10, left: 20 })
                        }
                        .width('80%')
                        .height('100%')

                        .alignItems(HorizontalAlign.Start)
                      }.width('100%').height('20%')

                      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                    }.width('100%')
                  })
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
            }.tabBar('已发货')

            TabContent() {
              Scroll() {
                Column() {
                  Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                  ForEach(this.tableData, (item: OrderRecord, index: number) => {
                    Column() {
                      Row() {
                        Image(this.goodsList[index].imgList[0].url)
                          .width('20%')
                          .aspectRatio(1)
                          .margin({ left: 10 })
                          .borderRadius(5)
                          .onClick(() => {
                            router.pushUrl({ url: 'pages/GoodsDetail', params: { gid: this.goodsList[index].id } })
                          })
                        Column() {
                          Text(`      ${this.goodsList[index].name}`)
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ top: 5 })
                          Row() {
                            Text(`      ￥${this.goodsList[index].price}`)
                            Text(`  *`)
                            Text(`  ${item.scount}`)
                            Text(`  ${item.total}元`).fontWeight(FontWeight.Bolder).fontColor(Color.Red)
                            //todo
                          }.margin({ top: 10 })

                          Text(`      ${item.name}`).fontSize(12).margin({ top: 10, left: 10 })
                          Row({ space: 5 }) {
                            Button('订单详情')
                              .type(ButtonType.Normal)
                              .borderRadius(10)
                              .fontColor(Color.Black)
                              .backgroundColor(Color.White)
                              .border({ width: 1 })
                              .onClick(() => {
                                AppStorage.setOrCreate<number>('oid', Number(item.id))

                                router.pushUrl({
                                  url: 'pages/OrderDetail'
                                })
                              })
                            if (item.statu === 3) {
                              Button('确认收货')
                                .type(ButtonType.Normal)
                                .borderRadius(10)
                                .fontColor(Color.Black)
                                .backgroundColor(Color.White)
                                .border({ width: 1 })
                            }
                          }.margin({ top: 10, left: 20 })
                        }
                        .width('80%')
                        .height('100%')

                        .alignItems(HorizontalAlign.Start)
                      }.width('100%').height('20%')

                      Divider().color('#C9C9C9').width('100%').strokeWidth(1)
                    }.width('100%')
                  })
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
            }.tabBar('已收货')
          }.backgroundColor(Color.White).align(Alignment.TopStart).onChange((index: number) => {
            this.statu = index
            this.load()
          })

        }.width('100%').height('100%')
        .onRefreshing(async () => {
          await this.load()
          this.refreshing = false
        })

      }.width('100%').height('93%')

    }.width('100%').height('98%').backgroundColor('#ededed')
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
