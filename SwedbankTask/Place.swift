//
//  Location.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import Foundation

enum SerialisationKey: String {
	case address = "a"
	case latitude = "lat"
	case longitude = "lon"
	case name = "n"
	case region = "r"
	case type = "t"
	case availability = "av"
	case info = "i"
	case noCash = "ncash"
	case coinStation = "cs"
}

//TODO: - support NSCoding
final class Place {
	
	let name: String
	let address: String
	let type: PlaceType
	let region: String
	let availability: String?
	var branchInfo: BranchInfo? //applicable for branches only
	
	enum PlaceType: Int {
		case branch, atm, nba
	}

	struct BranchInfo {
		let noCash: Bool
		let coinStation: Bool
		let info: String?

		var fullDescription: String {
			var result = ""
			if let information = info {
				result += information + ". "
			}
			if noCash {
				result += "No cash. "
			}
			if coinStation {
				result += "Has a coin station. "
			}
			return result
		}
		
	}
	
	init?(json: [String : Any]) {
		guard let address = json.string(forKey: .address),
		let typeRaw = json.integer(forKey: .type),
		let type = PlaceType(rawValue: typeRaw),
		let name = json.string(forKey: .name),
		let region = json.string(forKey: .region) else {
			return nil
		}
		
		if type == .branch {
			let info = json[SerialisationKey.info.rawValue] as? String
			let coinStation = json[SerialisationKey.coinStation.rawValue] as? Bool ?? false
			let noCash = json[SerialisationKey.noCash.rawValue] as? Bool ?? false
			self.branchInfo = BranchInfo(noCash: noCash, coinStation: coinStation, info: info)
		}

		self.name = name
		self.address = address
		self.type = type
		self.region = region
		availability = json.string(forKey: .availability)
	}
	
}

extension Dictionary where Key == String, Value == Any {
	
	func string(forKey key: SerialisationKey) -> String? {
		return self[key.rawValue] as? String
	}
	
	func integer(forKey key: SerialisationKey) -> Int? {
		return self[key.rawValue] as? Int
	}
	
}



//a = "ENDLA 45, 10615 TALLINN";
//av = "E-R 10.00-19.00; L 10.00-16.00";
//lat = "59.42706667";
//lon = "24.72249167";
//n = "KRISTIINE KK";
//ncash = 1;
//r = "Kristiine linnaosa";
//t = 0;
