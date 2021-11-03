import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commander/src/command_context.dart';
import 'package:nyxx_commander/src/command_handler.dart';

/// Used to determine if command can be executed in given environment.
/// Return true to allow executing command or false otherwise.
typedef PassHandlerFunction = FutureOr<bool> Function(ICommandContext context);

/// Handler for executing command logic.
typedef CommandHandlerFunction = FutureOr<void> Function(ICommandContext context, String message);

/// Handler for executing logic after executing command.
typedef AfterHandlerFunction = FutureOr<void> Function(ICommandContext context);

/// Handler used to determine prefix for command in given environment.
/// Can be used to define different prefixes for different guild, users or dms.
/// Return String containing prefix or null if command cannot be executed.
typedef PrefixHandlerFunction = FutureOr<String?> Function(IMessage message);

/// Callback to customize logger output when command is executed.
typedef LoggerHandlerFunction = FutureOr<void> Function(ICommandContext context, String commandName, Logger logger);

/// Callback called when command executions returns with [Exception] or [Error] ([exception] variable could be either).
typedef CommandExecutionError = FutureOr<void> Function(ICommandContext context, dynamic exception);

class CommandMatcher {
  /// Matches [commands] from [messageParts]. Performs recursive lookup on available commands and it's children.
  static ICommandEntity? findMatchingCommand(Iterable<String> messageParts, Iterable<ICommandEntity> commands) {
    for (final entity in commands) {
      if(entity is CommandGroup && entity.name == "") {
        final e = findMatchingCommand(messageParts, entity.commandEntities);

        if (e != null) {
          return e;
        }
      }

      if (entity is CommandGroup && entity.isEntityName(messageParts.first)) {
        if (messageParts.length == 1 && entity.defaultHandler != null) {
          return entity.defaultHandler;
        } else if (messageParts.length == 1 && entity.defaultHandler == null) {
          return null;
        }

        final e = findMatchingCommand(messageParts.skip(1), entity.commandEntities);

        if (e != null) {
          return e;
        } else if (entity.defaultHandler != null) {
          return entity.defaultHandler;
        }
      }

      if (entity is CommandHandlerAbstract && entity.isEntityName(messageParts.first)) {
        return entity;
      }
    }

    return null;
  }
}
