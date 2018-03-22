//
//  GZMenuController.m
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import "GZMenuController.h"
#import "GZMenuWindow.h"
#import "GZMenuContainer.h"

NSNotificationName const GZMenuControllerWillShowMenuNotification = @"GZMenuControllerWillShowMenuNotification";
NSNotificationName const GZMenuControllerDidShowMenuNotification = @"GZMenuControllerDidShowMenuNotification";
NSNotificationName const GZMenuControllerWillHideMenuNotification = @"GZMenuControllerWillHideMenuNotification";
NSNotificationName const GZMenuControllerDidHideMenuNotification = @"GZMenuControllerDidHideMenuNotification";
NSNotificationName const GZMenuControllerMenuFrameDidChangeNotification = @"GZMenuControllerMenuFrameDidChangeNotification";

@interface GZMenuController ()

@property (nonatomic, strong, readwrite) GZMenuContainer *menuContainer;
@property (nonatomic, weak) UIView *targetView;

@end

@implementation GZMenuController

#pragma mark - Public methods

+ (GZMenuController *)sharedMenuController {
    static GZMenuController *sharedMenuController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMenuController = [[GZMenuController alloc] init];
    });
    
    return sharedMenuController;
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated {
    _menuVisible = menuVisible;
    [[GZMenuWindow sharedWindow] setMenu:self.menuContainer visible:menuVisible animation:animated];
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView {
    if (!self.menuContainer) {
        return;
    }
    self.targetView = targetView;
    [self.menuContainer setTargetRect:targetRect inView:targetView];
}

- (void)update {
    [self.menuContainer updateMenuView];
}

#pragma mark - Setter

- (void)setMenuVisible:(BOOL)menuVisible {
    [self setMenuVisible:menuVisible animated:NO];
}

- (void)setArrowDirection:(GZMenuControllerArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    self.menuContainer.arrowDirection = arrowDirection;
}

- (void)setMenuItems:(NSArray<GZMenuItem *> *)menuItems {
    _menuItems = menuItems;
    self.menuContainer.menuItems = menuItems;
}

#pragma mark - Getter

- (GZMenuContainer *)menuContainer {
    if (!_menuContainer) {
        _menuContainer = [[GZMenuContainer alloc] init];
    }
    return _menuContainer;
}

- (CGRect)menuFrame {
    return self.menuContainer ? self.menuContainer.frame :CGRectZero;
}

@end


@implementation GZMenuItem

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [self initWithTitle:title imageNamed:nil target:target action:action];
}

- (instancetype)initWithTitle:(nullable NSString *)title
                   imageNamed:(nullable NSString *)imageNamed
                       target:(id)target
                       action:(SEL)action {
    self = [super init];
    if (self) {
        _title = title;
        _imageNamed = imageNamed;
        _target = target;
        _action = action;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([self isKindOfClass:[object class]]) {
        return [self hash] == [object hash];
    }
    return [super isEqual:object];
}

- (NSUInteger)hash {
    return self.description.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@%@%@",self.title,self.imageNamed,[self.target class],NSStringFromSelector(self.action)];
}

@end
