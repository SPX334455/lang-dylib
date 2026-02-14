#import <UIKit/UIKit.h>

// --- PANEL ARAYÜZÜ ---
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
        self.clipsToBounds = YES;

        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 20)];
        header.text = @"GHOST COOKIE EDITOR V4";
        header.textColor = [UIColor whiteColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:header];

        _inputField = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, frame.size.width - 20, 150)];
        _inputField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        _inputField.textColor = [UIColor greenColor];
        _inputField.font = [UIFont systemFontOfSize:9];
        _inputField.layer.cornerRadius = 5;
        [self addSubview:_inputField];

        // KAPATMA BUTONU (Yanlışlıkla açılırsa diye)
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(frame.size.width - 30, 5, 25, 25);
        [closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];

        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        goBtn.frame = CGRectMake(10, 200, frame.size.width - 20, 40);
        [goBtn setTitle:@"TEMİZLE VE GİRİŞ YAP" forState:UIControlStateNormal];
        [goBtn setBackgroundColor:[UIColor redColor]];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        goBtn.layer.cornerRadius = 5;
        [goBtn addTarget:self action:@selector(processAndLogin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:goBtn];
    }
    return self;
}

- (void)hideMenu { self.hidden = YES; }

- (void)processAndLogin {
    // 1. ADIM: TÜM MEVCUT ÇEREZLERİ SİL (Cookie-Editor Delete All Mantığı)
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [storage deleteCookie:cookie];
    }

    NSString *raw = _inputField.text;
    if (raw.length < 5) return;

    // 2. ADIM: JSON AYIKLAMA
    if ([raw containsString:@"\"name\""]) {
        NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSArray class]]) {
            for (NSDictionary *d in json) {
                [self addCookie:d[@"name"] val:d[@"value"] dom:d[@"domain"] ?: @".netflix.com"];
            }
        }
    } 
    // 3. ADIM: NETSCAPE (TAB) AYIKLAMA
    else if ([raw containsString:@"\t"]) {
        NSArray *lines = [raw componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *p = [line componentsSeparatedByString:@"\t"];
            if (p.count >= 7) [self addCookie:p[5] val:p[6] dom:p[0]];
        }
    }

    // 4. ADIM: KAYDET VE UYGULAMAYI ZORLA KAPAT
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0); 
    });
}

- (void)addCookie:(NSString *)name val:(NSString *)val dom:(NSString *)dom {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props setObject:name forKey:NSHTTPCookieName];
    [props setObject:val forKey:NSHTTPCookieValue];
    [props setObject:dom forKey:NSHTTPCookieDomain];
    [props setObject:@"/" forKey:NSHTTPCookiePath];
    [props setObject:@"TRUE" forKey:NSHTTPCookieSecure];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:props];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}
@end

// --- UYGULAMA AÇILDIĞINDA OTOMATİK GÖSTER ---
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *win = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene* scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        win = scene.windows.firstObject;
                        break;
                    }
                }
            }
            if (!win) win = [UIApplication sharedApplication].keyWindow;

            if (win) {
                GhostPanel *panel = [[GhostPanel alloc] initWithFrame:CGRectMake((win.frame.size.width-300)/2, 120, 300, 250)];
                panel.tag = 9988;
                [win addSubview:panel];
                [win bringSubviewToFront:panel];
            }
        });
    });
}
%end
