//
//  TKBAddViewController.h
//  ScheduleManager
//
//  Created by kazuya on 8/15/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TKBAddViewControllerDelegate;

@interface TKBAddViewController : UIViewController
@property (weak, nonatomic) id <TKBAddViewControllerDelegate> delegate;

@end


@protocol TKBAddViewControllerDelegate <NSObject>

- (void)didTapCompleteButtonInViewController:(TKBAddViewController *)vc;

@end