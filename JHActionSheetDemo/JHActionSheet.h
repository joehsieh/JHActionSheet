//
//  JHActionSheet.h
//  JHActionSheetDemo
//
//  Created by joehsieh on 4/4/14.
//  Copyright (c) 2014 JH. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kJHActionTitle;
extern NSString *const kJHActionTitleColor;
extern NSString *const kJHActionBackgroundColor;

typedef void (^JHActionCallback)(NSUInteger index);
@interface JHActionSheet : UIView

- (instancetype)initWithAttributedMessage:(NSAttributedString *)inAttributedMessage buttonInfos:(NSArray *)inButtonInfos;
- (instancetype)initWithAttributedMessage:(NSAttributedString *)inAttributedMessage subAttibutedMessage:(NSAttributedString *)inAttributedSubMessage buttonInfos:(NSArray *)inButtonInfos;
- (instancetype)initWithMessage:(NSString *)inMessage buttonInfos:(NSArray *)inButtonInfos;
- (instancetype)initWithMessage:(NSString *)inMessage subMessage:(NSString *)inSubMessage buttonInfos:(NSArray *)inButtonInfos;

- (void)showOnView:(UIView *)inView callback:(JHActionCallback)inCallback;
- (void)dismiss;
@end
