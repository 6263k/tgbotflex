//
//  TGMessageOrBool+Extensions.swift
//  tgbotflex
//
//  Created by Danil Blinov on 28.03.2024.
//

import TelegramVaporBot

extension TGMessageOrBool {
	var message: TGMessage? {
		guard case let .message(tGMessage) = self else { return nil }
		return tGMessage
	}
}

