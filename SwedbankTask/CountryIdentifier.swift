//
//  CountryIdentifier.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import CoreData

enum CountryIdentifier: Int16 {
	case ee, lt, lv
	
	static let all = [CountryIdentifier.ee, .lt, .lv]
}

extension Country {
	
	var name: String {
		
		switch self.id {
		case CountryIdentifier.ee.rawValue: return NSLocalizedString("Estonia", comment: "Estonia")
		case CountryIdentifier.lv.rawValue: return NSLocalizedString("Latvia", comment: "Latvia")
		case CountryIdentifier.lt.rawValue: return NSLocalizedString("Lithuania", comment: "Lithuania")
		default: return ""
		}
	}
	

}

