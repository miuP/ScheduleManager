//
//  TKBAddViewController.m
//  ScheduleManager
//
//  Created by kazuya on 8/15/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "TKBAddViewController.h"
#import "TKBTitleWithTextViewTableViewCell.h"

@interface TKBAddViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
    BOOL _isInputItemNumber;
    NSInteger _subjectNumber;
    NSMutableDictionary *_schedule;
    NSMutableArray *_subjects;
    NSIndexPath *_activeIndexPath;
    BOOL _observing;
    float _defaultTableViewHeight;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TKBAddViewController



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
    _schedule = [@{} mutableCopy];
    _isInputItemNumber = NO;
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = NO;
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TKBTitleWithTextViewTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"Cell"];
    _defaultTableViewHeight = _tableView.bounds.size.height;
    NSLog(@"%f", _tableView.bounds.origin.y);
    [self prepareView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // super
    [super viewWillAppear:animated];
    
    // Start observing
    if (!_observing) {
        NSNotificationCenter *center;
        center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(keyboardWillShow:)
                       name:UIKeyboardWillShowNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(keybaordWillHide:)
                       name:UIKeyboardWillHideNotification
                     object:nil];
        
        _observing = YES;
    }
}

- (void) prepareView
{
    //NaviBarに完了ボタンの追加
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"完了"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(didTapCompleteButton)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didTapCompleteButton
{
    if ([[_schedule objectForKey:@"Title"] isEqualToString:@""] || [_schedule objectForKey:@"Title"] == Nil) [_schedule setValue:@"NoTitle" forKey:@"Title"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *schedules = [[ud objectForKey:@"Schedules"] mutableCopy];
    
    [schedules addObject:_schedule];
    [ud setObject:schedules forKey:@"Schedules"];
    [ud synchronize];
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(didTapCompleteButtonInViewController:)]) {
        [self.delegate didTapCompleteButtonInViewController:self];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKBTitleWithTextViewTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textView.text = @"";
    cell.textView.tag = [[NSString stringWithFormat:@"%ld%ld", indexPath.section + 1, indexPath.row + 1] integerValue];
    cell.textView.delegate = self;
    cell.textView.returnKeyType = UIReturnKeyDone;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"タイトル";
                    cell.textView.text = (NSString *)[_schedule objectForKey:@"Title"];
                    break;
                
                case 1:
                    if (_isInputItemNumber) {
                        cell.textView.text = [NSString stringWithFormat:@"%ld", _subjectNumber];
                    }
                    cell.titleLabel.text = @"項目数(1~9で入力してください)";
                    break;
                
                default:
                    break;
            }
            break;
            
        case 1:
            cell.titleLabel.text = [NSString stringWithFormat:@"項目%ldのタイトル", indexPath.row + 1];
            cell.textView.text = [(NSDictionary *)_subjects[indexPath.row] objectForKey:@"Title"];
            break;
            
        case 2:
            cell.titleLabel.text = [NSString stringWithFormat:@"項目%ldのマスの数", indexPath.row + 1];
            cell.textView.text = [[(NSDictionary *)_subjects[indexPath.row] objectForKey:@"ItemNumber"] stringValue];
            break;
            
        default:
            break;
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return _subjectNumber;
            break;
            
        case 2:
            return _subjectNumber;
            break;
            
        default:
            break;
    }
    return 4;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"isItemNum:%d", _isInputItemNumber);
    if (_isInputItemNumber) return 3;
    else return 1;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *tagString = [NSString stringWithFormat:@"%ld", textView.tag];
    NSInteger section = [[tagString substringWithRange:NSMakeRange(0, 1)] integerValue] -1;
    NSInteger row     = [[tagString substringWithRange:NSMakeRange(1, [tagString length] -1)] integerValue] -1;
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"%ld", textView.tag);
        switch (section) {
            case 0:
                switch (row) {
                    case 0:
                        [_schedule setValue:textView.text forKey:@"Title"];
                        break;
                        
                    case 1:
                        if (1 <= [textView.text integerValue] && [textView.text integerValue] <= 9) {
                            _isInputItemNumber = YES;
                            _subjectNumber = [textView.text integerValue];
                            [_schedule setValue:@([textView.text integerValue]) forKey:@"SubjectNumber"];
                            _subjects = [NSMutableArray arrayWithCapacity:_subjectNumber];
                            [_schedule setValue:_subjects forKey:@"Subjects"];
                            for (int i = 0; i < _subjectNumber; i++) _subjects[i] = [@{} mutableCopy];
                            [_tableView reloadData];
                        } else {
                            textView.text = @"1~9の数字で入力してください";
                        }
                        break;
                    default:
                        break;
                }
                break;
            case 1:
                [(NSMutableDictionary *)_subjects[row] setValue:textView.text forKey:@"Title"];
                break;
                
            case 2:
            {
                [(NSMutableDictionary *)_subjects[row] setValue:@([textView.text integerValue]) forKey:@"ItemNumber"];
                NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:[textView.text integerValue]];
                NSMutableArray *complete   = [NSMutableArray arrayWithCapacity:[textView.text integerValue]];
                for (int i = 0; i < [textView.text integerValue]; i++) {
                    itemTitles[i] = @"";
                    complete[i]   = @(0);
                }
                [(NSMutableDictionary *)_subjects[row] setValue:itemTitles forKey:@"ItemTitles"];
                [(NSMutableDictionary *)_subjects[row] setValue:complete forKey:@"Complete"];
            }
                break;
            default:
                
                break;
        }
        [textView resignFirstResponder];
        _activeIndexPath = nil;
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSString *tagString = [NSString stringWithFormat:@"%ld", textView.tag];
    NSInteger section = [[tagString substringWithRange:NSMakeRange(0, 1)] integerValue] -1;
    NSInteger row     = [[tagString substringWithRange:NSMakeRange(1, [tagString length] -1)] integerValue] -1;
    _activeIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return YES;
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    
    NSDictionary *info = [notification userInfo];
    // キーボードのサイズを取得する
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect tableViewFrame = _tableView.bounds;
    tableViewFrame.size.height = _defaultTableViewHeight - kbFrame.size.height;
    tableViewFrame.origin.y = 0;
    _tableView.frame = tableViewFrame;
    [_tableView scrollToRowAtIndexPath:_activeIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}

