//
//  SinglePlaceVC.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import UIKit

private let cellHeight: CGFloat = 45

final class SinglePlaceVC: UITableViewController, ContextDelegate {
	
	weak var place: Place!
	
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var regionLabel: UILabel!
	@IBOutlet weak var availabilityLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = place.name
		
		tableView.estimatedRowHeight = cellHeight
//		tableView.rowHeight = UITableViewAutomaticDimension
		
		configureLabels()
		
	}
	
	private func configureLabels() {
		
		typeLabel.text = PlaceFields.PlaceType(rawValue: place.type)?.description
		addressLabel.text = place.address
		regionLabel.text = place.region?.name
		
		availabilityLabel.text = place.availability
		infoLabel.text = place.branchInfo
		
	}
	

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if indexPath == IndexPath(row: 0, section: 1) && place.availability == nil {
			return 0
		} else if indexPath == IndexPath(row: 1, section: 1) && place.branchInfo == nil {
			return 0
		} else {
			return UITableViewAutomaticDimension
		}
	}
	

}
