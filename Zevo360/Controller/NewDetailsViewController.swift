//
//  NewDetailsViewController.swift
//  Zevo360
//
//  Created by $umit on 15/05/23.
//

import UIKit
import WebKit

class NewDetailsViewController: UIViewController {

    @IBOutlet weak var w3: WKWebView!
    
    var newDetails = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News Details"
        let url = URL (string: newDetails)
        let urlRequestCache = NSURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60)
        w3.load(urlRequestCache as URLRequest)
    }

}
