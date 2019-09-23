//
//  ViewController.swift
//  URLProtocolExample
//
//  Created by yaoning on 2019/9/17.
//  Copyright © 2019 yaoning. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    private lazy var manager = { () -> SessionManager in
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
//        config.protocolClasses?.insert(CustomURLProtocol.self, at: 0)
        let manager = Alamofire.SessionManager(configuration: config)
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        log.info("View did load")
//        showMethodList(clazz: URLSession.classForCoder())
//        showMethodList(clazz: URLSession.self)
        showMethodList(clazz: TestA.self)
        showStaticMethodList(clazz: TestA.self)
    }

    func showMethodList(clazz: AnyClass) {
        var count: UInt32 = 0
        guard let methods = class_copyMethodList(clazz, &count) else { return }
        for i in 0..<Int(count) {
            let sel = method_getName(methods[i])
            let name_sel = sel_getName(sel)
            let name = NSString(utf8String: name_sel) ?? ""
            log.info("\(clazz) method \(i): \(name)")
        }
    }

    func showStaticMethodList(clazz: AnyClass) {
        var count: UInt32 = 0
        guard let methods = class_copyMethodList(object_getClass(clazz), &count) else { return }
        for i in 0..<Int(count) {
            let sel = method_getName(methods[i])
            let name_sel = sel_getName(sel)
            let name = NSString(utf8String: name_sel) ?? ""
            log.info("\(clazz) static method \(i): \(name)")
        }
    }

    @IBAction func clickAlamofire1(_ sender: Any) {
        var url = URLComponents(string: "https://suggest.taobao.com/sug")
        url!.queryItems = [
            URLQueryItem(name: "code", value: "utf-8"),
            URLQueryItem(name: "q", value: "猫粮")
        ]
        let request = URLRequest(url: url!.url!)

        manager.request(request).responseJSON { data in
            log.info("clickAlamofire1 success1 \(data)")
        }
    }

    @IBAction func clickAmamofire2(_ sender: Any) {
        let a = TestA(name: "aaa")
        a.sayName()
    }

    @IBAction func clickOrigin1(_ sender: Any) {
        var url = URLComponents(string: "https://suggest.taobao.com/sug")
        url!.queryItems = [
            URLQueryItem(name: "code", value: "utf-8"),
            URLQueryItem(name: "q", value: "猫粮")
        ]
        let request = URLRequest(url: url!.url!)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            do {
                _ = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
                log.info("clickOrigin1 success")
            } catch {
                log.info("clickOrigin1 error")
                return
            }
        }
        dataTask.resume()
    }

    @IBAction func clickOrigin2(_ sender: Any) {
        TestA.staticSayName()
    }

}

extension ViewController {
    class func exchangeViewDidLoad() {
        if self != ViewController.self {
            return
        }
        let orig = #selector(ViewController.viewDidLoad)
        let alter = #selector(ViewController.customViewDidLoad)

        let result = ViewController.swizzleInstanceMethod(originSelector: orig, alterSelector: alter)
        log.info("exchangeViewDidLoad \(result)")
    }

    @objc func customViewDidLoad() {
        log.info("custom View did load")
        self.customViewDidLoad()
    }
}

