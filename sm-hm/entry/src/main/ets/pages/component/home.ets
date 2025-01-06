import Result from '../../utils/result'
import request from '../../utils/request'
import Ipage from '../../utils/ipage'
import Elemessage from '../../utils/elmessage'
import { McPieChart, Options } from '@mcui/mccharts'
import log from '../../utils/log'
import { CategoryRecord } from '../Category'
import { router } from '@kit.ArkUI'
import { GoodsRecord, ImgRecord } from './goods'
import Loading from './loading'

interface Banner {

  id: number
  name: string
  img: string
  color: string
}


@Component
export default struct Home {
  @State name: string = '';
  @State loading: boolean = false
  @State fid: number = 0;
  @State bgcColor: string = '#FFFFFF'
  @State categoryList: CategoryRecord[] = []
  @State tableData: Banner[] = []
  @State currentx: number = 0
  @State currenty: number = 0
  @State currentShow: number = 0
  @State pageNum: number = 1
  @State pageSize: number = 10
  @State goodsList: GoodsRecord [] = []
  @State refreshing: boolean = false
  hexToRgba = (hex: string): string => {
    // 检查是否是有效的 16 进制颜色代码
    const validHex = /^#?([a-fA-F0-9]{6})$/;
    if (!validHex.test(hex)) {
      throw new Error("Invalid hex color.");
    }

    // 去掉 '#' 符号
    hex = hex.replace('#', '');

    // 将 16 进制颜色转换为 RGB
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);

    // 返回带有 0.8 透明度的 RGBA 颜色
    return `rgba(${r}, ${g}, ${b}, 0.8)`;
  }
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
  load = async () => {

    const res: Result<Ipage<Banner>> = await request.get(`/banner/page`)
    this.currentx = 1
    this.currenty = 1
    if (this.tableData.length === 0) {
      this.bgcColor = this.hexToRgba(res.data.records[0].color ? res.data.records[0].color : '#FFFFFF')
    }
    this.tableData = res.data.records
    //发起分页请求
    const gres: Result<Ipage<GoodsRecord>> = await request.get(`/goods/home`, {
      params: {
        pageSize: this.pageSize,
        pageNum: this.pageNum,

      }
    })

    this.goodsList = gres.data.records
    this.goodsList.forEach((good: GoodsRecord) => {
      good.imgList = JSON.parse(good.img) as ImgRecord[]
    })


    this.pageNum = gres.data.current
    this.pageSize = gres.data.size

    const cres: Result<CategoryRecord[]> = await request.get(`/category`)
    this.categoryList = cres.data
  }

  aboutToAppear(): void {
    this.load()
  }

  build() {
    Column() {
      // 第一行搜索
      Column() {
        Text(`  点击进行搜索`)

          .fontSize(15)
          .borderRadius(20)
          .width('100%')
          .height('35%').backgroundColor('#51f3f3f3')      .onClick(() => router.pushUrl({ url: 'pages/SearchView' }))
      }

      .height('15%')
      .width('100%')
      .backgroundColor(this.bgcColor)
      .padding({
        left: 20, right: 20
      })
      .justifyContent(FlexAlign.Center)


      Refresh({ refreshing: $$this.refreshing }) {
        Column() {
          // 轮播图
          Swiper() {
            ForEach(this.tableData, (item: Banner, index: number) => {
              Image(item.img)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Fill)
                .borderRadius(10)
                .scale({
                  x: this.currentx,
                  y: this.currenty
                })
                .animation({
                  duration: 1000
                })
            })
          }
          .height('20%')
          .width('100%')
          .padding({
            left: 5,
            right: 5,
            bottom: 10
          })
          .autoPlay(true)
          .interval(4000)
          .backgroundColor(this.bgcColor)
          .animation({
            duration: 200
          })
          .onChange((index: number) => {
            this.bgcColor = this.hexToRgba(this.tableData[index] ? this.tableData[index].color : '#FFFFFF')
          })

          //第三行分类图标展示
          Row() {
            // 八张图片
            Stack({ alignContent: Alignment.TopEnd }) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.categoryList, (item: CategoryRecord, index: number) => {
                  if (index <= 7) {

                    Column() {
                      Image(item.img).width(40)
                      Text(item.name).fontSize(12)

                    }
                    .borderRadius(5)
                    .width('25%')
                    .height('50%')
                    .backgroundColor(Color.White)
                    .justifyContent(FlexAlign.SpaceAround)
                    .onClick(() => {
                      AppStorage.setOrCreate<number>('cid', index)
                      AppStorage.setOrCreate<number>('index', 1)
                      router.replaceUrl({ url: 'pages/Index' })
                    })
                  }

                })
              }.width('100%').height('100%')

              if (this.categoryList.length > 8) {
                Image($r('app.media.more')).width(20).onClick(() => {
                  AppStorage.setOrCreate<number>("index", 1)
                  AppStorage.setOrCreate<number>('cid', 0)
                  router.replaceUrl({ url: 'pages/Index' })
                })
              }
            }.width('100%').height('100%')

          }.width('100%').height('20%').justifyContent(FlexAlign.SpaceAround).backgroundColor(Color.White)

          //第四行推荐商品
          Column() {


            Scroll() {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.goodsList, (item: GoodsRecord, index: number) => {
                  Column() {
                    Image(item.imgList[0].url).width('100%').aspectRatio(1).objectFit(ImageFit.Contain)    .borderRadius(5)
                    Text(`  ${item.name}`)
                      .fontSize(12)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .height('10%')
                    Row() {
                      Text(`  ￥${item.price}`).fontColor(Color.Red)
                      Text(`  已抢${item.sales}件  `).fontColor(Color.Gray)
                    }.width('100%').height('10%').justifyContent(FlexAlign.SpaceBetween)
                  }
                  .onClick(()=>{
                    AppStorage.setOrCreate<number>('ids',Number(item.id))
                    router.pushUrl({url:'pages/GoodsDetail',params:{gid:item.id}})
                  })
                  .width('48.5%')
                  .height('70%')
                  .margin({ left: '1%', top: 5 })
                  .borderRadius(5)
                  .backgroundColor(Color.White)
                  .alignItems(HorizontalAlign.Start)

                })
                if (this.loading) {
                  Loading()
                }
              }

            }.width('100%').height('100%').onScrollEdge((side: Edge) => {
              if (side == Edge.Bottom) {
                this.handleSizeChange()
              }
            })

          }
          .width('100%')
          .height('45%')
          .borderRadius(10)

          .margin({ top: 5 })
        }

      }.onRefreshing(async () => {

        await this.load()
        this.refreshing = false
      })

    }


    .height('100%')
    .width('100%')
    .backgroundColor('#ededed')
  }
}