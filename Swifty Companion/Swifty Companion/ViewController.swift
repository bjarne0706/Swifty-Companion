//
//  ViewController.swift
//  Swifty Companion
//
//  Created by Danylo CHANTSEV on 7/10/19.
//  Copyright © 2019 Danylo CHANTSEV. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ChameleonFramework

class ViewController: UIViewController {

	let myUID = "a654002709bf0586c8ea6ef9ad7f93f1a250ab5644b536ecbcf3d11be9f8f04d"
	let secret = "bd3d73d12168fdaadff8a7f415c998f984c6f8e10f7415544349f6eb2e0a260e"
	let redirectUri = "swiftyCompanion://swiftyCompanion"
	let fullStr = "https://api.intra.42.fr/oauth/authorize?client_id=a654002709bf0586c8ea6ef9ad7f93f1a250ab5644b536ecbcf3d11be9f8f04d&redirect_uri=swiftyCompanion%3A%2F%2FswiftyCompanion&response_type=code"
	var json: JSON?
	
	@IBOutlet weak var myTextField: UITextField!
	@IBAction func findBtn(_ sender: UIButton) {
		let myLogin = myTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		if myLogin.count == 0 {
			let alert = UIAlertController(title: "Alert", message: "Empty line", preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return 
		}
		let header: HTTPHeaders = ["Authorization" : "Bearer \(Token.accessToken!)"]
		Alamofire.request("https://api.intra.42.fr/v2/users/" + myLogin, method: .get, headers: header).responseJSON { response in
			print(response)
			switch response.result {
			case .success:
				self.json = JSON(response.value!)
				if (self.json!.isEmpty) { self.presentError(); return }
				self.performSegue(withIdentifier: "showStudent", sender: "sender")
				break
			case .failure:
				print("Failure")
				self.presentError()
				break
			}
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let attributes = [
			NSAttributedString.Key.foregroundColor: UIColor.white,
			NSAttributedString.Key.font : UIFont(name: "Futura-MediumItalic", size: 17)!
		]
		myTextField.attributedPlaceholder = NSAttributedString(string: "Login", attributes:attributes)
		myTextField.layer.borderColor = UIColor(red:0.32, green:0.78, blue:0.81, alpha:1.0).cgColor
		myTextField.layer.borderWidth = 1.0
		getToken()
	}
	
	override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
		
	}
	
	func getToken() {
		Alamofire.request("https://api.intra.42.fr/oauth/token", method: .post, parameters: ["grant_type" : "client_credentials", "client_id" : myUID, "client_secret" : secret]).validate().responseJSON {
			response in
			switch response.result {
			case .success(_):
				self.json = JSON(response.value!)
				Token.accessToken = self.json!["access_token"].string
				break
			case .failure(_):
				print("Failure")
				break
			}
		}
	}
	
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showStudent" {
			let destVC = segue.destination as! StudentViewController
			destVC.login = myTextField.text
			destVC.title = myTextField.text
		}
	}
	
//	func fillInfo(_ json: JSON) {
////		print(json)
//		StudentInfo.correctionPoint = "\(json["correction_point"].int!)"
//		StudentInfo.grade = json["cursus_users"][0]["grade"].string!
//		StudentInfo.level = "\(json["cursus_users"][0]["level"].double!)"
//		StudentInfo.name = json["displayname"].string!
//		StudentInfo.login = json["login"].string!
//		StudentInfo.email = json["email"].string!
//		StudentInfo.imageURL = json["image_url"].string!
//		if let checkLocation = json["location"].string {
//			StudentInfo.location = "Available \(checkLocation)"
//		} else {
//			StudentInfo.location = "Unavailable"
//		}
//		StudentInfo.phone = json["phone"].string!
//		StudentInfo.wallet = "\(json["wallet"].int!)"
////		print(StudentInfo.correctionPoint,"\n", StudentInfo.grade,"\n",StudentInfo.level,"\n",StudentInfo.name,StudentInfo.login,"\n",StudentInfo.email,"\n",StudentInfo.imageURL,"\n",StudentInfo.location,"\n",StudentInfo.phone,"\n",StudentInfo.wallet)
//	}
}

extension UIViewController {
	func presentError() {
		let alert = UIAlertController(title: "Alert", message: "No such user", preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
