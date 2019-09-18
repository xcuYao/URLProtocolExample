//
//  CustomURLProtocol.swift
//  URLProtocolExample
//
//  Created by yaoning on 2019/9/17.
//  Copyright © 2019 yaoning. All rights reserved.
//

import Foundation

class CustomURLProtocol: URLProtocol {

    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var urlResponse: URLResponse?
    private var receivedData: NSMutableData?

    private lazy var netInfo: NetworkInfo = {
        let info = NetworkInfo()
        return info
    }()

    /// 标记request是否已经被拦截
    static var PropertyKey: String = "PropertyKey"

    private var reqString: String {
        return self.request.url?.absoluteString ?? ""
    }

    // ------override class method--------

    /// 是否需要拦截请求
    /// 这里的调用次数 可能跟URLSessionConfiguration.default.protocolClasses的数量有关系
    /// 这里只拦截http https的请求 也可按需拦截对应host的请求
    /// - Parameter request:
    /// - Returns: true 记录 false 不记录
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme else { return false }
        let reqString = request.url?.absoluteString ?? ""
        log.info("我需要拦截 \(reqString) 吗？")
        if ["http", "https"].contains(scheme) {
            if URLProtocol.property(forKey: CustomURLProtocol.PropertyKey, in: request) != nil {
                log.info("重复拦截了！ \(reqString)")
                return false
            }
            log.info("拦截了 \(reqString)")
            return true
        }
        return false
    }

    /// 返回一个规范的request
    /// 这里可以对request进行转换 进行增加头部等操作
    /// - Parameter request:
    /// - Returns:
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    /// 缓存一致性检查
    ///
    /// - Parameters:
    ///   - a:
    ///   - b:
    /// - Returns:
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    // ------override method--------

    /// 请求开始
    /// 这里对请求进行了拦截 中断了原本的流程 做完自己的事情(记录拦截)后 需要将请求‘resume’
    /// 并且将URLSessionDataDelegate挂到了自己身上 这样就可以拦截整个请求过程中发生的事情
    override func startLoading() {
        log.info("开始拦截 \(reqString)")
        let newReq = self.request
        if let mutableReq = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            URLProtocol.setProperty("true", forKey: CustomURLProtocol.PropertyKey, in: mutableReq)
        }

        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: newReq)
        dataTask?.resume()
        netInfo.urlString = reqString
        netInfo.requestTimestamp = Date().timeIntervalSince1970
    }

    /// 请求结束
    /// 取消任务 清除数据记录
    override func stopLoading() {
        log.info("结束拦截 \(reqString))")
        NetworkCollecter.shared.collect(info: netInfo)
        dataTask?.cancel()
        dataTask = nil
        receivedData = nil
    }

}

extension CustomURLProtocol: URLSessionDataDelegate, URLSessionTaskDelegate {
    /// URLSession 收到响应之后的处理
    /// 这里持有一个response的引用 然后调用client的didReceive方法 并且不缓存数据
    /// - Parameters:
    ///   - session: 会话
    ///   - dataTask: 任务
    ///   - response: 响应主体
    ///   - completionHandler: 完成之后回调
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        log.info("收到响应了 \(reqString)")
        netInfo.code = (response as? HTTPURLResponse)?.statusCode
        netInfo.responseTime = Date().timeIntervalSince1970
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.urlResponse = response
        completionHandler(.allow)
    }
    /// URLSession 收到数据之后的处理
    /// 因为数据可能不是一次性回来的 所以依次添加到receivedData中 然后调用client的didLoad方法
    /// - Parameters:
    ///   - session: 会话
    ///   - dataTask: 任务
    ///   - data: 数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        log.info("收到数据了 \(reqString)")
        self.client?.urlProtocol(self, didLoad: data)
        if receivedData == nil {
            receivedData = NSMutableData()
        }
        receivedData?.append(data)
    }
    /// URLSession 任务完成之后的处理
    /// 任务结束 失败了调用 client的didFailWithError方法 成功了调用urlProtocolDidFinishLoading方法
    /// - Parameters:
    ///   - session: 会话
    ///   - task: 任务
    ///   - error:
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let url = task.currentRequest?.url?.absoluteString ?? ""
        log.info("任务结束了 \(url)__\(reqString) 大小: \(receivedData?.count ?? 0)")
        netInfo.responseSize = urlResponse?.expectedContentLength
        if let e = error {
            self.client?.urlProtocol(self, didFailWithError: e)
        } else {
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
}
