//
//  DataManger.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import Foundation

final class DataManager {
	
//FIXME: - prototype. this is to update UI it table

//	func updateRegions(with newRegions: NSOrderedSet, forCountry country: Country) {
//		
//		var regions = NSOrderedSet()
//		let toDelete = NSOrderedSet.difference(firstSet: regions, secondSet: newRegions)
//		let toInsert = NSOrderedSet.difference(firstSet: newRegions, secondSet: regions)
//		
//		regions = newRegions as! NSMutableOrderedSet
//		
//	}
	
}

extension NSOrderedSet {
	
	static func difference(firstSet: NSOrderedSet, secondSet: NSOrderedSet) -> NSOrderedSet {
		let toDeleteSet = firstSet.copy() as! NSMutableOrderedSet
		toDeleteSet.minus(secondSet)
		return toDeleteSet
	}
	
}
