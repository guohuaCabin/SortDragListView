//
//  SortDragVC.m
//  SortDragListView
//
//  Created by 秦国华 on 2018/6/26.
//  Copyright © 2018年 秦国华. All rights reserved.
//

#import "SortDragVC.h"
#import "EditListCell.h"
#import "UIView+CreateUtils.h"
@interface SortDragVC ()
<UICollectionViewDelegate,UICollectionViewDataSource,EditListCellDelegate>

@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIButton *selectAllBtn;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *doBtn;

@property (nonatomic,strong) UIView *segmentView;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *selectArray;

@property (nonatomic,strong) UICollectionView *collectionView;
//正在拖拽的indexpath
@property (nonatomic,strong) NSIndexPath *dragingIndexPath;
//目标位置
@property (nonatomic,strong) NSIndexPath *targetIndexPath;

@end

#define ScreenBounds           [[UIScreen mainScreen] bounds].size
#define ScreenW                 ScreenBounds.width
#define ScreenH                 ScreenBounds.height

@implementation SortDragVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupViews];
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

-(NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [[NSMutableArray alloc]init];
    }
    return _selectArray;
}

-(void)initData
{
    for (NSInteger i = 0; i<30; i++) {
        
        NSString *obj = [NSString stringWithFormat:@"GH_%li",i];
        [self.dataArray addObject:obj];
        
    }
}

-(void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    [self createHeaderView];
    [self createSegmentView];
    [self createCollectionView];
}
-(void)createHeaderView
{
    CGFloat commonF = 16;
    CGFloat navbarH = 44;
    UIColor *commonColor = [UIColor blackColor];
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, ScreenW, navbarH)];
    _headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headerView];
    
    
    CGFloat commonBtnW = 35;
    //全选
    _selectAllBtn = [self.view btnF:CGRectMake(20, 0, 61, 44) title:@"全选" fsize:commonF];
    [_selectAllBtn setTitleColor:commonColor forState:UIControlStateNormal];
    [_selectAllBtn setImage:[UIImage imageNamed:@"noSelectIcon"] forState:UIControlStateNormal];
    [_selectAllBtn addTarget:self action:@selector(selectAllBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat interval = 3;
    _selectAllBtn.imageEdgeInsets = UIEdgeInsetsMake(0,-interval, 0,interval);
    _selectAllBtn.titleEdgeInsets = UIEdgeInsetsMake(0, interval, 0, -interval);
    [_headerView addSubview:_selectAllBtn];
    
    //删除
    CGFloat deleteBtnX = _selectAllBtn.frame.origin.x + _selectAllBtn.frame.size.width +50;
    _deleteBtn = [self.view btnF:CGRectMake(deleteBtnX, 0, commonBtnW, navbarH) title:@"删除" fsize:commonF];
    [_deleteBtn setTitleColor:commonColor forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_deleteBtn];
    
    //完成
    _doBtn = [self.view btnF:CGRectMake(ScreenW-commonBtnW-15, 0, commonBtnW, navbarH) title:@"完成" fsize:commonF];
    [_doBtn setTitleColor:commonColor forState:UIControlStateNormal];
    [_doBtn addTarget:self action:@selector(doBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_doBtn];
    
}

-(void)createSegmentView
{
    CGFloat segmentViewY = _headerView.frame.origin.y + _headerView.frame.size.height;
    _segmentView = [[UIView alloc]initWithFrame:CGRectMake(0, segmentViewY, ScreenW, 50)];
    _segmentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_segmentView];
    
    CGFloat labW = 30;
    CGFloat labY = 22;
    CGFloat labH = 12;
    CGFloat commonF = 12;
    UIColor *commonColor = [UIColor grayColor];
    UILabel *nameLab = [self.view labF:CGRectMake(60, labY, labW, labH) text:@"名称" fsize:commonF];
    nameLab.textColor = commonColor ;
    [_segmentView addSubview:nameLab];
    
    UILabel *topLab = [self.view labF:CGRectMake(230, labY, labW, labH) text:@"置顶" fsize:commonF];
    topLab.textColor = commonColor;
    topLab.textAlignment = NSTextAlignmentRight;
    [_segmentView addSubview:topLab];
    
    CGFloat dragLabX = ScreenW - 35 - labW;
    UILabel *dragLab = [self.view labF:CGRectMake(dragLabX, labY, labW, labH) text:@"拖动" fsize:commonF];
    dragLab.textAlignment = NSTextAlignmentRight;
    dragLab.textColor = commonColor ;
    [_segmentView addSubview:dragLab];
    
}

-(void)createCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGFloat collectionViewY = _segmentView.frame.origin.y + _segmentView.frame.size.height;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, ScreenW, ScreenH-collectionViewY) collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[EditListCell class] forCellWithReuseIdentifier:@"EditListCell"];
    
}

