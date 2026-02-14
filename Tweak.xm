#import <UIKit/UIKit.h>

@interface GhostPanel : UIView
@property (nonatomic, strong) UITextView *inputField;
@end

@implementation GhostPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.98];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;
        
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 20)];
        header.text = @"GHOST FORCE INJECTOR V5";
        header.textColor = [UIColor whiteColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:header];

        _inputField = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, frame.size.width - 20, 150)];
        _inputField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        _inputField.textColor = [UIColor greenColor];
        _inputField.font = [UIFont systemFontOfSize:9];
        [self addSubview:_inputField];

        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        goBtn.frame = CGRectMake(10, 200, frame.size.width - 20, 40);
        [goBtn setTitle:@"ZORLA ENJEKTE ET VE BAŞLAT" forState:UIControlStateNormal];
        [goBtn setBackgroundColor:[UIColor redColor]];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [goBtn addTarget:self action:@selector(forceInject) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:goBtn];
    }
    return self;
}

- (void)forceInject {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [storage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways]; // Her şeyi kabul et

    // Eskileri temizle
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }

    NSString *raw = _inputField.text;
    if (raw.length < 10) return;

    // JSON veya Netscape ayıkla
    if ([raw containsString:@"\"name\""]) {
        NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSArray class]]) {
            for (NSDictionary *d in json) {
                [self addC:d[@"name"] v:d[@"value"] d:d[@"domain"] ?: @".netflix.com"];
            }
        }
    } else {
        // Netscape/Tab ayıklama
        NSArray *lines = [raw componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *p = [line componentsSeparatedByString:@"\t"];
            if (p.count >= 7) [self addC:p[5] v:p[6] d:p[0]];
        }
    }

    // Çerezleri diske yazmaya zorla
    [[NSUserDefaults standardUserDefaults] synchronize];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0); 
    });
}

- (void)addC:(NSString *)name v:(NSString *)val d:(NSString *)dom {
    if (!name || !val) return;
    
    // Domain'in başında nokta olduğundan emin ol
    NSString *finalDom = dom;
    if (![finalDom hasPrefix:@"."]) finalDom = [NSString stringWithFormat:@".%@", finalDom];

    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props setObject:name forKey:NSHTTPCookieName];
    [props setObject:val forKey:NSHTTPCookieValue];
    [props setObject:finalDom forKey:NSHTTPCookieDomain];
    [props setObject:@"/" forKey:NSHTTPCookiePath];
    [props setObject:@"TRUE" forKey:NSHTTPCookieSecure];
    // Kritik: Netflix uygulaması bazen HTTPOnly çerezleri kontrol eder
    [props setObject:@"TRUE" forKey:@"HttpOnly"]; 
    
    // Çerezin süresini 1 yıl sonraya ayarla ki hemen silinmesin
    [props setObject:[[NSDate date] dateByAddingTimeInterval:31536000] forKey:NSHTTPCookieExpires];

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:props];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}
@end

// PANEL GÖSTERİMİ
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *win = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        win = scene.windows.firstObject; break;
                    }
                }
            }
            if (win) {
                GhostPanel *panel = [[GhostPanel alloc] initWithFrame:CGRectMake((win.frame.size.width-300)/2, 150, 300, 250)];
                [win addSubview:panel];
                [win bringSubviewToFront:panel];
            }
        });
    });
}
%end
