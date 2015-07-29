//
//  FirstSearchViewController.m
//  SearchModule
//
//  Created by Vols on 15/7/29.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import "FirstSearchViewController.h"

@interface FirstSearchViewController () <UISearchBarDelegate>

@end

@implementation FirstSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化,定义frame
    UISearchBar *bar = [[UISearchBar alloc] initWithFrame:CGRectMake
                        (0, 80, self.view.frame.size.width, 80)];
    //添加到控制器的视图上
    [self.view addSubview:bar];
    
    //autocapitalizationType:包含4种类型，但是有时候键盘会屏蔽此属.
    //1.autocapitalizationType————自动对输入文本对象进行大小写设置.
    bar.autocapitalizationType = UITextAutocapitalizationTypeWords;
    //2.autocorrectionType————自动对输入文本对象进行纠错
    bar.autocorrectionType = UITextAutocorrectionTypeYes;
    //3.设置title
    bar.prompt = @"全部联系人";
    
    //4.设置颜色
    bar.tintColor  = [UIColor purpleColor];//渲染颜色
    bar.barTintColor = [UIColor orangeColor];//搜索条颜色
    bar.backgroundColor =  [UIColor purpleColor];//背景颜色,因为毛玻璃效果(transulent).
    
    //5.translucent————指定控件是否会有透视效果
    bar.translucent = YES;
    
    //6.scopeButtonTitles(范围buttonTitle)
    bar.scopeButtonTitles = @[@"精确搜索",@"模糊搜索"];
    bar.selectedScopeButtonIndex = 1;//通过下标指定默认选择的那个选择栏
    
    //7.控制搜索栏下部的选择栏是否显示出来（需设置为YES 才能使用scopebar）
    bar.showsScopeBar = YES;
    
    //8.设置搜索栏右边的按钮
//    bar.showsSearchResultsButton  = YES;//向下的箭头
    bar.showsCancelButton = YES; //取消按钮
    bar.showsBookmarkButton =  YES; //书签按钮
    
    //9.提示内容
    bar.placeholder = @"搜索";
    
    //10.取消键盘操作
    [bar resignFirstResponder];
    
    //11.设置代理
    //UISearchBar不执行搜索行为，必须使用delegate，当输入搜索文本、点击button按钮后，代理的方法会完成搜索对应的操作。
    //.控件的委托，委托要遵从UISearchBarDelegate协议，默认是nil
    bar.delegate = self;

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
