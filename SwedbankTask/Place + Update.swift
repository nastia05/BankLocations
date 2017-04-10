//
//  Place + Update.swift
//  SwedbankTask
//
//  Created by nastia on 12/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import CoreData

extension Place {
	
	static func update(with placeFields: FieldsDictionary, forCountry countryId: CountryIdentifier, forRegions regions: [Region], context: NSManagedObjectContext) throws {
		
		let allFetchedPlaces: [Place] = try context.fetch(Place.fetchRequest())
		
		for region in regions {
			
			let fetchedPlaces = allFetchedPlaces.filter({ $0.region == region })
			
			let fetchedPlacesNames = Set(fetchedPlaces.map{ $0.name! })
			let newPlacesNames = Set(placeFields[countryId]!.filter{ $0.region == region.name }.flatMap { $0.name })
			
			//places to delete
			let placeNamestoDelete = fetchedPlacesNames.subtracting(newPlacesNames)
			for place in fetchedPlaces {
				if placeNamestoDelete.contains(place.name!) {
					context.delete(place)
				}
			}
			
			//place to insert
			let placeNamestoInsert = newPlacesNames.subtracting(fetchedPlacesNames)
			let placesFields = placeFields[countryId]!.filter{ $0.region == region.name }
			for placeName in placeNamestoInsert {
				let place = Place(context: context)
				let fields = placesFields.filter({ $0.name == placeName }).first!
				place.address = fields.address
				place.availability = fields.availability
				place.branchInfo = fields.branchInfo?.fullDescription
				place.name = fields.name
				place.region = region
				place.type = fields.type.rawValue
			}
			
			//places to update
			let placeNamesToUpdate = newPlacesNames.intersection(fetchedPlacesNames)
			
			for place in fetchedPlaces {
				if placeNamesToUpdate.contains(place.name!) {
					let fields = placesFields.filter({ $0.name == place.name! }).first!
					place.address = fields.address
					place.availability = fields.availability
					place.branchInfo = fields.branchInfo?.fullDescription
					place.type = fields.type.rawValue
				}
			}
			
		}
	}
}
