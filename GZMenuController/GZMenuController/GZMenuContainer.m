//
//  GZMenuContainer.m
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import "GZMenuContainer.h"
#import "GZMenuWindow.h"

#define GZMenuStatusBarHeight  [UIApplication sharedApplication].statusBarFrame.size.height
#define GZMenuScreenHeight [UIScreen mainScreen].bounds.size.height
#define GZMenuScreenWidth [UIScreen mainScreen].bounds.size.width

@interface GZMenuContainer ()

@property (nonatomic, strong) CAShapeLayer *contentLayer;
@property (nonatomic, strong) GZMenuView *menuView;
@property (nonatomic, assign) CGFloat arrowMidx;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGRect targetRect;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) GZMenuControllerArrowDirection correctDirection;

@end

@implementation GZMenuContainer

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultConfigs];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize arrowSize = self.arrowSize;
    CGRect roundedRect = self.menuView.frame;
    roundedRect.origin.y = (self.correctDirection == GZMenuControllerArrowUp ? arrowSize.height : 0);
    self.menuView.frame = roundedRect;
    
    CGFloat arrowMidx = self.anchorPoint.x - self.frame.origin.x;
    if ((self.anchorPoint.x-arrowSize.width/2)<(self.frame.origin.x+self.cornerRadius+3)) {
        arrowMidx = self.cornerRadius+3+arrowSize.width/2;
    }
    if ((self.anchorPoint.x+arrowSize.width/2)>(CGRectGetMaxX(self.frame)-self.cornerRadius-3)) {
        arrowMidx = roundedRect.size.width - self.cornerRadius-arrowSize.width/2-3;
    }
    self.arrowMidx = arrowMidx;
    CGFloat cornerRadius = self.cornerRadius;
    
    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftBottomArcCenter.y)];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
    
    if (self.correctDirection == GZMenuControllerArrowDown) {
        //始画三角形，箭头向下
        [path addLineToPoint:CGPointMake(arrowMidx-arrowSize.width / 2, CGRectGetMaxY(roundedRect))];
        [path addLineToPoint:CGPointMake(arrowMidx , CGRectGetMaxY(roundedRect) + arrowSize.height)];
        [path addLineToPoint:CGPointMake(arrowMidx + arrowSize.width / 2, CGRectGetMaxY(roundedRect))];
    }
    
    [path addLineToPoint:CGPointMake(rightBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightTopArcCenter.y)];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];
    
    if (self.correctDirection == GZMenuControllerArrowUp) {
        // 箭头向上
        [path addLineToPoint:CGPointMake(arrowMidx + arrowSize.width/ 2, CGRectGetMinY(roundedRect))];
        [path addLineToPoint:CGPointMake(arrowMidx, CGRectGetMinY(roundedRect) - arrowSize.height)];
        [path addLineToPoint:CGPointMake(arrowMidx- arrowSize.width / 2, CGRectGetMinY(roundedRect))];
    }
    [path closePath];
    
    self.contentLayer.path = path.CGPath;
    self.contentLayer.frame = self.bounds;
}

#pragma mark - Public methods

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView {
    self.targetRect = targetRect;
    self.targetView = targetView;
    [self updateMenuView];
}

- (void)updateMenuView {
    if (self.menuView.superview) {
        [self.menuView removeFromSuperview];
    }
    if (!self.targetView ||
        CGRectEqualToRect(self.targetRect, CGRectZero) ||
        self.menuItems.count == 0) {
        return;
    }
    
    [self addSubview:self.menuView];
    
    [self.menuView updateLayout];
    CGRect menuRect = self.menuView.frame;
    CGRect rect = [self.targetView convertRect:self.targetRect toView:[GZMenuWindow sharedWindow]];
    
    self.anchorPoint = [self _calculateAnchorPoint:rect menuViewSize:menuRect.size];
    
    if (self.anchorPoint.x < GZMenuScreenWidth/2) {
        if ((self.anchorPoint.x-menuRect.size.width/2)>self.menuEdgeInsets.left) {
            menuRect.origin.x = (self.anchorPoint.x-menuRect.size.width/2);
        } else {
            menuRect.origin.x = self.menuEdgeInsets.left;
        }
    } else {
        if ((self.anchorPoint.x + menuRect.size.width/2)>(GZMenuScreenWidth-self.menuEdgeInsets.right)) {
            menuRect.origin.x = (GZMenuScreenWidth - self.menuEdgeInsets.right-menuRect.size.width);
        } else {
            menuRect.origin.x =(self.anchorPoint.x - menuRect.size.width/2);
        }
    }
    
    menuRect.size.height += self.arrowSize.height;
    switch (self.correctDirection) {
        case GZMenuControllerArrowUp: {
            menuRect.origin.y = self.anchorPoint.y;
            break;
        }
        case GZMenuControllerArrowDown: {
            menuRect.origin.y = self.anchorPoint.y - menuRect.size.height;
            break;
        }
        case GZMenuControllerArrowDefault:
        default:
            break;
    }
    
    if (!CGRectEqualToRect(self.frame, menuRect)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GZMenuControllerMenuFrameDidChangeNotification object:nil];
    }
    self.frame = menuRect;
    
    [self setNeedsLayout];
}

