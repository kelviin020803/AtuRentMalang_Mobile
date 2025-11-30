import 'package:hive/hive.dart';

part 'search_history.g.dart';

@HiveType(typeId: 0)
class SearchHistory extends HiveObject {
  @HiveField(0)
  String searchTerm;

  @HiveField(1)
  DateTime timestamp;

  SearchHistory({
    required this.searchTerm,
    required this.timestamp,
  });
}
