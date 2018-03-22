//
//  GZMenuView.m
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import "GZMenuView.h"

#define kItemTextHeight 35
#define kItemImageHeight 50

@interface GZMenuView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL isAllTextItem;

@property (nonatomic, assign) CGFloat actualMenuWidth;
@property (nonatomic, assign) CGFloat singleMenuHeight;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray <__kindof NSNumber *> *pageCounts;
@property (nonatomic, strong) NSMutableArray <__kindof NSNumber *> *pageRemainWidth;

@property (nonatomic, strong) GZMenuButton *forwardButton;
@property (nonatomic, strong) GZMenuButton *backwardButton;

@property (nonatomic, strong) NSCache *menuItemCache;

@end

@implementation GZMenuView

#pragma mark - Life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.contentView];
        _singleMenuHeight = kItemTextHeight;
    }
    return self;
}

#pragma mark - Public methods

- (void)updateLayout {
    if (self.menuItems.count == 0) {
        [self reset];
        return;
    }
    
    [self.menuItems enumerateObjectsUsingBlock:^(GZMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.imageNamed.length > 0) {
            self.isAllTextItem = NO;
        }
    }];
    
    CGSize size = CGSizeZero;
    if (!self.isAllTextItem && self.unfoldDisplay) {
        size = [self _layoutUnfoldMenuView];
    } else {
        size = [self _layoutSingleMenuViews];
    }
    
    self.frame = (CGRect){.size = size};
    self.contentView.frame = self.bounds;
}

#pragma mark - Layout

- (CGSize)_layoutUnfoldMenuView {
    CGSize menuSize = CGSizeZero;
    
    if (_imagePosition == GZMenuButtonImagePositionTop || _imagePosition == GZMenuButtonImagePositionBottom) {
        self.singleMenuHeight = kItemImageHeight + (_menuItemFont?_menuItemFont.lineHeight:[UIFont systemFontOfSize:14].lineHeight);
    } else {
        self.singleMenuHeight = kItemTextHeight;
    }
    
    if (self.actualMenuWidth == 0.0) { // 计算出menu的实际宽度
        NSUInteger itemCount = self.menuItems.count;
        CGFloat totalItemWidth = itemCount * GZMenuItemImageItemWidth;
        CGFloat actualMenuWidth = self.maxMenuViewWidth - self.menuEdgeInsets.left - self.menuEdgeInsets.right - self.cornerRadius * 2;
        
        if (totalItemWidth < actualMenuWidth) {
            actualMenuWidth = totalItemWidth + self.cornerRadius * 2;
        } else {
            NSUInteger column = actualMenuWidth / GZMenuItemImageItemWidth;
            actualMenuWidth = column * GZMenuItemImageItemWidth + self.cornerRadius * 2;
        }
        
        self.actualMenuWidth = actualMenuWidth;
    }
    
    // layout menu button
    // 清空之前视图
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __block NSUInteger row = 1;
    __block CGFloat itemOriginX = self.cornerRadius;
    __block CGFloat itemOriginY = 0.0;
    
    [self.menuItems enumerateObjectsUsingBlock:^(GZMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GZMenuButton *button = [self createButtonWithItem:obj];
        // 判断是否需要换行
        if (itemOriginX + GZMenuItemImageItemWidth > self.actualMenuWidth) {
            row += 1;
            itemOriginX = self.cornerRadius;
            itemOriginY += self.singleMenuHeight;
        }
        button.frame = CGRectMake(itemOriginX, itemOriginY, GZMenuItemImageItemWidth,  self.singleMenuHeight);
        itemOriginX += GZMenuItemImageItemWidth;
        [self.contentView addSubview:button];
    }];
    
    menuSize = CGSizeMake(self.actualMenuWidth, self.singleMenuHeight * row);
    
    return menuSize;
}

/*
 1. 循环计算所有item宽度
 2. 确定总长度，是否需要分页
 3. 需要分页，则总长度对屏宽求余，余值均分，均分到各页
 4. 最后得出实际menu宽度
 5. 计算分页，根据实际menu宽度，和最小item宽度计算每一页的item，同时保存每一页的冗余长度
 layout排版，当前页冗余长度除以当前页item数量，即为每个item分配到的多余宽度，根据分页情况layout，同时每个item宽度＝计算宽度＋多余宽度
 */
