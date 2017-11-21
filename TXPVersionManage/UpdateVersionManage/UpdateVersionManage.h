//
//  UpdateVersionManage.h
//  WuYouTianXia
//
//  Created by tianxiuping on 2017/11/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UpdateVersionManage : NSObject

+ (instancetype)sharedInstance;
+(void)checkVersionInController:(UIViewController *)showController;
@end
