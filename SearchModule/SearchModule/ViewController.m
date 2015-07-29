//
//  ViewController.m
//  SearchModule
//
//  Created by Vols on 15/7/29.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import "ViewController.h"
#import "NoNavSearchViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search Styles";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _tableView.tableFooterView = [[UIView alloc] init];
    _dataSource = @[@"1", @"2", @"3",@"4", @"没有导航栏的Search样式",@"6"];
    
}


#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"ID";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //    for(UIView * view in cell.contentView.subviews){
    //        [view removeFromSuperview];
    //    }
    
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.textColor = [UIColor colorWithWhite:0.293 alpha:1.000];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.text = _dataSource[indexPath.row];
    
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(deselect:) withObject:tableView afterDelay:0.2f];
    
    
    switch (indexPath.row) {
        case 0:
        {
            
            [self performSegueWithIdentifier:@"OneSegue" sender:self];
            
            break;
        }
        case 1:
        {
            [self performSegueWithIdentifier:@"TwoSegue" sender:self];
            
            break;
        }
        case 2:
        {
            [self performSegueWithIdentifier:@"ThreeSegue" sender:self];
            
            break;
        }
        case 3:
        {
            [self performSegueWithIdentifier:@"FourSegue" sender:self];
            
            break;
        }
        case 4:
        {
            [self presentViewController:[[NoNavSearchViewController alloc] init] animated:YES completion:nil];
            break;
        }
        case 5:
        {
            [self performSegueWithIdentifier:@"FriSegue" sender:self];
            break;
        }
        default:
            break;
    }
    
    
    
}

- (void)deselect:(UITableView *)tableView
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}



@end
