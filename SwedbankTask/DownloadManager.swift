//
//  Request.swift
//  SwedbankTask
//
//  Created by nastia on 06/04/2017.
//  Copyright © 2017 Anastasiia Soboleva. All rights reserved.
//

import Foundation

typealias SingleSuccessHandler = (Data) -> Void
typealias SingleErrorHandler = (Error) -> Void
let ConsoleErrorHandler: SingleErrorHandler = { print($0) }


extension Country {

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


final class DownloadManager {
	
	fileprivate static let cookieName = "Swedbank-Embedded"
	fileprivate static let cookieValue = "iphone-app"
	
	func downloadInformationFor(country: Country, singleCompletionHandler sch: @escaping SingleSuccessHandler, singleErrorHandler seh: @escaping SingleErrorHandler) {
		
		setupCookies(forURL: country.request.url!)
		
		let task = URLSession.shared.dataTask(with: country.request, completionHandler: { (data, response, error) in
			
			guard error == nil else {
				seh(error!)
				return
			}
			
			sch(data!)
			
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
