//
//  TGBot+Extensions.swift
//  tgbotflex
//
//  Created by Danil Blinov on 28.03.2024.
//

import TelegramVaporBot

extension TGBot {
	// Шляпная коробка! если передать меседж то отредактирует, в обратном случае отправит новое
	@discardableResult
	func editMessageIfPossibleOrSendNew(
		chatId: TGChatId,
		messageId: Int? = nil,
		text: String,
		buttons: [[TGInlineKeyboardButton]]
	) async throws -> TGMessage? {
		if let messageId {
			let editParams = TGEditMessageTextParams(
				chatId: chatId,
				messageId: messageId,
				text: text,
				replyMarkup: TGInlineKeyboardMarkup(inlineKeyboard: buttons)
			)
			let tgBoolMessage = try await self.editMessageText(params: editParams)
			return tgBoolMessage.message
		} else {
			let keyboard = TGInlineKeyboardMarkup(inlineKeyboard: buttons)
			let messageParams = TGSendMessageParams(
				chatId: chatId,
				text: text,
				replyMarkup: .inlineKeyboardMarkup(keyboard)
			)
			return try await self.sendMessage(params: messageParams)
		}
	}
}
