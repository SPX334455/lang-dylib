#import <Foundation/Foundation.h>

%hook NSLocale

+ (NSArray<NSString *> *)preferredLanguages {
    return @[@"tr-TR"];
}

+ (NSLocale *)currentLocale {
    return [[NSLocale alloc] initWithLocaleIdentifier:@"tr_TR"];
}

%end


%hook NSBundle

- (NSArray<NSString *> *)preferredLocalizations {
    return @[@"tr"];
}

%end
