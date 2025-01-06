import hilog from '@ohos.hilog';
/**
 * 日志工具类
 */
export default class log{
  /**
   * info
   */
  static info=(msg:string)=>{
    hilog.info(0x0000, 'log', '%{public}s', msg);
  }
  /**
   * warn
   */
  static warn=(msg:string)=>{
    hilog.warn(0x0000, 'log', '%{public}s', msg);
  }
  /**
   * error
   */
  static error=(msg:string)=>{
    hilog.error(0x0000, 'log', '%{public}s', msg);
  }
}