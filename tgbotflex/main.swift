import Vapor
import TelegramVaporBot

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount * 4)
let app = Application(env, Application.EventLoopGroupProvider.shared(eventLoop))
defer { app.shutdown() }

HyperLikeClient.shared.setApplication(app: app)
try await HyperLikeClient.shared.sendReq()
let TGBOT = TGBotConnection()


try await configure(app)
try app.run()

