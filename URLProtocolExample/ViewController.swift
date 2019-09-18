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
        config.protocolClasses?.insert(CustomURLProtocol.self, at: 0)
        let manager = Alamofire.SessionManager(configuration: config)
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
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

    }

}