#pragma mark - ****************  Action
//全选
-(void)selectAllBtnClicked:(UIButton *)sender
{
    self.selectAllBtn.selected = !self.selectAllBtn.isSelected;
    NSString *selectAllImgStr = self.selectAllBtn.selected?@"selectIcon":@"noSelectIcon";
    [self.selectAllBtn setImage:[UIImage imageNamed:selectAllImgStr] forState:UIControlStateNormal];
    if (self.selectAllBtn.isSelected) {
        [self.selectArray removeAllObjects];
        [self.selectArray addObjectsFromArray:self.dataArray];
        [_collectionView reloadData];
    }else{
        [self.selectArray removeAllObjects];
        [_collectionView reloadData];
    }
}

//删除
-(void)deleteBtnClicked:(UIButton *)sender
{
    NSMutableArray<NSIndexPath *> *indexArr = [NSMutableArray array];
    for (int i = 0; i < self.selectArray.count; i++) {
        NSInteger index = [self.dataArray indexOfObject:self.selectArray[i]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [indexArr addObject:indexPath];
    }
    
    // 不能写在上面的for循环里面
    [self.selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.dataArray containsObject:obj] ) {
            [self.dataArray removeObject:obj];
        }
    }];
    
    [self.selectArray removeAllObjects];
    __weak typeof(SortDragVC) *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView deleteItemsAtIndexPaths:indexArr];
    });
    
}
//完成
-(void)doBtnClicked:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark LongPressMethod
//拖拽开始 找到被拖拽的item
-(void)dragBegin:(CGPoint)point
{
    //通过点击的点来获得indexpath
    _dragingIndexPath = [_collectionView indexPathForItemAtPoint:point];
    if (!_dragingIndexPath)
    {
        return;
    }
    //触发长按手势的cell
    EditListCell * cell = (EditListCell*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    cell.isMoving = YES;
    
}

//正在被拖拽ing
-(void)dragChanged:(CGPoint)startPoint
{
    if (!_dragingIndexPath )
    {
        return;
    }
    _targetIndexPath = [_collectionView indexPathForItemAtPoint:startPoint];
    //交换位置 如果没有找到_targetIndexPath则不交换位置
    if (_dragingIndexPath && _targetIndexPath &&(_dragingIndexPath.row != _targetIndexPath.row)) {
        //更新数据源
        [self updateSortDatas];
        //更新item位置
        [_collectionView moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
        _dragingIndexPath = _targetIndexPath;
    }
}

//拖拽结束
-(void)dragEnd{
    if (!_dragingIndexPath)
    {
        return;
    }
    EditListCell *item = (EditListCell*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    item.backgroundColor = [UIColor clearColor];
    item.isMoving = NO;
    [_collectionView reloadData];
    
}

#pragma mark 刷新方法
//拖拽排序后需要重新排序数据源
-(void)updateSortDatas
{
    NSString *text = self.dataArray[_dragingIndexPath.row];
    [_dataArray removeObjectAtIndex:_dragingIndexPath.row];
    [_dataArray insertObject:text atIndex:_targetIndexPath.row];
    
}

#pragma mark - **************** zixuandelegate
-(void)selectEditListCellWithSelectText:(NSString *)selectText isSelect:(BOOL)isSelect
{
    if (selectText == nil) {
        return;
    }
    if (isSelect) {
        if (![self.selectArray containsObject:selectText]) {
            [self.selectArray addObject:selectText];
        }
    }else{
        if ([self.selectArray containsObject:selectText]) {
            [self.selectArray removeObject:selectText];
        }
    }
    
    [_collectionView reloadData];
    
}

-(void)stickTopCellWithTopText:(NSString *)topText
{
    if (topText == nil) {
        return;
    }
    if ([self.dataArray containsObject:topText]) {
        [_dataArray removeObject:topText];
        [_dataArray insertObject:topText atIndex:0];
        [_collectionView reloadData];
    }
}

-(void)dragCellWithTap:(UILongPressGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:_collectionView];
    switch (tap.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}


#pragma mark CollectionViewDelegate&DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"EditListCell";
    EditListCell* item = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    item.delegate = self;
    NSString *text = self.dataArray[indexPath.row];
    BOOL isSelect = NO;
    if ([self.selectArray containsObject:text]) {
        isSelect = YES;
    }
    [item updateCellWithText:text isSelect:isSelect];
    
    return  item;
}

//定义每个cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = [EditListCell cellHeight];
    return CGSizeMake(self.view.frame.size.width, cellHeight);
}

//两行cell之间的间距（上下行cell的间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
