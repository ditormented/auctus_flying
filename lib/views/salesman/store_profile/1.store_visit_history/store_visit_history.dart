import 'package:auctus_call/utilities/colors.dart';
import 'package:auctus_call/views/salesman/store_profile/1.store_visit_history/call_document_object.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

class StoreVisitHistory extends StatefulWidget {
  final List<CallDocumentObject> listCall;
  final String userID;
  const StoreVisitHistory(
      {super.key, required this.listCall, required this.userID});

  @override
  _StoreVisitHistoryState createState() => _StoreVisitHistoryState();
}

class _StoreVisitHistoryState extends State<StoreVisitHistory> {
  @override
  Widget build(BuildContext context) {
    List<CallDocumentObject> listCall =
        List<CallDocumentObject>.from(widget.listCall.reversed);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visit History',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: mainColor,
      ),
      body: ListView.builder(
        itemCount: listCall.length,
        itemBuilder: (context, index) {
          return timelineTile(
            context,
            documentID: listCall[index].documentID,
            time: listCall[index].dateTime,
            title: listCall[index].dateTime,
            description: widget.listCall[index].callResult,
            imageUrl: listCall[index].imageUrl,
            isFirst: index == 0,
            isLast: index == widget.listCall.length - 1,
          );
        },
      ),
    );
  }

  TimelineTile timelineTile(BuildContext context,
      {required DateTime time,
      required String documentID,
      required DateTime title,
      required String description,
      required String imageUrl,
      bool isFirst = false,
      bool isLast = false}) {
    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateFormat dateFormat = DateFormat('EEE, dd MMM yyyy');
    String formattedTime = timeFormat.format(time);
    String formattedDate = dateFormat.format(title);

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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 50.0,
                width: 50.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 50.0,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentID,
                  // formattedTime,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      beforeLineStyle: LineStyle(
        color: Colors.grey,
        thickness: 2,
      ),
    );
  }
}
