//
//  RegionsTVC.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import UIKit
import CoreData

let emptyHandler: (Void) -> Void = { _ in }
let consoleErrorsHandler: ([Error]) -> Void = { $0.forEach { print($0)} }

let kLastDataUpdate = "LastUpdate"

final class RegionsTVC: UITableViewController, ContextDelegate, NSFetchedResultsControllerDelegate {

	let downloadManager = DownloadManager()
	var regionsResultsController: NSFetchedResultsController<Region>!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//read from local cache
		setupFecthedController()
	
		//refresh control
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(updateBankModel), for: .valueChanged)
		
		//download on launch
		downloadManager.updateBankModel(completionHandler: {
			UserDefaults.standard.set(Date(), forKey: kLastDataUpdate)
		}, errorsHandler: consoleErrorsHandler)
		
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		refreshControl?.endRefreshing()
	}
	
	private func setupFecthedController() {
		regionsResultsController = NSFetchedResultsController(fetchRequest: Region.configuredFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: #keyPath(Region.country.name), cacheName: nil)
		regionsResultsController.delegate = self
		do {
			try regionsResultsController.performFetch()
		} catch let error {
			fatalError("Failed to initialize FetchedResultsController: \(error)")
		}
	}
	
	@objc private func updateBankModel() {
		if let lastUpdateDate = UserDefaults.standard.object(forKey: kLastDataUpdate) as? Date {
			guard abs(lastUpdateDate.timeIntervalSinceNow) > TimeInterval.hour else {
				refreshControl?.endRefreshing()
				return
			}
		}
		
		downloadManager.updateBankModel(completionHandler: { [weak self] in
			self?.refreshControl?.endRefreshing()
			UserDefaults.standard.set(Date(), forKey: kLastDataUpdate)
		}, errorsHandler: { [weak self] in
			self?.refreshControl?.endRefreshing()
			consoleErrorsHandler($0)
		})
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dvc = segue.destination as? PlacesTVC {
			let selectedRow = tableView.indexPathForSelectedRow!
			let object = regionsResultsController.object(at: selectedRow)
			dvc.region = object
		}
	}
 
    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let sections = regionsResultsController.sections else {
			fatalError("No sections in fetchedResultsController")
		}		
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return regionsResultsController.sections?[section].numberOfObjects ?? 0
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCellSID", for: indexPath)
		
		let region = regionsResultsController.object(at: indexPath)
		cell.textLabel?.text = region.name

        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sectionInfo = regionsResultsController.sections?[section]
		return sectionInfo?.name
	}

	
	//MARK: - NSFetchedREsultsController delegate
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
		case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
		default: break
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
		case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
		case .update: tableView.reloadRows(at: [indexPath!], with: .automatic)
		case .move: tableView.moveRow(at: indexPath!, to: newIndexPath!)
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}

}

private extension Region {
	
	static func configuredFetchRequest() -> NSFetchRequest<Region> {
		let regionsRequest: NSFetchRequest<Region> = Region.fetchRequest()
		regionsRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Region.country.id), ascending: true), NSSortDescriptor(key: #keyPath(Region.name), ascending: true)]
		return regionsRequest
	}
	
}

extension TimeInterval {
	static let hour: TimeInterval = 3600
}

