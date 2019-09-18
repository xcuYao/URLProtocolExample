//
//  UIWebViewController.swift
//  URLProtocolExample
//
//  Created by yaoning on 2019/9/18.
//  Copyright © 2019 yaoning. All rights reserved.
//

import UIKit

class UIWebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadRequest(URLRequest(url: URL(string: "https://www.jd.com")!))
    }


}
