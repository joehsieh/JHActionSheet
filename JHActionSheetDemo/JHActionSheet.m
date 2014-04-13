//
//  JHActionSheet.m
//  JHActionSheetDemo
//
//  Created by joehsieh on 4/4/14.
//  Copyright (c) 2014 JH. All rights reserved.
//

#import "JHActionSheet.h"

NSString *const kJHActionTitle = @"title";
NSString *const kJHActionTitleColor = @"titleColor";
NSString *const kJHActionBackgroundColor = @"backgroundColor";

CGFloat const kTopMarginOfCancelButton = 10.0;
CGFloat const kBottomMarginOfCancelButton = 10.0;
CGFloat const kTopOrBottomMarginOfLabel = 20.0;
CGFloat const kMinLeftOrRightMarginOfLabel = 20.0;
CGFloat const kLeftOrRightMarginOfContainerView = 20.0;

@interface JHContainerView : UIView
@property (nonatomic, assign) CGFloat separatorY;
@end

@implementation JHContainerView

- (void)drawRect:(CGRect)rect
{
    // draws transparent separator
    CGRect rectIntersection = CGRectIntersection(CGRectMake(0, separatorY, CGRectGetWidth(self.frame), kTopMarginOfCancelButton), rect);
    [[UIColor clearColor] setFill];
    UIRectFill(rectIntersection);

    // Draws four rounded corners
	CGFloat strokeWidth = 1.0;
	CGFloat cornerRadius = 6.0;
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);

    CGRect rrect = self.bounds;

    CGFloat radius = cornerRadius;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);

    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;

    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = 0.0;
    CGFloat midy = separatorY / 2.0;
    CGFloat maxy = separatorY;
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}
@synthesize separatorY;
@end

@interface JHActionSheet()
{
    // views
    NSMutableArray *buttons;
	NSMutableArray *lines;
    UILabel *messageLabel;
	UILabel *subMessageLabel;
    JHContainerView *containerView;
    UIButton *previousCancelButton;
    __weak UIView *targetView; // view which actionSheet attached.
    // data
    NSArray *buttonInfos;
    NSAttributedString *attributedMessage;
    NSAttributedString *attributedSubMessage;
    // callback
	JHActionCallback callback;
}
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *subMessageLabel;
@property (nonatomic, strong) JHContainerView *containerView;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, strong) NSArray *buttonInfos;
@property (nonatomic, strong) NSAttributedString *attributedMessage;
@property (nonatomic, strong) NSAttributedString *attributedSubMessage;
@property (nonatomic, copy) JHActionCallback callback;
@property (nonatomic, strong) UIButton *previousCancelButton;
@end

@implementation JHActionSheet

#pragma mark - Initial methods

- (instancetype)initWithAttributedMessage:(NSAttributedString *)inAttributedMessage subAttibutedMessage:(NSAttributedString *)inAttributedSubMessage buttonInfos:(NSArray *)inButtonInfos
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.attributedMessage = inAttributedMessage;
        self.attributedSubMessage = inAttributedSubMessage;
        self.buttonInfos = inButtonInfos;
    }
    return self;
}
- (instancetype)initWithAttributedMessage:(NSAttributedString *)inAttributedMessage buttonInfos:(NSArray *)inButtonInfos
{
    return [self initWithAttributedMessage:inAttributedMessage subAttibutedMessage:nil buttonInfos:buttons];
}

- (instancetype)initWithMessage:(NSString *)inMessage buttonInfos:(NSArray *)inButtonInfos
{
    return [self initWithAttributedMessage:[[NSAttributedString alloc] initWithString:inMessage] buttonInfos:inButtonInfos];
}

- (instancetype)initWithMessage:(NSString *)inMessage subMessage:(NSString *)inSubMessage buttonInfos:(NSArray *)inButtonInfos
{
    return [self initWithAttributedMessage:[[NSAttributedString alloc] initWithString:inMessage] subAttibutedMessage:[[NSAttributedString alloc] initWithString:inSubMessage] buttonInfos:buttons];
}

