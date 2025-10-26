// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:subscriptions_app/core/theme/color.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   int _notificationHour = 21; // 9 PM
//   int _notificationMinute = 12; // 12 minutes
//   TimeOfDay? _selectedTime;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotificationSettings();
//   }

//   Future<void> _loadNotificationSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _notificationHour = prefs.getInt('notification_hour') ?? 21;
//       _notificationMinute = prefs.getInt('notification_minute') ?? 12;
//       _selectedTime = TimeOfDay(hour: _notificationHour, minute: _notificationMinute);
//     });
//   }

//   Future<void> _selectTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(
//             context,
//           ).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: ColorsManager.kPrimaryColor)),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedTime = picked;
//         _notificationHour = picked.hour;
//         _notificationMinute = picked.minute;
//       });
//     }
//   }

//   Future<void> _saveSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('notification_hour', _notificationHour);
//     await prefs.setInt('notification_minute', _notificationMinute);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('تم حفظ إعدادات وقت التذكيرات: ${_formatTime(_notificationHour, _notificationMinute)}'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   String _formatTime(int hour, int minute) {
//     final period = hour >= 12 ? 'مساءً' : 'صباحاً';
//     final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//     return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إعدادات التذكيرات'),
//         backgroundColor: ColorsManager.kPrimaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       '⏰ وقت التذكيرات',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorsManager.kPrimaryColor),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'اختر الوقت الذي تريد أن تظهر فيه التذكيرات',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     ListTile(
//                       leading: const Icon(Icons.access_time, color: ColorsManager.kPrimaryColor),
//                       title: const Text('وقت التذكيرات'),
//                       subtitle: Text(_formatTime(_notificationHour, _notificationMinute)),
//                       trailing: const Icon(Icons.arrow_forward_ios),
//                       onTap: _selectTime,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       '📅 معلومات التذكيرات',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorsManager.kPrimaryColor),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text('سيتم إرسال 3 تذكيرات لكل اشتراك:', style: TextStyle(fontSize: 14, color: Colors.grey)),
//                     const SizedBox(height: 12),
//                     _buildReminderInfo('1️⃣', 'تذكير مبكر', 'قبل الموعد حسب إعداداتك'),
//                     _buildReminderInfo('2️⃣', 'تذكير أخير', 'يوم واحد قبل الموعد'),
//                     _buildReminderInfo('3️⃣', 'تذكير نهائي', 'في يوم الموعد نفسه'),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _saveSettings,
//                 icon: const Icon(Icons.save),
//                 label: const Text('حفظ الإعدادات'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ColorsManager.kPrimaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReminderInfo(String emoji, String title, String description) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(emoji, style: const TextStyle(fontSize: 16)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//                 Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
