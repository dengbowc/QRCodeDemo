//
//  ViewController.swift
//  QRCodeDemo
//
//  Created by 瑶波波 on 16/6/29.
//  Copyright © 2016年 dengbowc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func scanClick(sender: AnyObject) {
        
        let sb = UIStoryboard.init(name: "QRCodeViewController", bundle: nil)
        let toVc = sb.instantiateInitialViewController()!
        self.presentViewController(toVc, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

