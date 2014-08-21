//
//  TKBListViewController.m
//  ScheduleManager
//
//  Created by kazuya on 8/15/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "TKBListViewController.h"
#import "TKBAddViewController.h"
#import "TKBScheduleViewController.h"

@interface TKBListViewController () <UITableViewDataSource, UITableViewDelegate, TKBAddViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TKBListViewController

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
    self.title = @"一覧";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self prepareView];
}

- (void) prepareView
{
    //NaviBarにボタンの追加
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(didTapAddButton)];
    self.navigationItem.rightBarButtonItem = addButton;
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"更新"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(updateView)];
    self.navigationItem.leftBarButtonItem = reloadButton;
    
}

- (void)updateView
{
    [_tableView reloadData];
}

- (void)didTapAddButton
{
    TKBAddViewController *toVC = [[TKBAddViewController alloc] initWithNibName:NSStringFromClass([TKBAddViewController class])
                                                                        bundle:nil];
    toVC.delegate = self;
    [self.navigationController pushViewController:toVC animated:YES];
    toVC.title = @"新規作成";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSArray *schedules = [[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"];
    cell.textLabel.text =  [(NSDictionary *)schedules[indexPath.row] objectForKey:@"Title"];;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKBScheduleViewController *toVC = [[TKBScheduleViewController alloc] initWithNibName:NSStringFromClass([TKBScheduleViewController class]) bundle:nil];
    toVC.schedule = [((NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"])[indexPath.row] mutableCopy];
    toVC.scheduleRow = indexPath.row;
    [self.navigationController pushViewController:toVC animated:YES];
    
}

- (void)didTapCompleteButtonInViewController:(TKBAddViewController *)vc
{
     [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *schedules = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Schedules"] mutableCopy];
        [schedules removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:schedules forKey:@"Schedules"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