#pragma mark - Private methods

- (void)_setupDefaultConfigs {
    _autoHide = YES;
    _unfoldDisplay = YES;
    _maxMenuViewWidth = GZMenuScreenWidth;
    _menuEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _cornerRadius = 6;
    _arrowSize = CGSizeMake(17, 9.7);
    _arrowMargin = 5.5;
    _fillColor = [UIColor colorWithRed:26/255 green:26/288 blue:27/255 alpha:1];
    _menuItemFont = [UIFont systemFontOfSize:14];
    _menuItemTintColor = [UIColor whiteColor];
    _menuItemHighlightColor = [UIColor lightGrayColor];
    _imagePosition = GZMenuButtonImagePositionBottom;
    
    [self.layer addSublayer:self.contentLayer];
}


- (CGPoint)_calculateAnchorPoint:(CGRect)targetRect menuViewSize:(CGSize)size {

    CGPoint targetPoint = CGPointZero;
    
    if (CGRectGetMinX(targetRect) > 0 && CGRectGetMaxX(targetRect) < GZMenuScreenWidth) {
        targetPoint.x = CGRectGetMidX(targetRect);
    } else if (CGRectGetMinX(targetRect) < 0 && CGRectGetMaxX(targetRect) > GZMenuScreenWidth) {
        targetPoint.x = GZMenuScreenWidth / 2;
    } else {
        if (CGRectGetMinX(targetRect) < 0) {
            targetPoint.x = CGRectGetMaxX(targetRect) / 2;
        } else {
            targetPoint.x = (GZMenuScreenWidth - CGRectGetMinX(targetRect)) / 2;
        }
    }
    
    CGFloat realSizeHeight = size.height + self.arrowMargin + self.arrowSize.height;
    BOOL targetBeyondTop = (CGRectGetMinY(targetRect) - realSizeHeight) < GZMenuStatusBarHeight;
    BOOL targetBeyondBottom = (CGRectGetMaxY(targetRect) + realSizeHeight) > GZMenuScreenHeight;
    
    BOOL adjustTargetPointY = NO;
    
    switch (self.arrowDirection) {
        case GZMenuControllerArrowDefault: {
            if (!targetBeyondTop) {
                self.correctDirection = GZMenuControllerArrowDown;
                targetPoint.y = CGRectGetMinY(targetRect) - self.arrowMargin;
            } else if (!targetBeyondBottom) {
                self.correctDirection = GZMenuControllerArrowUp;
                targetPoint.y = CGRectGetMaxY(targetRect) + self.arrowMargin;
            } else {
                self.correctDirection = GZMenuControllerArrowDown;
                adjustTargetPointY = YES;
            }
            break;
        }
        case GZMenuControllerArrowUp: {
            self.correctDirection = GZMenuControllerArrowUp;
            if (!targetBeyondBottom) {
                targetPoint.y = CGRectGetMaxY(targetRect) + self.arrowMargin;
            } else {
                adjustTargetPointY = YES;
            }
            break;
        }
        case GZMenuControllerArrowDown: {
            self.correctDirection = GZMenuControllerArrowDown;
            if (!targetBeyondTop) {
                targetPoint.y = CGRectGetMinY(targetRect) - self.arrowMargin;
            } else {
                adjustTargetPointY = YES;
            }
            break;
        }
        default:
            break;
    }
    
    if (adjustTargetPointY) {
        realSizeHeight -= self.arrowMargin;
        if (realSizeHeight > GZMenuScreenHeight) {
            NSAssert(false, @"menu is too high!");
            targetPoint.y = GZMenuScreenHeight / 2;
            return targetPoint;
        }
        
        CGFloat minPointY = 0;
        CGFloat maxPointY = 0;
        
        switch (self.correctDirection) {
            case GZMenuControllerArrowUp: {
                maxPointY = GZMenuScreenHeight - realSizeHeight - self.menuEdgeInsets.bottom;
                
                if (GZMenuScreenHeight - CGRectGetMinY(targetRect) + self.menuEdgeInsets.top > realSizeHeight) {
                    minPointY = CGRectGetMinY(targetRect);
                    if (minPointY < 0) {
                        minPointY = 0;
                    }
                } else {
                    minPointY = maxPointY;
                }
                break;
            }
            case GZMenuControllerArrowDown: {
                minPointY = realSizeHeight + self.menuEdgeInsets.top;
                if (CGRectGetMaxY(targetRect) - self.menuEdgeInsets.top > realSizeHeight) {
                    maxPointY = CGRectGetMaxY(targetRect);
                    if (maxPointY > GZMenuScreenHeight - self.menuEdgeInsets.bottom) {
                        maxPointY = GZMenuScreenHeight - self.menuEdgeInsets.bottom;
                    }
                } else {
                    maxPointY = minPointY;
                }
                break;
            }
            case GZMenuControllerArrowDefault:
            default: {
                NSAssert(false, @"correct direction is confused!");
                targetPoint.y = GZMenuScreenHeight / 2;
                return targetPoint;
            }
        }
        
        if (maxPointY == minPointY) {
            targetPoint.y = minPointY;
        } else {
            targetPoint.y = minPointY + (maxPointY - minPointY) / 2;
        }
    }
    
    return targetPoint;
}

