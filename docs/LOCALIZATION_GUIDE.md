# Localization Guide for eCar Garage Application

This guide outlines the implementation of multilingual support in the eCar Garage Management Application for the Tunisian market.

## Supported Languages

The application supports the following languages:
- Arabic (العربية) - Primary language
- French (Français) - Widely used in Tunisian business contexts
- Tunisian Dialect (الدارجة التونسية) - Local dialect for improved user experience

## Implementation in Flutter (Mobile and Admin Web)

### Setup

The Flutter application uses the `flutter_localizations` and `intl` packages for localization:

1. **Dependencies in pubspec.yaml**:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_localizations:
       sdk: flutter
     intl: ^0.17.0
   ```

2. **Localization Delegates in main.dart**:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_localizations/flutter_localizations.dart';
   import 'l10n/app_localizations.dart';

   void main() {
     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         // Localization delegates
         localizationsDelegates: [
           AppLocalizations.delegate,
           GlobalMaterialLocalizations.delegate,
           GlobalWidgetsLocalizations.delegate,
           GlobalCupertinoLocalizations.delegate,
         ],
         // Supported locales
         supportedLocales: [
           const Locale('ar', ''), // Arabic
           const Locale('fr', ''), // French
           const Locale('ar', 'TN'), // Tunisian Dialect (specialized Arabic)
         ],
         // Locale resolution
         localeResolutionCallback: (locale, supportedLocales) {
           // Check if the device locale is supported
           for (var supportedLocale in supportedLocales) {
             if (supportedLocale.languageCode == locale?.languageCode &&
                 supportedLocale.countryCode == locale?.countryCode) {
               return supportedLocale;
             }
           }
           // Default to Arabic if the locale isn't supported
           return supportedLocales.first;
         },
         home: HomeScreen(),
       );
     }
   }
   ```

### Translation Files

Translations are stored in ARB (Application Resource Bundle) files, located in `lib/l10n/`:

1. **app_ar.arb** (Arabic):
   ```json
   {
     "appTitle": "تطبيق إدارة ورشة السيارات",
     "loginTitle": "تسجيل الدخول",
     "username": "اسم المستخدم",
     "password": "كلمة المرور",
     "vehicleDetails": "تفاصيل السيارة",
     "repairHistory": "سجل الإصلاح",
     "invoices": "الفواتير",
     "profile": "الملف الشخصي",
     "mileage": "عدد الكيلومترات",
     "logout": "تسجيل الخروج"
   }
   ```

2. **app_fr.arb** (French):
   ```json
   {
     "appTitle": "Application de Gestion de Garage",
     "loginTitle": "Connexion",
     "username": "Nom d'utilisateur",
     "password": "Mot de passe",
     "vehicleDetails": "Détails du Véhicule",
     "repairHistory": "Historique des Réparations",
     "invoices": "Factures",
     "profile": "Profil",
     "mileage": "Kilométrage",
     "logout": "Déconnexion"
   }
   ```

3. **app_ar_TN.arb** (Tunisian Dialect):
   ```json
   {
     "appTitle": "تطبيق إدارة حانوت الكرهبة",
     "loginTitle": "دخّل",
     "username": "آسم المستعمل",
     "password": "كلمة السر",
     "vehicleDetails": "تفاصيل الكرهبة",
     "repairHistory": "تاريخ الصلاح",
     "invoices": "الفكتورات",
     "profile": "بروفيل",
     "mileage": "الكيلومتراج",
     "logout": "أخرج"
   }
   ```

### Usage in Code

To use translations in Flutter widgets:

```dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.loginTitle),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: localizations.username,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: localizations.password,
            ),
            obscureText: true,
          ),
          // Other widgets
        ],
      ),
    );
  }
}
```

### Language Switcher

A language switcher component allows users to change the application language:

