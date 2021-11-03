import 'dart:async';

import 'package:nyxx/nyxx.dart';

final argumentsRegex = RegExp('([^"\' ]+)|["\']([^"]*)["\']');
final quotedTextRegex = RegExp('["\']([^"]*)["\']');
final codeBlocksRegex = RegExp(r"```(\w+)?(\s)?(((.+)(\s)?)+)```");

abstract class ICommandContext {
  /// Channel from where message come from
  ITextChannel get channel;

  /// Author of message
  IMessageAuthor get author;

  /// Message that was sent
  IMessage get message;

  /// Guild in which message was sent
  IGuild? get guild;

  /// Returns author as guild member
  IMember? get member;

  /// Reference to client
  INyxxWebsocket get client;

  /// Shard on which message was sent
  int get shardId;

  /// Substring by which command was matched
  String get commandMatcher;

  /// Creates inline reply for message
  Future<IMessage> reply(MessageBuilder builder, {bool mention = false, bool reply = false });

  /// Reply to message. It allows to send regular message, Embed or both.
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   await context.reply(content: context.user.avatarURL());
  /// }
  /// ```
  Future<IMessage> sendMessage(MessageBuilder builder);

  /// Reply to messages, then delete it when [duration] expires.
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   await context.replyTemp(content: user.avatarURL());
  /// }
  /// ```
  Future<IMessage> sendMessageTemp(Duration duration, MessageBuilder builder);

  /// Replies to message after delay specified with [duration]
  /// ```
  /// Future<void> getAv(CommandContext context async {
  ///   await context.replyDelayed(Duration(seconds: 2), content: user.avatarURL());
  /// }
  /// ```
  Future<IMessage> sendMessageDelayed(Duration duration, MessageBuilder builder);

  /// Awaits for emoji under given [msg]
  Future<IEmoji> awaitEmoji(IMessage msg);

  /// Collects emojis within given [duration]. Returns empty map if no reaction received
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   final msg = await context.replyDelayed(content: context.user.avatarURL());
  ///   final emojis = await context.awaitEmojis(msg, Duration(seconds: 15));
  ///
  /// }
  /// ```
  Future<Map<IEmoji, int>> awaitEmojis(IMessage msg, Duration duration);

  /// Waits for first [TypingEvent] and returns it. If timed out returns null.
  /// Can listen to specific user by specifying [user]
  Future<ITypingEvent?> waitForTyping(IUser user, {Duration timeout = const Duration(seconds: 30)});

  /// Gets all context channel messages that satisfies [predicate].
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   final messages = await context.nextMessagesWhere((msg) => msg.content.startsWith("fuck"));
  /// }
  /// ```
  Stream<IMessageReceivedEvent> nextMessagesWhere(bool Function(IMessageReceivedEvent msg) predicate, {int limit = 1});

  /// Gets next [num] number of any messages sent within one context (same channel).
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   // gets next 10 messages
  ///   final messages = await context.nextMessages(10);
  /// }
  /// ```
  Stream<IMessageReceivedEvent> nextMessages(int num);

  /// Starts typing loop and ends when [callback] resolves.
  Future<T> enterTypingState<T>(Future<T> Function() callback);

  /// Returns list of words separated with space and/or text surrounded by quotes
  /// Text: `hi this is "example stuff" which 'can be parsed'` will return
  /// `List<String> [hi, this, is, example stuff, which, can be parsed]`
  Iterable<String> getArguments();

  /// Returns list which content of quotes.
  /// Text: `hi this is "example stuff" which 'can be parsed'` will return
  /// `List<String> [example stuff, can be parsed]`
  Iterable<String> getQuotedText();

  /// Returns list of all code blocks in message
  /// Language string `dart, java` will be ignored and not included
  /// """
  /// n> eval ```(dart)?
  ///   await reply(content: 'no to elo');
  /// ```
  /// """
  Iterable<String> getCodeBlocks();
}

/// Helper class which describes context in which command is executed
class CommandContext implements ICommandContext {
  /// Channel from where message come from
  @override
  final ITextChannel channel;

  /// Author of message
  @override
  final IMessageAuthor author;

  /// Message that was sent
  @override
  final IMessage message;

  /// Guild in which message was sent
  @override
  final IGuild? guild;

  /// Returns author as guild member
  @override
  IMember? get member => this.message.member != null
      ? message.member!
      : null;

  /// Reference to client
  @override
  INyxxWebsocket get client => channel.client as INyxxWebsocket;

  /// Shard on which message was sent
  @override
  int get shardId => this.guild != null ? this.guild!.shard.id : 0;

  /// Substring by which command was matched
  @override
  final String commandMatcher;

  /// Creates na instance of [CommandContext]
  CommandContext(this.channel, this.author, this.guild, this.message, this.commandMatcher);

  static final _argumentsRegex = RegExp('([^"\' ]+)|["\']([^"]*)["\']');
  static final _quotedTextRegex = RegExp('["\']([^"]*)["\']');
  static final _codeBlocksRegex = RegExp(r"```(\w+)?(\s)?(((.+)(\s)?)+)```");

  /// Creates inline reply for message
  @override
  Future<IMessage> reply(MessageBuilder builder, {bool mention = false, bool reply = false }) async {
    if (mention) {
      if (builder.allowedMentions != null) {
        builder.allowedMentions!.allow(reply: true);
      } else {
        builder.allowedMentions = AllowedMentions()..allow(reply: true);
      }
    }

    if (reply) {
      builder.replyBuilder = ReplyBuilder.fromMessage(this.message);
    }

    return channel.sendMessage(builder);
  }

