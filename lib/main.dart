// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  // تأكد من تهيئة Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // تعيين اتجاه الشاشة (اختياري)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // تهيئة الخدمات الأساسية
  try {
    await StorageService().initialize();
    print('✅ تم تهيئة خدمة التخزين');
    
    await NotificationService().initialize();
    print('✅ تم تهيئة خدمة الإشعارات');
    
  } catch (e) {
    print('❌ خطأ في تهيئة الخدمات: $e');
  }
  
  // تشغيل التطبيق
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced VirusTotal Scanner',
      
      // إعدادات اللغة والاتجاه
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'), // العربية
        Locale('en', 'US'), // الإنجليزية
      ],
      
      // الثيمات
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // الشاشة الرئيسية
      home: HomeScreen(),
      
      // إخفاء شريط Debug
      debugShowCheckedModeBanner: false,
      
      // معالج الأخطاء العام
      builder: (context, child) {
        // معالجة الأخطاء في الواجهة
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Container(
            color: Colors.red,
            child: Center(
              child: Text(
                'حدث خطأ في التطبيق\n${errorDetails.exception}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        };
        
        return child ?? Container();
      },
    );
  }
}
