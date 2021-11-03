import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';

import 'package:nyxx_commander/src/command_handler.dart';
import 'package:nyxx_commander/src/command_context.dart';
import 'package:nyxx_commander/src/utils.dart';

/// Lightweight command framework. Doesn't use `dart:mirrors` and can be used in browser.
/// While constructing specify prefix which is string with prefix or
/// implement [PrefixHandlerFunction] for more fine control over where and in what conditions commands are executed.
///
/// Allows to specify callbacks which are executed before and after command - also on per command basis.
/// beforeCommandHandler callbacks are executed only command exists and is matched with message content.
// ignore: prefer_mixin
class Commander with CommandRegistrableAbstract {
  late final PrefixHandlerFunction _prefixHandler;
  late final PassHandlerFunction? _beforeCommandHandler;
  late final AfterHandlerFunction? _afterHandlerFunction;
  late final LoggerHandlerFunction _loggerHandlerFunction;
  late final CommandExecutionError? _commandExecutionError;

  @override
  final List<ICommandEntity> commandEntities = [];

  final Logger _logger = Logger("Commander");

  /// Resolves prefix for given [message]. Returns null if there is no prefix for given [message] which
  /// means command wouldn't execute in given context.
  FutureOr<String?> getPrefixForMessage(IMessage message) => _prefixHandler(message);

  /// Either [prefix] or [prefixHandler] must be specified otherwise program will exit.
  /// Allows to specify additional [beforeCommandHandler] executed before main command callback,
  /// and [afterCommandHandler] executed after main command callback.
  Commander(INyxxWebsocket client,
        {String? prefix,
        PrefixHandlerFunction? prefixHandler,
        PassHandlerFunction? beforeCommandHandler,
        AfterHandlerFunction? afterCommandHandler,
        LoggerHandlerFunction? loggerHandlerFunction,
        CommandExecutionError? commandExecutionError}) {
    if (!_hasRequiredIntents(client)) {
      _logger.shout("Commander cannot start without required intents (directMessages, guildMessages, guilds)");
      exit(1);
    }

    if (prefix == null && prefixHandler == null) {
      _logger.shout("Commander cannot start without both prefix and prefixHandler");
      exit(1);
    }

    if (prefix == null) {
      _prefixHandler = prefixHandler!;
    } else {
      _prefixHandler = (_) => prefix;
    }

    this._beforeCommandHandler = beforeCommandHandler;
    this._afterHandlerFunction = afterCommandHandler;
    this._commandExecutionError = commandExecutionError;
    this._loggerHandlerFunction = loggerHandlerFunction ?? _defaultLogger;

    client.eventsWs.onMessageReceived.listen(_handleMessage);

    this._logger.info("Commander ready!");
  }

  /// Registers command with given [commandName]. Allows to specify command specific before and after command execution callbacks
  void registerCommand(String commandName, CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler}) {
    this.registerCommandEntity(BasicCommandHandler(commandName, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler));
  }

  /// Registers command as implemented [CommandEntity] class
  void registerCommandGroup(CommandGroup commandGroup) => this.registerCommandEntity(commandGroup);

  Future<void> _handleMessage(IMessageReceivedEvent event) async {
    final prefix = await _prefixHandler(event.message);
    if (prefix == null) {
      return;
    }

    if(!event.message.content.startsWith(prefix)) {
      return;
    }

    this._logger.finer("Attempting to execute command from message: [${event.message.content}] from [${event.message.author.tag}]");

    // Find matching command with given message content
    final matchingCommand = CommandMatcher.findMatchingCommand(event.message.content.toLowerCase().replaceFirst(prefix, "").trim().split(" "), commandEntities) as ICommandHandler?;

    if(matchingCommand == null) {
      return;
    }

    // Builds a RegEx that matches the full command including their parents and all possible
    // aliases of the final command entity and their parents.
    // Example: (?<finalCommand>(quote|q) (remove|rm))
    // This will match the command `quote remove`, `q remove`, `quote rm` and `q rm`

    final match = RegExp("(?<finalCommand>${matchingCommand.getFullCommandMatch().trim()})").firstMatch(event.message.content.toLowerCase());
    final finalCommand = match?.namedGroup("finalCommand");

    this._logger.finer("Preparing command for execution: Command name: $finalCommand");

    // construct CommandContext
    final context = CommandContext(
      await event.message.channel.getOrDownload(),
      event.message.author,
      event.message.guild?.getFromCache(),
      event.message,
      "$prefix$finalCommand",
    );

    // Invoke before handler for commands
    if (!(await _invokeBeforeHandler(matchingCommand, context))) {
      return;
    }

    // Invoke before handler for commander
    if(this._beforeCommandHandler != null && !(await this._beforeCommandHandler!(context))) {
      return;
    }

    // Execute command
    try {
      await matchingCommand.commandHandler(context, event.message.content);
    } on Exception catch (e) {
      if(this._commandExecutionError != null) {
        await _commandExecutionError!(context, e);
      }

      this._logger.fine("Command [$finalCommand] executed with Exception: $e");
    } on Error catch (e) {
      if(this._commandExecutionError != null) {
        await _commandExecutionError!(context, e);
      }

      this._logger.fine("Command [$finalCommand] executed with Error: $e");
    }

    // execute logger callback
    _loggerHandlerFunction(context, finalCommand!, this._logger);

    // invoke after handler of command
    await _invokeAfterHandler(matchingCommand, context);

    // Invoke after handler for commander
    if (this._afterHandlerFunction != null) {
      this._afterHandlerFunction!(context);
    }
  }

  // Invokes command after handler and its parents
  Future<void> _invokeAfterHandler(ICommandEntity? commandEntity, CommandContext context) async {
    if(commandEntity == null) {
      return;
    }

    if(commandEntity.afterHandler != null) {
      await commandEntity.afterHandler!(context);
    }

    if(commandEntity.parent != null) {
      await _invokeAfterHandler(commandEntity.parent, context);
    }
  }

  // Invokes command before handler and its parents. It will check for next before handlers if top handler returns true.
  Future<bool> _invokeBeforeHandler(ICommandEntity? commandEntity, CommandContext context) async {
    if(commandEntity == null) {
      return true;
    }

    if(commandEntity.beforeHandler == null) {
      return _invokeBeforeHandler(commandEntity.parent, context);
    }

    if(await commandEntity.beforeHandler!(context)) {
      return _invokeBeforeHandler(commandEntity.parent, context);
    }

    return false;
  }

  FutureOr<void> _defaultLogger(ICommandContext ctx, String commandName, Logger logger) {
    logger.info("Command [$commandName] executed by [${ctx.author.tag}]");
  }

  bool _hasRequiredIntents(INyxxWebsocket client) =>
      PermissionsUtils.isApplied(client.intents, GatewayIntents.guildMessages)
          || PermissionsUtils.isApplied(client.intents, GatewayIntents.directMessages)
          || PermissionsUtils.isApplied(client.intents, GatewayIntents.guilds)
          || PermissionsUtils.isApplied(client.intents, GatewayIntents.guilds);
}