- (CGSize)_layoutSingleMenuViews {
    CGSize menuSize = CGSizeZero;
    
    NSUInteger itemCount = self.menuItems.count;
    
    if (self.isAllTextItem == NO && (_imagePosition == GZMenuButtonImagePositionTop || _imagePosition == GZMenuButtonImagePositionBottom)) {
        self.singleMenuHeight = kItemImageHeight + (_menuItemFont?_menuItemFont.lineHeight:[UIFont systemFontOfSize:14].lineHeight);
    } else {
        self.singleMenuHeight = kItemTextHeight;
    }
    
    if (self.actualMenuWidth == 0.0) { // 计算出menu的实际宽度
        __block CGFloat totalItemWidth = 0;
        __block CGFloat actualMenuWidth = self.maxMenuViewWidth - self.menuEdgeInsets.left - self.menuEdgeInsets.right;
        
        [self.menuItems enumerateObjectsUsingBlock:^(GZMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GZMenuButton *button = [self createButtonWithItem:obj];
            totalItemWidth += button.buttonSize.width;
        }];
        
        if (totalItemWidth > actualMenuWidth) {
            actualMenuWidth -= 2 * GZMenuItemMoreItemWidth;
            NSUInteger pageCount = (int)totalItemWidth / (int)actualMenuWidth + 1;
            CGFloat tempWidth = totalItemWidth / (CGFloat)pageCount;
            CGFloat remainWidth = actualMenuWidth - tempWidth;
            actualMenuWidth = tempWidth + (remainWidth / (CGFloat)pageCount) + 2 * GZMenuItemMoreItemWidth;
        } else {
            actualMenuWidth = totalItemWidth;
            [self.pageCounts addObject:@(itemCount)];
            [self.pageRemainWidth addObject:@(0)];
        }
        
        self.actualMenuWidth = actualMenuWidth;
    }
    
    if (self.pageCounts.count == 0) { //进行分页
        __block CGFloat totalItemWidth = GZMenuItemMoreItemWidth;
        [self.menuItems enumerateObjectsUsingBlock:^(GZMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            GZMenuButton *button = [self createButtonWithItem:obj];
            
            BOOL isLastIdx = (idx == itemCount - 1);
            BOOL isTooWide = (totalItemWidth + button.buttonSize.width >= self.actualMenuWidth);
            
            if (isTooWide || isLastIdx) { // 分页
                
                __block NSUInteger alreadyPage = 0;
                [self.pageCounts enumerateObjectsUsingBlock:^(__kindof NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    alreadyPage += obj.unsignedIntegerValue;
                }];
                
                if (idx >= alreadyPage) {
                    CGFloat pageRemainWidth = self.actualMenuWidth - totalItemWidth;
                    if (!isTooWide && isLastIdx) {
                        idx += 1;
                        pageRemainWidth = self.actualMenuWidth - totalItemWidth - button.buttonSize.width;
                    }
                    [self.pageCounts addObject:@(idx - alreadyPage)];
                    [self.pageRemainWidth addObject:@(pageRemainWidth)];
                }
                
                if (isTooWide && isLastIdx) { // 最后一个
                    [self.pageCounts addObject:@(1)];
                    CGFloat pageRemainWidth = self.actualMenuWidth - button.buttonSize.width - 2 * GZMenuItemMoreItemWidth;
                    if (pageRemainWidth < 0) {
                        pageRemainWidth = 0;
                    }
                    [self.pageRemainWidth addObject:@(pageRemainWidth)];
                }
                
                totalItemWidth = 2 * GZMenuItemMoreItemWidth + button.buttonSize.width;
                
            } else {
                totalItemWidth += button.buttonSize.width;
            }
        }];
    }
    
    // layout menu button
    
    // 清空之前视图
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __block NSUInteger startIndex = 0;
    __block NSUInteger endIndex = 0;
    if (self.currentPage == 0) {
        startIndex = 0;
        endIndex = [self.pageCounts.firstObject unsignedIntegerValue];
    } else {
        [self.pageCounts enumerateObjectsUsingBlock:^(__kindof NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < self.currentPage) {
                startIndex += obj.unsignedIntegerValue;
            } else if (idx == self.currentPage) {
                endIndex = startIndex + obj.unsignedIntegerValue;
                *stop = YES;
            }
        }];
    }
    
    endIndex -= 1;
    CGFloat itemRemainWidth = [[self.pageRemainWidth objectAtIndex:self.currentPage] doubleValue] / [[self.pageCounts objectAtIndex:self.currentPage] doubleValue];
    
    BOOL isNeedLine = self.isAllTextItem;
    __block CGFloat itemOriginX = 0;
    
    if (self.currentPage > 0) { // 显示向前按钮
        GZMenuButton *button = self.forwardButton;
        button.enabled = !(self.currentPage == 0);
        button.frame = CGRectMake(itemOriginX, 0, button.buttonSize.width, self.singleMenuHeight);
        itemOriginX += button.frame.size.width;
        [self.contentView addSubview:button];
        
        if (isNeedLine) {
            UIView *line = [UIView new];
            line.backgroundColor = self.menuItemTintColor ? : [UIColor whiteColor];
            line.frame = CGRectMake(itemOriginX, 0, 1/[UIScreen mainScreen].scale, self.singleMenuHeight);
            [self.contentView addSubview:line];
        }
    }
    
    [self.menuItems enumerateObjectsUsingBlock:^(GZMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= startIndex && idx <= endIndex) {
            GZMenuButton *button = [self createButtonWithItem:obj];
            button.frame = CGRectMake(itemOriginX, 0, button.buttonSize.width + itemRemainWidth, button.buttonSize.height);
            itemOriginX += button.frame.size.width;
            [self.contentView addSubview:button];
            
            if (isNeedLine && idx < endIndex) {
                UIView *line = [UIView new];
                line.backgroundColor = self.menuItemTintColor ? : [UIColor whiteColor];
                line.frame = CGRectMake(itemOriginX, 0, 1/[UIScreen mainScreen].scale, self.singleMenuHeight);
                [self.contentView addSubview:line];
            }
        }
    }];
    
    if (self.pageCounts.count > 1) { // 显示向后按钮
        GZMenuButton *button = self.backwardButton;
        button.enabled = !(self.currentPage >= self.pageCounts.count-1);
        CGFloat width = button.buttonSize.width;
        button.frame = CGRectMake(self.actualMenuWidth-width, 0, width, self.singleMenuHeight);
        [self.contentView addSubview:button];
        
        if (isNeedLine) {
            UIView *line = [UIView new];
            line.backgroundColor = self.menuItemTintColor ? : [UIColor whiteColor];
            line.frame = CGRectMake(self.actualMenuWidth-width, 0, 1/[UIScreen mainScreen].scale, self.singleMenuHeight);
            [self.contentView addSubview:line];
        }
    }
    
    menuSize = CGSizeMake(self.actualMenuWidth, self.singleMenuHeight);
    
    return menuSize;
}

