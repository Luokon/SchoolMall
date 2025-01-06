@Component
export default struct Loading {


  build() {
    Column() {
      Image($r('app.media.loading')).width(90)
    }.width('100%').backgroundColor('#ededed').justifyContent(FlexAlign.Center)
  }
}