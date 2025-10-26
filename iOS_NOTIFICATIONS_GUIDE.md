# 🍎 دليل إعدادات الإشعارات لـ iOS

## ✅ الإعدادات المطبقة:

### 1. **Info.plist:**
```xml
<!-- صلاحيات الإشعارات -->
<key>NSUserNotificationsUsageDescription</key>
<string>هذا التطبيق يحتاج إلى الإشعارات لتذكيرك بمواعيد الاشتراكات</string>

<key>NSLocalNotificationsUsageDescription</key>
<string>هذا التطبيق يحتاج إلى الإشعارات المحلية لتذكيرك بمواعيد الاشتراكات</string>

<!-- خلفيات التطبيق -->
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>remote-notification</string>
    <string>background-fetch</string>
</array>
```

### 2. **AppDelegate.swift:**
```swift
import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // إعداد UNUserNotificationCenter delegate
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    // طلب صلاحيات الإشعارات
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
          print("✅ iOS notification permissions granted")
        } else {
          print("❌ iOS notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. **Flutter Code:**
```dart
const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
  requestCriticalPermission: false,
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);
```

## 🧪 طرق الاختبار:

### 1. **اختبار iOS:**
- اضغط على زر 📱 (phone_iphone) في الشريط العلوي
- يجب أن تظهر إشعار تجريبي

### 2. **اختبار التذكيرات المجدولة:**
- اضغط على زر ⏰ (schedule) في الشريط العلوي
- أغلق التطبيق
- انتظر حتى الساعة 9:00 مساءً

### 3. **اختبار إضافة اشتراك:**
- أضف اشتراك جديد
- أغلق التطبيق
- انتظر حتى وقت التذكير

## ⚠️ أسباب محتملة لعدم ظهور الإشعارات:

### 1. **إعدادات الجهاز:**
- **Settings > Notifications > ذكّرني** - تأكد من التفعيل
- **Settings > General > Background App Refresh** - تأكد من التفعيل
- **Settings > Do Not Disturb** - تأكد من عدم التفعيل

### 2. **إعدادات التطبيق:**
- الإشعارات معطلة للتطبيق
- التطبيق محذوف من الذاكرة

### 3. **مشاكل في النظام:**
- إصدار قديم من iOS (يحتاج iOS 10.0+)
- مشكلة في المكتبة

## 🔧 خطوات إضافية لحل المشاكل:

### 1. **تنظيف وإعادة بناء:**
```bash
flutter clean
cd ios && pod install && cd ..
flutter run
```

### 2. **فحص إعدادات Xcode:**
- تأكد من `IPHONEOS_DEPLOYMENT_TARGET = 13.0`
- تأكد من تفعيل `Background Modes`

### 3. **فحص إعدادات الجهاز:**
- تأكد من تفعيل الإشعارات
- تأكد من تفعيل Background App Refresh
- تأكد من عدم وجود "Do Not Disturb"

## 📱 اختبار على أجهزة مختلفة:

### iPhone:
- تأكد من iOS 10.0+
- تأكد من تفعيل الإشعارات
- تأكد من تفعيل Background App Refresh

### iPad:
- نفس متطلبات iPhone
- تأكد من إعدادات الإشعارات

## 🎯 النتائج المتوقعة:

بعد تطبيق جميع الإعدادات، يجب أن تعمل الإشعارات:
- ✅ مع التطبيق مفتوح
- ✅ مع التطبيق مغلق
- ✅ مع الجهاز مغلق
- ✅ بعد إعادة تشغيل الجهاز

## 📞 إذا استمرت المشكلة:

1. تحقق من رسائل Console في Xcode
2. جرب على جهاز مختلف
3. تأكد من إعدادات الجهاز
4. جرب إعادة تشغيل التطبيق
