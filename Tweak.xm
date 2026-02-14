#import <UIKit/UIKit.h>

@interface GhostPanel : UIView
@property (nonatomic, strong) UITextView *inputField;
@end

@implementation GhostPanel
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
        self.layer.cornerRadius = 20;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;

        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 25)];
        header.text = @"GHOST COOKIE EDITOR V3";
        header.textColor = [UIColor whiteColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:header];

        _inputField = [[UITextView alloc] initWithFrame:CGRectMake(15, 50, frame.size.width - 30, 130)];
        _inputField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        _inputField.textColor = [UIColor greenColor];
        _inputField.font = [UIFont systemFontOfSize:10];
        _inputField.layer.cornerRadius = 8;
        [self addSubview:_inputField];

        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        goBtn.frame = CGRectMake(15, 190, frame.size.width - 30, 40);
        [goBtn setTitle:@"ESKİLERİ SİL VE YÜKLE" forState:UIControlStateNormal];
        [goBtn setBackgroundColor:[UIColor redColor]];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        goBtn.layer.cornerRadius = 8;
        [goBtn addTarget:self action:@selector(cleanAndInject) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:goBtn];
    }
    return self;
}

- (void)cleanAndInject {
    // 1. ÖNCE HER ŞEYİ SİL (Cookie-Editor'deki Delete All mantığı)
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain containsString:@"netflix"]) {
            [storage deleteCookie:cookie];
        }
    }

    NSString *raw = _inputField.text;
    if (raw.length < 5) return;

    // 2. YENİLERİ EKLE
    if ([raw containsString:@"\"name\""]) { // JSON Formatı
        NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSArray class]]) {
            for (NSDictionary *d in json) {
                [self setC:d[@"name"] v:d[@"value"] d:@".netflix.com"];
            }
        }
    } else if ([raw containsString:@"\t"]) { // Netscape Formatı
        NSArray *lines = [raw componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *p = [line componentsSeparatedByString:@"\t"];
            if (p.count >= 7) [self setC:p[5] v:p[6] d:p[0]];
        }
    }

    // 3. YENİDEN BAŞLAT
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0); 
    });
}

- (void)setC:(NSString *)n v:(NSString *)v d:(NSString *)d {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:n forKey:NSHTTPCookieName];
    [p setObject:v forKey:NSHTTPCookieValue];
    [p setObject:d ?: @".netflix.com" forKey:NSHTTPCookieDomain];
    [p setObject:@"/" forKey:NSHTTPCookiePath];
    [p setObject:@"TRUE" forKey:NSHTTPCookieSecure]; // Netflix güvenli bağlantı ister
    
    NSHTTPCookie *c = [NSHTTPCookie cookieWithProperties:p];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:c];
}
@end

// 3 PARMAK 3 TIKLAMA İÇİN DAHA AGRESİF HOOK
%hook UIWindow
- (void)becomeKeyWindow {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGhost:)];
        tap.numberOfTapsRequired = 3;
        tap.numberOfTouchesRequired = 3;
        tap.cancelsTouchesInView = NO; // Diğer dokunmaları engellemesin
        [self addGestureRecognizer:tap];
    });
}

%new
- (void)handleGhost:(UITapGestureRecognizer *)sender {
    static GhostPanel *panel = nil;
    if (!panel) {
        CGRect screen = [UIScreen mainScreen].bounds;
        panel = [[GhostPanel alloc] initWithFrame:CGRectMake((screen.size.width-300)/2, 100, 300, 250)];
        [self addSubview:panel];
    }
    panel.hidden = !panel.hidden;
    if (!panel.hidden) [self bringSubviewToFront:panel];
}
%end
