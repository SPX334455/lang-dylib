#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// Bu fonksiyon uygulama başladığında otomatik çalışır.
__attribute__((constructor))
static void initialize() {
    NSLog(@"[DilSihirbazi] Locale Spoofer Aktif Edildi!");

    // 1. Yöntem: NSUserDefaults üzerinden dili Türkçe'ye zorla
    [[NSUserDefaults standardUserDefaults] setObject:@[@"tr-TR", @"tr"] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 2. Yöntem: preferredLanguages metodunu "Hook" ederek manipüle etme
// Uygulama "Hangi dilleri tercih ediyorsun?" dediğinde her zaman @[@"tr-TR"] dönecek.
@interface NSLocale (LanguageSpoof)
@end

@implementation NSLocale (LanguageSpoof)
+ (NSArray *)swizzled_preferredLanguages {
    return @[@"tr-TR"];
}
@end

// Method Swizzling (Metot Takası) işlemi
__attribute__((constructor))
static void setup_swizzle() {
    Method original = class_getClassMethod([NSLocale class], @selector(preferredLanguages));
    Method swizzled = class_getClassMethod([NSLocale class], @selector(swizzled_preferredLanguages));
    method_exchangeImplementations(original, swizzled);
}
