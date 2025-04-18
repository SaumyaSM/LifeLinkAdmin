import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/events_model.dart';
import 'package:life_link_admin/screens/events/create_event.dart';
import 'package:life_link_admin/services/event_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/card_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/no_data_widget.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<EventModel> list = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() => isLoading = true);

    await EventService.getEventsList().then((value) {
      setState(() => list = value);
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(
              builder:
                  (context) => ButtonWidget(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    title: 'Create Event',
                  ),
            ),
          ],
        ),
        actions: <Widget>[Container()],
      ),
      body: buildBody(),
      endDrawer: CreateEvents(context: context, getData: () => getData()),
    );
  }

  Widget buildBody() {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child:
          isLoading
              ? const SizedBox()
              : list.length > 0
              ? ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _eventCard(list[index]);
                },
              )
              : NoDataWidget(),
    );
  }

  Widget _eventCard(EventModel model) {
    return CardWidget(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(model.description),
                    Text(model.date),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonWidget(
                    onTap: () => deleteEvent(model),
                    title: 'Delete Event',
                    color: kProfileIcon,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteEvent(EventModel model) {
    showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                  child: Text('Do you want to delete event?'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => isLoading = true);
                          await EventService.deleteEvent(model.id)
                              .then((value) {
                                getData();
                                ToastService.displaySuccessMotionToast(
                                  context: context,
                                  description: 'Deleted!',
                                );
                              })
                              .catchError((error) {
                                ToastService.displayErrorMotionToast(
                                  context: context,
                                  description: 'Something went wrong!',
                                );
                              });
                        },
                        child: const Text('YES'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('NO'),
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
