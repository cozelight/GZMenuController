//
//  GZMenuButton.m
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import "GZMenuButton.h"
#import "GZMenuController.h"

#define kTriangleHeight 11
#define kTriangleWidth 8.7
#define kTitleMargin 10
#define kImageMargin 5
#define kImageInnerWidth 24

NSString *const GZMenuItemForwardImageName = @"GZMenuItemForwardImageName";
NSString *const GZMenuItemBackwardImageName = @"GZMenuItemBackwardImageName";
CGFloat const GZMenuItemMoreItemWidth = 29.3;
CGFloat const GZMenuItemImageItemWidth = 55;

/// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}
/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

@interface GZMenuButton ()

@property (nonatomic, strong) UIColor *highlightedColor;

@property (nonatomic, assign) CGSize actualButtonSize;

@end

@implementation GZMenuButton

#pragma mark - Life cycle

+ (instancetype)menuButtonWithMenuItem:(GZMenuItem *)menuItem {
    return [[self alloc] initWithMenuItem:menuItem];
}

- (instancetype)initWithMenuItem:(GZMenuItem *)menuItem {
    self = [super init];
    if (self) {
        _menuItem = menuItem;
        self.imageEdgeInsets = UIEdgeInsetsMake(kImageMargin, kImageMargin, kImageMargin, kImageMargin);
        [self setupConfig];
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    UIButton *button = (UIButton *)object;
    if ([keyPath isEqualToString:@"highlighted"]) {
        if (button.highlighted) {
            [button setBackgroundColor:self.highlightedColor ? :[UIColor lightGrayColor]];
            return;
        }
        [button setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"highlighted"];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    if (self.imagePosition == GZMenuButtonImagePositionLeft ||
        self.menuItem.imageNamed.length == 0) {
        return;
    }
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    
    if (self.imagePosition == GZMenuButtonImagePositionTop || self.imagePosition == GZMenuButtonImagePositionBottom) {
        
        CGFloat imageLimitWidth = contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
        CGFloat imageLimitHeight = contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, imageLimitHeight)];
        CGRect imageFrame = (CGRect){{0,0},imageSize};
        
        CGSize titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) - imageSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.width = fminf(titleSize.width, self.frame.size.width);
        titleSize.height = fminf(titleSize.height, titleLimitSize.height);
        CGRect titleFrame = (CGRect){{0,0},titleSize};
        
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                imageFrame.origin.x =  self.contentEdgeInsets.left + self.imageEdgeInsets.left;
                titleFrame.origin.x  = self.contentEdgeInsets.left + self.titleEdgeInsets.left;
                break;
            case UIControlContentHorizontalAlignmentCenter:
                imageFrame.origin.x =self.contentEdgeInsets.left + self.imageEdgeInsets.left + (imageLimitWidth - imageSize.width)/2;
                titleFrame.origin.x =self.contentEdgeInsets.left + self.titleEdgeInsets.left + (titleLimitSize.width- titleSize.width)/2;
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame.origin.x  = CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - imageSize.width;
                titleFrame.origin.x  = CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.titleEdgeInsets.right - titleSize.width;
                break;
            case UIControlContentHorizontalAlignmentFill:
                imageFrame.origin.x = self.contentEdgeInsets.left + self.imageEdgeInsets.left;
                imageFrame.size.width =imageLimitWidth;
                titleFrame.origin.x = self.contentEdgeInsets.left + self.titleEdgeInsets.left;
                titleFrame.size.width = titleLimitSize.width;
                break;
        }
        
        if (self.imagePosition == GZMenuButtonImagePositionTop) {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    imageFrame.origin.y =  self.contentEdgeInsets.top + self.imageEdgeInsets.top;
                    titleFrame.origin.y = CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top;
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets);
                    CGFloat minY = (contentSize.height - contentHeight)/2.0 + self.contentEdgeInsets.top;
                    imageFrame.origin.y = minY + self.imageEdgeInsets.top;
                    titleFrame.origin.y = CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    titleFrame.origin.y = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame);
                    imageFrame.origin.y =  CGRectGetMinY(titleFrame) - self.titleEdgeInsets.top - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame);
                    break;
                case UIControlContentVerticalAlignmentFill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame.origin.y = self.contentEdgeInsets.top + self.imageEdgeInsets.top;
                    titleFrame.origin.y = CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top;
                    titleFrame.size.height = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame);
                    break;
            }
        } else {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    titleFrame.origin.y = self.contentEdgeInsets.top + self.titleEdgeInsets.top;
                    imageFrame.origin.y = CGRectGetMaxY(titleFrame) + self.titleEdgeInsets.bottom + self.imageEdgeInsets.top;
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                    CGFloat minY = (contentSize.height- contentHeight)/2.0 + self.contentEdgeInsets.top;
                    titleFrame.origin.y =  minY + self.titleEdgeInsets.top;
                    imageFrame.origin.y = CGRectGetMaxY(titleFrame) + self.titleEdgeInsets.bottom + self.imageEdgeInsets.top;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    imageFrame.origin.y = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame);
                    titleFrame.origin.y =  CGRectGetMinY(imageFrame) - self.imageEdgeInsets.top - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame);
                    
                    break;
                case UIControlContentVerticalAlignmentFill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame.origin.y = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame);
                    titleFrame.origin.y = self.contentEdgeInsets.top + self.titleEdgeInsets.top;
                    titleFrame.size.height
                    = CGRectGetMinY(imageFrame) - self.imageEdgeInsets.top - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame);
                    break;
            }
        }
        
        self.imageView.frame = imageFrame;
        self.titleLabel.frame = titleFrame;
        
    } else if (self.imagePosition == GZMenuButtonImagePositionRight) {
        CGFloat imageLimitWidth = contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
        CGFloat imageLimitHeight = contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
        CGRect imageFrame = (CGRect){{0,0},imageSize};
        
        CGSize titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - CGRectGetWidth(imageFrame) - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fminf(titleSize.height, titleLimitSize.height);
        titleSize.width = fminf(titleLimitSize.width, titleSize.width);
        CGRect titleFrame = (CGRect){{0,0},titleSize};
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                titleFrame.origin.x =  self.contentEdgeInsets.left + self.titleEdgeInsets.left;
                imageFrame.origin.x  = CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + self.imageEdgeInsets.left;
                break;
            case UIControlContentHorizontalAlignmentCenter: {
                CGFloat contentWidth = CGRectGetWidth(titleFrame) + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + CGRectGetWidth(imageFrame) + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
                CGFloat minX = self.contentEdgeInsets.left + (contentSize.width- contentWidth)/2;
                titleFrame.origin.x = minX + self.titleEdgeInsets.left;
                imageFrame.origin.x =  CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + self.imageEdgeInsets.left;
            }
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame.origin.x = CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame);
                titleFrame.origin.x =CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame);
                break;
            case UIControlContentHorizontalAlignmentFill:
                // 图片按自身大小显示，剩余空间由标题占满
                imageFrame.origin.x = CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame);
                titleFrame.origin.x = self.contentEdgeInsets.left + self.titleEdgeInsets.left;
                titleFrame.size.width =  CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame);
                break;
        }
        
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                titleFrame.origin.y = self.contentEdgeInsets.top + self.titleEdgeInsets.top;
                imageFrame.origin.y = self.contentEdgeInsets.top + self.imageEdgeInsets.top;
                break;
            case UIControlContentVerticalAlignmentCenter:
                titleFrame.origin.y = self.contentEdgeInsets.top + self.titleEdgeInsets.top + (contentSize.height - (CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets)))/2;
                imageFrame.origin.y = self.contentEdgeInsets.top + self.imageEdgeInsets.top + (contentSize.height- (CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets)))/2;
                break;
            case UIControlContentVerticalAlignmentBottom:
                titleFrame.origin.y = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame);
                imageFrame.origin.y = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame);
                break;
            case UIControlContentVerticalAlignmentFill:
                titleFrame.origin.y = self.contentEdgeInsets.top + self.titleEdgeInsets.top;
                titleFrame.size.height = CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame);
                imageFrame.origin.y = self.contentEdgeInsets.top + self.imageEdgeInsets.top;
                imageFrame.size.height =  CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetMinY(imageFrame);
                break;
        }
        
        self.imageView.frame = imageFrame;
        self.titleLabel.frame = titleFrame;
    }
}

