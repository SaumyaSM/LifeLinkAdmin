import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/events_model.dart';
import 'package:life_link_admin/services/event_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/text_input_widget.dart';
import 'package:life_link_admin/widgets/title_text.dart';

class CreateEvents extends StatefulWidget {
  BuildContext context;
  Function() getData;
  CreateEvents({super.key, required this.context, required this.getData});

  @override
  State<CreateEvents> createState() => _CreateEventsState();
}

class _CreateEventsState extends State<CreateEvents> {
  bool isLoading = false;
  TextEditingController titleTEC = TextEditingController();
  TextEditingController descriptionTEC = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child: SizedBox(
        width: 800,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(50),
            children: [
              TitleText(text: 'Create Admin'),
              const SizedBox(height: 50),
              TextInputWidget(
                controller: titleTEC,
                title: 'Title',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              TextInputWidget(
                controller: descriptionTEC,
                title: 'Description',
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Date: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 52),
                  ButtonWidget(
                    onTap: () => _selectDate(context),
                    title: 'Change Date',
                    color: kPeachColor,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ButtonWidget(onTap: () => createAdmin(), title: 'SUBMIT'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  createAdmin() async {
    if (titleTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(context: context, description: 'Title is Missing!');
      return;
    }

    if (descriptionTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Description is Missing!',
      );
      return;
    }

    setState(() => isLoading = true);

    EventModel model = EventModel(
      id: DateTime.now().toString(),
      date: '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
      description: descriptionTEC.text.trim(),
      title: titleTEC.text.trim(),
    );

    await EventService.createEvent(model)
        .then((value) {
          ToastService.displaySuccessMotionToast(context: context, description: 'Event Created!');
          Scaffold.of(context).closeEndDrawer();
          setState(() => isLoading = false);
          widget.getData();
        })
        .catchError((error) {
          ToastService.displayErrorMotionToast(
            context: context,
            description: 'Something went wrong!',
          );
          setState(() => isLoading = false);
        });
  }
}
