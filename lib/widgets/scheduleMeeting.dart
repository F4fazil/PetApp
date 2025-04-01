import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Database/database.dart';

class ScheduleMeeting {
  static void show(BuildContext context, String vetUid, String vetName,
      String userUid, String userName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _ScheduleMeetingBottomSheet(
          vetUid: vetUid,
          vetName: vetName,
          userUid: userUid,
          userName: userName,
        );
      },
      backgroundColor: Colors.white,
    );
  }
}

class _ScheduleMeetingBottomSheet extends StatefulWidget {
  final String vetUid;
  final String vetName;
  final String userUid;
  final String userName;

  const _ScheduleMeetingBottomSheet({
    required this.vetUid,
    required this.vetName,
    required this.userUid,
    required this.userName,
  });

  @override
  _ScheduleMeetingBottomSheetState createState() =>
      _ScheduleMeetingBottomSheetState();
}

class _ScheduleMeetingBottomSheetState
    extends State<_ScheduleMeetingBottomSheet> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _confirmSchedule() {
    if (selectedDate != null && selectedTime != null) {
      Navigator.pop(context);
      DataBaseStorage().scheduleMeeting(
        widget.userUid,
        widget.vetUid,
        widget.vetName,
        widget.userName,
        selectedDate!,
        selectedTime!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meeting with ${widget.vetName} scheduled on ${DateFormat('yyyy-MM-dd').format(selectedDate!)} at ${selectedTime!.format(context)} successfully!',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Schedule Meeting with ${widget.vetName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                    : 'Select Date',
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 41, 116, 112)),
              ),
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Pick Date',
                    style: TextStyle(color: Color.fromARGB(255, 41, 116, 112))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTime != null
                    ? 'Time: ${selectedTime!.format(context)}'
                    : 'Select Time',
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 41, 116, 112)),
              ),
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Pick Time',
                    style: TextStyle(color: Color.fromARGB(255, 41, 116, 112))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _confirmSchedule,
            child: const Text('Confirm Schedule',
                style: TextStyle(color: Color.fromARGB(255, 41, 116, 112))),
          ),
        ],
      ),
    );
  }
}
