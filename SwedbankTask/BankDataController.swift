//
//  BankDataController.swift
//  SwedbankTask
//
//  Created by nastia on 10/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import CoreData

final class BankDataController {
	
	var moc: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	let persistentContainer: NSPersistentContainer
	
	init(completionHandler: @escaping () -> () = {}) {
		persistentContainer = NSPersistentContainer(name: "BankModel")
		persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		persistentContainer.loadPersistentStores() { (description, error) in
			if let error = error {
				fatalError("Failed to load Core Data stack: \(error)")
			}
			
			completionHandler()
		}
	}
	
	static func backgroundContext(with parent: NSManagedObjectContext) -> NSManagedObjectContext {
		let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		backgroundContext.parent = parent
		return backgroundContext
	}
}

