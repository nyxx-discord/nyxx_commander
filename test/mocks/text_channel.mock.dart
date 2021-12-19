import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

class TextChannelMock extends SnowflakeEntity with Fake implements ITextChannel {
  TextChannelMock(): super(Snowflake.fromNow());
}
