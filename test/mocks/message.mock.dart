import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

import 'nyxx_websocket.mock.dart';

class MessageMock extends SnowflakeEntity with Fake implements IMessage {
  @override
  final String content;

  @override
  INyxx get client => NyxxWebsocketMock();

  MessageMock(this.content): super(Snowflake.fromNow());
}
