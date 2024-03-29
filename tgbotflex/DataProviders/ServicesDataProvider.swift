//
//  ServicesDataProvider.swift
//  tgbotflex
//
//  Created by Danil Blinov on 28.03.2024.
//

import TelegramVaporBot

final class ServicesDataProvider {
	private let client = HyperLikeClient.shared
	
	func getNetworkButtons() -> [[TGInlineKeyboardButton]] {
		let networks = client.networks
		var buttons = [[TGInlineKeyboardButton]]()
		var slice = [TGInlineKeyboardButton]()

		// Разбиваем социальные сети по 2 в ряд
		for network in networks {
			let callBackData = "network-\(network.type.rawValue)"
			let button = TGInlineKeyboardButton(text: network.type.rawValue, callbackData: callBackData)
			slice.append(button)

			if slice.count == 2 {
				buttons.append(slice)
				slice = []
			}
		}

		// Если кнопки разбились не по 2 в ряд, то последнюю суем так
		if !slice.isEmpty {
			buttons.append(slice)
		}

		let noLoyaltyButton = [TGInlineKeyboardButton(text: "NOLOYALTY CLUB", callbackData: "press 1")]
		buttons.append(noLoyaltyButton)

		return buttons
	}

	func getCategoryTypes(_ networkId: String) -> [[TGInlineKeyboardButton]] {
		print(networkId)
		guard let network = client.networks.first(where: { $0.type.rawValue == networkId }) else { return [] }
		var buttons = [[TGInlineKeyboardButton]]()
		for category in network.categories {
			let button = TGInlineKeyboardButton(
				text: category.name,
				callbackData: "category-\(category.name.toBase64())"
			)
			buttons.append([button])
		}

		let backButton = TGInlineKeyboardButton(text: "<- Назад", callbackData: "services")
		buttons.append([backButton])
		return buttons
	}
}
