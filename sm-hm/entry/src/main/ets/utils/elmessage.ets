import { promptAction } from '@kit.ArkUI'
export default class  Elmessage{

  static success=(msg:string=''):void=>{
      promptAction.showToast({
        message: msg ? msg : '操作成功',
        duration: 1000000000,
        bottom: 100,
      })
  }
  static warn=(msg:string=''):void=>{
    promptAction.showToast({
      message: msg ? msg : '操作成功',
      duration: 1000,
      bottom: 100,
    })
  }
  static error=(msg:string=''):void=>{
    promptAction.showToast({
      message: msg ? msg : '操作成功',
      duration: 1000,
      bottom: 100,
    })
  }
}