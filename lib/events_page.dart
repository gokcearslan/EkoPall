import 'package:flutter/material.dart';
import 'package:ekopal/services/event_model.dart';
import 'package:ekopal/services/firebase_service.dart';
import 'package:ekopal/detailed_event_page.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event>? events;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  fetchEvents() async {
    events = await EventService().getEvents();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the Theme to get the color scheme and text themes that align with Material 3
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Etkinlikler'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: events == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events!.length,
        itemBuilder: (context, index) {
          return buildEventCard(events![index]);
        },
      ),
    );
  }

  Widget buildEventCard(Event event) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column for the Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://i.pinimg.com/564x/12/ad/fa/12adfa1035792c44248d3eab35212c91.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.eventName,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.location,
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  // Date Information
                  Text(
                    event.eventDate, // Date information
                    style: theme.textTheme.bodyText2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          event.isFavorite ? Icons.star : Icons.star_border,
                          color: event.isFavorite ? Colors.amber : colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            event.isFavorite = !event.isFavorite;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedEventPage(event: event),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }












}
