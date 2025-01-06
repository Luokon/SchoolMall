import { hilog } from '@kit.PerformanceAnalysisKit';
import Result from 'ets/utils/result'
import request from 'ets/utils/request';
import Ipage from 'ets/utils/ipage'
import { window } from '@kit.ArkUI';
import Elmessage from '../utils/elmessage';
import Home from './component/home';
import Content from './component/content';

import Person from './component/person';
import Category from './Category';
import Cart from './component/cart';


@Entry
@Component
struct Index {
  @State message: string = '';
  @State currentIndex: number|undefined = AppStorage.get('index')


  @Builder
  tabbrBuilder(currnet: number, title: string, icon: ResourceStr, sIcon: ResourceStr) {

    Column({ space: 5 }) {

      Image(currnet === this.currentIndex ? sIcon : icon).width(20)
      Text(title).fontSize(12).fontColor(currnet === this.currentIndex ? '#1296db' : '#2c2c2c')

    }

  }

  /**
   * 非全屏显示
   */
  aboutToAppear(): void {
    window.getLastWindow(getContext())
      .then(win => {
        win.setWindowLayoutFullScreen(true)

      })
  }

  build() {
    //留底部安全区域
    Column(){
      Tabs({
        barPosition: BarPosition.End,
        index:AppStorage.get('index')

      }) {
        TabContent() {
          Home()
        }.tabBar(this.tabbrBuilder(0, '首页', $r('app.media.home'), $r('app.media.s_home')))

        TabContent() {
          Category()
        }.tabBar(this.tabbrBuilder(1, '分类', $r('app.media.category'), $r('app.media.s_category')))

        TabContent() {
         Cart()
        }.tabBar(this.tabbrBuilder(2, '购物车', $r('app.media.cart'), $r('app.media.cart')))

        TabContent() {
          Person()
        }.tabBar(this.tabbrBuilder(3, '个人', $r('app.media.person'), $r('app.media.s_person')))
      }.scrollable(false)
      .onChange((index: number) => {
        AppStorage.setOrCreate<number>('index',index)
        this.currentIndex = index}).width('100%').height('98%')
    }.width('100%').height('100%')

  }
}