#pragma mark - Action

- (void)forward:(UIButton *)btn {
    if (self.currentPage == 0) {
        return;
    }
    self.currentPage --;
    self.forwardButton.enabled = !(self.currentPage == 0);
    self.backwardButton.enabled = !(self.currentPage >= self.pageCounts.count-1);
    [self _layoutSingleMenuViews];
}

- (void)backward:(UIButton *)btn {
    if (self.currentPage >= self.pageCounts.count-1) {
        return;
    }
    self.currentPage ++;
    self.forwardButton.enabled = !(self.currentPage == 0);
    self.backwardButton.enabled = !(self.currentPage >= self.pageCounts.count-1);
    [self _layoutSingleMenuViews];
}

#pragma mark - Private methods

- (void)reset {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.pageCounts removeAllObjects];
    [self.pageRemainWidth removeAllObjects];
    self.currentPage = 0;
    self.actualMenuWidth = 0.0;
    self.isAllTextItem = YES;
}

- (GZMenuButton *)createButtonWithItem:(GZMenuItem *)menuItem {
    GZMenuButton *button = [self.menuItemCache objectForKey:menuItem.description];
    if (!button) {
        button = [GZMenuButton menuButtonWithMenuItem:menuItem];
        [self.menuItemCache setObject:button forKey:menuItem.description cost:1];
    }
    
    button.imagePosition = self.imagePosition;
    button.menuItemFont = self.menuItemFont;
    button.menuItemTintColor = self.menuItemTintColor;
    button.menuItemHighlightColor = self.menuItemHighlightColor;
    button.maxSize = CGSizeMake(self.maxMenuViewWidth-self.menuEdgeInsets.left-self.menuEdgeInsets.right, self.singleMenuHeight);
    
    return button;
}

#pragma mark - Setter

- (void)setMenuItems:(NSArray<GZMenuItem *> *)menuItems {
    if (_menuItems == menuItems) {
        return;
    }
    _menuItems = menuItems;
    [self reset];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    self.contentView.layer.cornerRadius = cornerRadius;
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = _cornerRadius;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (NSMutableArray *)pageCounts {
    if (!_pageCounts) {
        _pageCounts = [NSMutableArray array];
    }
    return _pageCounts;
}

- (NSMutableArray<NSNumber *> *)pageRemainWidth {
    if (!_pageRemainWidth) {
        _pageRemainWidth = [NSMutableArray array];
    }
    return _pageRemainWidth;
}

- (GZMenuButton *)forwardButton {
    if (!_forwardButton) {
        GZMenuItem *forwardItem = [[GZMenuItem alloc] initWithTitle:nil imageNamed:GZMenuItemForwardImageName target:self action:@selector(forward:)];
        _forwardButton = [self createButtonWithItem:forwardItem];
    }
    return _forwardButton;
}

- (GZMenuButton *)backwardButton {
    if (!_backwardButton) {
        GZMenuItem *backwardItem = [[GZMenuItem alloc] initWithTitle:nil imageNamed:GZMenuItemBackwardImageName target:self action:@selector(backward:)];
        _backwardButton = [self createButtonWithItem:backwardItem];
    }
    return _backwardButton;
}

- (NSCache *)menuItemCache {
    if (!_menuItemCache) {
        _menuItemCache = [[NSCache alloc] init];
    }
    return _menuItemCache;
}

@end

