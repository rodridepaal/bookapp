import 'package:hive/hive.dart';
part 'saved_book_model.g.dart';

@HiveType(typeId: 1)
class SavedBook extends HiveObject {

  @HiveField(0)
  final String bookId;

  @HiveField(1)
  final String status;

  @HiveField(2)
  final DateTime? finishedTimestamp;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String authors;

  @HiveField(5)
  final String thumbnailLink;

  SavedBook({
    required this.bookId,
    required this.status,
    this.finishedTimestamp,
    required this.title,
    required this.authors,
    required this.thumbnailLink,
  });
}