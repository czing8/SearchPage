//
//  VSearchController.h
//  SearchExample
//
//  Created by Vols on 2016/11/4.
//  Copyright © 2016年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSearchController;

typedef void(^DidSearchBlock)(VSearchController *searchController, UISearchBar *searchBar, NSString *searchText);

typedef NS_ENUM(NSInteger, VHotSearchStyle)  { // 热门搜索标签风格
    VHotSearchStyleNormalTag,      // 普通标签(不带边框)
    VHotSearchStyleColorfulTag,    // 彩色标签（不带边框，背景色为随机彩色）
    VHotSearchStyleBorderTag,      // 带有边框的标签,此时标签背景色为clearColor
    VHotSearchStyleARCBorderTag,   // 带有圆弧边框的标签,此时标签背景色为clearColor
    VHotSearchStyleRankTag,        // 带有排名标签
    VHotSearchStyleRectangleTag,   // 矩形标签,此时标签背景色为clearColor
    VHotSearchStyleDefault = VHotSearchStyleNormalTag // 默认为普通标签
};

typedef NS_ENUM(NSInteger, VSearchHistoryStyle) {  // 搜索历史风格
    VSearchHistoryStyleCell,            // UITableViewCell 风格
    VSearchHistoryStyleNormalTag,       // VHotSearchStyleNormalTag 标签风格
    VSearchHistoryStyleColorfulTag,     // 彩色标签（不带边框，背景色为随机彩色）
    VSearchHistoryStyleBorderTag,       // 带有边框的标签,此时标签背景色为clearColor
    VSearchHistoryStyleARCBorderTag,    // 带有圆弧边框的标签,此时标签背景色为clearColor
    VSearchHistoryStyleDefault = VSearchHistoryStyleCell // 默认为 VSearchHistoryStyleCell
};

@protocol VSearchControllerDelegate <NSObject, UITableViewDelegate>

@optional
/*
 * 点击(开始)搜索时调用 
 */
- (void)searchViewController:(VSearchController *)searchController didSearchWithsearchBar:(UISearchBar *)searchBar searchText:(NSString *)searchText;

/*
 * 搜索框文本变化时，显示的搜索建议通过searchController的searchSuggestions赋值即可
 */
- (void)searchViewController:(VSearchController *)searchController  searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText;

@end


@interface VSearchController : UITableViewController

/**
 * 排名标签背景色对应的16进制字符串（如：@"#ffcc99"）数组(四个颜色)
 * 前三个为分别为1、2、3 第四个为后续所有标签的背景色
 * 该属性只有在设置hotSearchStyle为PYHotSearchStyleColorfulTag才生效
 */
@property (nonatomic, strong) NSArray<NSString *> *rankTagBackgroundColorHexStrings;

/**
 * web安全色池,存储的是UIColor数组，用于设置标签的背景色
 * 该属性只有在设置hotSearchStyle为PYHotSearchStyleColorfulTag才生效
 */
@property (nonatomic, strong) NSMutableArray<UIColor *> *colorPol;

/** 代理 */
@property (nonatomic, weak) id<VSearchControllerDelegate> delegate;

/** 热门搜索风格 （默认为：PYHotSearchStyleDefault）*/
@property (nonatomic, assign) VHotSearchStyle hotSearchStyle;   //热门搜索风格
/** 搜索历史风格 （默认为：PYSearchHistoryStyleDefault）*/
@property (nonatomic, assign) VSearchHistoryStyle searchHistoryStyle;

/** 搜索时调用此Block */
@property (nonatomic, copy) DidSearchBlock didSearchBlock;
/** 搜索建议,注意：给此属性赋值时，确保searchSuggestionHidden值为NO，否则赋值失效 */
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;
/** 搜索建议是否隐藏 默认为：NO */
@property (nonatomic, assign) BOOL searchSuggestionHidden;

/**
 * 快速创建VSearchController对象
 *
 * hotSearches : 热门搜索数组
 * placeholder : searchBar占位文字
 *
 */
+ (VSearchController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder;

/**
 * 快速创建VSearchController对象
 *
 * hotSearches : 热门搜索数组
 * placeholder : searchBar占位文字
 * block: 点击（开始）搜索时调用block
 * 注意 : delegate(代理)的优先级大于block(即实现了代理方法则block失效)
 *
 */
+ (VSearchController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder didSearchBlock:(DidSearchBlock)block;

@end
