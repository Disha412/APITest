//
//  APIDemoViewController.swift
//  AlamofireData

import UIKit
import Alamofire

class APIDemoViewController: UIViewController {
    
    let apiName = "urlName"
    
    var industryArray = [FoodIndustryDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.callAPI()
    }
    
    
    func callAPI() {

//        AF.request(apiName, method: .get, parameters: [:]).responseDecodable(of: FoodIndustryModelHandlerClass.self) { (response) in
//
//            guard let model = response.value else { return }
////            print("Industry Type = \(model.status) && \(model.message)")
//        }
        
        AF.request(apiName, method: .get, parameters: [:]).responseJSON { (response) in
            print("API JSON Response = \(response)")

            do {
                if let model = try? JSONDecoder().decode(FoodIndustryModelHandlerClass.self, from: response.data!) {
                    print("Response status = \(model.status ?? 0) & Message = \(model.message ?? "")")
                    self.industryArray = model.data!
                    for i in 0..<self.industryArray.count {
                        print("industry id: \(self.industryArray[i].iIndustryId!)")
                        print("industry type: \(self.industryArray[i].vIndustryType!)")
                    }
                }
            } catch let message {
                print("Error msg = \(message)")
            }
        }
        
        
//        AF.request(apiName).validate().responseJSON { response in
//            switch response.result {
//            case .success:
//                print("validate sucessfull")
//                if let json = response.data {
//                    print(json)
//                    do {
//                        let resJson = try JSONDecoder().decode(FoodIndustryModelHandlerClass.self, from: json)
//
//                        print(resJson.message!)
//                    } catch let error {
//                        print("Couldn't Parse data because... \(error)")
//                    }
//                }
//                break
//            case .failure: break
//            }
//        }
        
       /* AF.request(apiName, method: .get, parameters: nil, encoding: URLEncoding(destination: .queryString)).responseString { response in
            switch response.result {

            case .success(let json):
                print(json)
                if let returnedValue = response.result.value, !returnedValue.isEmpty {
                    do {
                        let locationObject = try JSONDecoder().decode(FoodIndustryModelHandlerClass.self, from: (returnedValue.data(using: .utf8))!)
                    } catch let e {
                        print("Couldn't Parse data because... \(e)")
                    }
                }
                DispatchQueue.main.async {

//                   callback(location)

                }
            case .failure(let error):
                print(error)

//                callback(nil)
            }
        }*/
    }
    
}

class FoodIndustryModelHandlerClass : Decodable {
    var status : Int?
    var message : String?
    var data : [FoodIndustryDataModel]?
}

class FoodIndustryDataModel : Decodable {
    var iIndustryId : String?
    var vIndustryType : String?
}
