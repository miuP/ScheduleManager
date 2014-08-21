//
//  TKBTextFieldWithButtonView.h
//  ScheduleManager
//
//  Created by kazuya on 8/21/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TKBTextFieldWithButtonViewDelegate;


@interface TKBTextFieldWithButtonView : UIView
@property (weak, nonatomic) id <TKBTextFieldWithButtonViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;


@end

@protocol TKBTextFieldWithButtonViewDelegate <NSObject>

- (void)didTappedButtonOnView:(TKBTextFieldWithButtonView *)view;

@end