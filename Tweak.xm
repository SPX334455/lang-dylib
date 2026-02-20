#import <UIKit/UIKit.h>

// Bellek uyarılarını bastırarak oyunun loading'de atmasını engellemeye çalışır
%hook UIApplication
- (void)_performMemoryWarning {
    NSLog(@"[Ghost] Hafıza uyarısı susturuldu, oyuna devam!");
}
%end

%hook UIViewController
- (void)didReceiveMemoryWarning {
    // Boş bırakıldı: Oyunun kendi içindeki asset silme komutunu engeller
}
%end

// Orijinal Bundle ID taklidi
%hook NSBundle
- (NSString *)bundleIdentifier {
    return @"com.goapeship.app";
}
%end

// Performans modu
%hook NSProcessInfo
- (BOOL)isLowPowerModeEnabled {
    return NO;
}
%end