#pragma mark - Setter

- (void)setMenuItems:(NSArray<GZMenuItem *> *)menuItems {
    if (_menuItems == menuItems) {
        return;
    }
    _menuItems = menuItems;
    self.menuView.menuItems = menuItems;
}

- (void)setUnfoldDisplay:(BOOL)unfoldDisplay {
    _unfoldDisplay = unfoldDisplay;
    self.menuView.unfoldDisplay = unfoldDisplay;
}

- (void)setMenuEdgeInsets:(UIEdgeInsets)menuEdgeInsets {
    _menuEdgeInsets = menuEdgeInsets;
    self.menuView.menuEdgeInsets = menuEdgeInsets;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.menuView.cornerRadius = cornerRadius;
}

- (void)setMaxMenuViewWidth:(CGFloat)maxMenuViewWidth {
    _maxMenuViewWidth = maxMenuViewWidth;
    self.menuView.maxMenuViewWidth = maxMenuViewWidth;
}

- (void)setMenuItemFont:(UIFont *)menuItemFont {
    _menuItemFont = menuItemFont;
    self.menuView.menuItemFont = menuItemFont;
}

- (void)setMenuItemTintColor:(UIColor *)menuItemTintColor {
    _menuItemTintColor = menuItemTintColor;
    self.menuView.menuItemTintColor = menuItemTintColor;
}

- (void)setMenuItemHighlightColor:(UIColor *)menuItemHighlightColor {
    _menuItemHighlightColor = menuItemHighlightColor;
    self.menuView.menuItemHighlightColor = menuItemHighlightColor;
}

- (void)setImagePosition:(GZMenuButtonImagePosition)imagePosition {
    _imagePosition = imagePosition;
    self.menuView.imagePosition = imagePosition;
}

#pragma mark - Getter

- (CAShapeLayer *)contentLayer {
    if (!_contentLayer) {
        _contentLayer = [[CAShapeLayer alloc] init];
        _contentLayer.fillColor = [UIColor colorWithRed:26/255 green:26/288 blue:27/255 alpha:1].CGColor;
    }
    return _contentLayer;
}

- (GZMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[GZMenuView alloc] init];
        _menuView.unfoldDisplay = _unfoldDisplay;
        _menuView.maxMenuViewWidth = _maxMenuViewWidth;
        _menuView.menuEdgeInsets = _menuEdgeInsets;
        _menuView.cornerRadius = _cornerRadius;
        _menuView.menuItemFont = _menuItemFont;
        _menuView.menuItemTintColor = _menuItemTintColor;
        _menuView.menuItemHighlightColor = _menuItemHighlightColor;
        _menuView.imagePosition = _imagePosition;
    }
    return _menuView;
}

@end

/**
 
 锚点各种情况示意图
 
 === 代表屏幕
 ··· 代表targetView
 --- 代表menu
 
 ====================
 =                  =
 =                  =
 =                  =
 =    ----------    =
 =    |        |    =
 =    ----------    =
 =     ········     =
 =     ·      ·     =
 =     ········     =
 =                  =
 =                  =
 ====================
 
 1. target上方有足够空间展示menu
 
 ====================
 =                  =
 =    ----------    =
 =    |        |    =
 =    ----------    =
 =     ········     =
 =     ·      ·     =
 =     ·      ·     =
 
 2. target下方有足够空间展示menu
 
 =     ·      ·     =
 =     ·      ·     =
 =     ········     =
 =    ----------    =
 =    |        |    =
 =    ----------    =
 ====================
 
 3. 锚点只能放在targetView内
 
 ====================
 =    ----------    =
 =    |        |    =
 =    | ······ |    =
 =    | ·    · |    =
 =    ----------    =
 =      ·    ·      =
 =      ·    ·      =
 ====================
 
 
 */
