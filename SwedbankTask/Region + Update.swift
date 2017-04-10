//
//  Region + Update.swift
//  SwedbankTask
//
//  Created by nastia on 12/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import CoreData

extension Region {

	static func update(with placeFields: FieldsDictionary, forCountry country: Country, context: NSManagedObjectContext) throws -> [Region] {
		
		let regionReguest: NSFetchRequest<Region> = Region.fetchRequest()
		regionReguest.predicate = NSPredicate(format: "country = %@", country)
		
		let fetchedRegions = try context.fetch(regionReguest)

		let fetchedRegionsNames = Set(fetchedRegions.flatMap{ $0.name })
		let countryId = CountryIdentifier(rawValue: country.id)!
		let newRegionsNames = Set(placeFields[countryId]!.flatMap{ $0.region })
		
		//to delete regions
		let regionsNamesToDelete = fetchedRegionsNames.subtracting(newRegionsNames)
		for region in fetchedRegions {
			if regionsNamesToDelete.contains( region.name!) {
				context.delete(region)
			}
		}
		
		//to update regions
		let regionsNamesToUpdate = fetchedRegionsNames.intersection(newRegionsNames)
		var regionsToUpdate = fetchedRegions.filter { regionsNamesToUpdate.contains($0.name!) }
		
		//to create regions
		let regionsNamesToInsert = newRegionsNames.subtracting(fetchedRegionsNames)
		for name in regionsNamesToInsert {
			let region = Region(context: context)
			region.name = name
			region.country = country
			regionsToUpdate.append(region)
		}
		
		return regionsToUpdate
	}
	
}
