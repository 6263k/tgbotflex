//
//  DefaultBotHandlers.swift
//  
//
//  Created by Danil B A on 01.06.2021.
//

import Vapor
import TelegramVaporBot

actor MessagesStore {
	private var userEditableMessages: [Int64: Int] = [:]

	func setMessage(userId: Int64, message: Int) {
		userEditableMessages[userId] = message
	}

	func getMessage(userId: Int64) -> Int? {
		return userEditableMessages[userId]
	}
}

enum TGActionState: String {
	case services
	case service
}

final class DefaultBotHandlers {
	let messagesStore = MessagesStore()
	var flex: Int?

	func addHandlers(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await defaultBaseHandler(app: app, connection: connection)
        await messageHandler(app: app, connection: connection)
        await commandShowButtonsHandler(app: app, connection: connection)
        await buttonsActionHandler(app: app, connection: connection)
		await backButtonsHandler(app: app, connection: connection)
    }
}

// MARK: - Private
private extension DefaultBotHandlers {
	private func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let tgBaseHandler = TGBaseHandler() { update, bot in
			guard let message = update.message else { return }
			//			let params = TGSendMessageParams(chatId: .chat(message.chat.id), text: "TGBaseHandler")
			//			try await bot.sendMessage(params: params)
		}
		await connection.dispatcher.add(tgBaseHandler)
	}

	private func messageHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let messageHandler = TGMessageHandler(filters: (.all && !.command.names(["/ping", "/show_buttons"]))) { update, bot in
			//			let params = TGSendMessageParams(chatId: .chat(update.message!.chat.id), text: "Success")
			//			try await bot.sendMessage(params: params)
		}
		await connection.dispatcher.add(messageHandler)
	}

	private func commandShowButtonsHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let commandHandler = TGCommandHandler(commands: ["/start"]) { update, bot in
			guard let userId = update.message?.from?.id else {
				//				fatalError("user id not found")
				return
			}
			try await bot.sendMessage(params: TGSendMessageParams(chatId: .chat(userId), text: "Приветствуем 😁"))
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
			let keyboard = TGInlineKeyboardMarkup(inlineKeyboard: buttons)
			let params = TGSendMessageParams(
				chatId: .chat(userId),
				text: Localizable.Titles.greetings,
				replyMarkup: .inlineKeyboardMarkup(keyboard)
			)
			let data = try await bot.sendMessage(params: params)
			TGBot.log.info("Message sent \(userId), message id - \(data.messageId)")
			await self.messagesStore.setMessage(userId: userId, message: data.messageId)
		}
		await connection.dispatcher.add(commandHandler)
	}

	private func buttonsActionHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let tgLootKeeper = TGCallbackQueryHandler(pattern: "TGDefault") { update, bot in
			TGBot.log.info("press 1")
			guard let userId = update.callbackQuery?.from.id else {
				return
			}

			let params = TGAnswerCallbackQueryParams(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: nil,
				showAlert: nil,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)

			let buttons: [[TGInlineKeyboardButton]] = [
				[
					TGInlineKeyboardButton(text: "Подписчики", callbackData: "TGDefault"),
				],
				[
					TGInlineKeyboardButton(text: "Просмотры", callbackData: "press 1"),
				],
				[
					TGInlineKeyboardButton(text: "Реакции", callbackData: "press 1"),
				],
				[
					TGInlineKeyboardButton(text: "Голоса в опрос", callbackData: "press 1")
				],
				[
					TGInlineKeyboardButton(text: "<- Назад", callbackData: "backToServices")
				]
			]

			if let messageId = await self.messagesStore.getMessage(userId: userId) {
				let editParams = TGEditMessageTextParams(
					chatId: .chat(userId),
					messageId: messageId,
					text: "📂 Выберите категорию",
					replyMarkup: TGInlineKeyboardMarkup(inlineKeyboard: buttons)
				)
				try await bot.editMessageText(params: editParams)
			} else {
				let keyboard = TGInlineKeyboardMarkup(inlineKeyboard: buttons)
				let messageParams = TGSendMessageParams(
					chatId: .chat(userId),
					text: "📂 Выберите категорию",
					replyMarkup: .inlineKeyboardMarkup(keyboard)
				)
				try await bot.sendMessage(params: messageParams)
			}
		}
		await connection.dispatcher.add(tgLootKeeper)

		let callbackHandler = TGCallbackQueryHandler(pattern: "press 1") { update, bot in
			TGBot.log.info("press 1")
			let params = TGAnswerCallbackQueryParams(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: update.callbackQuery?.data  ?? "data not exist",
				showAlert: nil,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)
		}
		await connection.dispatcher.add(callbackHandler)

		let queryHandler = TGCallbackQueryHandler(pattern: "press 2") { update, bot in
			TGBot.log.info("press 2")
			let params = TGAnswerCallbackQueryParams(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: update.callbackQuery?.data  ?? "data not exist",
				showAlert: nil,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)
		}
		await connection.dispatcher.add(queryHandler)
	}

	// Вернуться к сервисам
	private func backButtonsHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let queryHandler = TGCallbackQueryHandler(pattern: "backToServices") { update, bot in
			guard let userId = update.callbackQuery?.from.id else {
				return
			}

			let params = TGAnswerCallbackQueryParams(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: nil,
				showAlert: nil,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)

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

			if let messageId = await self.messagesStore.getMessage(userId: userId) {
				let editParams = TGEditMessageTextParams(
					chatId: .chat(userId),
					messageId: messageId,
					text: Localizable.Titles.selectNetwork,
					replyMarkup: TGInlineKeyboardMarkup(inlineKeyboard: buttons)
				)
				try await bot.editMessageText(params: editParams)
			} else {
				let keyboard = TGInlineKeyboardMarkup(inlineKeyboard: buttons)
				let messageParams = TGSendMessageParams(
					chatId: .chat(userId),
					text: Localizable.Titles.selectNetwork,
					replyMarkup: .inlineKeyboardMarkup(keyboard)
				)
				try await bot.sendMessage(params: messageParams)
			}
		}
		await connection.dispatcher.add(queryHandler)
	}
}
