import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

class MessageMock extends SnowflakeEntity with Fake implements IMessage {
  @override
  final String content;

  MessageMock(this.content): super(Snowflake.fromNow());
}
