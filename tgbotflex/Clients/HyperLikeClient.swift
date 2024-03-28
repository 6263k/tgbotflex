//
//  HyperLikeClient.swift
//  tgbotflex
//
//  Created by Danil Blinov on 28.03.2024.
//

import Vapor

final class HyperLikeClient {
	enum Constants {
		static let apiToken = "YLMW4XdbibrOZnGn0HFQC8ijy6L7A9FueI3wpsdVRMENuMuTAuKXeOjZkacF"
	}
	static let shared = HyperLikeClient()

	private var app: Application?

	func setApplication(app: Application) {
		self.app = app
	}

	func sendReq() {
		let response = try await app?.get("https://hyperlike.ru/api/v2") { request in
			request.query.encode(["action": "services"])
			request.query.encode(["key": "Constants.apiToken"])
		}
	}
}
