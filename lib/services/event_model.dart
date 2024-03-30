class Event {
  final String eventName;
  final String eventDate;
  final String organizer;
  final String location;
  final String additionalInfo;
  bool isFavorite;

  Event({
    required this.eventName,
    required this.eventDate,
    required this.organizer,
    required this.location,
    required this.additionalInfo,
    this.isFavorite = false,
  });
}
