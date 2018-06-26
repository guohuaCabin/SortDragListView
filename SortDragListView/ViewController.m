//
//  ViewController.m
//  SortDragListView
//
//  Created by 秦国华 on 2018/6/26.
//  Copyright © 2018年 秦国华. All rights reserved.
//

#import "ViewController.h"
#import "UIView+CreateUtils.h"
#import "SortDragVC.h"
@interface ViewController ()

@property (nonatomic,strong) UIButton *sortBtn;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}



-(void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    
    _sortBtn = [self.view btnF:CGRectMake(20, 150, self.view.frame.size.width - 40, 50) title:@"点击进入排序界面" fsize:16];
    [_sortBtn addTarget:self action:@selector(sortBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_sortBtn];
}

-(void)sortBtnClicked:(UIButton *)sender
{
    SortDragVC *vc = [[SortDragVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
