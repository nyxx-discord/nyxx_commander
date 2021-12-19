import 'package:nyxx_commander/src/utils.dart';

abstract class ICommandRegistrable {
  List<ICommandEntity> get commandEntities;

  /// Registers [CommandEntity] within context of this instance. Throws error if there is command with same name as provided.
  void registerCommandEntity(ICommandEntity entity);
}

/// Provides common functionality for entities which can register subcommand or sub command groups.
abstract class CommandRegistrableAbstract implements ICommandRegistrable {
  @override
  List<ICommandEntity> get commandEntities;

  /// Registers [CommandEntity] within context of this instance. Throws error if there is command with same name as provided.
  @override
  void registerCommandEntity(ICommandEntity entity) {
    if (commandEntities.any((element) => element.isEntityName(entity.name))) {
      throw Exception("Command name should be unique! There is already command with name: ${entity.name}}");
    }

    if (entity is ICommandGroup && entity.name.isEmpty && entity.aliases.isNotEmpty) {
      throw Exception("Command group cannot have aliases if its name is empty! Provided aliases: [${entity.aliases.join(", ")}]");
    }

    commandEntities.add(entity);
  }
}

abstract class ICommandEntity {
  /// Executed before executing command.
  /// Used to check if command can be executed in current context.
  PassHandlerFunction? get beforeHandler;

  /// Callback executed after executing command
  AfterHandlerFunction? get afterHandler;

  /// Name of [CommandEntityAbstract]
  String get name;

  /// Aliases of [CommandEntityAbstract]
  List<String> get aliases;

  /// Parent of entity
  CommandEntityAbstract? get parent;

  /// A list of valid command names
  List<String> get commandNames;

  /// RegEx matching the fully qualified command name with its parents and all aliases
  String getFullCommandMatch();

  /// Returns true if provided String [str] is entity name or alias
  bool isEntityName(String str);
}

/// Base object for [CommandHandlerAbstract] and [BasicCommandGroup]
abstract class CommandEntityAbstract implements ICommandEntity {
  /// Executed before executing command.
  /// Used to check if command can be executed in current context.
  @override
  PassHandlerFunction? get beforeHandler => null;

  /// Callback executed after executing command
  @override
  AfterHandlerFunction? get afterHandler => null;

  /// Name of [CommandEntityAbstract]
  @override
  String get name;

  /// Aliases of [CommandEntityAbstract]
  @override
  List<String> get aliases;

  /// Parent of entity
  @override
  CommandEntityAbstract? get parent;

  /// A list of valid command names
  @override
  List<String> get commandNames => [if (name.isNotEmpty) name.toLowerCase(), ...aliases.map((e) => e.toLowerCase())];

  /// RegEx matching the fully qualified command name with its parents and all aliases
  @override
  String getFullCommandMatch() {
    var parentMatch = "";

    if (parent != null) {
      parentMatch = "${parent!.getFullCommandMatch()} ";
    }

    if (commandNames.isNotEmpty) {
      parentMatch += "(${commandNames.join('|')})";
    }

    return parentMatch.toLowerCase();
  }

  /// Returns true if provided String [str] is entity name or alias
  @override
  bool isEntityName(String str) => commandNames.contains(str.toLowerCase());
}

abstract class ICommandGroup implements ICommandEntity, ICommandRegistrable {
  /// Default [CommandHandlerAbstract] for [BasicCommandGroup] - it will be executed then no other command from group match
  CommandHandlerAbstract? get defaultHandler;

  /// Registers default command handler which will be executed if no subcommand is matched to message content
  void registerDefaultCommand(CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler});

  /// Registers subcommand
  void registerSubCommand(String name, CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler});

  /// Registers command as implemented [CommandEntityAbstract] class
  void registerCommandGroup(BasicCommandGroup commandGroup);
}

/// Creates command group. Pass a [name] to crated command and commands added
/// via [registerSubCommand] will be subcommands og that group
// ignore: prefer_mixin
class BasicCommandGroup extends CommandEntityAbstract with CommandRegistrableAbstract {
  @override
  final List<ICommandEntity> commandEntities = [];

  @override
  final PassHandlerFunction? beforeHandler;

  @override
  final AfterHandlerFunction? afterHandler;

  /// Default [CommandHandlerAbstract] for [BasicCommandGroup] - it will be executed then no other command from group match
  CommandHandlerAbstract? defaultHandler;

  @override
  final String name;

  @override
  final List<String> aliases;

  @override
  BasicCommandGroup? parent;

  /// Creates command group. Pass a [name] to crated command and commands added
  /// via [registerSubCommand] will be subcommands og that group
  BasicCommandGroup({this.name = "", this.aliases = const [], this.defaultHandler, this.beforeHandler, this.afterHandler, this.parent});

  /// Registers default command handler which will be executed if no subcommand is matched to message content
  void registerDefaultCommand(CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler}) {
    defaultHandler = CommandHandler("", commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler, parent: this);
  }

  /// Registers subcommand
  void registerSubCommand(String name, CommandHandlerFunction commandHandler, {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler}) {
    registerCommandEntity(CommandHandler(name, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler, parent: this));
  }

  /// Registers command as implemented [CommandEntityAbstract] class
  void registerCommandGroup(BasicCommandGroup commandGroup) => registerCommandEntity(commandGroup..parent = this);
}

class CommandGroup extends BasicCommandGroup {
  /// Creates command group. Pass a [name] to crated command and commands added
  /// via [registerSubCommand] will be subcommands og that group
  CommandGroup(
      {String name = "",
      List<String> aliases = const [],
      CommandHandlerAbstract? defaultHandler,
      PassHandlerFunction? beforeHandler,
      AfterHandlerFunction? afterHandler,
      CommandGroup? parent})
      : super(name: name, aliases: aliases, defaultHandler: defaultHandler, beforeHandler: beforeHandler, afterHandler: afterHandler, parent: parent);
}

abstract class ICommandHandler implements ICommandEntity {
  /// Main command callback
  CommandHandlerFunction get commandHandler;
}

/// Handles command execution - requires to implement [name] field which
/// returns name of command to match message content, and [commandHandler] callback
/// which is fired when command matches message content.
abstract class CommandHandlerAbstract extends CommandEntityAbstract implements ICommandHandler {}

abstract class IBasicCommandHandler implements ICommandHandler {}

/// Basic implementation of command handler. Used internally in library.
class CommandHandler extends CommandHandlerAbstract implements IBasicCommandHandler {
  @override
  final PassHandlerFunction? beforeHandler;

  @override
  final AfterHandlerFunction? afterHandler;

  @override
  CommandHandlerFunction commandHandler;

  @override
  final String name;

  @override
  final List<String> aliases;

  @override
  BasicCommandGroup? parent;

  /// Basic implementation of command handler. Used internally in library.
  CommandHandler(this.name, this.commandHandler, {this.aliases = const [], this.beforeHandler, this.afterHandler, this.parent});
}
