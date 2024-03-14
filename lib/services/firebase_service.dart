import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekopal/services/event_model.dart';

import 'announcement_model.dart'; // Adjust the import path as needed

class EventService {
  final CollectionReference events =
  FirebaseFirestore.instance.collection('events');

  Future<void> addEvent(Event event) {
    return events
        .add({
      'eventName': event.eventName,
      'eventDate': event.eventDate,
      'organizer': event.organizer,
      'location': event.location,
      'additionalInfo': event.additionalInfo,
    })
        .then((value) => print('Event added to Firestore'))
        .catchError((error) => print('Failed to add event: $error'));
  }
}

class AnnouncementService {
  final CollectionReference announcements =
  FirebaseFirestore.instance.collection('announcements');

  Future<void> addAnnouncement(Announcement announcement) {
    return announcements
        .add({
      'announcementName': announcement.announcementName,
      'announcementType': announcement.announcementType,
      'announcementDetails': announcement.announcementDetails,
    })
        .then((value) => print('Announcement added to Firestore'))
        .catchError((error) => print('Failed to add announcement: $error'));
  }
}
