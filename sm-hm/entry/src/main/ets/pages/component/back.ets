import { router } from '@kit.ArkUI';


@Component
export default struct Back {
  @State message: string = 'Hello World';
  @State url: string = ''

  build() {
    Column() {
      Row() {
        Image($r('app.media.back')).width(20)
        Text('返回').fontSize(20).fontWeight(FontWeight.Normal)
      }.onClick(() => {
          router.clear()
          router.replaceUrl({url:this.url})
      })
    }.width('100%').height('7%').justifyContent(FlexAlign.End).alignItems(HorizontalAlign.Start).backgroundColor(Color.White)
  }
}