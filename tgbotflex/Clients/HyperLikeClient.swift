//
//  HyperLikeClient.swift
//  tgbotflex
//
//  Created by Danil Blinov on 28.03.2024.
//

import Vapor

actor NetworksStore {
	private var networks = [SocialNetwork]()

	fileprivate func setNetworks(_ networks: [SocialNetwork]) {
		self.networks = networks
	}

	func getNetworks() -> [SocialNetwork] {
		return networks
	}
}

final class HyperLikeClient {
	enum Constants {
		static let apiToken = "YLMW4XdbibrOZnGn0HFQC8ijy6L7A9FueI3wpsdVRMENuMuTAuKXeOjZkacF"
	}
	static let shared = HyperLikeClient()
	private(set) var networks = [SocialNetwork]()
	let networkStore = NetworksStore()
	private var app: Application?

	func setApplication(app: Application) {
		self.app = app
	}

	func sendReq() async throws {
		let res = try await app?.client.get("https://hyperlike.ru/api/v2?action=services&key=\(Constants.apiToken)")
		guard let services = try res?.content.decode([HyperService].self) else { return }


		var socialNetworks = [SocialNetwork]()

		for (key, value) in Dictionary(grouping: services, by: { $0.network }) {
			let validatedKey = key.lowercased().replacingOccurrences(of: " ", with: "")
			print(validatedKey)
			guard let type = SocialNetworkType(rawValue: validatedKey) else { continue }
			let networkCategories = Dictionary(grouping: value, by: { $0.category })

			var categories = [SocialCategory]()
			for categoryElem in networkCategories {
				let category = SocialCategory(name: categoryElem.key, services: categoryElem.value)
				categories.append(category)
			}
			let network = SocialNetwork(type: type, categories: categories)
			socialNetworks.append(network)
		}

		await networkStore.setNetworks(socialNetworks)
		networks = socialNetworks
	}
}

enum SocialNetworkType: String {
	case telegram
	case telegramPremium = "telegrampremium"
	case instagram
	case vk
	case tiktok
	case youtube
}

final class SocialNetwork {
	let type: SocialNetworkType
	let categories: [SocialCategory]

	init(
		type: SocialNetworkType,
		categories: [SocialCategory]
	) {
		self.type = type
		self.categories = categories
	}
}

final class SocialCategory {
	let name: String
	let services: [HyperService]

	init(name: String, services: [HyperService]) {
		self.name = name
		self.services = services
	}
}

struct HyperService: Content {
	/// Айди сервиса
	let service: Int
	/// Соцсети
	let network: String
	/// Имя
	let name: String
	/// это енум
	let type: String
	/// Описание
	let category: String
	/// Цена за 1000
	let rate: Double
	/// Мин количество для заказа
	let min: Int
	/// Макс количество для заказа
	let max: Int
	/// Рефилл
	let refill: Bool
	/// Отмена
	let cancel: Bool
}
