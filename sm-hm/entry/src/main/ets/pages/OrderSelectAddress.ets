import Elmessage from '../utils/elmessage';
import Loading from './component/loading';
import Ipage from '../utils/ipage'
import request from '../utils/request'
import Result from '../utils/result'

import { router } from '@kit.ArkUI';
import Back from './component/back';


export interface AddressRecord {
  id: string,
  name: string,
  phone: string,
  content: string,
  username: string,
  isDefault: number,
}

@Entry
@Component
export default struct SelectAddress {
  @State name: string = ''
  @State aid: number = 0
  @State ids: string = ''
  @State fid: number | undefined | string = undefined
  @State pageNum: number = 1
  @State pageSize: number = 10
  @State form: AddressRecord = {
    id: '',


    name: '',


    phone: '',


    content: '',


    username: '',
    isDefault: 0
  }
  @State formError: AddressRecord = {
    id: '',
    name: '',
    phone: '',

    content: '',
    username: '',
    isDefault: 0
  }
  @State tableData: AddressRecord [] = []
  @State currentAddOpacity: number = 1
  @State currentCancelOpacity: number = 0
  @State refreshing: boolean = false
  @State loading: boolean = false
  // 初始加载(上拉刷新)下滑加载部分依赖使用
  load = async () => {
    //发起分页请求
    const res: Result<Ipage<AddressRecord>> = await request.get(`/address/page`, {
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
    await request.delete(`/address/${this.fid}`)
    Elmessage.success('删除成功！')
    await this.load()
    this.deleteController.close()
  }
  setCheck = async (item: AddressRecord) => {
    await request.put(`/address/${item.id}`, item)
    Elmessage.success('操作成功')
    await this.load()
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
      Column() {
        Row() {
          Image($r('app.media.back')).width(20)
          Text('返回').fontSize(20).fontWeight(FontWeight.Normal)
        }.onClick(() => {

          router.replaceUrl({url:'pages/Settle'})
        })
      }
      .width('100%')
      .height('7%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)


      //   第二层下滑刷新，上滑加载
      Column() {

        Refresh({ refreshing: $$this.refreshing }) {


          Scroll() {
            Column() {
              Divider().color('#C9C9C9').width('100%').strokeWidth(1)
              ForEach(this.tableData, (item: AddressRecord, index: number) => {
                //todo 此处需要自定义样式
                Column() {
                  Row({ space: 5 }) {
                    Text(`${item.name},`).fontSize(14)
                    Text(`${item.phone}`).fontSize(14)
                  }.width('100%').height('20%')

                  Row({ space: 5 }) {
                    Text(`${item.content}`).fontSize(16).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.width('100%').height('20%')


                  Button('选中').type(ButtonType.Normal).height(20).borderRadius(5).onClick(()=>{

                    AppStorage.setOrCreate<number>('aid',Number(item.id))
                    router.replaceUrl({url:'pages/Settle'})

                  })
                }
                .width('100%')

                .backgroundColor(Color.White)
                .padding({ left: 10, right: 10, top: 10 })
                .margin({ top: 1 })
                .height('15%')

                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceAround)

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
