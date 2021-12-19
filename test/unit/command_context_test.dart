import 'package:nyxx_commander/src/command_context.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/message.mock.dart';
import '../mocks/text_channel.mock.dart';
import '../mocks/user.mocks.dart';

main() {
  test(".getArguments", () {
    final messageMock = MessageMock("\"this is\" first argument \"test\" yeah");
    final commandContext = CommandContext(TextChannelMock(), UserMock(), null, messageMock, "test-command");

    final result = commandContext.getArguments();
    expect(result, equals(['this is', 'first', 'argument', 'test', 'yeah']));
  });
}
