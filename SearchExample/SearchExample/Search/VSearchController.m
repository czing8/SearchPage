//
//  VSearchController.m
//  SearchExample
//
//  Created by Vols on 2016/11/4.
//  Copyright © 2016年 vols. All rights reserved.
//

#import "VSearchController.h"
#import "UIView+VAdd.h"

#define kMargin     10  // 默认边距
// 搜索历史存储路径
#define kSearchHistoriesPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"kSearchHistories.plist"]

#define kRGB(r, g, b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]


NSString *const VSearchPlaceholderText = @"搜索内容";
NSString *const VHotSearchText = @"热门搜索";
NSString *const VSearchHistoryText = @"搜索历史";
NSString *const VEmptySearchHistoryText = @"清空搜索历史";


@interface VSearchController () <UISearchBarDelegate>

@property (nonatomic, strong) NSString *placeholderString;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIView *headerContentView;

@property (nonatomic, copy)     NSArray<NSString *> *hotSearches; // 热门搜索
@property (nonatomic, strong)   NSMutableArray *searchHistories;  // 搜索历史


@property (nonatomic, copy)   NSArray<UILabel *> *hotSearchTags;  // 所有的热门标签
@property (nonatomic, strong) UIView    *hotTagsContentView;      // 热门标签容器
@property (nonatomic, strong) UILabel   *hotTipLabel;             // 热门标签头部


@property (nonatomic, copy) NSArray<UILabel *> *rankTags;       // 排名标签(第几名)
@property (nonatomic, copy) NSArray<UILabel *> *rankTextLabels; // 排名内容
@property (nonatomic, copy) NSArray<UIView *> *rankViews;       //排名整体标签（包含第几名和内容）

/** 搜索历史标签容器，只有在PYSearchHistoryStyle值为PYSearchHistoryStyleTag才有值 */
@property (nonatomic, strong)   UIView *historyTagsContentView;
@property (nonatomic, copy)     NSArray<UILabel *> *searchHistoryTags;  // 存储搜索历史标签
@property (nonatomic, strong)   UILabel *historyTipLabel;     // 搜索历史标题

@property (nonatomic, strong)   UIButton *clearButton;        // 搜索历史标签的清空按钮

@end

@implementation VSearchController

+ (VSearchController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder {
    VSearchController *searchVC = [[VSearchController alloc] init];
    searchVC.hotSearches = hotSearches;
    searchVC.placeholderString = placeholder;
    
    return searchVC;
}

+ (VSearchController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder didSearchBlock:(DidSearchBlock)block {
    VSearchController *searchVC = [self searchViewControllerWithHotSearches:hotSearches searchBarPlaceholder:placeholder];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureDatas];
    [self displayUIs];
    [self setupHotSearchNormalTags];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}


- (void)configureDatas{
    self.hotSearchStyle = VHotSearchStyleDefault;
    self.searchHistoryStyle = VHotSearchStyleDefault;
}

- (void)displayUIs{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelDidClick)];

    [self.titleView addSubview:self.searchBar];
    self.navigationItem.titleView = self.titleView;
    
    UIView * headerView = [[UIView alloc] init];
    [headerView addSubview:self.headerContentView];
    [self.headerContentView addSubview:self.hotTipLabel];
    [self.headerContentView addSubview:self.hotTagsContentView];
    self.tableView.tableHeaderView = headerView;
 
    // 设置底部(清除历史搜索)
    UIView *footerView = [[UIView alloc] init];
    footerView.width = self.view.bounds.size.width;
    UILabel *emptySearchHistoryLabel = [[UILabel alloc] init];
    emptySearchHistoryLabel.textColor = [UIColor darkGrayColor];
    emptySearchHistoryLabel.font = [UIFont systemFontOfSize:13];
    emptySearchHistoryLabel.userInteractionEnabled = YES;
    emptySearchHistoryLabel.text = VEmptySearchHistoryText;
    emptySearchHistoryLabel.textAlignment = NSTextAlignmentCenter;
    emptySearchHistoryLabel.height = 30;
    [emptySearchHistoryLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptySearchHistoryDidClick)]];
    emptySearchHistoryLabel.width = self.view.bounds.size.width;
    [footerView addSubview:emptySearchHistoryLabel];
    footerView.height = 30;
    self.tableView.tableFooterView = footerView;
}


