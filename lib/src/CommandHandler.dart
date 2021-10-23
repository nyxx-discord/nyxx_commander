part of nyxx_commander;

/// Base object for [CommandHandler] and [CommandGroup]
abstract class CommandEntity {
  /// Executed before executing command.
  /// Used to check if command can be executed in current context.
  PassHandlerFunction? get beforeHandler => null;

  /// Callback executed after executing command
  AfterHandlerFunction? get afterHandler => null;

  /// Name of [CommandEntity]
  String get name;

  /// Aliases of [CommandEntity]
  List<String> get aliases;

  /// Parent of entity
  CommandEntity? get parent;

  /// A list of valid command names
  List<String> get commandNames => [if (this.name.isNotEmpty) this.name.toLowerCase(), ...aliases.map((e) => e.toLowerCase())];

  /// RegEx matching the fully qualified command name with its parents and all aliases
  String getFullCommandMatch() {
    var parentMatch = "";

    if (parent != null) {
      parentMatch = "${parent!.getFullCommandMatch()} ";
    }

    if (this.commandNames.isNotEmpty) {
      parentMatch += "(${this.commandNames.join('|')})";
    }

    return parentMatch.toLowerCase();
  }

  /// Returns true if provided String [str] is entity name or alias
  bool isEntityName(String str) => commandNames.contains(str.toLowerCase());
}

/// Creates command group. Pass a [name] to crated command and commands added
/// via [registerSubCommand] will be subcommands og that group
// ignore: prefer_mixin
class CommandGroup extends CommandEntity with ICommandRegistrable {
  @override
  final List<CommandEntity> _commandEntities = [];

  @override
  final PassHandlerFunction? beforeHandler;

  @override
  final AfterHandlerFunction? afterHandler;

  /// Default [CommandHandler] for [CommandGroup] - it will be executed then no other command from group match
  CommandHandler? defaultHandler;

  @override
  final String name;

  @override
  final List<String> aliases;

  @override
  CommandGroup? parent;

  /// Creates command group. Pass a [name] to crated command and commands added
  /// via [registerSubCommand] will be subcommands og that group
  CommandGroup({this.name = "", this.aliases = const [], this.defaultHandler, this.beforeHandler, this.afterHandler, this.parent});

  /// Registers default command handler which will be executed if no subcommand is matched to message content
  void registerDefaultCommand(CommandHandlerFunction commandHandler,
      {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler}) {
    this.defaultHandler = BasicCommandHandler("", commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler, parent: this);
  }

  /// Registers subcommand
  void registerSubCommand(String name, CommandHandlerFunction commandHandler,
      {PassHandlerFunction? beforeHandler, AfterHandlerFunction? afterHandler}) {
    this.registerCommandEntity(BasicCommandHandler(name, commandHandler, beforeHandler: beforeHandler, afterHandler: afterHandler, parent: this));
  }

  /// Registers command as implemented [CommandEntity] class
  void registerCommandGroup(CommandGroup commandGroup) => this.registerCommandEntity(commandGroup..parent = this);
}

/// Handles command execution - requires to implement [name] field which
/// returns name of command to match message content, and [commandHandler] callback
/// which is fired when command matches message content.
abstract class CommandHandler extends CommandEntity {
  /// Main command callback
  CommandHandlerFunction get commandHandler;
}

/// Basic implementation of command handler. Used internally in library.
class BasicCommandHandler extends CommandHandler {
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
  CommandGroup? parent;

  /// Basic implementation of command handler. Used internally in library.
  BasicCommandHandler(this.name, this.commandHandler, {this.aliases = const [], this.beforeHandler, this.afterHandler, this.parent});
}
