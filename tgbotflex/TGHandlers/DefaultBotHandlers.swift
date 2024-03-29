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
	private let messagesStore = MessagesStore()
	private let networkProvider = ServicesDataProvider()

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
			let buttons = self.networkProvider.getNetworkButtons()
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
		let tgLootKeeper = TGCallbackQueryHandler(pattern: "network") { update, bot in
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

			// Получаем из строки "network-telegram" id социальной сети telegram
			guard let networkId = update.callbackQuery?.data?.components(separatedBy: "-").last else { return }

			let buttons = self.networkProvider.getCategoryTypes(networkId)
			let messageId = await self.messagesStore.getMessage(userId: userId)
			try await bot.editMessageIfPossibleOrSendNew(
				chatId: .chat(userId),
				messageId: messageId,
				text: Localizable.Titles.selectCategory,
				buttons: buttons
			)
		}
		await connection.dispatcher.add(tgLootKeeper)
	}

	// Вернуться к сервисам
	private func backButtonsHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let queryHandler = TGCallbackQueryHandler(pattern: "services") { update, bot in
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

			let buttons = self.networkProvider.getNetworkButtons()
			let messageId = await self.messagesStore.getMessage(userId: userId)
			try await bot.editMessageIfPossibleOrSendNew(
				chatId: .chat(userId),
				messageId: messageId,
				text: Localizable.Titles.selectNetwork,
				buttons: buttons
			)
		}
		await connection.dispatcher.add(queryHandler)
	}
}
