export default  interface Result<T=undefined> {
  code: number;
  msg: string,
  data: T
}
