//
//  GZMenuView.h
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GZMenuController.h"
#import "GZMenuButton.h"

@interface GZMenuView : UIView

@property (nonatomic, copy) NSArray<GZMenuItem *> *menuItems;

@property (nonatomic, assign) UIEdgeInsets menuEdgeInsets;

@property (nonatomic, assign) CGFloat maxMenuViewWidth;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong) UIFont *menuItemFont;

@property (nonatomic, strong) UIColor *menuItemTintColor;

@property (nonatomic, strong) UIColor *menuItemHighlightColor;

@property (nonatomic, assign) GZMenuButtonImagePosition imagePosition;

@property (nonatomic, assign) BOOL unfoldDisplay;

- (void)updateLayout;

@end
