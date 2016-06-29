//
//  QRCodeViewController.swift
//  Swift微博项目
//
//  Created by 瑶波波 on 16/6/29.
//  Copyright © 2016年 米多财富管理有限公司. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, UITabBarDelegate {
    
    // MARK:xib属性
    @IBOutlet weak var customBar: UITabBar!
    // 扫描图片，动画主要是在这个图片上
    @IBOutlet weak var scanImage: UIImageView!
    
    @IBOutlet weak var containerHcons: NSLayoutConstraint!
    //冲击波中间约束，用于做动画使用
    @IBOutlet weak var centerCons: NSLayoutConstraint!
    
    // MARK:AVFoundation类属性，用于二维码扫描
    // 会话
    private lazy var session: AVCaptureSession = AVCaptureSession()
    
    // 输入设备
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        // 获取摄像头
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            // 创建输入对象
            let device = try AVCaptureDeviceInput.init(device: device)
            return device
        }catch {
            print(error)
            let fatal:NSError = error as NSError
            // 没有权限访问相机
            if fatal.code == -11852 {
                let alert = UIAlertController.init(title: "微博没有权限访问您的相机", message: "请您进入设置-隐私-相机为我们开启权限", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction.init(title: "我知道了", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return nil
        }
    }()
    
    // 输出对象
    private lazy var outPut: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    // 预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
        layer.frame = UIScreen.mainScreen().bounds
        return layer
    }()
    
    // MARK:主要方法
    override func viewDidLoad() {
        super.viewDidLoad()
        // 默认选中第一个标签
        customBar.selectedItem = customBar.items![0]
        customBar.delegate = self;
        
        //程序进入后台后动画被关闭,添加监听来重启动画
        let notiCenter = NSNotificationCenter.defaultCenter()
        notiCenter.addObserver(self, selector: #selector(startAnimation), name: UIApplicationWillEnterForegroundNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }
    
    /**
     开始扫描动画
     */
    func startAnimation() {
        centerCons.constant = -containerHcons.constant
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(2.0, animations: {
            self.centerCons.constant = self.containerHcons.constant
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
            }) { (completed) in
//                self.startAnimation()
        }
        startScan()
    }
    
    // MARK:开始扫描二维码
    private func startScan() {
        // 1、判断是否能够将输入添加到会话中
        if !session.canAddInput(deviceInput) {
            return
        }
        // 2、判断是否能够将输出添加到会话中
        if !session.canAddOutput(outPut) {
            return
        }
        // 3、将输入和输出都添加到会话中
        session.addInput(deviceInput)
        session.addOutput(outPut)
        
        // 4、设置输出能够解析的数据类型(默认包含二维码类型)
        // 这个设置必须是在输出对象被添加到会话之后
        outPut.metadataObjectTypes = outPut.availableMetadataObjectTypes
        print(outPut.availableMetadataObjectTypes)
        // 5、设置输出对象的代理，只要解析成功就会通知这个代理
        outPut.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        // 添加预览视图
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        // 6、告诉session开始扫描
        session.startRunning()
    }
    
    /**
     停止扫描
     */
    func stopScan() {
        self.scanImage.layer.removeAllAnimations()
        session.stopRunning()
        session.removeInput(deviceInput)
        session.removeOutput(outPut)
        // 预览图层从视图层中移除
        previewLayer.removeFromSuperlayer()
    }
    
    /**
     处理扫描结果
     
     - parameter result: 扫描结果
     */
    func handleResult(result: String) {
        // 停止扫描
        stopScan()
        // 打开地址
        if UIApplication.sharedApplication().canOpenURL(NSURL.init(string: result)!) {
            UIApplication.sharedApplication().openURL(NSURL.init(string: result)!)
        }
    }
    
    // MARK:tabBarDelegate
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 1 {
            print("二维码")
            editView(300)
        }else {
            print("条形码")
            editView(150)
        }
    }
    
    // 重新整理扫描框
    private func editView(constant :CGFloat) {
        self.containerHcons.constant = constant
        view.layoutIfNeeded()
        scanImage.layer.removeAllAnimations()
        startAnimation()
    }
    
    // MARK:左右头部点击
    @IBAction func leftClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rigjtClick(sender: AnyObject) {
    }

}

// MARK: - 扩展遵循AVCaptureMetadataOutputObjectsDelegate协议
extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    // 只要解析到数据就会调用这个方法
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        print(metadataObjects)
        if metadataObjects.count > 0 {
            let code: AVMetadataMachineReadableCodeObject = metadataObjects.last as!AVMetadataMachineReadableCodeObject
            let type = code.type
            if type.containsString("QRCode") {
                // 扫描结果为二维码
                let result = code.stringValue
                handleResult(result)
            }else {
                return
            }
        }
    }
}




