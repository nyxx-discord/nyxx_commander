import "package:nyxx/nyxx.dart";
import "package:nyxx_commander/nyxx_commander.dart";

void main() {
  // Start bot
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged)
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Start commander with prefix `!`
  ICommander.create(bot, mentionPrefixHandler)
    .registerCommand("ping", (context, message) { // register command ping that will answer pong
      context.reply(MessageBuilder.content("Pong"));
    });
}
