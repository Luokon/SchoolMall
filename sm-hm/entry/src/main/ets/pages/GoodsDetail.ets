import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import request from '../utils/request';
import { GoodsRecord, ImgRecord } from './component/goods';
import Result from '../utils/result'
import { inputMethod } from '@kit.IMEKit';

@Entry
@Component
struct GoodsDetail {
  @State message: string = '商品详情页面';
  @State gid: number | undefined = undefined;
  @State refreshing: boolean = false
  @State form: GoodsRecord = {
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

  aboutToAppear(): void {
    const inputController: inputMethod.InputMethodController = inputMethod.getController();
    inputController.off("insertText");
    inputController.off("deleteLeft");


    this.load()
  }

  load = async () => {
    const res: Result<GoodsRecord> = await request.get(`/goods/${AppStorage.get<number>('ids')}`)
    this.form = res.data
    this.form.imgList = JSON.parse(this.form.img)
    this.form.contentList = JSON.parse(this.form.content)
  }
  controller: CustomDialogController = new CustomDialogController({
    builder: CustomCartDialog({
      cancel: this.load,
      goods: this.form
    }), // 弹框的构造器
    alignment: DialogAlignment.BottomStart,
    cancel: () => {
      // 点击蒙层的回调
    },
    autoCancel: true, // 允许点击蒙层关闭弹窗
    customStyle: true               // 使用自定义样式
  });

  build() {
    Column() {
      Column() {
        Refresh({ refreshing: $$this.refreshing }) {
          Scroll() {
            Column() {
              // 第一行轮播图等宽高、stack定位
              Stack() {
                Swiper() {
                  ForEach(this.form.imgList, (item: ImgRecord, index: number) => {
                    Image(item.url).width('100%').height('100%').objectFit(ImageFit.Contain)
                  })
                }.width('100%').height('100%')

                Row() {
                  Image($r('app.media.back'))
                    .width(25)
                    .margin({ left: 5 })
                    .borderRadius(50)
                    .backgroundColor('#7a180000')
                    .fillColor(Color.White)
                    .onClick(() => {
                      router.back()
                    })
                }.width('100%').height('15%').alignItems(VerticalAlign.Bottom)
              }.width('100%').aspectRatio(1).align(Alignment.TopStart)

              //   第二行 售价+销量
              Row() {
                Text(`  ￥${this.form.price}`)
                  .fontColor(Color.Red)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(15)
                  .margin({ left: 5 })
                Text(` 已售${this.form.sales}`).fontColor(Color.Gray).fontSize(15).margin({ right: 5 })
              }.width('100%').height('5%').justifyContent(FlexAlign.SpaceBetween)

              //   第三行 商品名称
              Row() {
                Text(`  ${this.form.name}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Start)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }.width('100%').height('5%').alignItems(VerticalAlign.Top)

              Divider().color('#C9C9C9').width('100%').strokeWidth(1)

              // RichText(this.form.content)
              ForEach(this.form.contentList,  (item: ImgRecord, index: number) => {
                Image(item.url).width('100%').aspectRatio(1)
              })
              // 分割线
            }.alignItems(HorizontalAlign.Start)

          }.width('100%').height('100%').align(Alignment.TopStart)
        }.width('100%').height('100%').onRefreshing(() => {
          this.load()
          this.refreshing = false
        })
      }.width('100%').height('91%')

      Row({ space: 10 }) {
        // 加入购物车
        // 立即购买
        Button('加入购物车', { type: ButtonType.Normal })
          .width('45%')
          .backgroundColor('#F9982F')
          .fontColor(Color.White)
          .borderRadius(5)
          .onClick(() => {

            this.controller.open()
          })
        Button('立即购买', { type: ButtonType.Normal })
          .width('45%')
          .backgroundColor('#F85620')
          .fontColor(Color.White)
          .borderRadius(5)
          .onClick(()=>

          {
            AppStorage.setOrCreate<number>('aid',0)
            router.pushUrl({url:'pages/Apply'})
          })
      }.width('100%').height('6%').justifyContent(FlexAlign.Center)
    }.width('100%').height('100%')
  }
}

interface CartRecord {
  id: string,
  scount: number,
  gid: string,
  goods:GoodsRecord
}

@CustomDialog
struct CustomCartDialog {
  @Link goods: GoodsRecord
  @State form: CartRecord = {
    id: '',
    scount: 1,
    gid: '',
    goods:this.goods
  }
  private controller: CustomDialogController; // 定义controller
  cancel = () => {
  }
  confirm = () => {

  }

  build() {

    Column() {
      // Text(JSON.stringify(this.goods))
      //   第一行返回
      Row() {
        Image($r('app.media.delete')).width(30).onClick(() => {
          this.controller.close()
        })
      }.width('100%').height('5%').justifyContent(FlexAlign.End)

      //   第二行商品
      Row({ space: 10 }) {
        //   左边商品，右上名称、右下number选择器
        Image(this.goods.imgList[0].url).width('30%').aspectRatio(1)
        Column() {
          Text(`${this.goods.name}`)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(FontWeight.Bolder)
            .margin({ left: 5 })
          Text(`￥${this.goods.price}`)
            .fontColor(Color.Red)
            .fontWeight(FontWeight.Bold)
            .fontSize(15)
            .margin({ left: 5 })
          Counter() { // 包含一个子组件
            Text(this.form.scount.toString())// Text 默认值为 1
              .fontSize(18) // Text 字体大小
          }.margin({ left: 5 }).onInc(() => { // 自增操作
            this.form.scount++;
          })
          .onDec(() => { // 自减操作
            this.form.scount--;
          })
        }.width('60%').height('22%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .height('80%')

      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Center)

      //   第三行加入购物车
      Row() {
        Button('加入购物车', { type: ButtonType.Normal })
          .width('100%')
          .backgroundColor('#F9982F')
          .fontColor(Color.White)
          .borderRadius(5)
          .onClick(async () => {
            this.form.gid=this.form.goods.id
            await request.post('/cart',this.form)
            Elmessage.success('加入购物车成功')



            AppStorage.setOrCreate<number>('index', 2)
            router.replaceUrl({ url: 'pages/Index' })
            router.clear()
            this.controller.close()
          })
      }.width('100%').height('15%').padding(10)
    }.width('100%').backgroundColor(Color.White).height('80%')
  }
}

