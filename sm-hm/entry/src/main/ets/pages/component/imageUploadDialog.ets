import picker from '@ohos.file.picker';
import { checkPermissions, applyPermission, copyFileToCache } from '../../utils/index'
import { request } from '@kit.BasicServicesKit';
import { Permissions } from '@ohos.abilityAccessCtrl';
import camera from '@ohos.multimedia.camera';
import camerapicker from '@ohos.multimedia.cameraPicker';

import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import Elmessage from '../../utils/elmessage';
import log from '../../utils/log';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

//上传回调数据类型
interface ReceiveRes {
  body: string
  headers: object
}


@Extend(Text)
function custText() {
  .width('100%')
  .height('48')
  .fontColor('#39364D')
  .textAlign(TextAlign.Center)
}

@CustomDialog
export default struct ImageUploadDialog {
  dialogController: CustomDialogController
  @Prop uploadURL:string='';//上传接口地址
  private context = getContext(this) as common.UIAbilityContext; //UIAbilityContext
  private success: (res: ReceiveRes) => void = () => {} //上传成功回调
  private fail: (res: request.TaskState[]) => void = () => {} //上传失败回调
  private complete: (res: request.TaskState[]) => void = () => {} //上传完成回调

  //检查权限
  async checkAppPermission(): Promise<boolean> {

    try {
      const READ_MEDIA_PERMISSION: Permissions = 'ohos.permission.READ_MEDIA' //媒体读取权限
      const WRITE_MEDIA_PERMISSION: Permissions = 'ohos.permission.WRITE_MEDIA' //媒体写入权限
      let permissionList: Permissions[] = []; //需要申请选项列表
      let readPermission = await checkPermissions(READ_MEDIA_PERMISSION)//检查是否有媒体读取权限
      !readPermission && permissionList.push(READ_MEDIA_PERMISSION)
      let writePermission = await checkPermissions(WRITE_MEDIA_PERMISSION)//检查是否有媒体写入权限
      !writePermission && permissionList.push(READ_MEDIA_PERMISSION)
      //if !readPermission 则说明已经拥有这个权限了
     //如果没申请权限列表存在长度
      if (permissionList.length) {
        //则需要申请权限
        let res: boolean = await applyPermission(this.context, permissionList)
        if (!res) {//用户未同意授权

          AlertDialog.show({
            title: "提示",
            message: "无权限读写用户外部存储中的媒体文件信息，请前往系统设置开启",
            alignment: DialogAlignment.Center,
            secondaryButton: {
              value: '关闭',
              action: () => {
              }
            }
          })
        }
        return res
      }
      //如果无权限列表为空，那么则说明是软件是有权限的
      return true

    }

    catch (e) {
      return Promise.reject(e)
    }
  }

  //开始上传图片 path：图片路径后缀（图片名称）
  async uploadImage(path: string) {

    let uri=`internal://cache/${path}` //上传图片全路径
    let uploadConfig: request.UploadConfig = {
      url:this.uploadURL,
      header:{},
      method: "POST",
      files: [{ filename: path, name: "file", uri, type: path.split('.')[path.split('.').length-1] }],
      data: [],
    };
    try {
      let uploadTask:request.UploadTask=await request.uploadFile(this.context, uploadConfig)
      //上传中回调
      uploadTask.on('progress', (size,total) => {
        console.log(size.toString(),total.toString(),'上传进度')
      })

      //每上传一张图片成功回调
      uploadTask.on('headerReceive', (data: object) => {
        let res = data as ReceiveRes

        this.success && this.success(res)
      })

      //所有上传完成回调
      uploadTask.on('complete', (taskStates: request.TaskState[]) => {

        console.info("upOnComplete complete taskState:" + JSON.stringify(taskStates));
        this.complete && this.complete(taskStates)
      })
      //上传失败回调
      uploadTask.on('fail', (taskStates: request.TaskState[]) => {
        console.info("upOnComplete fail taskState:" + JSON.stringify(taskStates));
        this.fail&&this.fail(taskStates)
      })
    }catch (e){

      console.log( JSON.stringify(e),'e')
    }

  }

  build() {
    Column() {
      //拍照
      Text('拍照').custText().onClick(async()=>{
        //检查是否有读写外部媒体权限
        let res: boolean = await this.checkAppPermission()
        //无权限返回
        if (!res) return
        try {
          let pickerProfile: camerapicker.PickerProfile = {
            cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
          };
          let pickerResult: camerapicker.PickerResult = await camerapicker.pick(this.context,
            [camerapicker.PickerMediaType.PHOTO, camerapicker.PickerMediaType.PHOTO], pickerProfile);
          if(pickerResult?.resultUri){
            //关闭弹窗
            this.dialogController.close()
            //复制图片到缓存目录（缓存目录才有读写权限）
            let filePath = await copyFileToCache(pickerResult.resultUri, this.context)
            if (filePath) {

              this.uploadImage(filePath)
            }

          }
        } catch (error) {
          let err = error as BusinessError;
          console.error(`the pick call failed. error code: ${err.code}`);
        }

      })
      //从手机相册选择
      Text('从手机相册选择').custText().onClick(async () => {
        //检查是否有读写外部媒体权限
        let res: boolean = await this.checkAppPermission()
        //无权限返回
        if (!res) return

        // 实例化 选项对象
        const photoSelectOptions = new picker.PhotoSelectOptions();
        // 过滤选择媒体文件类型为IMAGE
        photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
        // 选择媒体文件的最大数目
        photoSelectOptions.maxSelectNumber = 1;


        //关闭弹窗
        this.dialogController.close()
        // 创建 图片选择对象
        const photoViewPicker = new picker.PhotoViewPicker();
        // 调用 select 方法，传入选项对象
        photoViewPicker.select(photoSelectOptions)
          .then(res => {
            const uri = res.photoUris[0]
            // 因为只选了一张
            // AlertDialog.show({ message: '图片路径为:' + uri })

            // 三、拷贝文件到缓存目录
            // 将文件保存到缓存目录(只能上传在缓存目录中的文件)
            const context = getContext(this)
            const fileType = 'jpg'
            // 生成一个新的文件名
            const fileName = Date.now() + '.' + fileType
            // 通过缓存路径+文件名 拼接出完整的路径
            const copyFilePath = context.cacheDir + '/' + fileName

            // 将文件 拷贝到 临时目录
            let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);


            fs.copyFileSync(file.fd, copyFilePath)
            let files: Array<request.File> = [
            // internal://cache/ 固定的
            // name 和接口文档的要求对上
              { filename: fileName, type: fileType, name: 'img', uri: `internal://cache/${fileName}` }
            ]
             this.uploadImage(files[0].filename)
          })

      })
      Button('取消', { type: ButtonType.Capsule })
        .backgroundColor('#F7F7F7')
        .fontSize('16fp')
        .fontColor('#333333')
        .width('100%')
        .margin({ top: '30' })
        .onClick(() => {
          this.dialogController.close()
        })
    }.width('100%').padding({ left: '16', top: '11', right: '16', bottom: '30' })
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: '24',
      topRight: '24'
    })
  }
}
