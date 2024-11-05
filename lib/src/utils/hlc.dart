import 'package:crdt/crdt.dart';
import 'package:drift/drift.dart';

class HlcConverter extends TypeConverter<Hlc, String>
    with JsonTypeConverter<Hlc, String> {
  const HlcConverter();

  @override
  Hlc fromSql(String fromDb) {
    return Hlc.parse(fromDb);
  }

  @override
  String toSql(Hlc value) {
    return value.toString();
  }
}
