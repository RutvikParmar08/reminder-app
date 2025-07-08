// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:reminderapp/LocalNotifications.dart';
//
// class SetTimerPage extends StatefulWidget {
//   const SetTimerPage({super.key});
//
//   @override
//   State<SetTimerPage> createState() => _SetTimerPageState();
// }
//
// class _SetTimerPageState extends State<SetTimerPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();
//   TimeOfDay? _selectedTime;
//
//   // Show dialog if exact alarms are not permitted
//   Future<void> _checkAndShowDialog() async {
//     if (await Permission.scheduleExactAlarm.isDenied) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Exact Alarms Not Permitted'),
//           content: const Text(
//               'To ensure precise notification timing, please allow exact alarms in settings.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await openAppSettings();
//               },
//               child: const Text('Open Settings'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   // Pick time for daily alarm
//   Future<void> _pickTime() async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (pickedTime != null && mounted) {
//       setState(() {
//         _selectedTime = pickedTime;
//       });
//     }
//   }
//
//   // Schedule the daily alarm
//   Future<void> _scheduleDailyAlarm() async {
//     if (_formKey.currentState!.validate() && _selectedTime != null) {
//       await _checkAndShowDialog();
//       final notificationId = await LocalNotifications.showDailyNotificationAtTime(
//         title: _titleController.text,
//         body: _bodyController.text,
//         payload: 'daily_alarm_data',
//         time: _selectedTime!,
//         context: context,
//       );
//       if (mounted) {
//         if (notificationId != -1) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   'Daily alarm scheduled at ${_selectedTime!.format(context)} (ID: $notificationId)'),
//             ),
//           );
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to schedule daily alarm')),
//           );
//         }
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields and select a time')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set Daily Alarm'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Alarm Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _bodyController,
//                 decoration: const InputDecoration(
//                   labelText: 'Alarm Body',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a body';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.access_time),
//                 label: Text(
//                   _selectedTime == null
//                       ? 'Pick Time'
//                       : 'Time: ${_selectedTime!.format(context)}',
//                 ),
//                 onPressed: _pickTime,
//               ),
//               const SizedBox(height: 24),
//               Center(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.alarm),
//                   label: const Text('Set Daily Alarm'),
//                   onPressed: _scheduleDailyAlarm,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:reminderapp/LocalNotifications.dart';
//
// class SetTimerPage extends StatefulWidget {
//   const SetTimerPage({super.key});
//
//   @override
//   State<SetTimerPage> createState() => _SetTimerPageState();
// }
//
// class _SetTimerPageState extends State<SetTimerPage> with TickerProviderStateMixin {
//   final _bodyController = TextEditingController();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }
//
//   // Show dialog if exact alarms are not permitted
//   Future<void> _checkAndShowDialog() async {
//     if (await Permission.scheduleExactAlarm.isDenied) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Row(
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
//               const SizedBox(width: 12),
//               const Text('Permission Required'),
//             ],
//           ),
//           content: const Text(
//             'To ensure precise notification timing, please allow exact alarms in settings.',
//             style: TextStyle(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Later', style: TextStyle(color: Colors.grey[600])),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await openAppSettings();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               child: const Text('Open Settings'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   // Pick time for daily alarm
//   Future<void> _pickTime() async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             timePickerTheme: TimePickerThemeData(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (pickedTime != null && mounted) {
//       setState(() {
//         _selectedTime = pickedTime;
//       });
//     }
//   }
//
//   // Add alarm with time picker and scheduling
//   Future<void> _addAlarm() async {
//     // First pick time
//     await _pickTime();
//
//     // Then schedule if user picked a time
//     if (mounted) {
//       await _checkAndShowDialog();
//
//       String alarmBody = _bodyController.text.trim();
//       if (alarmBody.isEmpty) {
//         alarmBody = 'Daily Reminder'; // Default body if empty
//       }
//
//       final notificationId = await LocalNotifications.showDailyNotificationAtTime(
//         title: 'ReminderApp', // Always use app name as title
//         body: alarmBody,
//         payload: 'daily_alarm_data',
//         time: _selectedTime,
//         context: context,
//       );
//
//       if (mounted) {
//         if (notificationId != -1) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   const Icon(Icons.check_circle, color: Colors.white),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Alarm set for ${_selectedTime.format(context)} daily',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//               backgroundColor: Colors.green,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               duration: const Duration(seconds: 3),
//             ),
//           );
//           _bodyController.clear();
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   const Icon(Icons.error, color: Colors.white),
//                   const SizedBox(width: 8),
//                   const Text('Failed to set alarm', style: TextStyle(fontSize: 16)),
//                 ],
//               ),
//               backgroundColor: Colors.red,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           );
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black87,
//         title: const Text(
//           'ReminderApp',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               // App logo/icon section
//               ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue[400]!, Colors.blue[600]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(30),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.alarm,
//                     size: 64,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Alarm message input
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _bodyController,
//                   maxLines: 5,
//                   decoration: InputDecoration(
//                     hintText: 'What would you like to be reminded about?',
//                     hintStyle: TextStyle(
//                       color: Colors.grey[400],
//                       fontSize: 16,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.all(20),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Icon(
//                         Icons.edit_note,
//                         color: Colors.blue[400],
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//
//               const Spacer(),
//
//               // Add Alarm Button
//               ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Container(
//                   width: double.infinity,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue[400]!, Colors.blue[600]!],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: _addAlarm,
//                       child: const Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add_alarm,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                             SizedBox(width: 12),
//                             Text(
//                               'Add Daily Alarm',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Helper text
//               Text(
//                 'Tap the button to select time and create your daily reminder',
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reminderapp/LocalNotifications.dart';
import 'dart:math';

class SetTimerPage extends StatefulWidget {
  const SetTimerPage({super.key});

  @override
  State<SetTimerPage> createState() => _SetTimerPageState();
}

class _SetTimerPageState extends State<SetTimerPage> with TickerProviderStateMixin {
  final _bodyController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> notificationMessages = [
    'Ready to solve some puzzles? 🧠✨',
    'Math magic is just a tap away! 🔢🪄',
    'Let’s play with numbers today! 🎲➗',
    'Challenge yourself – try a new level! 🚀',
    'It’s a great day for a math duel! ⚔️',
    'Sharpen your mind with a quick sum! ➕',
    'Numbers are fun, let’s go! 🎉',
    'Break time? Or game time? You choose! ⏱️🎮',
    'Try a word problem and be a math wizard! 📚🧙‍♂️',
    'Stretch your brain – go solve something cool! 🧩💥',
  ];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowDialog() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text('Permission Required'),
            ],
          ),
          content: const Text(
            'To ensure precise notification timing, please allow exact alarms in settings.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Later', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _addAlarm() async {
    await _pickTime();

    if (mounted) {
      await _checkAndShowDialog();

      String alarmBody = _bodyController.text.trim();
      if (alarmBody.isEmpty) {
        alarmBody = (notificationMessages..shuffle()).first;
      }

      final notificationId = await LocalNotifications.showDailyNotificationAtTime(
        title: 'ReminderApp',
        body: alarmBody,
        payload: 'daily_alarm_data',
        time: _selectedTime,
        context: context,
      );

      if (mounted) {
        if (notificationId != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alarm set for ${_selectedTime.format(context)} daily',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
          _bodyController.clear();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Failed to set alarm', style: TextStyle(fontSize: 16)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          'ReminderApp',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _bodyController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'What would you like to be reminded about?',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.edit_note,
                        color: Colors.blue[400],
                        size: 24,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _addAlarm,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_alarm,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Add Daily Alarm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tap the button to select time and create your daily reminder',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
