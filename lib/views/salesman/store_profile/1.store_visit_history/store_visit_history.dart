import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/store_profile/store_object.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class StoreVisitHistory extends StatefulWidget {
  final StoreObject storeObject;
  final String userID;
  const StoreVisitHistory(
      {super.key, required this.storeObject, required this.userID});

  @override
  _StoreVisitHistoryState createState() => _StoreVisitHistoryState();
}

class _StoreVisitHistoryState extends State<StoreVisitHistory> {
  List<TimelineEvent> events = [
    TimelineEvent(
        time: '9 - 11am', title: 'Finish Home Screen', description: 'Web App'),
    TimelineEvent(time: '12pm', title: 'Lunch Break', description: 'Main Room'),
    TimelineEvent(
        time: '3 - 4pm', title: 'Design Stand Up', description: 'Hangouts'),
    TimelineEvent(time: '5pm', title: 'New Icon', description: 'Mobile App'),
  ];

  void addEvent() {
    setState(() {
      events.add(TimelineEvent(
        time: '6pm',
        title: 'New Event',
        description: 'New Description',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visit History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return timelineTile(
            context,
            time: events[index].time,
            title: events[index].title,
            description: events[index].description,
            isFirst: index == 0,
            isLast: index == events.length - 1,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addEvent,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }

  TimelineTile timelineTile(BuildContext context,
      {required String time,
      required String title,
      required String description,
      bool isFirst = false,
      bool isLast = false}) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: isFirst || isLast ? Colors.purple : Colors.teal,
        padding: EdgeInsets.all(6),
      ),
      endChild: Container(
        constraints: BoxConstraints(minHeight: 80),
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.grey,
        thickness: 6,
      ),
    );
  }
}

class TimelineEvent {
  final String time;
  final String title;
  final String description;

  TimelineEvent(
      {required this.time, required this.title, required this.description});
}