```dart
class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Localizations.localeOf(context),
      items: [
        DropdownMenuItem(
          value: const Locale('ar', ''),
          child: Text('العربية'),
        ),
        DropdownMenuItem(
          value: const Locale('fr', ''),
          child: Text('Français'),
        ),
        DropdownMenuItem(
          value: const Locale('ar', 'TN'),
          child: Text('تونسي'),
        ),
      ],
      onChanged: (Locale? locale) {
        if (locale != null) {
          // Update the app locale
          final provider = Provider.of<LocaleProvider>(context, listen: false);
          provider.setLocale(locale);
        }
      },
    );
  }
}
```

## Backend Localization (Rails)

The Rails backend supports localization for API responses:

1. **Locale Files in config/locales/**:
   - `ar.yml` for Arabic
   - `fr.yml` for French
   - `ar-TN.yml` for Tunisian dialect

2. **Example of ar.yml**:
   ```yaml
   ar:
     activerecord:
       models:
         vehicle: "سيارة"
         repair: "إصلاح"
         invoice: "فاتورة"
       attributes:
         vehicle:
           brand: "الماركة"
           model: "الطراز"
           year: "سنة الصنع"
           license_plate: "رقم اللوحة"
     errors:
       messages:
         blank: "لا يمكن أن يكون فارغا"
         invalid: "غير صالح"
     api:
       messages:
         success: "تمت العملية بنجاح"
         error: "حدث خطأ"
   ```

3. **Setting Locale Based on Request**:
   ```ruby
   # app/controllers/application_controller.rb
   class ApplicationController < ActionController::API
     before_action :set_locale
     
     private
     
     def set_locale
       locale = request.headers['Accept-Language']&.split(',')&.first || 'ar'
       I18n.locale = locale
     end
   end
   ```

## Date, Time, and Number Formatting

The application handles culturally appropriate formatting:

1. **Date Formats**:
   - Arabic: DD/MM/YYYY (right-to-left)
   - French: DD/MM/YYYY
   - Numeric dates use the appropriate locale format

2. **Currency**:
   - Primary currency: Tunisian Dinar (TND)
   - Format example: "1,234.50 د.ت" (Arabic), "1 234,50 TND" (French)

3. **Number Formatting**:
   - Use appropriate thousand separators and decimal points based on locale
   - Arabic: 1,234.56
   - French: 1 234,56

## RTL (Right-to-Left) Support

For Arabic and Tunisian dialect interfaces, the application properly handles RTL layout:

1. **Flutter RTL Support**:
   ```dart
   // Automatically handles RTL based on locale
   Directionality(
     textDirection: Localizations.localeOf(context).languageCode == 'ar' 
         ? TextDirection.rtl 
         : TextDirection.ltr,
     child: child,
   )
   ```

2. **Text Alignment**:
   - Automatically adjusts text alignment based on locale
   - Form fields adapt to RTL for Arabic

3. **Icons and UI Elements**:
   - Mirror appropriate icons in RTL mode
   - Navigation elements adapt to RTL reading direction

## Market-Specific Localization Features

The application includes Tunisian-specific customizations:

1. **Vehicle Models Popular in Tunisia**:
   - Pre-populated database with common Tunisian market vehicles
   - Localized brand and model names

2. **Tunisian Holidays and Events**:
   - Calendar adjusts for Ramadan and local holidays
   - Maintenance reminders account for seasonal events

3. **Regional Terminology**:
   - Garage-specific terminology in Tunisian dialect
   - Vehicle part names in local dialect

## Testing Localization

To ensure proper localization:

1. **UI Testing**:
   - Visual inspection of RTL layouts
   - Screen size adaptation with localized text

2. **Content Verification**:
   - Review translations with native speakers
   - Check for contextual accuracy

3. **Functional Testing**:
   - Test forms and interactive elements in all languages
   - Verify date and number format handling

## Maintenance and Updates

The localization system allows for easy updates:

1. Add new translations to ARB files as features are developed
2. Use translation keys consistently across the application
3. Consider hiring a native Tunisian translator for dialect accuracy 