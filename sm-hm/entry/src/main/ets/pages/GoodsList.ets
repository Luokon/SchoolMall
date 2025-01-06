import { router } from '@kit.ArkUI'
import { MMKV } from '@tencent/mmkv';
import Loading from './component/loading'
import Result from '../utils/result'
import request from '../utils/request'
import Ipage from '../utils/ipage'
import { GoodsRecord, ImgRecord } from './component/goods';
import Elmessage from '../utils/elmessage';

let mmkv = MMKV.defaultMMKV();

@Entry
@Component
struct GoodsList {
  @State name: string = ''
  @State pageNum: number = 1
  @State pageSize: number = 10
  @State refreshing: boolean = false
  @State loading: boolean = false
  @State tableData: GoodsRecord[] = []

  aboutToAppear(): void {

    const params: object = router.getParams()
    const fname: string = params['name'] as string
    if (fname) {
      this.name = fname
      this.search()
    }
    this.search()


  }

  search = async () => {
    const res: Result<Ipage<GoodsRecord>> = await request.get('/goods/search', {
      params: {
        pageNum: this.pageNum,
        pageSize: this.pageSize,
        name: this.name
      }
    })
    this.tableData = res.data.records
    this.pageNum = res.data.current
    this.pageSize = res.data.size
    this.tableData.forEach((good: GoodsRecord) => {
      good.imgList = JSON.parse(good.img) as ImgRecord[]
    })
    this.refreshing=false
    this.loading=false
  }
  controller: TextInputController = new TextInputController()

  build() {
    Column() {
      //   第一行占位
      Column().width('100%').height('5%').backgroundColor(Color.White)
      // 第二行搜索
      Row() {

        Column() {
          Image($r('app.media.back'))
            .width('50%')
            .animation({ duration: 500 })
            .onClick(() => router.pushUrl({ url: 'pages/SearchView', params: { name: this.name } }))
            .zIndex(0)
        }.width('10%')

        Stack() {
          //   搜索样式
          TextInput({ placeholder: '请输入商品名称', text: this.name, controller: this.controller })
            .width('100%')
            .defaultFocus(false)
            .maxLength(10)
            .animation({ duration: 500 })
            .onChange((value) => this.name = value)
            .onFocus(() => {
              router.replaceUrl({ url: 'pages/SearchView', params: { name: this.name } })
            })
          if (this.name) {
            Image($r('app.media.delete')).width(20).onClick(() => {
              this.name = ''
              router.replaceUrl({ url: 'pages/SearchView', params: { name: '' } })
            }).margin({ right: 10 })
          }
        }
        .width('80%')
        .height('100%')
        .margin({ left: 5 })
        .alignContent(Alignment.End)
        .zIndex(1)

        Column().width('15%')


      }.width('100%').height('5%').justifyContent(FlexAlign.Center).backgroundColor(Color.White)

      //   第三列表
      Refresh({ refreshing: $$this.refreshing }) {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.tableData, (item: GoodsRecord, index: number) => {
              Column() {
                Image(item.imgList[0].url).width('100%').aspectRatio(1).objectFit(ImageFit.Contain)
                Text(`  ${item.name}`)
                  .fontSize(12)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .height('15%')
                Row() {
                  Text(`  ￥${item.price}`).fontColor(Color.Red)
                  Text(`  已抢${item.sales}件  `).fontColor(Color.Gray)
                }.width('100%').height('10%').justifyContent(FlexAlign.SpaceBetween)
              }
              .width('48.5%')
              .height('35%')
              .margin({ left: '1%', top: 5 })
              .borderRadius(5)
              .backgroundColor(Color.White)
              .alignItems(HorizontalAlign.Start)
              .onClick(()=>{
                AppStorage.setOrCreate<number>('ids',Number(item.id))
                router.pushUrl({url:'pages/GoodsDetail'})
              })

            })
            if (this.loading) {
              Loading()
            }
          }
        }.width('100%').height('100%').align(Alignment.TopStart).onScrollEdge((side: Edge) => {
          if (side == Edge.Bottom) {
            this.search()
          }
        })
      }.width('100%').height('90%')
      .onRefreshing(() => {
        this.search()
      })
    }.width('100%').height('100%').backgroundColor('#ededed')

  }
}