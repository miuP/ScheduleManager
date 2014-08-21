//
//  TKBScheduleViewController.m
//  ScheduleManager
//
//  Created by kazuya on 8/19/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "TKBScheduleViewController.h"
#import "TKBTextFieldWithButtonView.h"

@interface TKBScheduleViewController () <TKBTextFieldWithButtonViewDelegate, UITextFieldDelegate, UITextViewDelegate> {
    BOOL _isEditing;
    NSInteger _row;
    float _subjectTitleViewWidth;
    TKBTextFieldWithButtonView *_textFieldWithButtonView;
    UILabel *_editedLabel;
    NSMutableArray *_completeColors;
    NSMutableArray *_labels;
}
@property (weak, nonatomic) IBOutlet UIView *subjectsSuperView;
@property (weak, nonatomic) IBOutlet UITextView *memoTextView;
@property (weak, nonatomic) IBOutlet UIView *memoSuperView;

@end

@implementation TKBScheduleViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _row = 5;
    _memoTextView.delegate = self;
    _memoTextView.editable = NO;
    _memoTextView.text = [_schedule objectForKey:@"Memo"];
    [_memoSuperView.layer setBorderWidth:2.0];
    [_memoSuperView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.title = [_schedule objectForKey:@"Title"];
    _isEditing = NO;
    _completeColors = [NSMutableArray arrayWithCapacity:9];
    _completeColors[0] = [UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:0.4];
    _completeColors[1] = [UIColor colorWithRed:1.0 green:0.9 blue:0.8 alpha:0.4];
    _completeColors[2] = [UIColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:0.4];
    _completeColors[3] = [UIColor colorWithRed:0.9 green:1.0 blue:0.8 alpha:0.4];
    _completeColors[4] = [UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:0.4];
    _completeColors[5] = [UIColor colorWithRed:0.8 green:1.0 blue:0.9 alpha:0.4];
    _completeColors[6] = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:0.4];
    _completeColors[7] = [UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:0.4];
    _completeColors[8] = [UIColor colorWithRed:0.8 green:1.0 blue:1.0 alpha:0.4];
    _labels = [@[] mutableCopy];
    [self prepareView];
    
    
}