#pragma mark - Show and hide

- (void)showOnView:(UIView *)inView callback:(JHActionCallback)inCallback
{
    self.callback = inCallback;
    self.targetView = inView;
    
    self.frame = targetView.bounds;
    self.alpha = 0.0; // for animation
    
    // create actionSheet containerView
    self.containerView = [[JHContainerView alloc] init];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    // decides x and width of containerView
    CGRect rect = self.frame;
    rect.origin.x = kLeftOrRightMarginOfContainerView;
    rect.origin.y = CGRectGetMaxY(self.frame); // containerView is under screen at first
    rect.size.width = CGRectGetWidth(rect) - 2 * kLeftOrRightMarginOfContainerView;
    containerView.frame = rect;
    
    // adds a cancel button as the last button.
    NSMutableArray *buttonInfosWithCancel = [[NSMutableArray alloc] initWithArray:buttonInfos];
    NSDictionary* dismissAttributesDictionary =  @{kJHActionTitle:NSLocalizedString(@"Cancel", nil), kJHActionBackgroundColor:[UIColor whiteColor], kJHActionTitleColor:[UIColor blueColor]};
    [buttonInfosWithCancel addObject:dismissAttributesDictionary];
    self.buttonInfos = [buttonInfosWithCancel copy];
    
    // creates all UI components in actionSheet
    if (attributedMessage) {
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.frame) - 2 * kMinLeftOrRightMarginOfLabel, 0.0)];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.numberOfLines = 3;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];;
        messageLabel.attributedText = attributedMessage;
        messageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [containerView addSubview:messageLabel];
        [messageLabel sizeToFit];
        [self layoutIfNeeded];
        CGFloat messagePaddingFromHeadOrTail = (CGRectGetWidth(containerView.bounds) - CGRectGetWidth(messageLabel.frame)) / 2;
        CGRect rect = messageLabel.frame;
        rect.origin.x = messagePaddingFromHeadOrTail;
        rect.origin.y = kTopOrBottomMarginOfLabel;
        messageLabel.frame = rect;
    }
    
    if (attributedSubMessage && [attributedSubMessage length]) {
        self.subMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.bounds) - 2 * kMinLeftOrRightMarginOfLabel, 0.0)];
        subMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subMessageLabel.numberOfLines = 3;
        subMessageLabel.textAlignment = NSTextAlignmentCenter;
        subMessageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];;
        subMessageLabel.attributedText = attributedSubMessage;
        subMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [containerView addSubview:subMessageLabel];
        [subMessageLabel sizeToFit];
        [self layoutIfNeeded];
        CGFloat subMessagePaddingFromHeadOrTail = (CGRectGetWidth(containerView.bounds) - CGRectGetWidth(subMessageLabel.frame)) / 2;
        CGRect rect = subMessageLabel.frame;
        rect.origin.x = subMessagePaddingFromHeadOrTail;
        rect.origin.y = CGRectGetMaxY(messageLabel.frame) + kTopOrBottomMarginOfLabel;
        subMessageLabel.frame = rect;
    }
    
    CGFloat actionSheetHeight =  kTopOrBottomMarginOfLabel + (messageLabel ? CGRectGetHeight(messageLabel.frame) + kTopOrBottomMarginOfLabel: 0.0) + (subMessageLabel ? CGRectGetHeight(subMessageLabel.frame) + kTopOrBottomMarginOfLabel : 0.0) + [buttonInfos count] * 44.0 + kTopMarginOfCancelButton;
    
    if (buttonInfos) {
        if (!buttons) {
            self.buttons = [[NSMutableArray alloc] init];
        }
        if (!lines) {
            self.lines = [[NSMutableArray alloc] init];
        }
        CGFloat yOffset = 0.0;
        CGFloat buttonWidth = CGRectGetWidth(containerView.bounds);
        
        CGFloat buttonHeight = 44.0;
        CGFloat lineHeight = 1.0;
        CGFloat buttonsHeight = [buttonInfos count] * buttonHeight + kTopMarginOfCancelButton;
        yOffset = actionSheetHeight - buttonsHeight;
        
        for (NSUInteger i = 0 ; i < [buttonInfos count] ; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect rect = button.frame;
            rect.size.width = buttonWidth;
            rect.size.height = buttonHeight;
            button.frame = rect;
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:23.0];
            
            if (i == [buttonInfos count] - 1) {
                containerView.separatorY = yOffset;
                yOffset = yOffset + kTopMarginOfCancelButton;
                button.layer.cornerRadius = 6.0;
                button.layer.masksToBounds = YES;
            }
            else {
                // adds line
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, yOffset, buttonWidth, lineHeight)];
                lineView.backgroundColor = [UIColor grayColor];
                lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [lines addObject:lineView];
                [containerView addSubview:lineView];
                yOffset += lineHeight;
            }
            // adds button
            rect = button.frame;
            rect.origin.y = yOffset;
            button.frame = rect;
            [button setTitle:buttonInfos[i][kJHActionTitle] forState:UIControlStateNormal];
            [button setTitleColor:buttonInfos[i][kJHActionTitleColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            button.backgroundColor = buttonInfos[i][kJHActionBackgroundColor];
            button.tag = i;
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:button];
            [containerView addSubview:button];
            yOffset += buttonHeight;
            
            if (i == [buttonInfos count] - 2) {
                self.previousCancelButton = button;
                [self _updatePreviousCancelButtonLayout];
            }
        }
    }
    
    // decide y and height of containerView
    rect.size.height = actionSheetHeight;
    containerView.frame = rect;
    
    NSAssert(![self superview], @"view must have no super view");
    
    [self addSubview:containerView];
    [targetView addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
        CGRect rect = containerView.frame;
        rect.origin.y = CGRectGetHeight(self.bounds) - rect.size.height - kBottomMarginOfCancelButton;
        containerView.frame = rect;
    } completion:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _updatePreviousCancelButtonLayout];
}

