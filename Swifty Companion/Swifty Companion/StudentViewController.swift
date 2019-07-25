//
//  StudentViewController.swift
//  Swifty Companion
//
//  Created by Danylo CHANTSEV on 7/10/19.
//  Copyright © 2019 Danylo CHANTSEV. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class StudentViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var fullView: UIView!
	@IBOutlet weak var correctionPointLabel: UILabel!
	@IBOutlet weak var walletLabel: UILabel!
	@IBOutlet weak var gradeLabel: UILabel!
	@IBOutlet weak var fullNameLabel: UILabel!
	@IBOutlet weak var loginLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var levelLabel: UILabel!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var backgroundView: UIImageView!
	
	@IBOutlet weak var tableViewSkills: UITableView! {
		didSet {
			tableViewSkills.delegate = self
			tableViewSkills.dataSource = self
		}
	}
	@IBOutlet weak var tableViewProjects: UITableView! {
		didSet {
			tableViewProjects.delegate = self
			tableViewProjects.dataSource = self
		}
	}
	
	var json: JSON?
	var login: String?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		imageView.layer.cornerRadius = imageView.frame.size.width/2
		findUser(login ?? "")
    }

	struct Skill {
		var level: String
		var name: String
	}
	
	struct Project {
		var finalMark: String
		var name: String
		var validated: String
	}

	var skills: [Skill] = []
	var projects: [Project] = []

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == self.tableViewSkills {
			return skills.count
		} else {
			return projects.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == self.tableViewSkills {
			if let cell = tableViewSkills.dequeueReusableCell(withIdentifier: "skillCell") as? SkillTableViewCell {
				cell.skillLabel.text = skills[indexPath.row].name
				cell.levelLabel.text = skills[indexPath.row].level
				cell.progressView.progress = Float(skills[indexPath.row].level)! / 21
				return cell
			}
		} else {
			if let cell = tableViewProjects.dequeueReusableCell(withIdentifier: "projectCell") as? ProjectTableViewCell {
				cell.projectLabel.text = projects[indexPath.row].name

				if (projects[indexPath.row].validated == "true") {
					cell.markLabel.text = "\(projects[indexPath.row].finalMark)"
					cell.markLabel.textColor = UIColor(red:0.36, green:0.72, blue:0.36, alpha:1.0)
				} else {
					cell.markLabel.text = "\(projects[indexPath.row].finalMark)"
					cell.markLabel.textColor = UIColor(red:0.85, green:0.39, blue:0.44, alpha:1.0)
				}
				return cell
			}
		}
		return UITableViewCell()
	}
	
	func findUser(_ login: String) {
		let header: HTTPHeaders = ["Authorization" : "Bearer \(Token.accessToken!)"]
		Alamofire.request("https://api.intra.42.fr/v2/users/" + login, method: .get, headers: header).responseJSON { response in
			switch response.result {
			case .success:
				self.json = JSON(response.value!)
				if (self.json!.isEmpty) { return }
				self.fillInfo(self.json!)
				self.fillSkills(self.json!)
				self.fillProjects(self.json!)
				break
			case .failure:
				break
			}
		}
	}
	
	func fillInfo(_ json: JSON) {
		let header: HTTPHeaders = ["Authorization" : "Bearer \(Token.accessToken!)"]
		correctionPointLabel.text = "\(json["correction_point"].int!)"
		gradeLabel.text = json["cursus_users"][0]["grade"].string!
		fullNameLabel.text = json["displayname"].string!
		loginLabel.text = json["login"].string!
		Alamofire.request("https://api.intra.42.fr/v2/users/" + login! + "/coalitions", method: .get, headers: header).responseJSON {response in
			switch response.result {
			case .success(_):
				self.json = JSON(response.value!)
				if (self.json?.isEmpty)! { return }
				self.setBackground(self.json![0]["name"].string!, json["cursus_users"][0]["level"].double!)
			case .failure(_):
				print("Failure")
			}
		}
		levelLabel.text = getLevel(json["cursus_users"][0]["level"].double!)
		Alamofire.request(json["image_url"].string!, method: .get).responseImage { response in
			guard let image = response.result.value else { return }
			self.imageView.image = image
		}
		if let checkLocation = json["location"].string {
			statusLabel.text = "Available \(checkLocation)"
		}
		walletLabel.text = "\(json["wallet"].int!)₳"
		progressBar.progress = Float(json["cursus_users"][0]["level"].double!.truncatingRemainder(dividingBy: 1.0))
	}
	
	func setBackground(_ image: String, _ level: Double) {
		switch image {
		case "The Alliance":
			backgroundView.image = UIImage(imageLiteralResourceName: "alliance_background")
			progressBar.tintColor = UIColor(red:0.23, green:0.54, blue:0.24, alpha:1.0)
		case "The Hive" :
			backgroundView.image = UIImage(imageLiteralResourceName: "hive_background")
			progressBar.tintColor = UIColor(red:0.00, green:0.73,
													blue:0.82, alpha:1.0)
		case "The Empire":
			backgroundView.image = UIImage(imageLiteralResourceName: "empire_background")
			progressBar.tintColor = UIColor(red:0.94, green:0.26, blue:0.21, alpha:1.0)
		case "The Union":
			backgroundView.image = UIImage(imageLiteralResourceName: "union_background")
			progressBar.tintColor = UIColor(red:0.40, green:0.22, blue:0.70, alpha:1.0)
		default:
			break
		}
	}
	
	func getLevel(_ level: Double) -> String {
		let levelArr = String(level).components(separatedBy: ".")
		return "level \(levelArr[0]) - \(levelArr[1])%"
	}
	
	func fillSkills(_ json: JSON) {
		for skill in json["cursus_users"][0]["skills"] {
			skills.append(Skill(level: "\(skill.1["level"].double ?? 0.0)", name: "\(skill.1["name"].string ?? "")"))
		}
		self.tableViewSkills.reloadData()
	}
	
	func fillProjects(_ json: JSON) {
		for project in json["projects_users"] {
			if project.1["status"] == "finished" {
				if project.1["cursus_ids"][0].int == 1{
					if project.1["project"]["parent_id"].int == nil {
						projects.append(Project(finalMark: "\(project.1["final_mark"].int ?? 0)", name: "\(project.1["project"]["name"].string ?? "")", validated: "\(project.1["validated?"].bool ?? false)"))
					}
				}
			}
		}
		self.tableViewProjects.reloadData()
	}
}
