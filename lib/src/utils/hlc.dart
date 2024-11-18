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

Hlc hlcFromJson(Object obj) {
  if (obj is Hlc) return obj;
  if (obj is String) return Hlc.parse(obj);
  throw ArgumentError.value(obj, 'obj', 'Expected Hlc or String');
}