#pragma mark - Public methods

- (CGSize)buttonSize {
    if (CGSizeEqualToSize(self.actualButtonSize, CGSizeZero)) {
        CGFloat buttonWidth = GZMenuItemImageItemWidth;

        NSString *text = self.menuItem.title;
        BOOL isItemHasHorizonImage = (self.menuItem.imageNamed.length > 0) &&
        (self.imagePosition == GZMenuButtonImagePositionLeft || self.imagePosition == GZMenuButtonImagePositionRight);
        BOOL isItemHasVerticalImage = (self.menuItem.imageNamed.length > 0) &&
        (self.imagePosition == GZMenuButtonImagePositionTop || self.imagePosition == GZMenuButtonImagePositionBottom);
        
        if ([self.menuItem.imageNamed isEqualToString:GZMenuItemForwardImageName] ||
            [self.menuItem.imageNamed isEqualToString:GZMenuItemBackwardImageName]) {
            buttonWidth = GZMenuItemMoreItemWidth;
        }
        
        if (text.length > 0) {
            buttonWidth = [text sizeWithAttributes:@{NSFontAttributeName:self.menuItemFont ?: [UIFont systemFontOfSize:14]}].width;
            
            CGFloat maxWidth = self.maxSize.width-kTitleMargin*2;
            if (isItemHasHorizonImage) {
                maxWidth -= kImageInnerWidth;
            }
            
            if (buttonWidth > maxWidth) {
                buttonWidth = maxWidth;
            } else {
                buttonWidth += kTitleMargin * 2;
                if (isItemHasHorizonImage) {
                    buttonWidth += kImageInnerWidth;
                }
            }
            
            if (isItemHasVerticalImage) {
                if (buttonWidth < GZMenuItemImageItemWidth) {
                    buttonWidth = GZMenuItemImageItemWidth;
                }
            }
        }
        self.actualButtonSize = CGSizeMake(buttonWidth, self.maxSize.height);
    }
    return self.actualButtonSize;
}

