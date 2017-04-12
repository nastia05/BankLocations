//
//  BankModelUpdateManager.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import Foundation
import CoreData

enum UpdateError: Error {
	case parseError, undefined
}

//Uses data from the DownloadManager object to update a local storage
final class BankModelUpdateManager: ContextDelegate {

	func updateLocalCache(_ placeFields: FieldsDictionary, completionHandler ch: @escaping (Void) -> Void, errorHandler eh: @escaping ErrorHandler) {
		
		let backgroundContext = BankDataController.backgroundContext(with: moc)
		backgroundContext.perform { [weak self] in
			
			guard let strSelf = self else {
				eh(UpdateError.undefined)
				return
			}
			
			do {
				try strSelf.update(with: placeFields, context: backgroundContext)
			} catch {
				eh(error)
			}
			
			do {
				try backgroundContext.save()
			} catch {
				eh(error)
			}

			DispatchQueue.main.async { [weak strSelf] in
				guard let strSelf = strSelf else {
					eh(UpdateError.undefined)
					return
				}
				if strSelf.moc.hasChanges {
					do {
						try strSelf.moc.save()
					} catch {
						eh(error)
					}
				}
				ch()
			}
		}
		
	}
	
	private func update(with placeFields: FieldsDictionary, context: NSManagedObjectContext) throws {
		
		let countriesRequest: NSFetchRequest<Country> = Country.fetchRequest()
		let countries = try context.fetch(countriesRequest)
		
		for countryId in Array(placeFields.keys) {
			
			//gets(creates) a country
			var country: Country!
			if let index = countries.flatMap({ $0.id }).index(of: countryId.rawValue) {
				country = countries[index]
			} else {
				country = Country(context: context)
				country.id = countryId.rawValue
			}
			
			//updates regions
			let regionsToUpdate = try Region.update(with: placeFields, forCountry: country, context: context)
			
			//updates places
			try Place.update(with: placeFields, forCountry: countryId, forRegions: regionsToUpdate, context: context)
		}
		
	}
	
}


