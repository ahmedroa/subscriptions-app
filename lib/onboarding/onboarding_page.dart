import 'package:flutter/material.dart';
import 'package:subscriptions_app/core/theme/color.dart';
import 'package:subscriptions_app/home/ui/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'مرحباً بك في اشتراكاتي',
      description: 'تطبيق ذكي لإدارة جميع اشتراكاتك الشهرية وعدم نسيان مواعيد الدفع',
      icon: Icons.subscriptions,
      color: const Color(0xFF6366F1),
    ),
    OnboardingData(
      title: 'تذكيرات ذكية',
      description: 'احصل على تذكيرات قبل موعد الدفع بأيام لتجنب التأخير والرسوم الإضافية',
      icon: Icons.notifications_active,
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: 'إدارة سهلة',
      description: 'أضف، عدّل، أو احذف اشتراكاتك بسهولة مع واجهة بسيطة وسريعة',
      icon: Icons.manage_accounts,
      color: const Color(0xFFF59E0B),
    ),
    OnboardingData(
      title: 'تقارير مفصلة',
      description: 'اعرف إجمالي مصروفاتك الشهرية وتتبع نمط إنفاقك على الاشتراكات',
      icon: Icons.analytics,
      color: const Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _navigateToHome(),
                  child: const Text('تخطي', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingData.length, (index) => _buildPageIndicator(index)),
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('السابق', style: TextStyle(color: Colors.white70)),
                          ),
                        ),

                      if (_currentPage > 0) const SizedBox(width: 16),

                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage == _onboardingData.length - 1) {
                                _navigateToHome();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _currentPage == _onboardingData.length - 1 ? 'ابدأ الآن' : 'التالي',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
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

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: data.color.withOpacity(0.3), width: 2),
            ),
            child: Icon(data.icon, size: 60, color: data.color),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            data.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF6366F1) : Colors.white30,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToHome() async {
    try {
      // حفظ حالة Onboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);

      // التأكد من أن الحفظ تم بنجاح
      final saved = prefs.getBool('has_seen_onboarding') ?? false;
      print('Onboarding status saved: $saved');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      print('Error saving onboarding status: $e');
      // في حالة الخطأ، انتقل للصفحة الرئيسية مباشرة
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({required this.title, required this.description, required this.icon, required this.color});
}
