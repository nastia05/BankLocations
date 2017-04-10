//
//  PlacesTVC.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import UIKit
import CoreData

final class PlaceCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var circleView: CircleView!
	@IBOutlet weak var placeLabel: UILabel!
	
	weak var place: Place! {
		didSet {
			nameLabel.text = place.name
			addressLabel.text = place.address
			placeLabel.text = PlaceFields.PlaceType(rawValue: place.type)?.text
			circleView.color = PlaceFields.PlaceType(rawValue: place.type)?.color
			circleView.setNeedsDisplay()
		}
	}
}

final class PlacesTVC: UITableViewController, ContextDelegate {

	weak var region: Region!
	var placesResultsController: NSFetchedResultsController<Place>!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = region.name
		
		setupFecthedController()

    }
	
	private func setupFecthedController() {
		placesResultsController = NSFetchedResultsController(fetchRequest: Place.configuredFetchRequest(forRegion: region) , managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try placesResultsController.performFetch()
		} catch let error {
			fatalError("Failed to initialize FetchedResultsController: \(error)")
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dvc = segue.destination as? SinglePlaceVC {
			let indexPath = tableView.indexPathForSelectedRow
			let object = placesResultsController.object(at: indexPath!)
			dvc.place = object
		}
	}
	
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return placesResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCellSID", for: indexPath) as? PlaceCell else {
			fatalError("Wrong cell type")
		}

        cell.place = placesResultsController.object(at: indexPath)
        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64
	}

}

class CircleView: UIView {
	var color: UIColor?
	
	override func draw(_ rect: CGRect) {
		let path = UIBezierPath(ovalIn: bounds)
		(color?.withAlphaComponent(0.5) ?? UIColor.lightGray).setFill()
		path.fill()
	}
}

private extension PlaceFields.PlaceType {
	
	var color: UIColor {
		switch self {
		case .branch: return .blue
		case .atm: return .orange
		case .nba: return .green
		}
	}
	
	var text: String {
		switch self {
		case .branch: return "BR"
		case .atm: return "A"
		case .nba: return "B"
		}
	}
}

extension Place {

	static func configuredFetchRequest(forRegion region: Region) -> NSFetchRequest<Place> {
		let request: NSFetchRequest<Place> = Place.fetchRequest()
		let predicate = NSPredicate(format: "region = %@", region)
		request.predicate = predicate
		request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Place.type), ascending: true), NSSortDescriptor(key: #keyPath(Place.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
		return request
	}
}