- (void)prepareView
{
    //文字入力viewの作成
    _textFieldWithButtonView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TKBTextFieldWithButtonView class]) owner:self options:nil] firstObject];
    [self.view addSubview:_textFieldWithButtonView];
    [_textFieldWithButtonView.button setTitle:@"確定" forState:UIControlStateNormal];
    _textFieldWithButtonView.delegate = self;
    _textFieldWithButtonView.textField.delegate = self;
    
    _textFieldWithButtonView.button.layer.borderColor = [UIColor grayColor].CGColor;
    _textFieldWithButtonView.button.layer.borderWidth = 1.0f;
    _textFieldWithButtonView.button.layer.cornerRadius = 7.5f;
    
    _subjectTitleViewWidth = 140;
    //navigationBarに編集ボタンを追加
    NSArray *subjects = [_schedule objectForKey:@"Subjects"];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"編集"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(didTapEditButton)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    //Subjectを元に各科目をviewにおこしていく
    NSInteger subjectNum = [[_schedule objectForKeyedSubscript:@"SubjectNumber"] integerValue];
    NSInteger column = 0;
    NSInteger columns[subjectNum];
    for (int i = 0; i < subjectNum; i++) {
        NSInteger anItemNumber = [[(NSDictionary *)subjects[i] objectForKey:@"ItemNumber"] integerValue];
        column = column + (anItemNumber/(_row + 1)) + 1;
        columns[i] = (anItemNumber/(_row + 1)) + 1;
    }
    
    NSInteger curColumn = 0;
    for (int i = 0; i < subjectNum; i++) {
        UILabel *aSubjectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                               _subjectsSuperView.frame.size.height/column * curColumn,
                                                                               _subjectTitleViewWidth,
                                                                               _subjectsSuperView.frame.size.height/column * columns[i])];
        aSubjectTitleLabel.tag = [[NSString stringWithFormat:@"%d0", i + 1] integerValue];
        [aSubjectTitleLabel.layer setBorderWidth:0.4];
        [aSubjectTitleLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
        aSubjectTitleLabel.text = [(NSDictionary *)subjects[i] objectForKey:@"Title"];
        [_subjectsSuperView addSubview:aSubjectTitleLabel];
        aSubjectTitleLabel.textAlignment = NSTextAlignmentCenter;
        aSubjectTitleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
        [aSubjectTitleLabel addGestureRecognizer:tapGesture];
        curColumn = curColumn + columns[i];
    }
    
    curColumn = 0;
    
    for (int i = 0; i < subjectNum; i++) {
        NSInteger anItemNumber = [[(NSDictionary *)subjects[i] objectForKey:@"ItemNumber"] integerValue];
        NSArray *anItemTitles  = [(NSDictionary *)subjects[i] objectForKey:@"ItemTitles"];
        NSArray *aComplete     = [(NSDictionary *)subjects[i] objectForKey:@"Complete"];
        if (anItemNumber <= _row) {
            for (int j = 0; j < anItemNumber; j++) {
                UILabel *anItemLabel = [[UILabel alloc] initWithFrame:CGRectMake((_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/anItemNumber * j + _subjectTitleViewWidth,
                                                                                _subjectsSuperView.frame.size.height/column * curColumn,
                                                                                (_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/anItemNumber,
                                                                                _subjectsSuperView.frame.size.height/column)];
                [anItemLabel.layer setBorderWidth:0.4];
                [anItemLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
                anItemLabel.textAlignment = NSTextAlignmentCenter;
                anItemLabel.userInteractionEnabled = YES;
                anItemLabel.text = anItemTitles[j];
                if ([aComplete[j] boolValue]) anItemLabel.backgroundColor = _completeColors[i];
                [_subjectsSuperView addSubview:anItemLabel];
                anItemLabel.tag = [[NSString stringWithFormat:@"%d%d", i + 1, j + 1] integerValue];
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
                [anItemLabel addGestureRecognizer:tapGesture];
                [_labels addObject:anItemLabel];
            }
        } else {
            NSInteger surplus = anItemNumber % _row;
            if (surplus == 0) {
                for (int j = 0; j < _row; j++) {
                    for (int k = 0; k < columns[i]; k++) {
                            UILabel *anItemLabel = [[UILabel alloc] initWithFrame:CGRectMake((_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/_row * j + _subjectTitleViewWidth,
                                                                                             _subjectsSuperView.frame.size.height/column * (k + curColumn),
                                                                                             (_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/_row,
                                                                                             _subjectsSuperView.frame.size.height/column)];
                        anItemLabel.tag = [[NSString stringWithFormat:@"%d%ld", i + 1, j + 1 + k * _row] integerValue];
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
                        [anItemLabel addGestureRecognizer:tapGesture];
                        anItemLabel.text = anItemTitles[j + k * _row];
                        if ([aComplete[j + k * _row] boolValue]) anItemLabel.backgroundColor = _completeColors[i];
                        [anItemLabel.layer setBorderWidth:0.4];
                        [anItemLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
                        anItemLabel.textAlignment = NSTextAlignmentCenter;
                        anItemLabel.userInteractionEnabled = YES;
                        [_subjectsSuperView addSubview:anItemLabel];
                        [_labels addObject:anItemLabel];
                    }
                }
            }
            for (int j = 0; j < _row; j++) {
                if (j < surplus) {
                    for (int k = 0; k < columns[i]; k++) {
                        UILabel *anItemLabel = [[UILabel alloc] initWithFrame:CGRectMake((_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/_row * j + _subjectTitleViewWidth,
                                                                                         _subjectsSuperView.frame.size.height/column * (k + curColumn),
                                                                                         (_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/_row,
                                                                                         _subjectsSuperView.frame.size.height/column)];
                        anItemLabel.tag = [[NSString stringWithFormat:@"%d%ld", i + 1, j + 1 + k*_row] integerValue];
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
                        [anItemLabel addGestureRecognizer:tapGesture];
                        [anItemLabel.layer setBorderWidth:0.4];
                        anItemLabel.text = anItemTitles[j + k * _row];
                        if ([aComplete[j + k * _row] boolValue]) anItemLabel.backgroundColor = _completeColors[i];
                        [anItemLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
                        anItemLabel.textAlignment = NSTextAlignmentCenter;
                        anItemLabel.userInteractionEnabled = YES;
                        [_subjectsSuperView addSubview:anItemLabel];
                        [_labels addObject:anItemLabel];
                    }
                } else if (surplus != 0){
                    for (int k = 0; k < columns[i] -1; k++) {
                        UILabel *anItemLabel = [[UILabel alloc] initWithFrame:CGRectMake((_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/_row * j + _subjectTitleViewWidth,
                                                                                         _subjectsSuperView.frame.size.height/column * (k + curColumn),
                                                                                         (_subjectsSuperView.frame.size.width - _subjectTitleViewWidth)/_row,
                                                                                         _subjectsSuperView.frame.size.height/column)];
                        anItemLabel.tag = [[NSString stringWithFormat:@"%d%ld", i + 1, j + 1 + k*_row] integerValue];
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
                        [anItemLabel addGestureRecognizer:tapGesture];
                        [anItemLabel.layer setBorderWidth:0.4];
                        anItemLabel.text = anItemTitles[j + k * _row];
                        if ([aComplete[j + k * _row] boolValue]) anItemLabel.backgroundColor = _completeColors[i];
                        [anItemLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
                        anItemLabel.textAlignment = NSTextAlignmentCenter;
                        anItemLabel.userInteractionEnabled = YES;
                        [_subjectsSuperView addSubview:anItemLabel];
                        [_labels addObject:anItemLabel];
                    }
                }
            }
        }
        curColumn = curColumn + columns[i];
    }
    
    
}

- (void)labelTapped:(UITapGestureRecognizer *)sender
{
    NSString *tagString = [NSString stringWithFormat:@"%ld", (long)sender.view.tag];
    NSInteger section = [[tagString substringWithRange:NSMakeRange(0, 1)] integerValue] -1;
    NSInteger row     = [[tagString substringWithRange:NSMakeRange(1, [tagString length] -1)] integerValue];
    if (_editedLabel) {
        _editedLabel.backgroundColor = [UIColor clearColor];
    }
    if (_isEditing) {
        [self showTexrField];
        _editedLabel = (UILabel *)sender.view;
        _editedLabel.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        [_textFieldWithButtonView.textField becomeFirstResponder];
    } else {
        if (row != 0) {
            
            NSMutableArray *subjects = [[_schedule objectForKey:@"Subjects"] mutableCopy];
            NSMutableArray *complete  = [[(NSDictionary *)subjects[section] objectForKey:@"Complete"] mutableCopy];
            if ([complete[row -1] boolValue]) {
                complete[row -1] = @(NO);
                sender.view.backgroundColor = [UIColor clearColor];
            } else {
                complete[row -1] = @(YES);
                sender.view.backgroundColor = _completeColors[section];
            }
            
            NSMutableDictionary *subject = [(NSDictionary *)subjects[section] mutableCopy];
            [subject setValue:complete forKey:@"Complete"];
            subjects[section] = subject;
            [_schedule setValue:subjects forKey:@"Subjects"];
            NSMutableArray *schedules = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"] mutableCopy];
            schedules[_scheduleRow] = _schedule;
            [[NSUserDefaults standardUserDefaults] setObject:schedules forKey:@"Schedules"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
    
}

- (void)showTexrField
{
    CGRect viewRect = _textFieldWithButtonView.frame;
    viewRect.origin.y = 70;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _textFieldWithButtonView.frame = viewRect;
                     }];
}

- (void)hideTexrField
{
    CGRect viewRect = _textFieldWithButtonView.frame;
    viewRect.origin.y = 0;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _textFieldWithButtonView.frame = viewRect;
                     }];
    [_textFieldWithButtonView.textField resignFirstResponder];
}

- (void)memoViewMoveUpper
{
    CGRect viewRect = _memoSuperView.frame;
    viewRect.origin.y = viewRect.origin.y - 290;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         _memoSuperView.frame = viewRect;
                     }];
}

- (void)memoViewMoveUnder
{
    CGRect viewRect = _memoSuperView.frame;
    viewRect.origin.y = viewRect.origin.y + 290;
    [UIView animateWithDuration:0.25f
                     animations:^{
                         _memoSuperView.frame = viewRect;
                     }];
}

- (void)didTapEditButton
{
    if (_isEditing) {
        _isEditing = NO;
        _memoTextView.editable = NO;
        if (_editedLabel) _editedLabel.backgroundColor = [UIColor clearColor];
        _editedLabel = nil;
        [self hideTexrField];
        [self reloadLabels];
        self.navigationItem.rightBarButtonItem.title = @"編集";
        
    } else {
        _isEditing = YES;
        _memoTextView.editable = YES;
        self.navigationItem.rightBarButtonItem.title = @"完了";
        for (UILabel *aLabel in _labels) aLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void)didTappedButtonOnView:(TKBTextFieldWithButtonView *)view
{
    if (_editedLabel == nil) return;
    _editedLabel.text = view.textField.text;
    NSString *tagString = [NSString stringWithFormat:@"%ld", _editedLabel.tag];
    NSInteger section = [[tagString substringWithRange:NSMakeRange(0, 1)] integerValue] -1;
    NSInteger row     = [[tagString substringWithRange:NSMakeRange(1, [tagString length] -1)] integerValue];
    NSLog(@"%ld,%ld", section, row);
    if (row != 0) {
        NSMutableArray *subjects = [[_schedule objectForKey:@"Subjects"] mutableCopy];
        NSMutableArray *itemTitles  = [[(NSDictionary *)subjects[section] objectForKey:@"ItemTitles"] mutableCopy];
        itemTitles[row -1] = view.textField.text;
        NSLog(@"%@", itemTitles);
        NSMutableDictionary *subject = [(NSDictionary *)subjects[section] mutableCopy];
        [subject setValue:itemTitles forKey:@"ItemTitles"];
        subjects[section] = subject;
        [_schedule setValue:subjects forKey:@"Subjects"];
        NSMutableArray *schedules = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"] mutableCopy];
        schedules[_scheduleRow] = _schedule;
        [[NSUserDefaults standardUserDefaults] setObject:schedules forKey:@"Schedules"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSMutableArray *subjects = [[_schedule objectForKey:@"Subjects"] mutableCopy];
        NSMutableDictionary *subject = [(NSDictionary *)subjects[section] mutableCopy];
        [subject setValue:view.textField.text forKey:@"Title"];
        subjects[section] = subject;
        NSMutableArray *schedules = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"] mutableCopy];
        schedules[_scheduleRow] = _schedule;
        [_schedule setValue:subjects forKey:@"Subjects"];
        [[NSUserDefaults standardUserDefaults] setObject:schedules forKey:@"Schedules"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    view.textField.text = @"";
    _editedLabel.backgroundColor = [UIColor clearColor];
    _editedLabel = nil;
}



- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self memoViewMoveUpper];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self memoViewMoveUnder];
    [_schedule setValue:textView.text forKey:@"Memo"];
    NSMutableArray *schedules = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"] mutableCopy];
    schedules[_scheduleRow] = _schedule;
    [[NSUserDefaults standardUserDefaults] setObject:schedules forKey:@"Schedules"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void) reloadLabels
{
    NSInteger subjectNum = [[_schedule objectForKeyedSubscript:@"SubjectNumber"] integerValue];
    NSArray *subjects = [_schedule objectForKey:@"Subjects"];
    
    for (int i = 0; i < subjectNum; i++) {
        NSInteger anItemNumber = [[(NSDictionary *)subjects[i] objectForKey:@"ItemNumber"] integerValue];
        NSArray *anItemTitles  = [(NSDictionary *)subjects[i] objectForKey:@"ItemTitles"];
        NSArray *aComplete     = [(NSDictionary *)subjects[i] objectForKey:@"Complete"];
        for (int j = 0; j < anItemNumber; j++) {
            UILabel *aLabel = (UILabel *)[self.view viewWithTag:[[NSString stringWithFormat:@"%d%d", i + 1, j + 1] integerValue]];
            if ([aComplete[j] boolValue]) aLabel.backgroundColor = _completeColors[i];
        }
    }
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
