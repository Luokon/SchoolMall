import request from '../../utils/request';
import Result from '../../utils/result'
import Base from './base';


interface SystemInformation {
  freeDiskSpaceGB: number;
  maxMemoryGB: number;
  freeMemoryGB: number;
  totalDiskSpaceGB: number;
  osName: string; // 操作系统名称
  osArch: string; // 操作系统架构
  osVersion: string; // 操作系统版本
  userDir: string; // 当前程序所在目录
  javaVersion: string; // Java版本
  javaVendor: string; // Java供应商
  javaVmName: string; // Java虚拟机名称
  javaVendorUrl: string; // 供应商官网
  maxMemory: number; // 最大内存
  totalMemory: number; // 总内存
  totalMemoryGB: number; // 总内存GB
  freeMemory: number; // 空闲内存
  availableProcessors: number; // 可用处理器数量
  systemLoadAverage: number; // 系统负载平均值（如果支持的话）
  freeDiskSpace: number; // 磁盘的剩余空间
  totalDiskSpace: number; // 磁盘的总空间
  userLanguage: string; // 用户语言
  fileSeparator: string; // 文件分隔符
  lineSeparator: string; // 行分隔符
}


@Component
export default struct Content {
  @State message: string = '简介组件';
  @State refreshing: boolean = false
  @State form: SystemInformation = {
    freeDiskSpaceGB: 0,
    maxMemoryGB: 0,
    freeMemoryGB: 0,
    totalDiskSpaceGB: 0,
    osName: '',
    osArch: '',
    osVersion: '',
    userDir: '',
    javaVersion: '',
    javaVendor: '',
    javaVmName: '',
    javaVendorUrl: '',
    maxMemory: 0,
    totalMemory: 0,
    totalMemoryGB: 0,
    freeMemory: 0,
    availableProcessors: 0,
    systemLoadAverage: 0,
    freeDiskSpace: 0,
    totalDiskSpace: 0,
    userLanguage: '',
    fileSeparator: '',
    lineSeparator: ''
  }

  aboutToAppear(): void {
    this.load()
  }

  // 初始化方法
  load = async () => {
    const res: Result<SystemInformation> = await request.get(`/system`)
    this.form = res.data
  }

  @Builder
  buildDesTable() {
    Refresh({ refreshing: $$this.refreshing }) {
      Scroll() {
        Column() {
          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.window')).width('15')
              Text('系统名称').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(this.form.osName)
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.copyright')).width('15')
              Text('系统版本').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(this.form.osVersion)
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.arm')).width('15')
              Text('系统架构').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(this.form.osArch)
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.CPU')).width('15')
              Text('核心数量').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(JSON.stringify(this.form.availableProcessors))
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.java')).width('15')
              Text('Java版本').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(this.form.javaVersion)
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.company')).width('15')
              Text('供应源头').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(this.form.javaVendor)
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.disk')).width('15')
              Text('存储总量').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(JSON.stringify(this.form.totalDiskSpaceGB) + "GB")
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.cloud')).width('15')
              Text('剩余总量').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(JSON.stringify(this.form.freeDiskSpaceGB) + "GB")
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.ram')).width('15')
              Text('最大内存').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(JSON.stringify(this.form.maxMemoryGB) + "GB")
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 0
            },
            color: '#EBEEF5'
          })

          Row() {
            // 表单参数名
            Row({ space: 10 }) {
              Image($r('app.media.maxram')).width('15')
              Text('剩余内存').fontSize('15')

            }
            .width('50%')
            .height('100%')
            .backgroundColor('#F5F7FA')
            .border({
              width: {
                top: 0,
                left: 0,
                right: 1,
                bottom: 0
              },
              color: '#EBEEF5'
            })
            .justifyContent(FlexAlign.Center)

            // 表单参数值
            Row() {
              Text(JSON.stringify(this.form.freeMemoryGB) + "GB")
            }.width('50%').height('100%').justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('10%')
          .border({
            width: {
              top: 1,
              left: 1,
              right: 1,
              bottom: 1
            },
            color: '#EBEEF5'
          })
        }.width('100%').height('100%').align(Alignment.TopStart)
      }.width('100%').height('100%').align(Alignment.TopStart)

    }.width('100%').height('100%').onRefreshing(() => {
      this.load()
      this.refreshing = false
    })
  }

  build() {
    Column() {
      Column().width('100%').height('5%')
      //   下滑刷新，

      // 上滑加载

      // tabs栏
      Tabs() {


        TabContent() {
          this.buildDesTable()
        }.tabBar('系统参数').align(Alignment.TopStart)

      }

    }.width('100%').height('95%')
  }
}