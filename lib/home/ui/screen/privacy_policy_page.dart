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
          'سياسة الخصوصية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorsManager.containerColorDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سياسة الخصوصية',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تطبيق ذكّرني - Zakerni App',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('آخر تحديث:', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(
                        '26 أكتوبر 2024',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // جمع البيانات
            _buildSectionNumber(1),
            _buildSectionTitle('جمع البيانات'),
            _buildParagraph(
              'تطبيق "ذكّرني" لا يجمع أي بيانات شخصية. جميع البيانات المدخلة في التطبيق (أسماء الاشتراكات، المبالغ، التواريخ، الملاحظات) تُحفظ محلياً على جهاز المستخدم فقط ولا يتم إرسالها لأي خوادم خارجية.',
            ),

            const SizedBox(height: 32),

            // التخزين
            _buildSectionNumber(2),
            _buildSectionTitle('التخزين والأمان'),
            _buildParagraph(
              'جميع البيانات تُخزن على الجهاز فقط باستخدام التخزين المحلي. لا يتم نقل أو مشاركة هذه البيانات مع أي طرف ثالث. التطبيق يعمل بشكل كامل دون اتصال بالإنترنت.',
            ),

            const SizedBox(height: 32),

            // الأذونات
            _buildSectionNumber(3),
            _buildSectionTitle('الأذونات'),
            _buildParagraph(
              'التطبيق يطلب أذونات الإشعارات فقط لإرسال تذكيرات بمواعيد الدفع. لا يتم طلب أي أذونات أخرى مثل الموقع، الكاميرا، أو جهات الاتصال.',
            ),

            const SizedBox(height: 32),

            // الخدمات الخارجية
            _buildSectionNumber(4),
            _buildSectionTitle('الخدمات الخارجية'),
            _buildParagraph(
              'التطبيق لا يستخدم أي خدمات تحليلات (Analytics)، إعلانات، أو خدمات سحابية خارجية. لا يتم جمع أو مشاركة أي بيانات مع أطراف ثالثة.',
            ),

            const SizedBox(height: 32),

            // حذف البيانات
            _buildSectionNumber(5),
            _buildSectionTitle('حذف البيانات'),
            _buildParagraph(
              'يمكن للمستخدم حذف جميع بياناته في أي وقت من خلال حذف التطبيق من الجهاز. عند حذف التطبيق، يتم حذف جميع البيانات نهائياً.',
            ),

            const SizedBox(height: 32),

            // التغييرات
            _buildSectionNumber(6),
            _buildSectionTitle('تحديثات السياسة'),
            _buildParagraph('قد يتم تحديث هذه السياسة من وقت لآخر. يُنصح بمراجعة هذه الصفحة بشكل دوري.'),

            const SizedBox(height: 32),

            // الاتصال
            _buildSectionNumber(7),
            _buildSectionTitle('الاتصال'),
            _buildParagraph('للاستفسارات حول سياسة الخصوصية:'),
            Container(
              margin: const EdgeInsets.only(top: 12, left: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorsManager.containerColorDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('البريد الإلكتروني:', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '[بريدك الإلكتروني]',
                    style: const TextStyle(color: Color(0xFF6366F1), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionNumber(int number) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
