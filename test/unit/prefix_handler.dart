import 'package:nyxx_commander/nyxx_commander.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/message.mock.dart';

main() {
  group("mentionPrefixHandler", () {
    test("valid message", () {
      final messageWithMention = MessageMock('<@!123> this is example command');

      final result = mentionPrefixHandler(messageWithMention);
      expect(result, isNotNull);
      expect(result, equals("<@!123>"));
    });

    test("valid message mention at the end", () {
      final messageWithMention = MessageMock('this is example command <@123>');

      final result = mentionPrefixHandler(messageWithMention);
      expect(result, isNotNull);
      expect(result, equals("<@123>"));
    });

    test('invalid message no mention', () {
      final messageWithMention = MessageMock('!some-other-stuff this is example command');

      final result = mentionPrefixHandler(messageWithMention);
      expect(result, isNotNull);
    });

    test('invalid message invalid app id', () {
      final messageWithMention = MessageMock('<@!321> this is example command');

      final result = mentionPrefixHandler(messageWithMention);
      expect(result, isNull);
    });
  });
}
