//
//  VKDevScriptModule.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/17.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKDevScriptModule.h"
#import "VKDevMenu.h"
#import "VKScriptConsole.h"
#import "VKDevToolDefine.h"
#import "VKDevTipView.h"
#import "VKUIKitMarco.h"
#import "VKDevTool.h"

@interface VKDevScriptModule ()<VKDevMenuDelegate,VKScriptConsoleDelegate>

@property (nonatomic,strong) VKDevMenu *devMenu;

@property (nonatomic,strong) VKScriptConsole *devConsole;

@property (nonatomic,assign) BOOL isSelecting;

@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;

@end

@implementation VKDevScriptModule


-(instancetype)init
{
    self = [super init];
    if (self) {
        _isSelecting = NO;
        
        _devMenu = [[VKDevMenu alloc]init];
        _devMenu.delegate = self;
        
    }
    return self;
}

-(UIView *)moduleView
{
    return self.devConsole;
}

-(void)showModuleMenu
{
    [self.devMenu show];
}

-(void)hideModuleMenu{
    [self.devMenu hide];
}

#pragma mark VKDevMenuDelegate
-(NSString *)needDevMenuTitle
{
    return @"VKDevTool";
}

-(NSArray *)needDevMenuItemsArray
{
    return @[@"ChangeTarget",@"exit",@"clearInput",@"clearOutput"];
}

-(void)didClickMenuWithButtonIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            [self VKScriptConsoleExchangeTargetAction];
        }
            break;
        case 1:
        {
            [self VKScriptConsoleExitAction];
        }
            break;
        case 2:
        {
            self.devConsole.inputView.text = @"";
        }
            break;
        case 3:
        {
            self.devConsole.inputView.text = @"";

        }
            break;
            
        default:
            break;
    }
}


#pragma mark DebugScript
-(void)VKScriptConsoleExitAction
{
    self.isSelecting = NO;
    [VKDevTool gotoMainModule];
}

-(void)VKScriptConsoleExchangeTargetAction
{
    [self.devConsole hideConsole];
    self.isSelecting = YES;
}

-(void)startScriptDebug
{
    self.isSelecting = YES;
}

-(void)setIsSelecting:(BOOL)isSelecting
{
    self.tapGesture.enabled = isSelecting;
    if (isSelecting) {
        [VKDevTipView showVKDevTip:@"请选择一个界面View元素" autoHide:NO];
    }else{
        [VKDevTipView hideVKDevTip];
    }
    
}

-(UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
#ifdef VKDevMode
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        // View selection
        UITapGestureRecognizer *selectionTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchTap:)];
        [window addGestureRecognizer:selectionTapGR];
        selectionTapGR.enabled = NO;
        _tapGesture = selectionTapGR;
#endif
        
    }
    return _tapGesture;
}


-(VKScriptConsole *)devConsole
{
    if (!_devConsole) {
#ifdef VKDevMode
        VKScriptConsole *scriptv = [[VKScriptConsole alloc]initWithFrame:CGRectMake(0, 0, VK_AppScreenWidth, VK_AppScreenHeight)];
        _devConsole = scriptv;
        scriptv.delegate = self;
#endif
    }
    return _devConsole;
}


-(void)handleTouchTap:(UITapGestureRecognizer *)tapGR
{
#ifdef VKDevMode
    UIView *gesturetarget = tapGR.view;
    CGPoint tapPointInView = [tapGR locationOfTouch:0 inView:gesturetarget];
    UIView *touchview = [self viewForSelectionAtPoint:tapPointInView];
    
    [gesturetarget addSubview:self.devConsole];
    self.devConsole.target = touchview;
    [self.devConsole showConsole];
    
    self.isSelecting = NO;
#endif
}


- (UIView *)viewForSelectionAtPoint:(CGPoint)tapPointInWindow
{
    // Select in the window that would handle the touch, but don't just use the result of hitTest:withEvent: so we can still select views with interaction disabled.
    // Default to the the application's key window if none of the windows want the touch.
    UIWindow *windowForSelection = [[UIApplication sharedApplication] keyWindow];
    
    // Select the deepest visible view at the tap point. This generally corresponds to what the user wants to select.
    return [[self recursiveSubviewsAtPoint:tapPointInWindow inView:windowForSelection skipHiddenViews:YES] lastObject];
}


- (NSArray *)recursiveSubviewsAtPoint:(CGPoint)pointInView inView:(UIView *)view skipHiddenViews:(BOOL)skipHidden
{
    NSMutableArray *subviewsAtPoint = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        BOOL isHidden = subview.hidden || subview.alpha < 0.01;
        if (skipHidden && isHidden) {
            continue;
        }
        
        BOOL subviewContainsPoint = CGRectContainsPoint(subview.frame, pointInView);
        if (subviewContainsPoint) {
            [subviewsAtPoint addObject:subview];
        }
        
        // If this view doesn't clip to its bounds, we need to check its subviews even if it doesn't contain the selection point.
        // They may be visible and contain the selection point.
        if (subviewContainsPoint || !subview.clipsToBounds) {
            CGPoint pointInSubview = [view convertPoint:pointInView toView:subview];
            [subviewsAtPoint addObjectsFromArray:[self recursiveSubviewsAtPoint:pointInSubview inView:subview skipHiddenViews:skipHidden]];
        }
    }
    return subviewsAtPoint;
}


@end

