//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 01.06.2021.
//

import Vapor
import TelegramVaporBot

final class DefaultBotHandlers {

    static func addHandlers(app: Vapor.Application, connection: TGConnectionPrtcl) async {
        await defaultBaseHandler(app: app, connection: connection)
        await messageHandler(app: app, connection: connection)
        await commandShowButtonsHandler(app: app, connection: connection)
        await buttonsActionHandler(app: app, connection: connection)
    }
    
    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let tgBaseHandler = TGBaseHandler() { update, bot in
			guard let message = update.message else { return }
//			let params = TGSendMessageParams(chatId: .chat(message.chat.id), text: "TGBaseHandler")
//			try await bot.sendMessage(params: params)
		}
        await connection.dispatcher.add(tgBaseHandler)
    }

    private static func messageHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let messageHandler = TGMessageHandler(filters: (.all && !.command.names(["/ping", "/show_buttons"]))) { update, bot in
//			let params = TGSendMessageParams(chatId: .chat(update.message!.chat.id), text: "Success")
//			try await bot.sendMessage(params: params)
		}
        await connection.dispatcher.add(messageHandler)
    }

    private static func commandShowButtonsHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
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
			try await bot.sendMessage(params: params)
		}
        await connection.dispatcher.add(commandHandler)
    }

    private static func buttonsActionHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
		let tgLootKeeper = TGCallbackQueryHandler(pattern: "TGDefault") { update, bot in
			guard let userId = update.message?.from?.id else {
				return
			}
			let params = TGAnswerCallbackQueryParams(
				callbackQueryId: update.callbackQuery?.id ?? "0",
				text: update.callbackQuery?.data ?? "data not exist",
				showAlert: false,
				url: nil,
				cacheTime: nil
			)
			try await bot.answerCallbackQuery(params: params)
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
}

