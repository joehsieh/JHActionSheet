//
//  JHViewController.m
//  JHActionSheetDemo
//
//  Created by joehsieh on 4/4/14.
//  Copyright (c) 2014 JH. All rights reserved.
//

#import "JHViewController.h"
#import "JHActionSheet.h"

@interface JHViewController ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation JHViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor whiteColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[view setShouldGroupAccessibilityChildren:YES];
    self.view = view;
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:NSLocalizedString(@"Click it!", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self _layoutViews];
    [self.view addSubview:button];
}

- (void)_layoutViews
{
    CGFloat buttonWidth = 100.0;
    CGFloat buttonHeight = 44.0;
    button.frame = CGRectMake((CGRectGetWidth(self.view.frame) - buttonWidth) / 2.0,(CGRectGetHeight(self.view.frame) - buttonHeight) / 2.0, buttonWidth, buttonHeight);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showActionSheet:(id)sender
{
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"This is a demo of JHActionSheet", nil) attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}];
    
    NSAttributedString *attributedSubMessage = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Hello!", nil)  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0]}];
    
    NSArray *buttons = @[
                         @{kJHActionTitle:NSLocalizedString(@"Item1", nil), kJHActionTitleColor:[UIColor orangeColor], kJHActionBackgroundColor:[UIColor darkGrayColor]},
                         @{kJHActionTitle:NSLocalizedString(@"Item2", nil), kJHActionTitleColor:[UIColor magentaColor], kJHActionBackgroundColor:[UIColor cyanColor]},
                          @{kJHActionTitle:NSLocalizedString(@"Item3", nil), kJHActionTitleColor:[UIColor greenColor], kJHActionBackgroundColor:[UIColor whiteColor]}];
    
    JHActionSheet *actionSheet = [[JHActionSheet alloc] initWithAttributedMessage:attributedMessage subAttibutedMessage:attributedSubMessage buttonInfos:buttons];
    
    [actionSheet showOnView:self.view callback:^(NSUInteger index) {
        NSLog(@"%d", index);
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	CGRect frame = self.view.frame;
    
	if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
		frame.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
		frame.size.height = CGRectGetHeight([UIScreen mainScreen].bounds);
	}
	else {
		frame.size.width = CGRectGetHeight([UIScreen mainScreen].bounds);
		frame.size.height = CGRectGetWidth([UIScreen mainScreen].bounds);
	}
	self.view.frame = frame;
	[self _layoutViews];
}

@synthesize button;
@end
