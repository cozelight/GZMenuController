//
//  GZMenuWindow.m
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import "GZMenuWindow.h"
#import "GZMenuContainer.h"
#import "GZMenuController.h"

static inline CGSize GZMenuScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}

@interface GZMenuWindow ()

@property (nonatomic, weak) GZMenuContainer *currentMenu;

@end

@implementation GZMenuWindow

+ (instancetype)sharedWindow {
    static GZMenuWindow *sharedWindow = nil;
    if (!sharedWindow) {
        // iOS 9 compatible
        NSString *mode = [NSRunLoop currentRunLoop].currentMode;
        if (mode.length == 27 &&
            [mode hasPrefix:@"UI"] &&
            [mode hasSuffix:@"InitializationRunLoopMode"]) {
            return nil;
        }
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWindow = [[GZMenuWindow alloc] init];
        sharedWindow.frame = (CGRect){.size = GZMenuScreenSize()};
        sharedWindow.userInteractionEnabled = NO;
        sharedWindow.windowLevel = UIWindowLevelNormal;
        sharedWindow.hidden = NO;
        
        // for iOS 9:
        sharedWindow.opaque = NO;
        sharedWindow.backgroundColor = [UIColor clearColor];
        sharedWindow.layer.backgroundColor = [UIColor clearColor].CGColor;
    });
    
    return sharedWindow;
}

- (void)setMenu:(GZMenuContainer *)menu visible:(BOOL)visible animation:(BOOL)animation {
    if (!menu) {
        return;
    }
    
    if (visible) {
        [self _showMenu:menu animation:animation];
    } else {
        [self _hideMenu:menu animation:animation];
    }
}

#pragma mark - Private methods


- (void)_showMenu:(GZMenuContainer *)menu animation:(BOOL)animation {
    if (!menu) {
        return;
    }
    
    menu.alpha = 0;
    
    if (menu.superview != self) {
        [self addSubview:menu];
    }
    
    self.currentMenu = menu;
    [self _updateWindowLevel:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerWillShowMenuNotification object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (menu) {
                menu.alpha = 1;
            }
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerDidShowMenuNotification object:nil];
        }];
    } else {
        menu.alpha = 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerDidShowMenuNotification object:nil];
    }
}

- (void)_hideMenu:(GZMenuContainer *)menu animation:(BOOL)animation {
    if (!menu) {
        return;
    }
    
    if (menu.superview != self) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerWillHideMenuNotification object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (menu) {
                menu.alpha = 0;
                [menu removeFromSuperview];
            }
        } completion:^(BOOL finished) {
            self.currentMenu = nil;
            [self _updateWindowLevel:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerDidHideMenuNotification object:nil];
        }];
    } else {
        menu.alpha = 0;
        [menu removeFromSuperview];
        self.currentMenu.menuItems = nil;
        self.currentMenu = nil;
        [self _updateWindowLevel:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerDidHideMenuNotification object:nil];
    }
}

- (void)_updateWindowLevel:(BOOL)increase {
    UIApplication *app =  [UIApplication sharedApplication];
    if (!app) {
        return;
    }
    
    UIWindow *top = app.windows.lastObject;
    UIWindow *key = app.keyWindow;
    if (key && key.windowLevel > top.windowLevel) {
        top = key;
    }
    
    if (!increase) {
        self.windowLevel = top.windowLevel - 1;
        return;
    }
    
    if (top == self) {
        return;
    }
    
    self.windowLevel = top.windowLevel + 1;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event] == NO) {
        return nil;
    }
    
    NSInteger count = self.subviews.count;
    UIView *fitView = nil;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = self.subviews[i];
        CGPoint childP = [self convertPoint:point toView:childView];
        fitView = [childView hitTest:childP withEvent:event];
        if (fitView) {
            break;
        }
    }
    if (fitView) {
        return fitView;
    }
    
    if (self.currentMenu && self.currentMenu.superview && self.currentMenu.autoHide) {
        [self _hideMenu:self.currentMenu animation:NO];
    }
    
    return nil;
}


@end
