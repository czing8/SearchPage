//
//  Example1Controller.m
//  SearchExample
//
//  Created by Vols on 2015/11/4.
//  Copyright © 2015年 vols. All rights reserved.
//

#import "Example1Controller.h"
#import "VSearchController.h"

#define kCellIdentifier   @"cell_identifier"

@interface Example1Controller ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * data1Source;
@property (nonatomic, strong) NSArray * data2Source;

@end

@implementation Example1Controller

- (void)viewDidLoad
{
//    [UIButton ]
    [super viewDidLoad];
    [self initData];
    self.title = @"";
    [self.view addSubview:self.tableView];   //会自动调用 (UITableView *)tableView
}

- (void)initData{
    _data1Source = @[@"PYHotSearchStyleDefault", @"PYHotSearchStyleColorfulTag", @"PYHotSearchStyleBorderTag", @"PYHotSearchStyleARCBorderTag", @"PYHotSearchStyleRankTag", @"PYHotSearchStyleRectangleTag"];
    _data2Source = @[@"PYSearchHistoryStyleDefault", @"PYSearchHistoryStyleNormalTag", @"PYSearchHistoryStyleColorfulTag", @"PYSearchHistoryStyleBorderTag", @"PYSearchHistoryStyleARCBorderTag"];
}


- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? _data2Source.count : _data1Source.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.section == 0) {
        cell.textLabel.text = _data1Source[indexPath.row];
    } else {
        cell.textLabel.text = _data2Source[indexPath.row];
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section ? @"历史记录Style":@"热门搜索Style";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        NSArray *hotSeaches = @[@"Java", @"Python", @"Objective-C", @"Swift", @"C", @"C++", @"PHP", @"C#", @"Perl", @"Go", @"JavaScript", @"R", @"Ruby", @"MATLAB"];
    
    if (indexPath.section == 0) {
//        VSearchController * searchVC = [[VSearchController alloc] init];
        VSearchController * searchVC = [VSearchController searchViewControllerWithHotSearches:hotSeaches searchBarPlaceholder:@"搜索内容" didSearchBlock:^(VSearchController *searchController, UISearchBar *searchBar, NSString *searchText) {
            NSLog(@"searchText --> %@", searchText);
        }];
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:searchVC];
        [self presentViewController:navController animated:NO completion:nil];
    }
    
    
    [self performSelector:@selector(deselect:) withObject:tableView afterDelay:0.2f];
}

- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