- (void)setupHotSearchNormalTags {
    // 添加和布局标签
    self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotTagsContentView tagTexts:self.hotSearches];
}


#pragma mark - actions

/** 点击取消 */
- (void)cancelDidClick {
//    [self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}


//  选中标签
- (void)tagDidCLick:(UITapGestureRecognizer *)gr {
    UILabel *label = (UILabel *)gr.view;
    self.searchBar.text = label.text;
    [self searchBarSearchButtonClicked:self.searchBar];
    
    if (self.searchHistoryStyle == VSearchHistoryStyleCell) { // 搜索历史为标签时，刷新标签
        [self.tableView reloadData];
    } else {
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
}


- (void)closeDidClick:(UITapGestureRecognizer *)gr {
    UITableViewCell *cell = (UITableViewCell *)gr.view.superview;
    [self.searchHistories removeObject:cell.textLabel.text];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:kSearchHistoriesPath];
    [self.tableView reloadData];
}


// 点击清空历史按钮
- (void)emptySearchHistoryDidClick {
    [self.searchHistories removeAllObjects];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:kSearchHistoriesPath];
    if (self.searchHistoryStyle == VSearchHistoryStyleCell) {
        [self.tableView reloadData];
    } else {
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
}


#pragma mark - setter/getter

- (NSMutableArray *)searchHistories {
    if (!_searchHistories) {
        _searchHistories = [NSKeyedUnarchiver unarchiveObjectWithFile:kSearchHistoriesPath];
        if (!_searchHistories) {
            _searchHistories = [NSMutableArray array];
        }
    }
    return _searchHistories;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.frame = CGRectMake(kMargin*0.5, 7, self.view.bounds.size.width - 64 - kMargin, 30);
        _titleView.backgroundColor = [UIColor whiteColor];
    }
    return _titleView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.frame = CGRectMake(0, 0, _titleView.bounds.size.width - kMargin * 1.5, 30);
        _searchBar.placeholder = _placeholderString ? _placeholderString : VSearchPlaceholderText;
        _searchBar.backgroundImage = [UIImage imageNamed:@"VSearch.bundle/clearImage"];
        _searchBar.delegate = self;
        
    }
    return _searchBar;
}

- (UILabel *) hotTipLabel {
    if (!_hotTipLabel) {
        _hotTipLabel = [self buildLabel:VHotSearchText];
        _hotTipLabel.frame = CGRectMake(0, 0, 200, 30);
    }
    return _hotTipLabel;
}

- (UILabel *) historyTipLabel {
    if (!_historyTipLabel) {
        _historyTipLabel = [self buildLabel:VHotSearchText];
        _historyTipLabel.frame = CGRectMake(0, 0, 200, 30);
    }
    return _historyTipLabel;
}


- (UIView *)headerContentView {
    if (!_headerContentView) {
        _headerContentView = [[UIView alloc] init];
        _headerContentView.frame = CGRectMake(kMargin*1.5, kMargin, self.view.bounds.size.width - kMargin*3, 80);
        _headerContentView.backgroundColor = [UIColor whiteColor];
    }
    return _headerContentView;
}

- (UIView *)hotTagsContentView {
    if (!_hotTagsContentView) {
        _hotTagsContentView = [[UIView alloc] init];
        _hotTagsContentView.frame = CGRectMake(0, CGRectGetMaxY(_hotTipLabel.frame) + kMargin, _headerContentView.bounds.size.width - kMargin, 40);
        _hotTagsContentView.backgroundColor = [UIColor whiteColor];
    }
    return _hotTagsContentView;
}


// 创建并设置标题
- (UILabel *)buildLabel:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    [titleLabel sizeToFit];
    return titleLabel;
}

// 添加标签
- (UILabel *)tagWithTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = kRGB(210, 210, 210);
    label.layer.cornerRadius = 3;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.width += 20;
    label.height += 14;
    return label;
}

/**
 * 设置搜索历史标签
 * PYSearchHistoryStyleTag
 */
