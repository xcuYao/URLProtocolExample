//
//  SwizzingTest.swift
//  URLProtocolExample
//
//  Created by yaoning on 2019/9/20.
//  Copyright © 2019 yaoning. All rights reserved.
//

import Foundation
import UIKit

@objc
class TestA: NSObject {

    private var name: String!

    init(name: String) {
        self.name = name
        super.init()
    }

    @objc func sayName() {
        log.info("TestA sayName \(name!)")
    }

    @objc class func staticSayName() {
        log.info("TestA staticSayName")
    }

}

extension TestA {

    class func swizzleSayName() {
        let orig = #selector(TestA.sayName)
        let alter = #selector(TestA.sayOtherName)
        let result = TestA.swizzleInstanceMethod(originSelector: orig, alterSelector: alter)
        log.info("swizzleSayName \(result)")

//        let orig = #selector(TestA.staticSayName)
//        let alter = #selector(TestA.staticSayNameSS)
//        let result = TestA.swizzleClassMethod(originSelector: orig, alterSelector: alter)
//        log.info("swizzleSayName \(result)")
    }

    @objc func sayOtherName() {
        log.info("SayOtherName sayName2 \(name!)")
        sayOtherName()
    }

    @objc class func staticSayNameSS() {
        log.info("TestA staticSayNameSS")
        staticSayNameSS()
    }
}

extension UIApplication {
    private static let runOnce: Void = {
//        TestA.swizzleSayName()
//        ViewController.exchangeViewDidLoad()
//        let result = URLSession.hook()
//        log.info("URLSession Hook result \(result)")
        log.info("UIApplication runOnce")
    }()
    override open var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}
