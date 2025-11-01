import 'package:flutter/material.dart';
import 'package:subscriptions_app/core/theme/color.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // جمع البيانات
            _buildSectionTitle('Data Collection'),
            _buildParagraph(
              'The "Ashtrakati" app does not collect any personal data. All data entered in the app (subscription names, amounts, dates, notes) is stored locally on the user\'s device only and is not sent to any external servers.',
            ),

            const SizedBox(height: 32),

            // التخزين
            _buildSectionTitle('Storage and Security'),
            _buildParagraph(
              'All data is stored on the device only using local storage. This data is not transferred or shared with any third party. The app works completely offline without an internet connection.',
            ),

            const SizedBox(height: 32),

            // الأذونات
            _buildSectionTitle('Permissions'),
            _buildParagraph(
              'The app only requests notification permissions to send payment date reminders. No other permissions such as location, camera, or contacts are requested.',
            ),

            const SizedBox(height: 32),

            // الخدمات الخارجية
            _buildSectionTitle('External Services'),
            _buildParagraph(
              'The app does not use any analytics services, advertisements, or external cloud services. No data is collected or shared with third parties.',
            ),

            const SizedBox(height: 32),

            // حذف البيانات
            _buildSectionTitle('Data Deletion'),
            _buildParagraph(
              'Users can delete all their data at any time by uninstalling the app from their device. When the app is deleted, all data is permanently removed.',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Policy Updates'),
            _buildParagraph(
              'This policy may be updated from time to time. We recommend reviewing this page periodically.',
            ),

            const SizedBox(height: 32),

       
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.8),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
