//
//  Student.swift
//  Swifty Companion
//
//  Created by Danylo CHANTSEV on 7/10/19.
//  Copyright © 2019 Danylo CHANTSEV. All rights reserved.
//

import UIKit

struct StudentInfo {
	static var correctionPoint: String = ""
	static var grade: String = ""
	static var level: String = ""
	static var name: String = ""
	static var login: String = ""
	static var email: String = ""
	static var imageURL: String = ""
	static var location: String = ""
	static var phone: String = ""
	static var wallet: String = ""
}

struct Skill {
	static var level: String = ""
	static var name: String = ""
}

struct Project {
	static var finalMark: String = ""
	static var name: String = ""
	static var status: String = ""
	static var validated: Int = 0
}

struct AllInfo {
	static var studentInfo: StudentInfo? = nil
	static var skills: [Skill]?  = nil
	static var projects: [Project]? = nil
}