- (void)_updatePreviousCancelButtonLayout
{
    if (!previousCancelButton) {
        return;
    }
    UIBezierPath *shapePath = [UIBezierPath bezierPathWithRoundedRect:previousCancelButton.bounds
                                                    byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                          cornerRadii:CGSizeMake(6.0, 6.0)];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    shapeLayer.frame = previousCancelButton.bounds;
    shapeLayer.path = shapePath.CGPath;
    previousCancelButton.layer.mask = shapeLayer;
}

- (void)buttonClicked:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = sender;
        self.callback(button.tag);
        [self dismiss];
    }
}

- (void)dismiss
{
    NSAssert([self superview], @"view must have super view");
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = containerView.frame;
        rect.origin.y = CGRectGetMaxY(self.frame);
        containerView.frame = rect;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [messageLabel removeFromSuperview];
        self.messageLabel = nil;
        
        [subMessageLabel removeFromSuperview];
        self.subMessageLabel = nil;
        
        for (UIButton *button in buttons) {
            NSAssert([button superview], @"view must have super view");
            [button removeFromSuperview];
        }
        [buttons removeAllObjects];
        self.buttons = nil;
        
        for (UIView *lineView in lines) {
            NSAssert([lineView superview], @"view must have super view");
            [lineView removeFromSuperview];
        }
        [lines removeAllObjects];
        self.lines = nil;
        
        [containerView removeFromSuperview];
        self.containerView = nil;
        
        [self removeFromSuperview];
        self.targetView = nil;
        
        self.previousCancelButton = nil;
    }];
}

#pragma mark - Properties

@synthesize callback;
@synthesize targetView;
@synthesize buttons;
@synthesize lines;
@synthesize messageLabel;
@synthesize subMessageLabel;
@synthesize containerView;
@synthesize buttonInfos;
@synthesize attributedMessage;
@synthesize attributedSubMessage;
@synthesize previousCancelButton;
@end
