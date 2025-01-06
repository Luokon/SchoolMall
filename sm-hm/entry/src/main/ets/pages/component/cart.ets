import Elmessage from '../../utils/elmessage';
import Loading from './loading';
import Ipage from '../../utils/ipage'
import request from '../../utils/request'
import Result from '../../utils/result'

import { router } from '@kit.ArkUI';
import { GoodsRecord } from './goods';
import { it } from '@ohos/hypium';


export interface CartRecord {
  id: string,
  name: string,
  gid: string,
  time: string,
  scount: 0,
  goods: GoodsRecord
}


@Component
export default struct Cart {
  @State name: string = ''
  @State fid: number | undefined | string = undefined
  @State pageNum: number = 1
  @State pageSize: number = 8
  @State form: CartRecord = {
    id: '',


    name: '',


    gid: '',


    time: '',
    goods: {
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
      contentList:[]
    },
    scount: 0
  }
  @State tableData: CartRecord [] = []
  @State currentAddOpacity: number = 1
  @State currentCancelOpacity: number = 0
  @State refreshing: boolean = false
  @State loading: boolean = false
  // 初始加载(上拉刷新)下滑加载部分依赖使用
  load = async () => {
    //发起分页请求
    const res: Result<Ipage<CartRecord>> = await request.get(`/cart/page`, {
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
    this.tableData.forEach((item: CartRecord) => {
      item.goods.imgList = JSON.parse(item.goods.img)
    })

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

  handleUpdate = async (item: CartRecord) => {
    await request.put(`/cart/${item.id}`, item)
    router.replaceUrl({ url: 'pages/Index' })
  }
  //删除请求方法
  delete = async () => {
    if (this.fid === undefined) {
      this.batchdelete()
      return
    }
    await request.delete(`/cart/${this.fid}`)
    Elmessage.success('删除成功！')
    this.deleteController.close()
    router.replaceUrl({ url: 'pages/Index' })


  }
  // 批量删除
  @State selectCartArr: string[] = []
  batchdelete = async () => {
    await request.delete(`/cart/batch/${this.selectCartArr.toString()}`)
    Elmessage.success('删除成功！')
    router.replaceUrl({ url: 'pages/Index' })

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

        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          CheckboxGroup({ group: 'checkboxGroup' },)
            .checkboxShape(CheckBoxShape.ROUNDED_SQUARE)
            .selectedColor('#007DFF').selectAll(false)
            .onChange((itemName: CheckboxGroupResult) => {
              // console.info("checkbox group content" + JSON.stringify(itemName))
              this.selectCartArr = itemName.name
            })
          Text('全选').fontSize(14).lineHeight(20).fontColor('#182431').fontWeight(500)
          if (this.selectCartArr.length > 0) {
            Text('删除')
              .fontSize(14)
              .lineHeight(20)
              .fontColor(Color.Red)
              .fontWeight(500)
              .margin({ left: 5 })
              .onClick(() => {
                this.deleteController.open()
              })
          }
        }
      }
      .width('100%')
      .height('10%')
      .backgroundColor(Color.White)
      .padding({
        left: 10, right: 10, bottom: 10
      })
      .justifyContent(FlexAlign.End)
      .animation({
        duration: 200
      })

      //   第二层下滑刷新，上滑加载
    if (this.tableData.length===0){
      Column() {
        Image($r('app.media.call')).width('100%')
        Text('您的购物车还是空的，请您添加!')
      }.width('100%').height('94%').backgroundColor(Color.White).justifyContent(FlexAlign.Center)
    }else{
      Column() {

        Refresh({ refreshing: $$this.refreshing }) {


          Scroll() {
            Column() {
              Divider().color('#C9C9C9').width('100%').strokeWidth(1)
              ForEach(this.tableData, (item: CartRecord, index: number) => {
                //todo 此处需要自定义样式

                Scroll() {
                  Row() {
                    Row() {
                      Row() {
                        Checkbox({ name: item.id.toString(), group: 'checkboxGroup', })
                          .select(false)//默认选中
                          .selectedColor(Color.Red)//选中颜色
                          .onChange((value: boolean) => {

                          })
                        Image(item.goods.imgList[0].url).width('50%').aspectRatio(1).onClick(() => {
                          AppStorage.setOrCreate<number>('ids',Number(item.gid))

                          router.pushUrl({
                            url: 'pages/GoodsDetail'
                          })
                        })
                      }.width('30%').height('100%')

                      Column() {
                        Text(item.goods.name)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .fontWeight(FontWeight.Bolder)
                        Counter() { // 包含一个子组件
                          Text(item.scount.toString())// Text 默认值为 1
                            .fontSize(18) // Text 字体大小
                        }.margin({ top: 5 }).onInc(() => { // 自增操作
                          item.scount++;
                          this.handleUpdate(item)

                        })
                        .onDec(() => { // 自减操作
                          if (item.scount === 0) {
                            this.fid = item.id
                            this.delete()
                          }
                          item.scount--;
                          this.handleUpdate(item)
                        })
                      }.width('70%').height('100%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)
                    }.width('100%').height('100%')

                    Column() {
                      Text('删除').fontColor(Color.White).fontWeight(FontWeight.Bolder)
                    }
                    .width('30%')
                    .height('100%')
                    .backgroundColor(Color.Red)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      this.fid = item.id
                      this.deleteController.open()
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal) // 设置为横向滑动
                .scrollBar(BarState.Off)
                .width('100%')
                .height('12%')
                .backgroundColor(Color.White)
                .margin({ top: 1 })

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
      }.width('100%').height('85%').backgroundColor(Color.White)
    }


      //   第三行全选结算
      Column() {
        if (this.selectCartArr.length > 0) {
          Button('立即结算').type(ButtonType.Normal).borderRadius(10).backgroundColor('#F9982F').onClick(() => {

            AppStorage.setOrCreate<string[]>('cids',this.selectCartArr)
            AppStorage.setOrCreate<number>('aid',0)
            router.pushUrl({
              url: 'pages/Settle'
            })
          })
        }
      }.width('100%').height('5%').backgroundColor(Color.White)
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