//- (void)setupSearchHistoryTags
//{
//    // 隐藏尾部清除按钮
//    self.tableView.tableFooterView = nil;
//    // 添加搜索历史头部
//    self.searchHistoryHeader.y = self.hotSearches.count > 0 ? CGRectGetMaxY(self.hotSearchTagsContentView.frame) + kMargin * 1.5 : 0;
//    self.searchHistoryTagsContentView.y = CGRectGetMaxY(self.emptyButton.frame) + PYMargin;
//    // 添加和布局标签
//    self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:[self.searchHistories copy]];
//}

//  添加和布局标签
- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<NSString *> *)tagTexts;
{
    // 清空标签容器的子控件
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 添加热门搜索标签
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UILabel *label = [self tagWithTitle:tagTexts[i]];
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        [contentView addSubview:label];
        [tagsM addObject:label];
    }
    
    // 计算位置
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    // 调整布局
    for (UILabel *subView in tagsM) {
        // 当搜索字数过多，宽度为contentView的宽度
        if (subView.width > contentView.width) subView.width = contentView.width;
        if (currentX + subView.width + kMargin * countRow > contentView.width) { // 得换行
            subView.x = 0;
            subView.y = (currentY += subView.height) + kMargin * ++countCol;
            currentX = subView.width;
            countRow = 1;
        } else { // 不换行
            subView.x = (currentX += subView.width) - subView.width + kMargin * countRow;
            subView.y = currentY + kMargin * countCol;
            countRow ++;
        }
    }
    // 设置contentView高度
    contentView.height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    // 设置头部高度
    self.tableView.tableHeaderView.height = self.headerContentView.height = CGRectGetMaxY(contentView.frame) + kMargin * 2;
    return [tagsM copy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    // 先移除再刷新
    [self.searchHistories removeObject:searchBar.text];
    [self.searchHistories insertObject:searchBar.text atIndex:0];
    // 刷新数据
    if (self.searchHistoryStyle == VSearchHistoryStyleCell) { // 普通风格Cell
        [self.tableView reloadData];
    } else {
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:kSearchHistoriesPath];
    
    // 如果代理实现了代理方法则调用代理方法
    if ([self.delegate respondsToSelector:@selector(searchViewController:didSearchWithsearchBar:searchText:)]) {
        [self.delegate searchViewController:self didSearchWithsearchBar:searchBar searchText:searchBar.text];
        return;
    }
    // 如果有block则调用
    if (self.didSearchBlock) self.didSearchBlock(self, searchBar, searchBar.text);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    // 根据输入文本显示建议搜索条件
//    self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || !searchText.length;
//    // 放在最上层
//    [self.view bringSubviewToFront:self.searchSuggestionVC.view];
//    // 如果代理实现了代理方法则调用代理方法
//    if ([self.delegate respondsToSelector:@selector(searchViewController:searchTextDidChange:searchText:)]) {
//        [self.delegate searchViewController:self searchTextDidChange:searchBar searchText:searchText];
//    }
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 没有搜索记录就隐藏
    self.tableView.tableFooterView.hidden = self.searchHistories.count == 0;
    return  self.searchHistoryStyle == VSearchHistoryStyleCell ? self.searchHistories.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PYSearchHistoryCellID";
    // 创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor purpleColor];
        
        // 添加关闭
        UIImageView *closeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VSearch.bundle/close"]];
        closeView.userInteractionEnabled = YES;
        [closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDidClick:)]];
        cell.accessoryView =  closeView;
        // 添加分割线
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PYSearch.bundle/cell-content-line"]];
        line.height = 0.5;
        line.alpha = 0.7;
        line.x = kMargin;
        line.y = 43;
        line.width = self.view.bounds.size.width;
        [cell.contentView addSubview:line];
    }
    
    // 设置数据
    cell.imageView.image = [UIImage imageNamed:@"VSearch.bundle/search_history"];
    cell.textLabel.text = self.searchHistories[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.searchHistories.count && self.searchHistoryStyle == VSearchHistoryStyleCell ? VSearchHistoryText : nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取出选中的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchBar.text = cell.textLabel.text;
    [self searchBarSearchButtonClicked:self.searchBar];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}


@end
