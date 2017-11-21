//
//  UpdateVersionManage.m
//  WuYouTianXia
//
//  Created by tianxiuping on 2017/11/20.
//

#import "UpdateVersionManage.h"
#define oldVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

@interface UpdateVersionManage ()

@property(nonatomic, copy)void(^updateBlock)(NSString *,NSString *,NSString *,NSString *);
@property(nonatomic, strong)UIViewController *showController;
@property(nonatomic, assign)BOOL isHaveIgnoreUP;//是否已经忽略更新--
@end

@implementation UpdateVersionManage

+ (instancetype)sharedInstance {
    static UpdateVersionManage *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setIsHaveIgnoreUP:(BOOL)isHaveIgnoreUP{
    _isHaveIgnoreUP = isHaveIgnoreUP;
}

-(instancetype)init{
    self=[super init];
    if (self) {
        __weak typeof(self) weakSelf=self;
        self.updateBlock = ^(NSString *currentVersion ,NSString *releaseNotes, NSString *trackUrl, NSString *type){
            __strong typeof(self) strongSelf=weakSelf;
            
            [strongSelf showUpdateViewWith:(NSString *)currentVersion with:(NSString *)releaseNotes with:(NSString *)trackUrl with:type];
            
        };
        
    }
    return self;
}

#pragma mark--版本更新--1表示不需要更新，2选择更新，3强制更新
+(void)checkVersionInController:(UIViewController *)showController{
    
#pragma mark--type --网络请求获得type值，根据业务处理
    NSString *type = @"2";
    if ([type isEqualToString:@"2"])
    {//有更新，当前版本可用
        if ([UpdateVersionManage sharedInstance].isHaveIgnoreUP == YES) {
            return ;
        }
        [UpdateVersionManage sharedInstance].showController = showController;
        [UpdateVersionManage sharedInstance].isHaveIgnoreUP = YES;
        if ([UpdateVersionManage sharedInstance].updateBlock) {
            [UpdateVersionManage sharedInstance].updateBlock(@"更新内容", @"优化了哪些内容",@"下载链接",type);
        }
    }
    else if ([type isEqualToString:@"3"])//强制更新
    {
        [UpdateVersionManage sharedInstance].showController = showController;
        
        if ([UpdateVersionManage sharedInstance].updateBlock) {
            [UpdateVersionManage sharedInstance].updateBlock(@"更新内容", @"优化了哪些内容",@"下载链接",type);
        }
        
    }
    
}

#pragma mark  - 更新界面
-(void)showUpdateViewWith:(NSString *)currentVersion with:(NSString *)releaseNotes with:(NSString *)trackUrl with:(NSString *)type{
    
    if ([type isEqualToString:@"2"])
    {
        [self showIgnoreUpdateViewWith:currentVersion with:releaseNotes with:trackUrl];
    }else if ([type isEqualToString:@"3"])
    {
       [self showMustUpdateViewWith:currentVersion with:releaseNotes with:trackUrl];
    }
}

-(void)showIgnoreUpdateViewWith:(NSString *)currentVersion with:(NSString *)releaseNotes with:(NSString *)trackUrl{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"发现新版本%@",currentVersion] message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    UIAlertAction *action0=[UIAlertAction actionWithTitle:@"忽略此版本" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"前往更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[trackUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }];
    [alertController addAction:action1];
    [alertController addAction:action0];
    [alertController addAction:action2];
    if ([UpdateVersionManage sharedInstance].showController) {
         [[UpdateVersionManage sharedInstance].showController presentViewController:alertController animated:YES completion:nil];
    }else
    {
        [[UpdateVersionManage getCurrentVC] presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)showMustUpdateViewWith:(NSString *)currentVersion with:(NSString *)releaseNotes with:(NSString *)trackUrl{
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"发现新版本%@",currentVersion] message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"前往更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[trackUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        
    }];
    [alertController addAction:action2];
    if ([UpdateVersionManage sharedInstance].showController) {
        [[UpdateVersionManage sharedInstance].showController presentViewController:alertController animated:YES completion:nil];
    }else
    {
        [[UpdateVersionManage getCurrentVC] presentViewController:alertController animated:YES completion:nil];
    }
}
#pragma mark  - 版本号比较
+(BOOL)versionOlder:(NSString *)older sameTo:(NSString *)newer{
    if ([older isEqualToString:newer]) {
        return YES;
    }else{
        if ([older compare:newer options:NSNumericSearch]==NSOrderedDescending) {
            return YES;
        }else{
            return NO;
        }
    }
}

#pragma mark  - 字符串分割
+(NSArray *)seperateToRow:(NSString *)describe{
    
    NSArray *array=[describe componentsSeparatedByString:@"\n"];
    return array;
    
}

//获取当前屏幕显示的viewcontroller   (这里面获取的相当于rootViewController)
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


@end
