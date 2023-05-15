//
//  NewsModel.swift
//  Zevo360
//
//  Created by $umit on 15/05/23.
//

import Foundation

struct NewsModel{
    
    public let title: String
    public let description: String
    public let urlToImage: String
    public let url: String
    
    public init? (json:[String:Any]){
        title = json["title"] as? String ?? ""
        description = json["description"] as? String ?? ""
        urlToImage = json["urlToImage"] as? String ?? ""
        url = json["url"] as? String ?? ""
    }
    
    static func array(jsonObject: [[String:Any]])->[NewsModel]{
        var dataArray: [NewsModel] = []
        jsonObject.forEach { json in
            guard let infoDict = NewsModel(json: json) else { return }
            dataArray.append(infoDict)
        }
        return dataArray
    }
}
