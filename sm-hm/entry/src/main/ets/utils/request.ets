import axios, { AxiosError, AxiosInstance, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import Result from 'ets/utils/result'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { promptAction, router } from '@kit.ArkUI'
import { constant } from '@kit.ConnectivityKit'
import Constant from '../common/Constant'
import log from './log'
import { MMKV } from '@tencent/mmkv';

let mmkv = MMKV.defaultMMKV();
const request: AxiosInstance = axios.create({
  baseURL: Constant.ipAddress,
  timeout: 5000
})
/**
 * 前置拦截
 */
request.interceptors.request.use((config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
  log.warn(JSON.stringify(AppStorage.get<string>('Authorization')))
  config.headers.Authorization= mmkv.decodeString('Authorization')

  return config
})
/**
 * 后置拦截
 */
request.interceptors.response.use((response: AxiosResponse) => {
  //获取返回来的对象
  const result: Result | undefined = response.data
  //判断result的code值
  if (result?.code === 200) {
    return response.data
  } else {
    showErrorMessage(result?.msg)
    return Promise.reject(result?.msg)
  }


}, (error: AxiosError<Result<undefined>, undefined>): Promise<never> => {
  const status: number | undefined = error.response?.status
  const result: Result | undefined = error.response?.data
  // showErrorMessage(JSON.stringify(error))
  // hilog.info(0x0000, 'requesttag', '%{public}s', JSON.stringify(status));
  // hilog.info(0x0000, 'requesttag', '%{public}s', JSON.stringify(result));
  log.info(JSON.stringify(status))
  log.warn(JSON.stringify(result))
  if (error.message.search('2300028') != -1) {
    showErrorMessage('网络超时，请进行检查！')
  } else if (status === 400) {
    showErrorMessage(result?.msg)
  } else if (status === 500) {
    showErrorMessage(result?.msg?result?.msg:'服务器内部异常')
  } else if (status === 401) {
    //准备清除缓存，跳转到登录页面
    mmkv.removeValueForKey('Authorization');

    router.replaceUrl({
      url: 'pages/Login' // 目标url
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke replaceUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke replaceUrl succeeded.');
    })
  } else if (status === 403) {
    showErrorMessage('您暂时没有权限！')
  } else if (status === 404) {
    showErrorMessage('访问路径不存在！')
  } else if (status === 405) {
    showErrorMessage('请求方法错误！')
  } else {
    showErrorMessage('系统异常！')
  }

  return Promise.reject(error)

})
const showErrorMessage = (msg: string | undefined): void => {
  promptAction.showToast({
    message: msg ? msg : '系统异常请联系管理员!',
    duration: 1000,
    bottom: 100
  })
}

export default request