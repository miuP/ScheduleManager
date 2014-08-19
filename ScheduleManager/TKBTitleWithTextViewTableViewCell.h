//
//  TKBTitleWithTextViewTableViewCell.h
//  ScheduleManager
//
//  Created by kazuya on 8/16/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKBTitleWithTextViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
