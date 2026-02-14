#import <UIKit/UIKit.h>

@interface GhostMenu : UIView
@property (nonatomic, strong) UITextView *inputArea;
@property (nonatomic, strong) UIButton *injectBtn;
@end

@implementation GhostMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor redColor].CGColor;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 20)];
        title.text = @"GHOST COOKIE INJECTOR";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:title];

        _inputArea = [[UITextView alloc] initWithFrame:CGRectMake(10, 40, frame.size.width - 20, 150)];
        _inputArea.backgroundColor = [UIColor darkGrayColor];
        _inputArea.textColor = [UIColor greenColor];
        _inputArea.layer.cornerRadius = 8;
        [self addSubview:_inputArea];

        _injectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _injectBtn.frame = CGRectMake(10, 200, frame.size.width - 20, 40);
        [_injectBtn setTitle:@"DÖNÜŞTÜR VE ENJEKTE ET" forState:UIControlStateNormal];
        [_injectBtn setBackgroundColor:[UIColor redColor]];
        [_injectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _injectBtn.layer.cornerRadius = 8;
        [_injectBtn addTarget:self action:@selector(processAndInject) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_injectBtn];
    }
    return self;
}

- (void)processAndInject {
    NSString *rawInput = _inputArea.text;
    if ([rawInput length] < 5) return;

    // NETSCAPE TO JSON CONVERTER MANTIĞI
    NSArray *lines = [rawInput componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        if ([line hasPrefix:@"#"] || [line length] < 10) continue;
        
        NSArray *parts = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *cleanParts = [NSMutableArray array];
        for (NSString *p in parts) if ([p length] > 0) [cleanParts addObject:p];

        if ([cleanParts count] >= 7) {
            // Netscape Formatı Ayıklama
            [self setCookieWithName:cleanParts[5] value:cleanParts[6] domain:cleanParts[0]];
        } else if ([rawInput containsString:@"\"name\":"]) {
            // Zaten JSON ise doğrudan işle (Basit mantık)
            [self injectJSON:rawInput];
            break;
        }
    }
    
    // İşlem bitince uygulamayı kapat (Yeniden yükleme için)
    exit(0);
}

- (void)setCookieWithName:(NSString *)name value:(NSString *)value domain:(NSString *)domain {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props setObject:name forKey:NSHTTPCookieName];
    [props setObject:value forKey:NSHTTPCookieValue];
    [props setObject:domain forKey:NSHTTPCookieDomain];
    [props setObject:@"/" forKey:NSHTTPCookiePath];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:props];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)injectJSON:(NSString *)jsonStr {
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (NSDictionary *d in arr) {
        [self setCookieWithName:d[@"name"] value:d[@"value"] domain:@".netflix.com"];
    }
}

@end

// 3 PARMAK 3 TIKLAMA GESTURE SİSTEMİ
%hook UIWindow
- (void)layoutSubviews {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGhostTap:)];
        tap.numberOfTapsRequired = 3;
        tap.numberOfTouchesRequired = 3;
        [self addGestureRecognizer:tap];
    });
}

%new
- (void)handleGhostTap:(UITapGestureRecognizer *)sender {
    static GhostMenu *menu = nil;
    if (!menu) {
        menu = [[GhostMenu alloc] initWithFrame:CGRectMake(20, 100, 280, 250)];
        [[UIApplication sharedApplication].keyWindow addSubview:menu];
    }
    menu.hidden = !menu.hidden;
    [menu.inputArea becomeFirstResponder];
}
%end
