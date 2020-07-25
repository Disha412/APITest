//
//  ServiceManager.swift
//  Service
//
import UIKit
//import SVProgressHUD
import MobileCoreServices

struct ServiceData: Decodable {
    var modelClass : String?
    var url : String?
    var methodType : String?
}

class ServiceManager: NSObject {
    
    let baseURL = ""

    private static var serviceManager: ServiceManager = {
        let serviceManager = ServiceManager()
        
        return serviceManager
    }()
    
    //MARK:- Initilize
    private override init(){
        
    }
    
    //MARK:- Public Methods
    class func shared() -> ServiceManager{
        return serviceManager
    }
    
    func call(serviceName : String, parameters : [String: Any]?, isHudShow : Bool, completion: @escaping (_ success : Bool, _ responseData: Data) -> (), failure: @escaping (_ error : ServiceError) -> ()){
        //Generate URLRequest based on service name

        print("😎😎😎😎 API Name - \(baseURL)\(serviceName)")
        print("😎😎😎😎 <=======Parameters=======>\n \(parameters!)")
        
        if isHudShow {
//            SVProgressHUD.show()
        }
        
        if let request = getRequestFor(serviceName: serviceName, parameters: parameters){
            dataTask(request: request, completion: { (data, response) in
                if let responseData = data {
                    #if DEBUG
                    self.printJSON(responseData: responseData)
                    #endif
                    
                    //Verify HTTP Response using status code
//                    SVProgressHUD.dismiss()
                    
                    self.validateServiceResponse(response: response, completion: { (isVlaid) in
                        completion(true, responseData)
                    }, failure: { (error) in
                        DispatchQueue.main.async {
                            failure(error)
                        }
                    })
                }
            }, failure: { (error) in
//                SVProgressHUD.dismiss()
                failure(ServiceError.createError(statusCode: .common, description: error.localizedDescription))
            })
        }
    }
    
