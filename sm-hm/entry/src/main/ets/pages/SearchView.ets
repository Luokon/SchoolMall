import { router, window } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import { MMKV } from '@tencent/mmkv';

let mmkv = MMKV.defaultMMKV();

@Entry
@Component
struct SearchView {
  @State inputWidth: string = '98%'
  @State backWidth: string = '0'
  @State name: string = ''
  @State searchList: string[] = []
  @State isEnableKeyboardOnFocus: boolean = false
  controller: TextInputController = new TextInputController()
  search = () => {
    if (!this.name) {
      return
    }

    if (!this.searchList.includes(this.name)) {
      this.searchList.unshift(this.name); // 如果不包含则添加到数组中
    }
    router.pushUrl({
      url: 'pages/GoodsList', params: {
        name: this.name
      }
    })
    mmkv.encodeString("searchList", JSON.stringify(this.searchList))

  }

  /**
   * 全屏显示
   */
  aboutToAppear(): void {
    window.getLastWindow(getContext())
      .then(win => {
        win.setWindowLayoutFullScreen(true)

      })
    const params: object = router.getParams()
    if (params) {
      const fname: string = params['name'] as string

      if (fname) {
        this.name = fname
      }
    }
    // Elmessage.success(JSON.stringify(params['name']))

    // if (fname) {
    //   this.name = fname
    // }

    this.isEnableKeyboardOnFocus = true
    const str: string = mmkv.decodeString("searchList") as string
    if (str) {
      this.searchList = JSON.parse(str) as string[]
    }
    setTimeout(() => {
      this.backWidth = '5%'
      this.inputWidth = '80%'
    }, 300)
  }

  build() {
    // 整体父结构
    Column() {
      //   第一行占位
      Column().width('100%').height('5%')
      // 第二行搜索
      Row() {

        Column() {
          Image($r('app.media.back'))
            .width('100%')
            .animation({ duration: 500 })
            .onClick(() => router.replaceUrl({ url: 'pages/Index' }))
            .zIndex(0)
        }.width(this.backWidth)

        Stack() {
          //   搜索样式
          TextInput({ placeholder: '请输入商品名称', text: this.name, controller: this.controller })
            .width('100%')
            .defaultFocus(this.isEnableKeyboardOnFocus)
            .maxLength(10)
            .animation({ duration: 500 })
            .onChange((value) => this.name = value)
            .onSubmit(() => {
              this.search()
            })
          if (this.name) {
            Image($r('app.media.delete')).width(20).onClick(() => {
              this.name = ''
            }).margin({ right: 10 })
          }
        }
        .width(this.inputWidth)
        .height('100%')
        .margin({ left: 5 })
        .alignContent(Alignment.End)
        .zIndex(1)

        Text('搜索').fontColor('#0D7BF8').margin({ left: 10 }).onClick(() => {
          this.search()
          this.controller.stopEditing()
        }).zIndex(0)

      }.width('100%').height('5%').justifyContent(FlexAlign.Center)

      //   第三行搜索记录
      Column() {
        Row({ space: 5 }) {
          Text(` 搜索记录`).fontSize(12).fontWeight(FontWeight.Bolder)
          Image($r('app.media.view')).width(18)
        }.width('100%')

      }
      .width('100%')
      .height('5%')
      .border({ width: { bottom: 1 }, color: '#ededed' })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      // 搜索记录内容
      Column() {

        Scroll() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.searchList, (item: string, index: number) => {
              Text(item)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .backgroundColor('#ededed')
                .borderRadius(10)
                .height('3%')
                .padding({ left: 5, right: 5 })
                .margin({ top: 5, bottom: 5, left: 5 })
                .onClick(() => {
                  this.name = item
                  this.search()
                })
            })
          }
        }.width('100%').height('100%').align(Alignment.Top)
      }.width('100%').height('82%')
    }.width('100%').height('100%')
  }
}