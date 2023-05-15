//
//  MainViewController.swift
//  Zevo360
//
//  Created by $umit on 15/05/23.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var resultTbleView: UITableView!
    var newsArray: [NewsModel] = []
    
    var arr = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News"
        resultTbleView.delegate = self
        resultTbleView.dataSource = self
        resultTbleView.register(UINib(nibName: "ResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultsTableViewCell")
        fetchSavedData()
    }
}
// MARK: - TableView Delegate/Datasource methods

extension MainViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as! ResultsTableViewCell
        cell.infoData = self.newsArray[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewDetailsViewController") as! NewDetailsViewController
        newsVC.newDetails = self.newsArray[indexPath.row].url
        self.navigationController?.pushViewController(newsVC, animated: true)
    }
}


// MARK: - Webservice methods
extension MainViewController{
    func callGetNewsDataApi(){
        showActivityIndicator()
        callAPI(apiname: APIMethods.everything,
                params: nil,
                viewController : self,
                success: {(response) in
            print("Response:- \(response)")
            if let status = response["status"] as? String,
               status == "ok", let articles = response["articles"] as? [[String: Any]]{
                if !articles.isEmpty{
                    self.save(data: articles)
                }
            }
            else if let message = response["message"] as? String{
                showAlertMessage(vc: self, title: nil, message: message, actionTitle: "Ok", handler: nil)
            }
            hideActivityIndicator()
        })
    }
}


// MARK: - Core data methods
extension MainViewController {
    func save(data: [[String: Any]]) {
        for infoDict in data{
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: CoreDataKeys.entityName, in: managedContext)!
            let article = NSManagedObject(entity: entity, insertInto: managedContext)
            
            let title = infoDict["title"] as? String ?? ""
            let description = infoDict["description"] as? String ?? ""
            let urlNew = infoDict["url"] as? String ?? ""
            
            article.setValue(title, forKeyPath: CoreDataKeys.title)
            article.setValue(description, forKeyPath: CoreDataKeys.news_description)
            article.setValue(urlNew, forKeyPath: CoreDataKeys.urlNew)
            if let urlToImage = infoDict["urlToImage"] as? String, let imageData = urlToImage.data(using: .utf8){
                article.setValue(imageData, forKeyPath: CoreDataKeys.urlToImage)
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                // showAlertMessage(vc: self, title: nil, message: "Could not save. \(error), \(error.userInfo)", actionTitle: "Ok", handler: nil)
            }
        }
        self.fetchSavedData()
    }
    
    
    func fetchSavedData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        var coreDataArray: [NSManagedObject] = []
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataKeys.entityName)
        do {
            coreDataArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
              showAlertMessage(vc: self, title: nil, message: "Could not fetch. \(error), \(error.userInfo)", actionTitle: "Ok", handler: nil)
        }
      
        if coreDataArray.isEmpty{
            self.callGetNewsDataApi()
        }
        else{
            self.newsArray = self.coreDataToModel(coArray: coreDataArray)
            self.resultTbleView.reloadData()
        }
    }
    
    func coreDataToModel(coArray: [NSManagedObject]) -> [NewsModel] {
        var resultArray: [[String: Any]] = []
        for item in coArray {
            var dict: [String: Any] = [:]
            dict["title"] = item.value(forKeyPath: CoreDataKeys.title)
            dict["description"] = item.value(forKeyPath: CoreDataKeys.news_description)
            dict["url"] = item.value(forKeyPath: CoreDataKeys.urlNew)
            if let imgData = item.value(forKeyPath: CoreDataKeys.urlToImage) as? Data{
                let imageUrl = String(data: imgData, encoding: String.Encoding.utf8)
                dict["urlToImage"] = imageUrl
            }
            resultArray.append(dict)
        }
        return NewsModel.array(jsonObject: resultArray)
    }
    
}