    //This method returns URLRequest object based on serviceName that you pass
    private func getRequestFor(serviceName: String, parameters : [String: Any]?) -> URLRequest? {
        if let serviceData = ServiceMapping.shared().getServiceData(name: serviceName){
            if let url = URL.init(string: baseURL + serviceData.url.asStringOrEmptyValue()){
                
                var urlRequest : URLRequest = URLRequest.init(url: url)
                urlRequest.httpMethod = serviceData.methodType.asStringOrEmptyValue()
                
                self.setReqeustHeaders(request: &urlRequest)
                //self.setBody(parameters: parameters, request: &urlRequest)
                
                let boundary = "Boundary-\(NSUUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                //urlRequest.httpBody = createBodyWithParams(parameters: parameters!, filePathKey: "file", boundary: boundary) as Data
                urlRequest.httpBody = createBodyWithParams(parameters: parameters!, boundary: boundary) as Data
                return urlRequest
            }
            else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func setReqeustHeaders( request : inout URLRequest){
//        request.setValue(Constants.shared.deviceToken, forHTTPHeaderField: "deviceToken")
//        request.setValue("iOS", forHTTPHeaderField: "osType")
//        request.setValue(Constants.DeviceType, forHTTPHeaderField: "deviceType")
//        request.setValue(Constants.shared.osVersion, forHTTPHeaderField: "osVersion")
//        request.setValue(Constants.shared.appVersion, forHTTPHeaderField: "appVersion")
    }
    
    private func setBody(parameters : [String: Any]?, request : inout URLRequest) {
        
        if let requestData = parameters{
            /*
             do {
             request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: .prettyPrinted)
             } catch let error {
             print(error.localizedDescription)
             }
             */
            var dict = Dictionary<String, Any>()
            dict = requestData as! Dictionary<String, Any>
            
            let postString = (dict.compactMap({ (key, value) -> String in
                return "\(key)=\(value)"
            }) as Array).joined(separator: "&")
            request.httpBody = postString.data(using: String.Encoding.utf8)
        }
    }
    
    func createBodyWithParams(parameters: [String: Any]?,boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
            
//            if multipleImage.count > 0 {
//                var i = 1;
//                let mimetype = MIME_TYPE.IMAGE.rawValue
//                for data in multipleImage{
//
//                    let filename = "image\(i).png"
//                    body.appendString(string: "--\(boundary)\r\n")
//                    body.appendString(string: "Content-Disposition: form-data; name=\"\(ProductParam.vImage)\"; filename=\"\(filename)\"\r\n")
//                    body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
//                    body.append(data)
//                    body.appendString(string: "\r\n")
//                    i = i + 1
//                }
//            }
//
//            if singleImage.count > 0 {
//                let mimetype = MIME_TYPE.IMAGE.rawValue
//                let filename = "image.png"
//                body.appendString(string: "--\(boundary)\r\n")
//                body.appendString(string: "Content-Disposition: form-data; name=\"\(SignupParam.vLogo)\"; filename=\"\(filename)\"\r\n")
//                body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
//                body.append(singleImage)
//                body.appendString(string: "\r\n")
//            }
        }
        body.appendString(string: "--\(boundary)--\r\n")
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    //MARK:- Private Methods
    private func dataTask(request: URLRequest, completion: @escaping (_ responseData: Data?,_ response : URLResponse?) -> (), failure: @escaping (_ error : Error) -> ()){
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var dataTask: URLSessionDataTask?
        dataTask = session.dataTask(with: request) { (data, response, error) in
            print("😎😎😎😎 Service HTTP response: \(String(describing: response))")
            if let serviceError = error{
                failure(serviceError)
            }else{
                completion(data, response)
            }
        }
        dataTask?.resume()
    }
    
    
    private func validateServiceResponse(response : URLResponse?, completion: @escaping (_ success: Bool) -> (), failure: @escaping (_ error: ServiceError) -> ()){
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == StatusCode.Success.rawValue {
                completion(true)
            }else{
                failure(ServiceError.createError(statusCode: StatusCode(rawValue: httpResponse.statusCode), description: "Oops! Something went wrong. Please try again later"))
            }
        }else{
            failure(ServiceError.createError(statusCode: .common, description: "Oops! Something went wrong. Please try again later"))
        }
    }
    
    
    //MARK:- Debugging methods
    func printJSON(responseData : Data){
        do {
            //let json = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
            //print(json)
            
            if let todoJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject]{
                print("😎😎😎😎 Service response: \(todoJSON)")

                if let apiStatus = todoJSON["status"] as? NSNumber {
                    
                    let status = Int(truncating: apiStatus)
                    
                    if status == ApiDataStatus.CommonKeys.kIsSuccess {

                    }                    
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension Optional {
    func asStringOrEmptyValue() -> String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case _:
            return ""
        }
    }
    
    func asStringOrNilValue() -> String {
        switch self {
        case .some(let value):
            return String(describing: value)
        case _:
            return "(nil)"
        }
    }
}

struct ApiDataStatus {
    
    struct CommonKeys {
        static let kY = "Y"
        static let kN = "N"
        static let kYes = "Yes"
        static let kNo = "No"
        static let kAuthIsSuccess = 21
        static let kIsSuccess = 1
        static let kIsFailure = 0
        static let kSocialNewUser = 2
        static let kUserNotFound = 3
    }
}




/*
 BaseService Response File
 */
//
//  ServiceResponse.swift
//  Service

import UIKit
import Foundation
class BaseServiceResponse: Decodable {
    var success : Int? = 0
    var alert : Alert?
}
class BaseServiceAcceptRejectResponse: Decodable {
    var success : Int? = 0
    var alert : Alert?
}


/*
 Model class is use to dislay alert message.
 Alert action is to trigger different action on alert message. Ex: redirect to url, close alert messgae etc.
 */
class Alert: NSObject, Decodable {
    var message : String?
    var action: String?
}

enum StatusCode: Int, Decodable {
    case Success = 200
    case PartialResponse = 203
    case NoResponse = 204
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    case InternalError = 500
    case common
}

class ServiceError : NSObject, Decodable {
    var statusCode : StatusCode?
    var errorDescription : String?
    var canRetry : Bool?
    
    init(statusCode: StatusCode?, errorDescription : String?, canRetry  :Bool?) {
        self.statusCode = statusCode
        self.errorDescription = errorDescription
        self.canRetry = canRetry
    }
   
    static func createErrorWithDefaultMessage() -> ServiceError{
        return ServiceError.init(statusCode: .common, errorDescription: "Oops! Something went wrong. Please try again later", canRetry: false)
    }
    
    static func createError(statusCode : StatusCode? ,description : String) -> ServiceError{
        return ServiceError.init(statusCode: statusCode, errorDescription: description, canRetry: false)
    }
}


/*
 ServiceMapping File
 */


class ServiceMapping: NSObject {

    private static var serviceMapping: ServiceMapping = {
        let serviceMapping = ServiceMapping()
        
        return serviceMapping
    }()
    
    private var fileData : [String: ServiceData] = [:]
    
    override init() {
        super.init()
        self.loadServiceMappingFile()
    }
    
    //MARK:- Private Methods
    class func shared() -> ServiceMapping{
        return serviceMapping
    }
    
    //Read ServiceMapping plist file and Create model class object
    private func loadServiceMappingFile(){
        if let url = Bundle.main.url(forResource: "ServiceMapping", withExtension: "plist"){
            do {
                //Convert Plist file data into JSON
                let data = try Data(contentsOf:url)
                let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                let jsonData = try JSONSerialization.data(withJSONObject: dict , options: .prettyPrinted)
                
                //Decode JSON to model class
                do{
                    let sData = try JSONDecoder().decode([String: ServiceData].self, from: jsonData)
                    self.fileData = sData
                }catch{
                    print("Error deserializing JSON: \(error)")
                }
            } catch {
                print(error)
            }
        }
    }

    
    //MARK:- Public Methods
    //This method returns Service Data like suffix url, methodType based on serviceName that you pass
    func getServiceData(name: String) -> ServiceData?{
        if let serviceData = self.fileData[name]{
            return serviceData
        }
        else{
            return nil
        }
    }
 
}



/*
 How To Use
 */


/*
 
 let params = [
               LoginParam.vEmail: self.txtEmail.text!,
               LoginParam.vPassword: self.txtPassword.text!,
               CommonParam.vAppVersion: Helper().getAppVersion(),
               CommonParam.eDeviceType: Constants.DeviceType,
               CommonParam.vDeviceToken: userDataModel.firebaseToken!,
               CommonParam.vDeviceUniqueId: "\(UIDevice().deviceID)",
               CommonParam.vDeviceName: "\(UIDevice().modelName)"
             ]
 
 self.loginAPI(param: params)
 
 
 
 func loginAPI(param: [String : Any]) -> Void {

     ServiceManager.shared().call(serviceName: Key.ServiceName.Login, parameters: param, isHudShow: true, completion: { (success, responseData) in
         
         DispatchQueue.main.async {
             if let modelObject = self.Decode(modelClass: LoginHandlerClass.self, from: responseData){
                 
                 if modelObject.status == ApiDataStatus.CommonKeys.kIsSuccess {
                     
                     BaseViewController.sharedInstance.saveUserData(userData: responseData)
                     BaseViewController.sharedInstance.getUserData()
                     
                     if !userDataResponse.ePhoneVerificationStatus.isTrue {
                         let vcSignup = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: SCREENNAME.SIGNUP) as? SignupViewController
                         vcSignup?.isUserAlreadyRegister = true
                         self.navigationController?.pushViewController(vcSignup!, animated: true)
                     }
                     else if !userDataResponse.eIndustryDataSubmitted.isTrue {
                         self.pushToViewController(viewControllerIdentifier: SCREENNAME.INDUSTRY_DETAILS_STEP_1, withAnimation: true)
                     }
                     else if !userDataResponse.eIndustryExtraDataSubmitted.isTrue {
                         self.pushToViewController(viewControllerIdentifier: SCREENNAME.INDUSTRY_DETAILS_STEP_2, withAnimation: true)
                     }
                     else {
                         self.navigateToHomeScreen()
                     }
                 } else {
                     UIAlertController().alertViewWithTitleAndMessage(self, message: modelObject.message!)
                 }
             }
         }
     }, failure: { (errorMessage) in
         DispatchQueue.main.async {
             UIAlertController().alertViewWithTitleAndMessage(self, message: "\(errorMessage.errorDescription!)")
             print(errorMessage)
         }
     })
 }
 

 
 extension NSObject {
     func Decode<T: Decodable>(modelClass: T.Type, from inputData: Data) -> T?{
         do {
             let resultData = try JSONDecoder().decode(modelClass.self, from: inputData)
             return resultData
         } catch let message {
             print("JSON serialization error:" + "\(message)")
             return nil
         }
     }
 }
 
 
 */
