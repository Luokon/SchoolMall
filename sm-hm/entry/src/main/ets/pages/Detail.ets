import { router } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import Result from 'ets/utils/result'
import request from 'ets/utils/request';
import Back from './component/back';

interface MessageRecord {
  id: undefined;
  name: string;
  des: string;
  createTime: string; // ISO 8601 format, e.g., '2023-09-07T12:34:56'
  username: string;
  reply: string;
  statu: number;
}

@Entry
@Component
struct Detail {
  @State message: string = '留言详情页面';
  @State fid: number = 0
  @State refreshing: boolean = false
  @State form: MessageRecord = {
    id: undefined,
    name: '',
    des: '',
    createTime: '',
    username: '',
    reply: '',
    statu: 0
  }

  onPageShow(): void {
    const params: object = router.getParams()
    this.fid = params['id'] as number
    this.load()
  }

  load = async () => {
    const res: Result<MessageRecord> = await request.get(`/message/${this.fid}`)
    this.form = res.data
  }

  build() {
    Column() {
      Back({ url: 'pages/Index' })

      Refresh({ refreshing: $$this.refreshing }) {
        Column() {
          Scroll() {
            Column() {
              Text(this.form.name).fontSize(20).fontWeight(FontWeight.Bold).height(30)
              Text(this.form.createTime).fontSize(12).height(20)
               Text(this.form.des).fontSize(12).fontColor('#878787').margin({bottom:5})

              Divider().color('#C9C9C9').width('100%').strokeWidth(1)
              if (this.form.statu===1){
                Text('回复如下:').fontSize(12).fontColor(Color.Red).margin({bottom:5,top:5})
                Text(this.form.reply).fontSize(12).margin({bottom:5})

              }
            }.alignItems(HorizontalAlign.Start).padding(10)

          }.width('100%').height('100%').align(Alignment.TopStart)
        }.width('100%').height('100%').backgroundColor(Color.White)

      }.width('100%').height('90%').onRefreshing(async () => {
        this.refreshing = false
        await this.load
      })
    }.width('100%').height('100%')
  }
}