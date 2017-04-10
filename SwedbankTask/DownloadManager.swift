//
//  DownloadManager.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import Foundation

typealias SuccessHandler = (Data) -> Void
typealias ErrorHandler = (Error) -> Void
typealias FieldsDictionary = [CountryIdentifier : [PlaceFields]]

extension CountryIdentifier {

	private var requestSring: String {
		switch self {
		case .ee: return "https://www.swedbank.ee/finder.json"
		case .lt: return "https://ib.swedbank.lt/finder.json"
		case .lv: return "https://ib.swedbank.lv/finder.json"
		}
	}
	
	var request: URLRequest {
		let url = URL(string: requestSring)!
		return URLRequest(url: url)
	}
}

//Get data from backend for each, parse it, and pass to the BankModelUpdateManager object
final class DownloadManager {
	
	fileprivate static let cookieName = "Swedbank-Embedded"
	fileprivate static let cookieValue = "iphone-app"
	
	private let updateManager = BankModelUpdateManager()
	
	func updateBankModel(completionHandler: @escaping (Void) -> Void, errorsHandler: @escaping ([Error]) -> Void) {
		
		let group = DispatchGroup()
		var errors = [Error]()
		
		var countriesPlacesFields = FieldsDictionary()
		
		for countryId in CountryIdentifier.all {
			group.enter()
			
			let groupErrorHandler: (Error) -> Void = {
				errors.append($0)
				group.leave()
			}
			
			let downloadHandler: (Data) -> Void = {
				guard let jsonObject = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments), let json = jsonObject as? Array<Dictionary<String, Any>> else {
					groupErrorHandler(UpdateError.parseError)
					return
				}
				
				let placeFieldsArray = json.flatMap { PlaceFields(json: $0) }
				countriesPlacesFields[countryId] = placeFieldsArray
				
				group.leave()
			}
			
			downloadDataFor(country: countryId, completionHandler: downloadHandler, errorHandler: groupErrorHandler)
		}
		
		group.notify(queue: .main) { [weak self] in
			//insert data into local storage
			self?.updateManager.updateLocalCache(countriesPlacesFields, completionHandler: {
				errors.isEmpty ? completionHandler() : errorsHandler(errors)
			}, errorHandler: { err in
				errors.append(err)
				errorsHandler(errors)
			})
		}
		
	}
	
	private func downloadDataFor(country: CountryIdentifier, completionHandler ch: @escaping SuccessHandler, errorHandler eh: @escaping ErrorHandler) {
		
		setupCookies(forURL: country.request.url!)
		
		let task = URLSession.shared.dataTask(with: country.request, completionHandler: { (data, response, error) in
			
			guard error == nil else {
				eh(error!)
				return
			}
			
			ch(data!)
			
		})
		task.resume()
	}
	
	private func setupCookies(forURL url: URL) {
		let cookies = HTTPCookieStorage.shared.cookies(for: url)
		if cookies == nil || cookies!.isEmpty {
			HTTPCookieStorage.shared.setCookies([HTTPCookie.swedbankCookie(forURL: url)], for: url, mainDocumentURL: nil)
		}
	}
	
}

fileprivate extension HTTPCookie {
	
	static func swedbankCookie(forURL url: URL) -> HTTPCookie {
		let properties: [HTTPCookiePropertyKey : Any] = [
			.name : DownloadManager.cookieName,
			.value : DownloadManager.cookieValue,
			.path : "/",
			.originURL: url
		]
		return HTTPCookie(properties: properties)!
	}
}
