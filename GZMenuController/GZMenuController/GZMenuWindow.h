//
//  GZMenuWindow.h
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GZMenuContainer;

@interface GZMenuWindow : UIWindow

+ (instancetype)sharedWindow;

- (void)setMenu:(GZMenuContainer *)menu visible:(BOOL)visible animation:(BOOL)animation;

@end
