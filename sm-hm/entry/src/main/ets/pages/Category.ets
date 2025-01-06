import Elmessage from '../utils/elmessage';
import Loading from './component/loading';
import Ipage from '../utils/ipage'
import request from '../utils/request'
import Result from '../utils/result'

import { router } from '@kit.ArkUI';
import { it } from '@ohos/hypium';
import { GoodsRecord, ImgRecord } from './component/goods';


export interface CategoryRecord {
  id: string,
  name: string,
  img: string,
  time: string,
}


@Component
export default struct Category {
  @State name: string = ''
  @State fid: number | undefined | string = undefined
  @State pageNum: number = 1
  @State pageSize: number = 10
  @State tableData: CategoryRecord [] = []
  @State goodsData: GoodsRecord [] = []
  @State currentAddOpacity: number = 1
  @State currentCancelOpacity: number = 0
  @State refreshing: boolean = false
  @State loading: boolean = false
  @State currentInputWidth: string = '100%'
  @State currentIndex: number = 10
  // 初始加载(上拉刷新)下滑加载部分依赖使用
  load = async () => {

    // if (index) {
    //   this.currentIndex=index
    // }
    //发起分页请求
    const res: Result<CategoryRecord[]> = await request.get(`/category`)
    //进行赋值
    this.tableData = res.data
    if (this.tableData.length === 0) {
      Elmessage.error('暂无分类数据，请联系管理员添加')

    }
    const gres: Result<Ipage<GoodsRecord>> = await request.get(`/goods/category`, {
      params: {
        pageNum: this.pageNum,
        pageSize: this.pageSize,
        cid: this.tableData[this.currentIndex].id
      }
    })
    this.goodsData = gres.data.records
    this.pageNum = gres.data.current
    this.pageSize = gres.data.size

    this.goodsData.forEach((good: GoodsRecord) => {
      good.imgList = JSON.parse(good.img) as ImgRecord[]
    })

  }
  //上滑加载
  handleSizeChange = async () => {
    // pageSize+5 可以自定义

    this.loading = true
    this.pageSize = this.pageSize + 6
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
    this.currentIndex = AppStorage.get<number>('cid') as number


    // Elmessage.success(index.toString())
    this.load()
  }

  //删除请求方法
  delete = async () => {
    await request.delete(`/category/${this.fid}`)
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

  @Builder
  buildTabbar(title: string, index: number) {
    // 0A59F7
    Text(title)
      .fontSize(20)
      .fontColor(index === this.currentIndex ? '#0A59F7' : '#666666')
      .width('100%')
      .height('8%')
      .textAlign(TextAlign.Center)
  }

  build() {
    Column() {

      // 第一行搜索
      // 第一行搜索
      Column() {
        Text(`  点击进行搜索`)

          .fontSize(15)
          .borderRadius(20)
          .width('100%')
          .height('50%').backgroundColor('#51f3f3f3')      .onClick(() => router.pushUrl({ url: 'pages/SearchView' }))
      }
      .height('10%')
      .width('100%')
      .backgroundColor(Color.White)
      .padding({
        left: 20, right: 20
      })
      .justifyContent(FlexAlign.End)


      //   第二层下滑刷新，上滑加载
      Column() {


        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
          ForEach(this.tableData, (item: CategoryRecord, index: number) => {

            TabContent() {
              Refresh({ refreshing: $$this.refreshing }) {
                Scroll() {

                  Flex({ wrap: FlexWrap.Wrap }) {
                    Row({ space: 5 }) {
                      Image(this.tableData[this.currentIndex].img).width(15)
                      Text(this.tableData[this.currentIndex].name).fontWeight(FontWeight.Bold)
                    }.width('100%').height('6%').backgroundColor(Color.White)

                    ForEach(this.goodsData, (item: GoodsRecord, index: number) => {

                      Column() {
                        Image(item.imgList[0].url).width('100%').borderRadius(5).aspectRatio(1).objectFit(ImageFit.Contain)
                        Row() {
                          Text(`  ${item.name}`)
                            .maxLines(1)
                            .fontSize(10)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                        }.width('100%').height('25%')
                      }
                      .onClick(()=>
                      {
                        AppStorage.setOrCreate<number>('ids',Number(item.id))
                        router.pushUrl({url:'pages/GoodsDetail'})
                      })
                      .width('48.5%')
                      .height('25%')
                      .backgroundColor(Color.White)
                      .margin({ left: '1%', top: 3 })
                      .borderRadius(2)

                    })

                    if (this.goodsData.length === 0) {

                      Column() {
                        Image($r('app.media.call')).width('100%')
                        Text('上新中，敬请期待!')
                      }.width('100%').height('94%').backgroundColor(Color.White).justifyContent(FlexAlign.Center)
                    }
                    if (this.loading) {
                      Loading()
                    }
                  }

                }.width('100%').height('100%').align(Alignment.TopStart).onScrollEdge((side: Edge) => {
                  if (side == Edge.Bottom) {
                    this.handleSizeChange()
                  }
                })
              }.width('100%').height('100%')
              .onRefreshing(async () => {
                await this.load()
                this.refreshing = false
              })
            }.tabBar(this.buildTabbar(item.name, index)).align(Alignment.TopStart)
          }
          )
        }
        .scrollable(false)
        .barMode(BarMode.Scrollable)
        .vertical(true)
        .barWidth('30%')
        .barHeight('100%')
        .barBackgroundColor(Color.White)
        .onChange(async (index) => {
          this.currentIndex = index
          await this.load()
        })

      }.width('100%').height('90%')

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
