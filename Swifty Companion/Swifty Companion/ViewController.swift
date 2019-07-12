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
		findUser(myTextField.text!)
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
	
	func findUser(_ login: String) {
		let header: HTTPHeaders = ["Authorization" : "Bearer \(Token.accessToken!)"]
		Alamofire.request("https://api.intra.42.fr/v2/users/" + login, method: .get, headers: header).responseJSON { response in
			print(response)
			switch response.result {
			case .success:
				self.json = JSON(response)
				if (self.json!.isEmpty) { return }
				self.fillInfo(self.json!)
				self.fillSkills(self.json!)
				self.fillProjects(self.json!)
				self.performSegue(withIdentifier: "showStudent", sender: self)
				break
			case .failure:
				break
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
	}
	
	func fillInfo(_ json: JSON) {
		StudentInfo.correctionPoint = self.json!["correction_point"].string!
		StudentInfo.grade = self.json!["grade"].string!
		StudentInfo.level = self.json!["level"].string!
		StudentInfo.name = self.json!["displayname"].string!
		StudentInfo.login = self.json!["login"].string!
		StudentInfo.email = self.json!["email"].string!
		StudentInfo.imageURL = self.json!["image_url"].string!
		StudentInfo.location = self.json!["location"].string!
		StudentInfo.phone = self.json!["phone"].string!
		StudentInfo.wallet = self.json!["wallet"].string!
		print(StudentInfo.self)
	}
	
	func fillSkills(_ json: JSON) {
		
	}
	
	func fillProjects(_ json: JSON) {
		
	}
}

