import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

class NyxxWebsocketMock extends Fake implements INyxxWebsocket {
  @override
  Snowflake get appId => Snowflake(123);
}
