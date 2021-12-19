# nyxx_commander

[![Discord Shield](https://discordapp.com/api/guilds/846136758470443069/widget.png?style=shield)](https://discord.gg/nyxx)
[![pub](https://img.shields.io/pub/v/nyxx_commander.svg)](https://pub.dartlang.org/packages/nyxx_commander)
[![documentation](https://img.shields.io/badge/Documentation-nyxx_interactions-yellow.svg)](https://www.dartdocs.org/documentation/nyxx_commander/latest/)

Simple, robust framework for creating discord bots for Dart language.

<hr />

### Features

- **commands and subcommands**
- **aliases support**
- **extensive support for middleware**
- **lightweight**

## Quick example

Commands:
```dart
void main() {
  final bot = NyxxFactory.createNyxxWebsocket("<TOKEN>", GatewayIntents.allUnprivileged);

  Commander(bot, prefix: "!!!")
    ..registerCommand("ping", (context, message) => context.reply(content: "Pong!"));
}
```

## Other nyxx packages

- [nyxx](https://github.com/nyxx-discord/nyxx)
- [nyxx_interactions](https://github.com/nyxx-discord/nyxx_interactions)
- [nyxx_extensions](https://github.com/nyxx-discord/nyxx_extensions)
- [nyxx_lavalink](https://github.com/nyxx-discord/nyxx_lavalink)
- [nyxx_pagination](https://github.com/nyxx-discord/nyxx_pagination)

## More examples

Nyxx examples can be found [here](https://github.com/nyxx-discord/nyxx_commander/tree/dev/example).

### Example bots
- [Running on Dart](https://github.com/l7ssha/running_on_dart)

## Documentation, help and examples

**Dartdoc documentation for latest stable version is hosted on [pub](https://www.dartdocs.org/documentation/nyxx_commander/latest/)**

#### [Docs and wiki](https://nyxx.l7ssha.xyz)
You can read docs and wiki articles for latest stable version on my website. This website also hosts docs for latest
dev changes to framework (`dev` branch)

#### [Official nyxx discord server](https://discord.gg/nyxx)
If you need assistance in developing bot using nyxx you can join official nyxx discord guild.

#### [Discord API docs](https://discordapp.com/developers/docs/intro)
Discord API documentation features rich descriptions about all topics that nyxx covers.

#### [Discord API Guild](https://discord.gg/discord-api)
The unofficial guild for Discord Bot developers. To get help with nyxx check `#dart_nyxx` channel.

#### [Dartdocs](https://www.dartdocs.org/documentation/nyxx_commander/latest/)
The dartdocs page will always have the documentation for the latest release.

## Contributing to Nyxx

Read [contributing document](https://github.com/l7ssha/nyxx_commander/blob/development/CONTRIBUTING.md)

## Credits

* [Hackzzila's](https://github.com/Hackzzila) for [nyx](https://github.com/Hackzzila/nyx).
