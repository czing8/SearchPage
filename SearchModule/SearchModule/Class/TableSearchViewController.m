//
//  TableSearchViewController.m
//  SearchModule
//
//  Created by Vols on 15/7/29.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import "TableSearchViewController.h"

@interface TableSearchViewController ()<UISearchDisplayDelegate>
{
    UISearchDisplayController   *_searchDisplayController;
    
    NSArray						*_listContent;			// the master content
    NSMutableArray				*_filteredListContent;	// the filtered content as a result of the search
    
    // the saved state of our search UI if we received a memory warning and destroyed our view
    NSString                    *_savedSearchTerm;
//    NSInteger                    savedScopeButtonIndex;
//    unsigned int                 searchWasActive;
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSArray *listContent;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) unsigned int searchWasActive;

@end

@implementation TableSearchViewController


- (void)viewDidLoad {
    
    // set up the search bar
    _searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"All", @"Portable", @"Desktop", nil];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    // create the UISearchDisplayController
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplayController.searchResultsDataSource = self;
    _searchDisplayController.searchResultsDelegate = self;
    _searchDisplayController.delegate = self;
    
    // create the master list that will be the data source of our main table
    _listContent = [[NSArray alloc] initWithObjects:
                   [NSArray arrayWithObjects:@"Portable", @"iPhone",      nil],
                   [NSArray arrayWithObjects:@"Portable", @"iPod",        nil],
                   [NSArray arrayWithObjects:@"Portable", @"iPod Touch",  nil],
                   [NSArray arrayWithObjects:@"Desktop",  @"iMac",        nil],
                   [NSArray arrayWithObjects:@"Portable", @"iBook",       nil],
                   [NSArray arrayWithObjects:@"Portable", @"MacBook",     nil],
                   [NSArray arrayWithObjects:@"Portable", @"MacBook Pro", nil],
                   [NSArray arrayWithObjects:@"Desktop",  @"Mac Pro",     nil],
                   [NSArray arrayWithObjects:@"Portable", @"PowerBook",   nil], nil];
    
    // create our filtered list that will be the data source of our search results table
    _filteredListContent = [[NSMutableArray alloc] initWithCapacity: [_listContent count]];
    
    // restore the search settings that were saved in didReceiveMemoryWarning
    if (_savedSearchTerm) {
        [_searchDisplayController setActive:_searchWasActive];
        [_searchBar setSelectedScopeButtonIndex:_savedScopeButtonIndex];
        [_searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    [self.tableView reloadData];
}


- (void)viewDidUnload {
    // save the state of the search UI so that we can restore it if our view is re-created
    self.searchWasActive = [_searchDisplayController isActive];
    self.savedSearchTerm = [_searchBar text];
    self.savedScopeButtonIndex = [_searchBar selectedScopeButtonIndex];
    
    // destroy the UISearchDisplayController. we'll create a new one if the view is reloaded and point it to the new UISearchBar
    self.searchDisplayController = nil;
    
    // clear out references to outlet views. we'll get a new UISearchBar if the nib is reloaded
    self.searchBar = nil;
    
    // clear the lists, they are recreated in viewDidLoad
    self.listContent = nil;
    self.filteredListContent = nil;
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchDisplayController.searchResultsTableView) {
        // return filtered content for the search results table view
        return [_filteredListContent count];
    }
    else {
        // return content for the main table view
        return [_listContent count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    
    if (tableView == _searchDisplayController.searchResultsTableView) {
        // return filtered content for the search results table view
        cell.textLabel.text = [[_filteredListContent objectAtIndex:indexPath.row] lastObject];
    }
    else {
        // return content for the main table view
        cell.textLabel.text = [[_listContent objectAtIndex:indexPath.row] lastObject];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *detailsViewController = [[UIViewController alloc] init];
    detailsViewController.view.backgroundColor = [UIColor orangeColor];
    
    if (tableView == _searchDisplayController.searchResultsTableView) {
        // use the filtered content for the search results table view
        detailsViewController.title = [[_filteredListContent objectAtIndex:indexPath.row] lastObject];
    }
    else {
        // use the full content for the main table view
        detailsViewController.title = [[_listContent objectAtIndex:indexPath.row] lastObject];
    }
    
    [[self navigationController] pushViewController:detailsViewController animated:YES];
}


- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
    [self performSelector:@selector(hideSearchDisplayController) withObject:nil afterDelay:3.f];
    
}

- (void)hideSearchDisplayController {
    
    [_searchDisplayController setActive:NO animated:YES];
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [_filteredListContent removeAllObjects];	// clear the filtered array first
    
    // search the table content for cell titles that match "searchText"
    // if found add to the mutable array
    //
    for (NSArray *entry in _listContent) {
        
        if ([scope isEqualToString:@"All"] || [[entry objectAtIndex:0] isEqualToString:scope]) {
            NSComparisonResult result = [[entry objectAtIndex:1] compare:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, [searchText length])];
            
            if (result == NSOrderedSame)  {
                [_filteredListContent addObject:entry];
            }
        }
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:[[_searchBar scopeButtonTitles] objectAtIndex:[_searchBar selectedScopeButtonIndex]]];
    
    // return YES to cause the search result table view to be reloaded
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[_searchBar text] scope:[[_searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // return YES to cause the search result table view to be reloaded
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
