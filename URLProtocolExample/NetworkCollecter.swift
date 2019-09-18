//
//  NetworkCollecter.swift
//  URLProtocolExample
//
//  Created by yaoning on 2019/9/17.
//  Copyright © 2019 yaoning. All rights reserved.
//

import Foundation

struct NetworkInfo {
    /// http 链接
    var urlString: String?
    /// http code
    var code: Int?
    /// 请求返回时间
    var responseTime: TimeInterval?
    /// 返回体大小
    var responseSize: Int64?
    /// 请求方法
    var method: String?
    /// 请求发出时间
    var requestTimestamp: TimeInterval?
    /// 请求体大小
    var requestSize: Int?
}

class NetworkCollecter {
    static let shared = NetworkCollecter()
    
    func collect(info: NetworkInfo) {
        log.info("收集一次网络请求 \(info)")
    }

}
