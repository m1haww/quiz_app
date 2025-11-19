//
//  LocalizationManager.swift
//  quiz app
//
//  Created by Mihail Ozun on 19.11.2025.
//

import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "English" {
        didSet {
            print("🌐 LocalizationManager: Language changed to \(currentLanguage)")
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
    
    private init() {
        currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "English"
    }
    
    func localizedString(_ key: String) -> String {
        switch currentLanguage {
        case "Arabic":
            return arabicTranslations[key] ?? key
        default:
            return englishTranslations[key] ?? key
        }
    }
    
    private let englishTranslations: [String: String] = [
        // Onboarding
        "continue": "Continue",
        "find_out_who_lives": "Find out who lives in the most luxurious homes in the UAE!",
        
        // Nickname
        "enter_your_nickname": "Enter your nickname",
        "nickname": "Nickname",
        "please_enter_nickname": "Please enter a nickname",
        
        // Avatar
        "choose_your_avatar": "Choose your avatar",
        
        // Main App
        "home": "Home",
        "leaderboard": "Leaderboard",
        "profile": "Profile",
        "settings": "Settings",
        
        // Quiz
        "About to take quiz": "About to take quiz",
        "Ready to take the quiz about": "Ready to take the quiz about", 
        "Start Quiz": "Start Quiz",
        "Back": "Back",
        "Next Quiz": "Next Quiz", 
        "Main Screen": "Main Screen",
        
        // Profile
        "stars": "stars",
        "edit": "Edit",
        "no_nickname_set": "No nickname set",
        
        // Edit Profile
        "Edit Profile": "Edit Profile",
        "Cancel": "Cancel", 
        "Save": "Save",
        "Choose Avatar": "Choose Avatar",
        "Nickname": "Nickname",
        "Enter your nickname": "Enter your nickname",
        
        // Settings
        "language": "Language",
        "english": "English",
        "arabic": "Arabic",
        "privacy_policy": "Privacy Policy",
        "contact_us": "Contact Us",
        "reset_progress": "Reset Progress"
    ]
    
    private let arabicTranslations: [String: String] = [
        // Onboarding
        "continue": "متابعة",
        "find_out_who_lives": "اكتشف من يعيش في أفخم المنازل في دولة الإمارات!",
        
        // Nickname
        "enter_your_nickname": "أدخل اسمك المستعار",
        "nickname": "اسم مستعار",
        "please_enter_nickname": "يرجى إدخال اسم مستعار",
        
        // Avatar
        "choose_your_avatar": "اختر صورتك الرمزية",
        
        // Main App
        "home": "الرئيسية",
        "leaderboard": "المتصدرين",
        "profile": "الملف الشخصي",
        "settings": "الإعدادات",
        
        // Quiz
        "About to take quiz": "على وشك إجراء الاختبار",
        "Ready to take the quiz about": "مستعد لإجراء الاختبار حول",
        "Start Quiz": "ابدأ الاختبار", 
        "Back": "رجوع",
        "Next Quiz": "الاختبار التالي",
        "Main Screen": "الشاشة الرئيسية",
        
        // Profile
        "stars": "نجمة",
        "edit": "تعديل", 
        "no_nickname_set": "لم يتم تعيين اسم مستعار",
        
        // Edit Profile
        "Edit Profile": "تعديل الملف الشخصي",
        "Cancel": "إلغاء",
        "Save": "حفظ", 
        "Choose Avatar": "اختر الصورة الرمزية",
        "Nickname": "الاسم المستعار",
        "Enter your nickname": "أدخل اسمك المستعار",
        
        // Settings
        "language": "اللغة",
        "english": "English",
        "arabic": "العربية",
        "privacy_policy": "سياسة الخصوصية",
        "contact_us": "اتصل بنا",
        "reset_progress": "إعادة تعيين التقدم"
    ]
}