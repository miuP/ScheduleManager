//
//  TKBTextFieldWithButtonView.m
//  ScheduleManager
//
//  Created by kazuya on 8/21/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "TKBTextFieldWithButtonView.h"

@implementation TKBTextFieldWithButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)buttonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTappedButtonOnView:)]) {
        [self.delegate didTappedButtonOnView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