  /// Reply to message. It allows to send regular message, Embed or both.
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   await context.reply(content: context.user.avatarURL());
  /// }
  /// ```
  @override
  Future<IMessage> sendMessage(MessageBuilder builder) => channel.sendMessage(builder);

  /// Reply to messages, then delete it when [duration] expires.
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   await context.replyTemp(content: user.avatarURL());
  /// }
  /// ```
  @override
  Future<IMessage> sendMessageTemp(Duration duration, MessageBuilder builder) => channel
        .sendMessage(builder)
        .then((msg) {
          Timer(duration, () => msg.delete());
          return msg;
      });

  /// Replies to message after delay specified with [duration]
  /// ```
  /// Future<void> getAv(CommandContext context async {
  ///   await context.replyDelayed(Duration(seconds: 2), content: user.avatarURL());
  /// }
  /// ```
  @override
  Future<IMessage> sendMessageDelayed(Duration duration, MessageBuilder builder) =>
      Future.delayed(duration, () => channel.sendMessage(builder));

  /// Awaits for emoji under given [msg]
  @override
  Future<IEmoji> awaitEmoji(IMessage msg) async =>
      (await this.client.eventsWs.onMessageReactionAdded.where((event) => event.message == msg).first).emoji;

  /// Collects emojis within given [duration]. Returns empty map if no reaction received
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   final msg = await context.replyDelayed(content: context.user.avatarURL());
  ///   final emojis = await context.awaitEmojis(msg, Duration(seconds: 15));
  ///
  /// }
  /// ```
  @override
  Future<Map<IEmoji, int>> awaitEmojis(IMessage msg, Duration duration){
    final collectedEmoji = <IEmoji, int>{};
    return Future<Map<IEmoji, int>>(() async {
      await for (final event in client.eventsWs.onMessageReactionAdded.where((evnt) => evnt.message != null && evnt.message!.id == msg.id)) {
        if (collectedEmoji.containsKey(event.emoji)) {
          // TODO: NNBD: weird stuff
          var value = collectedEmoji[event.emoji];

          if (value != null) {
            value += 1;
            collectedEmoji[event.emoji] = value;
          }
        } else {
          collectedEmoji[event.emoji] = 1;
        }
      }

      return collectedEmoji;
    }).timeout(duration, onTimeout: () => collectedEmoji);
  }


  /// Waits for first [TypingEvent] and returns it. If timed out returns null.
  /// Can listen to specific user by specifying [user]
  @override
  Future<ITypingEvent?> waitForTyping(IUser user, {Duration timeout = const Duration(seconds: 30)}) =>
      Future<ITypingEvent?>(() => client.eventsWs.onTyping.firstWhere((e) => e.user == user && e.channel == this.channel)).timeout(timeout, onTimeout: () => null);

  /// Gets all context channel messages that satisfies [predicate].
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   final messages = await context.nextMessagesWhere((msg) => msg.content.startsWith("fuck"));
  /// }
  /// ```
  @override
  Stream<IMessageReceivedEvent> nextMessagesWhere(bool Function(IMessageReceivedEvent msg) predicate, {int limit = 1}) =>
    client.eventsWs.onMessageReceived.where((event) => event.message.channel.id == channel.id).where(predicate).take(limit);

  /// Gets next [num] number of any messages sent within one context (same channel).
  ///
  /// ```
  /// Future<void> getAv(CommandContext context) async {
  ///   // gets next 10 messages
  ///   final messages = await context.nextMessages(10);
  /// }
  /// ```
  @override
  Stream<IMessageReceivedEvent> nextMessages(int num) =>
      client.eventsWs.onMessageReceived.where((event) => event.message.channel.id == channel.id).take(num);

  /// Starts typing loop and ends when [callback] resolves.
  @override
  Future<T> enterTypingState<T>(Future<T> Function() callback) async {
    this.channel.startTypingLoop();
    final result = await callback();
    this.channel.stopTypingLoop();

    return result;
  }

  /// Returns list of words separated with space and/or text surrounded by quotes
  /// Text: `hi this is "example stuff" which 'can be parsed'` will return
  /// `List<String> [hi, this, is, example stuff, which, can be parsed]`
  @override
  Iterable<String> getArguments() sync* {
    final matches = _argumentsRegex.allMatches(this.message.content.toLowerCase().replaceFirst(commandMatcher.toLowerCase(), ""));

    for(final match in matches) {
      final group1 = match.group(1);

      yield group1 ?? match.group(2)!;
    }
  }

  /// Returns list which content of quotes.
  /// Text: `hi this is "example stuff" which 'can be parsed'` will return
  /// `List<String> [example stuff, can be parsed]`
  @override
  Iterable<String> getQuotedText() sync* {
    final matches = _quotedTextRegex.allMatches(this.message.content.replaceFirst(commandMatcher, ""));
    for(final match in matches) {
      yield match.group(1)!;
    }
  }

  /// Returns list of all code blocks in message
  /// Language string `dart, java` will be ignored and not included
  /// """
  /// n> eval ```(dart)?
  ///   await reply(content: 'no to elo');
  /// ```
  /// """
  @override
  Iterable<String> getCodeBlocks() sync* {
    final matches = _codeBlocksRegex.allMatches(message.content);
    for (final match in matches) {
      final matchedText = match.group(3);

      if (matchedText != null) {
        yield matchedText;
      }
    }
  }
}
