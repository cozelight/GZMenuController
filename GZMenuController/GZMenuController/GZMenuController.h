//
//  GZMenuController.h
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSNotificationName const GZMenuControllerWillShowMenuNotification;
UIKIT_EXTERN NSNotificationName const GZMenuControllerDidShowMenuNotification;
UIKIT_EXTERN NSNotificationName const GZMenuControllerWillHideMenuNotification;
UIKIT_EXTERN NSNotificationName const GZMenuControllerDidHideMenuNotification;
UIKIT_EXTERN NSNotificationName const GZMenuControllerMenuFrameDidChangeNotification;

typedef NS_ENUM(NSInteger, GZMenuControllerArrowDirection) {
    GZMenuControllerArrowDefault, // up or down based on screen location
    GZMenuControllerArrowUp,
    GZMenuControllerArrowDown,
};

@class GZMenuItem, GZMenuContainer;

@interface GZMenuController : NSObject

@property (nonatomic, assign, getter=isMenuVisible) BOOL menuVisible; // default is NO

@property (nonatomic, assign) GZMenuControllerArrowDirection arrowDirection; // default is GZMenuControllerArrowDefault

@property (nonatomic, copy, nullable) NSArray<GZMenuItem *> *menuItems; // default is nil. these are in addition to the standard items

@property (nonatomic, assign, readonly) CGRect menuFrame;

@property (nonatomic, strong, readonly) GZMenuContainer *menuContainer;

+ (GZMenuController *)sharedMenuController;

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;

- (void)update;

@end

@interface GZMenuItem : NSObject

- (instancetype)initWithTitle:(nullable NSString *)title target:(id)target action:(SEL)action;

- (instancetype)initWithTitle:(nullable NSString *)title
                   imageNamed:(nullable NSString *)imageNamed
                       target:(id)target
                       action:(SEL)action;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *imageNamed;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

@end

NS_ASSUME_NONNULL_END
