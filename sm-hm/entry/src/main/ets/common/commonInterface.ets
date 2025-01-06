/**
 * 验证码接口
 */
export interface Captcha {
  /**
   * 验证码url
   */
  captchaImg: string,

  /**
   * 验证码key
   */
  token: string
}
/**
 * 注册和找回密码接口
 */
export   interface RegisterDto {

  username: string; // 账户名
  password: string; // 密码
  checkPass: string; // 确认密码
  nickname: string; // 昵称
  avatar: string; // 头像
  phone: string; // 手机号
  email: string; // 邮箱
  content: string; // 个人简介
  token: string; // 令牌
  code: string; // 验证码
  balance:number;
  applyPassword:string
}