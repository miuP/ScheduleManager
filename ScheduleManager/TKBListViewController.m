//
//  TKBListViewController.m
//  ScheduleManager
//
//  Created by kazuya on 8/15/14.
//  Copyright (c) 2014 COINS Project AID. All rights reserved.
//

#import "TKBListViewController.h"
#import "TKBAddViewController.h"

@interface TKBListViewController () <UITableViewDataSource, UITableViewDelegate>
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
    //NaviBarにNewボタンの追加
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(didTapAddButton)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didTapAddButton
{
    TKBAddViewController *toVC = [[TKBAddViewController alloc] initWithNibName:NSStringFromClass([TKBAddViewController class])
                                                                        bundle:nil];
    [self.navigationController pushViewController:toVC animated:YES];
    toVC.title = @"新規作成";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
