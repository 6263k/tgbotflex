//
//  ServicesDataProvider.swift
//  tgbotflex
//
//  Created by Danil Blinov on 28.03.2024.
//

import TelegramVaporBot

final class ServicesDataProvider {
	func getNetworkButtons() -> [[TGInlineKeyboardButton]] {
		let buttons: [[TGInlineKeyboardButton]] = [
			[
				TGInlineKeyboardButton(text: "💎 Telegram", callbackData: "TGDefault"),
				TGInlineKeyboardButton(text: "💎 Telegram Premium", callbackData: "press 2")
			],
			[
				TGInlineKeyboardButton(text: "💎 Instagram", callbackData: "press 1"),
				TGInlineKeyboardButton(text: "💎 TikTok", callbackData: "press 1"),
			],
			[
				TGInlineKeyboardButton(text: "💎 VK", callbackData: "press 1"),
				TGInlineKeyboardButton(text: "💎 YouTube", callbackData: "press 1"),
			],
			[TGInlineKeyboardButton(text: "NOLOYALTY CLUB", callbackData: "press 1")]
		]

		return buttons
	}

	func getServiceTypes(_ networkId: Int) -> [[TGInlineKeyboardButton]] {
		return []
	}
}
