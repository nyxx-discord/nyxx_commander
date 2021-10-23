import "dart:io";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commander/commander.dart";

void main() {
  // final bot = Nyxx(Platform.environment["BOT_TOKEN"]!, GatewayIntents.allUnprivileged, ignoreExceptions: false);
  //
  // Commander(bot, prefix: "test>")
  //   ..registerCommand("test1", (context, message) async {
  //     await context.channel.sendMessage(MessageBuilder.content("Test 1"));
  //   })
  //   ..registerCommand("test2", (context, message) async {
  //     final args = message.split(" ");
  //
  //     if (args.length == 2 && args.last == "arg1") {
  //       await context.channel.sendMessage(MessageBuilder.content("Test 2"));
  //     }
  //   })
  //   ..registerCommand("test3", (context, message) async {
  //     await context.message.delete();
  //   })
  //   ..registerCommandGroup(CommandGroup(name: "test4", aliases: ["t4"])
  //     ..registerCommandGroup(CommandGroup(name: "test14")
  //       ..registerSubCommand("test1", (context, message) async => context.channel.sendMessage(MessageBuilder.content("Test 11")))
  //     )
  //   );
}
