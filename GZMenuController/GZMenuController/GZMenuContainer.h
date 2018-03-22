//
//  GZMenuContainer.h
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GZMenuView.h"
#import "GZMenuButton.h"
#import "GZMenuController.h"

@interface GZMenuContainer : UIView

@property (nonatomic, assign) GZMenuControllerArrowDirection arrowDirection;

@property (nonatomic, copy) NSArray<GZMenuItem *> *menuItems;

@property (nonatomic, assign) BOOL autoHide;

@property (nonatomic, assign) UIEdgeInsets menuEdgeInsets; // menuView 与屏幕边缘间隙

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) CGFloat maxMenuViewWidth;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, assign) CGSize arrowSize;

@property (nonatomic, assign) CGFloat arrowMargin;

@property (nonatomic, strong) UIFont *menuItemFont;

@property (nonatomic, strong) UIColor *menuItemTintColor;

@property (nonatomic, strong) UIColor *menuItemHighlightColor;

/// 仅在 MenuItem 包含图片时生效，表示 MenuItem 的图片位置
@property (nonatomic, assign) GZMenuButtonImagePosition imagePosition;

/// 仅在 MenuItem 包含图片时生效，表示 Menu 是否平铺展开显示
@property (nonatomic, assign) BOOL unfoldDisplay;

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;

- (void)updateMenuView;

@end
