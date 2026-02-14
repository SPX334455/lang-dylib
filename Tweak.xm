#import <UIKit/UIKit.h>

// --- Arayüz Tanımlamaları ---
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
        header.text = @"GHOST INJECTOR V2";
        header.textColor = [UIColor whiteColor];
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:header];

        _inputField = [[UITextView alloc] initWithFrame:CGRectMake(15, 50, frame.size.width - 30, 140)];
        _inputField.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
        _inputField.textColor = [UIColor greenColor];
        _inputField.font = [UIFont systemFontOfSize:10];
        _inputField.layer.cornerRadius = 10;
        _inputField.placeholder = @"JSON veya Netscape Çerezlerini Yapıştırın...";
        [self addSubview:_inputField];

        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        goBtn.frame = CGRectMake(15, 205, frame.size.width - 30, 45);
        [goBtn setTitle:@"ENJEKTE ET VE YENİLE" forState:UIControlStateNormal];
        [goBtn setBackgroundColor:[UIColor redColor]];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        goBtn.layer.cornerRadius = 10;
        [goBtn addTarget:self action:@selector(injectNow) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:goBtn];
    }
    return self;
}

- (void)injectNow {
    NSString *raw = _inputField.text;
    if (raw.length < 5) return;

    // Netscape/Tab Formatı Kontrolü
    if ([raw containsString:@"\t"]) {
        NSArray *lines = [raw componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *p = [line componentsSeparatedByString:@"\t"];
            if (p.count >= 7) [self saveC:p[5] v:p[6] d:p[0]];
        }
    } 
    // JSON Formatı Kontrolü
    else if ([raw containsString:@"\"name\""]) {
        NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json isKindOfClass:[NSArray class]]) {
            for (NSDictionary *d in json) [self saveC:d[@"name"] v:d[@"value"] d:@".netflix.com"];
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0); // Uygulamayı tazele
    });
}

- (void)saveC:(NSString *)n v:(NSString *)v d:(NSString *)d {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:n forKey:NSHTTPCookieName];
    [p setObject:v forKey:NSHTTPCookieValue];
    [p setObject:d forKey:NSHTTPCookieDomain];
    [p setObject:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *c = [NSHTTPCookie cookieWithProperties:p];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:c];
}
@end

// --- Hooking Bölümü ---
%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGhostPanel)];
        tap.numberOfTapsRequired = 3;
        tap.numberOfTouchesRequired = 3;
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:tap];
    });
}

%new
- (void)showGhostPanel {
    static GhostPanel *panel = nil;
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    if (!panel) {
        panel = [[GhostPanel alloc] initWithFrame:CGRectMake((win.frame.size.width-300)/2, 100, 300, 270)];
        [win addSubview:panel];
    }
    panel.hidden = !panel.hidden;
    if (!panel.hidden) [panel.inputField becomeFirstResponder];
}
%end
