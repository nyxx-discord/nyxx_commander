import "package:nyxx/nyxx.dart";
import "package:nyxx_commander/nyxx_commander.dart";

void main() {
  // Start bot
  final bot = NyxxFactory.createNyxxWebsocket("TOKEN", GatewayIntents.allUnprivileged);

  // Start commander with prefix `!`
  ICommander.create(bot, mentionPrefixHandler)
    .registerCommand("ping", (context, message) { // register command ping that will answer pong
      context.reply(MessageBuilder.content("Pong"));
    });
}
