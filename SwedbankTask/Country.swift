//
//  Country.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import Foundation

enum Country: String {
	
	case ee, lt, lv
	
	var name: String {
		switch self {
		case .ee: return NSLocalizedString("Estonia", comment: "Estonia")
		case .lv: return NSLocalizedString("Latvia", comment: "Latvia")
		case .lt: return NSLocalizedString("Lithuania", comment: "Lithuania")
		}
	}
	
}
