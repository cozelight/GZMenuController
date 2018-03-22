//
//  GZMenuButton.h
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const GZMenuItemForwardImageName;
UIKIT_EXTERN NSString *const GZMenuItemBackwardImageName;
UIKIT_EXTERN CGFloat const GZMenuItemMoreItemWidth;
UIKIT_EXTERN CGFloat const GZMenuItemImageItemWidth;

typedef NS_ENUM(NSUInteger, GZMenuButtonImagePosition) {
    GZMenuButtonImagePositionLeft,
    GZMenuButtonImagePositionRight,
    GZMenuButtonImagePositionTop,
    GZMenuButtonImagePositionBottom,
};

@class GZMenuItem;

@interface GZMenuButton : UIButton

@property (nonatomic, strong, readonly) GZMenuItem *menuItem;

@property (nonatomic, strong) UIFont *menuItemFont;

@property (nonatomic, strong) UIColor *menuItemTintColor;

@property (nonatomic, strong) UIColor *menuItemHighlightColor;

@property (nonatomic, assign) GZMenuButtonImagePosition imagePosition;

@property (nonatomic, assign) CGSize maxSize;

+ (instancetype)menuButtonWithMenuItem:(GZMenuItem *)menuItem;

- (instancetype)initWithMenuItem:(GZMenuItem *)menuItem;

- (CGSize)buttonSize;

@end
