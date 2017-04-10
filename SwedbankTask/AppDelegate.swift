//
//  AppDelegate.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var bankDataController: BankDataController!
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		bankDataController = BankDataController()
		
		return true
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		try? bankDataController.moc.save()
	}
}

//MARK: - ContextDelegate provides classes with a managed object context

protocol ContextDelegate {
	var moc: NSManagedObjectContext { get }
	var persistenceContainer: NSPersistentContainer { get }
}

extension ContextDelegate {
	
	var moc: NSManagedObjectContext {
		assert(Thread.isMainThread)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		return appDelegate.bankDataController.moc
	}
	
	var persistenceContainer: NSPersistentContainer {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		return appDelegate.bankDataController.persistentContainer
	}
	
}
