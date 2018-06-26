//
//  EditListCell.h
//  SortDragListView
//
//  Created by 秦国华 on 2018/6/26.
//  Copyright © 2018年 秦国华. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditListCellDelegate<NSObject>

-(void)selectEditListCellWithSelectText:(NSString *)selectText isSelect:(BOOL)isSelect;

-(void)stickTopCellWithTopText:(NSString *)topText;

-(void)dragCellWithTap:(UILongPressGestureRecognizer *)tap ;

@end

@interface EditListCell : UICollectionViewCell

//是否正在移动状态
@property (nonatomic, assign) BOOL isMoving;

//是否不可移动
@property (nonatomic, assign) BOOL isFixed;

@property (nonatomic,weak) id<EditListCellDelegate> delegate;

-(void)updateCellWithText:(NSString *)text isSelect:(BOOL)isSelect;


+(CGFloat)cellHeight;

@end