#pragma mark - Private methods

- (void)setupConfig {
    if (_menuItem.title.length > 0) {
        [self setTitle:_menuItem.title forState:UIControlStateNormal];
    }
    if (_menuItem.imageNamed.length > 0) {
        NSString *imageName = _menuItem.imageNamed;
        UIImage *image;
        if ([imageName isEqualToString:GZMenuItemForwardImageName]) {
            image = [self createTriangleImageWithSize:CGSizeMake(kTriangleWidth, kTriangleHeight) tintColor:_menuItemTintColor isRight:NO];
        } else if ([imageName isEqualToString:GZMenuItemBackwardImageName]) {
            image = [self createTriangleImageWithSize:CGSizeMake(kTriangleWidth, kTriangleHeight) tintColor:_menuItemTintColor isRight:YES];
        } else {
            image = [UIImage imageNamed:imageName];
        }
        if (image) {
            [self setImage:image forState:UIControlStateNormal];
        }
    }
    if (_menuItemFont) {
        self.titleLabel.font = _menuItemFont;
    }
    if (_menuItemTintColor) {
        [self setTitleColor:_menuItemTintColor forState:UIControlStateNormal];
    }
    if (_menuItemHighlightColor) {
        self.highlightedColor = _menuItemHighlightColor;
    }
    [self addTarget:_menuItem.target action:_menuItem.action forControlEvents:UIControlEventTouchUpInside];
}


- (UIImage *)createTriangleImageWithSize:(CGSize)size tintColor:(UIColor *)tintColor isRight:(BOOL)isRight {
    
    UIImage *resultImage = nil;
    tintColor = tintColor ? tintColor : [UIColor whiteColor];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPath];
    if (!isRight) {
        [path moveToPoint:CGPointMake(0, size.height/2)];
        [path addLineToPoint:CGPointMake(size.width , 0)];
        [path addLineToPoint:CGPointMake(size.width, size.height)];
        [path closePath];
    } else {
        [path moveToPoint:CGPointMake(0, size.height)];
        [path addLineToPoint:CGPointMake(0 , 0)];
        [path addLineToPoint:CGPointMake(size.width, size.height/2)];
        [path closePath];
    }
    
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    [path fill];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark - Setter

- (void)setMenuItemFont:(UIFont *)menuItemFont {
    if (_menuItemFont == menuItemFont) {
        return;
    }
    _menuItemFont = menuItemFont;
    self.titleLabel.font = _menuItemFont;
    _actualButtonSize = CGSizeZero;
}

- (void)setMenuItemTintColor:(UIColor *)menuItemTintColor {
    if (_menuItemTintColor == menuItemTintColor) {
        return;
    }
    _menuItemTintColor = menuItemTintColor;
    [self setTitleColor:_menuItemTintColor forState:UIControlStateNormal];
}

- (void)setMenuItemHighlightColor:(UIColor *)menuItemHighlightColor {
    if (_menuItemHighlightColor == menuItemHighlightColor) {
        return;
    }
    _menuItemHighlightColor = menuItemHighlightColor;
    self.highlightedColor = _menuItemHighlightColor;
}

- (void)setImagePosition:(GZMenuButtonImagePosition)imagePosition {
    if (_imagePosition == imagePosition) {
        return;
    }
    _imagePosition = imagePosition;
    _actualButtonSize = CGSizeZero;
}

- (void)setMaxSize:(CGSize)maxSize {
    if (CGSizeEqualToSize(_maxSize, maxSize)) {
        return;
    }
    _maxSize = maxSize;
    _actualButtonSize = CGSizeZero;
}


@end
