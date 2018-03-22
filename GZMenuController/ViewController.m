//
//  ViewController.m
//  GZMenuController
//
//  Created by coze on 2018/3/16.
//  Copyright © 2018年 cozelight. All rights reserved.
//

#import "ViewController.h"
#import "GZMenuController.h"
#import "GZMenuContainer.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *textMenu1;
@property (weak, nonatomic) IBOutlet UIButton *imageMenu1;
@property (weak, nonatomic) IBOutlet UIButton *imageMenu2;
@property (weak, nonatomic) IBOutlet UIButton *imageMenu3;

@property (weak, nonatomic) IBOutlet UIButton *textMenu2;
@property (weak, nonatomic) IBOutlet UIButton *imageMenu4;
@property (weak, nonatomic) IBOutlet UIButton *imageMenu5;
@property (weak, nonatomic) IBOutlet UIButton *imageMenu6;

// configuration
@property (weak, nonatomic) IBOutlet UISwitch *isUnfold;
@property (weak, nonatomic) IBOutlet UISwitch *isArrowUp;
@property (weak, nonatomic) IBOutlet UIPickerView *imageDirection;

@property (nonatomic, assign) GZMenuButtonImagePosition imagePosition;
@property (nonatomic, strong) NSMutableArray *defaultItems;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *textItems;
@property (nonatomic, copy) NSArray *imageItems;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageDirection.dataSource = self;
    _imageDirection.delegate = self;
    
    _images = @[@"setting",@"photo",@"share",@"time",@"trash"];
    _defaultItems = [NSMutableArray array];
    
    GZMenuItem *item1 = [[GZMenuItem alloc] initWithTitle:@"复制" target:self action:@selector(test)];
    GZMenuItem *item2 = [[GZMenuItem alloc] initWithTitle:@"选择" target:self action:@selector(test)];
    GZMenuItem *item3 = [[GZMenuItem alloc] initWithTitle:@"转发" target:self action:@selector(test)];
    GZMenuItem *item4 = [[GZMenuItem alloc] initWithTitle:@"粘贴" target:self action:@selector(test)];
    GZMenuItem *item5 = [[GZMenuItem alloc] initWithTitle:@"查询" target:self action:@selector(test)];
    self.textItems = @[item1,item2,item3,item4,item5];
    
    NSString *image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item6 = [[GZMenuItem alloc] initWithTitle:@"复制" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item7 = [[GZMenuItem alloc] initWithTitle:@"选择" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item8 = [[GZMenuItem alloc] initWithTitle:@"转发" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item9 = [[GZMenuItem alloc] initWithTitle:@"粘贴" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item10 = [[GZMenuItem alloc] initWithTitle:@"查询" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item11 = [[GZMenuItem alloc] initWithTitle:@"转文字" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item12 = [[GZMenuItem alloc] initWithTitle:@"静音播放" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item13 = [[GZMenuItem alloc] initWithTitle:@"多选" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item14 = [[GZMenuItem alloc] initWithTitle:@"引用" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item15 = [[GZMenuItem alloc] initWithTitle:@"收藏" imageNamed:image target:self action:@selector(test)];
    image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item16 = [[GZMenuItem alloc] initWithTitle:@"撤回" imageNamed:image target:self action:@selector(test)];
//    self.imageItems = @[item6,item7,item8,item9,item10,item11];
    self.imageItems = @[item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16];
}

- (void)test {
    
}

- (IBAction)textMenuDidClick:(UIButton *)sender {
    GZMenuController *menu = [GZMenuController sharedMenuController];
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.textItems];
    [items addObjectsFromArray:self.defaultItems];
    menu.menuItems = items;
    if (self.isArrowUp.isOn) {
        menu.arrowDirection = GZMenuControllerArrowUp;
    } else {
        menu.arrowDirection = GZMenuControllerArrowDefault;
    }
    menu.menuContainer.unfoldDisplay = self.isUnfold.isOn;
    menu.menuContainer.imagePosition = self.imagePosition;
    menu.menuContainer.menuItemFont = [UIFont systemFontOfSize:14.0];
    
    [menu setTargetRect:sender.frame inView:self.view];
    [menu setMenuVisible:YES];
}

- (IBAction)imageMenuDidClick:(UIButton *)sender {
    GZMenuController *menu = [GZMenuController sharedMenuController];
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.imageItems];
    [items addObjectsFromArray:self.defaultItems];
    menu.menuItems = items;
    if (self.isArrowUp.isOn) {
        menu.arrowDirection = GZMenuControllerArrowUp;
    } else {
        menu.arrowDirection = GZMenuControllerArrowDown;
    }
    menu.menuContainer.unfoldDisplay = self.isUnfold.isOn;
    menu.menuContainer.imagePosition = self.imagePosition;
    menu.menuContainer.menuItemFont = [UIFont systemFontOfSize:10.0];
    
    [menu setTargetRect:sender.frame inView:self.view];
    [menu setMenuVisible:YES];
}

- (IBAction)addTextItem:(UIButton *)sender {
    NSString *text = [NSString stringWithFormat:@"%@",@(arc4random())];
    GZMenuItem *item = [[GZMenuItem alloc] initWithTitle:text target:self action:@selector(test)];
    [self.defaultItems addObject:item];
}

- (IBAction)addImageItem:(UIButton *)sender {
    NSString *text = [NSString stringWithFormat:@"%@",@(arc4random())];
    NSString *image = [self.images objectAtIndex:(arc4random()%5)];
    GZMenuItem *item = [[GZMenuItem alloc] initWithTitle:text imageNamed:image target:self action:@selector(test)];
    [self.defaultItems addObject:item];
}

- (IBAction)deleteItem:(UIButton *)sender {
    if (self.defaultItems.count > 0) {
        [self.defaultItems removeLastObject];
    }
}

- (IBAction)resetItem:(UIButton *)sender {
    [_defaultItems removeAllObjects];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"左";
    } else if (row == 1) {
        return @"右";
    } else if (row == 2) {
        return @"上";
    } else if (row == 3) {
        return @"下";
    } else {
        return @"左";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.imagePosition = (GZMenuButtonImagePosition)row;
}


@end
