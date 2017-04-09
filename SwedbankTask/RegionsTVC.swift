//
//  RegionsTVC.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import UIKit

final class RegionsTVC: UITableViewController {

	var downloadManager: DownloadManager!
	var data: [Country : [String : NSOrderedSet]?]!
	
	lazy var regions: [Country : NSOrderedSet] = {
		print("TEST")
		var _regions = [Country : NSOrderedSet]()
		for country in self.data!.keys {
			if let regionsArray = (self.data[country]??.keys.sorted(by: { $0.lowercased() < $1.lowercased() })).flatMap({ $0 }) {
				_regions[country] = NSOrderedSet(array: regionsArray)
			}
		}
		return _regions
	}()
	
	lazy var countries: [Country] = {
		return Array(self.data.keys).sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		downloadManager = DownloadManager()
		
		let handler: SingleSuccessHandler = { data in
			
			guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let json = jsonObject as? Array<Dictionary<String, Any>> else {
				return
			}
			
			let placesArray = json.flatMap { Place(json: $0) }
			let regions = NSOrderedSet(array: placesArray.map{ $0.region }.sorted(by: { $0.lowercased() < $1.lowercased() }))
			regions.forEach {
				print($0)
			}
		}
		//downloadManager.downloadInformationFor(country: .ee, singleCompletionHandler: handler, singleErrorHandler: ConsoleErrorHandler)

		data = [Country.ee : ["Harju" : NSOrderedSet(array: []), "Jarva" : NSOrderedSet(array: []), "Haapsalu" : NSOrderedSet(array: [])], Country.lv : ["Riga" : NSOrderedSet(array: [])] ]
		
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions[countries[section]]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCellSID", for: indexPath)
		
		let region = regions[countries[indexPath.section]]?[indexPath.row] as? String
		cell.textLabel?.text = region
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return countries[section].name
	}

}
