//
//  NoNavSearchViewController.m
//  SearchModule
//
//  Created by Vols on 15/7/29.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import "NoNavSearchViewController.h"

@interface NoNavSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray * dataArray;
@property (nonatomic, strong) NSArray * searchArray;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UISearchDisplayController * SDController;

@end

@implementation NoNavSearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    
    self.view.backgroundColor = kRGB(108, 108, 108);
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchBar];
    
    [self addView];
    
}

- (void) initData{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Top100FamousPersons" ofType:@"plist"];
    _dataArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    NSLog(@"%@", _dataArray);
}

- (void) addView{
    _SDController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _SDController.searchResultsDataSource = self;
    _SDController.searchResultsDelegate = self;
    _SDController.delegate = self;
}

#pragma mark -------  View Lifecycle  -------

- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 60, self.view.bounds.size.width, self.view.bounds.size.height-60}];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:(CGRect){0, 20, self.view.bounds.size.width, 60}];
        _searchBar.placeholder = @"输入搜索";
        _searchBar.delegate = self;
        
        //for iOS 7
        if ([self.searchBar respondsToSelector: @selector (barTintColor)]) {
            [self.searchBar setBarTintColor:[UIColor clearColor]];
        }
    }
    return _searchBar;
}


#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return _dataArray.count;
    }
    else{
        return _searchArray.count;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"ID";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (tableView == self.tableView) {
            cell.textLabel.text = _dataArray[indexPath.row];
    }
    else{
        cell.textLabel.text = _searchArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(deselect:) withObject:tableView afterDelay:0.2f];
}

- (void)deselect:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.searchArray = self.dataArray;
    NSLog(@"%@", self.searchArray);
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchArray = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.searchArray = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
    
    NSLog(@"%@", self.searchArray);
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
