import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';

class UserMock extends SnowflakeEntity with Fake implements IUser {
  UserMock(): super(Snowflake.fromNow());
}