- (void)keybaordWillHide:(NSNotification*)notification
{
    CGRect tableViewFrame = _tableView.bounds;
    tableViewFrame.size.height = _defaultTableViewHeight;
    tableViewFrame.origin.y = 0;
    _tableView.frame = tableViewFrame;
}

- (void)didReceiveMemoryWarning

{

    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSString *tagString = [NSString stringWithFormat:@"%ld", textView.tag];
    NSInteger section = [[tagString substringWithRange:NSMakeRange(0, 1)] integerValue] -1;
    NSInteger row     = [[tagString substringWithRange:NSMakeRange(1, [tagString length] -1)] integerValue] -1;
    NSLog(@"%ld", textView.tag);
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    [_schedule setValue:textView.text forKey:@"Title"];
                    break;
                    
                case 1:
                    if (1 <= [textView.text integerValue] && [textView.text integerValue] <= 9) {
                        _isInputItemNumber = YES;
                        _subjectNumber = [textView.text integerValue];
                        [_schedule setValue:@([textView.text integerValue]) forKey:@"SubjectNumber"];
                        _subjects = [NSMutableArray arrayWithCapacity:_subjectNumber];
                        [_schedule setValue:_subjects forKey:@"Subjects"];
                        for (int i = 0; i < _subjectNumber; i++) _subjects[i] = [@{} mutableCopy];
                        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    } else {
                        textView.text = @"1~9の数字で入力してください";
                    }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            [(NSMutableDictionary *)_subjects[row] setValue:textView.text forKey:@"Title"];
            break;
            
        case 2:
        {
            [(NSMutableDictionary *)_subjects[row] setValue:@([textView.text integerValue]) forKey:@"ItemNumber"];
            NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:[textView.text integerValue]];
            NSMutableArray *complete   = [NSMutableArray arrayWithCapacity:[textView.text integerValue]];
            for (int i = 0; i < [textView.text integerValue]; i++) {
                itemTitles[i] = @"";
                complete[i]   = @(0);
            }
            [(NSMutableDictionary *)_subjects[row] setValue:itemTitles forKey:@"ItemTitles"];
            [(NSMutableDictionary *)_subjects[row] setValue:itemTitles forKey:@"Complete"];
        }
            break;
        default:
            
            break;
    }
    _activeIndexPath = nil;
    return YES;
}

@end