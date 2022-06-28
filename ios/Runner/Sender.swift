//
//  Sender.swift
//  Runner
//
//  Created by 탁원준 on 2022/06/22.
//

import Foundation

class Sender{
    private var urlComponents: URLComponents?
    private var requestURL: URLRequest?
    private var postString = ""
    private var ip: String
    private var port: Int
    private var flag = false
    
    init(){
        ip = "https://dev.zips.ai"
        port = 11009
    }
    
    func Connect(){
        let url = URL(string: "\(ip):\(port)/data/location/save")
        requestURL = URLRequest(url:url!)
        requestURL?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        requestURL?.httpMethod = "POST"
    }
    
    func InputParam(key:String, val:String){
        if(postString.count > 0) {
            postString+="&"
        }
        postString += "\(key)=\(val)"
    }
    
    func Send(){
        guard requestURL != nil else{
            print("this is null")
            return
        }
        
        requestURL?.httpBody = postString.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: requestURL!){
            (data,res,err) in
            
            guard err == nil else{
                print("fail: ",err?.localizedDescription ?? "")
                return
            }
            
            let sucrange = 200..<300
            guard let status = (res as? HTTPURLResponse)?.statusCode, sucrange.contains(status)
            else{
                print("err: ",(res as? HTTPURLResponse)?.statusCode ?? 0)
                print("msg: ",(res as? HTTPURLResponse)?.description ?? "")
                return;
            }
            
            let resCode = (res as? HTTPURLResponse)?.statusCode ?? 0
            let resLen = data!
            let resString = String(data:resLen, encoding: .utf8) ?? ""
        }
        dataTask.resume()
    }
    
    func Start() -> Bool{
        guard flag else{
            self.postString = ""
            flag = !flag
            return flag
        }
        return false
    }
    func End(){
        flag = !flag
    }
    
    
}
