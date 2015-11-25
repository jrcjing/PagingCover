//
//  LJPagingCover.h
//  ContextTest
//
//  Created by 婧 李 on 15/9/2.
//  Copyright (c) 2015年 Lisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LJPagingCover;

@protocol LJPageCoverDelegate <NSObject>
@optional
- (void)pageCoverDidScroll:(LJPagingCover *)pagingCover;
- (void)pageCoverDidEndScroll:(LJPagingCover *)pagingCover;
- (void)pageCoverCurrentPageDidChanged:(LJPagingCover *)pagingCover;

@end

@protocol LJPageCoverDataSource <NSObject>
@required
- (CGSize)pageItemSizeInPagingCover:(LJPagingCover *)pagingCover;

- (CGFloat)pageItemSpaceInPagingCover:(LJPagingCover *)pagingCover;

- (NSInteger)pageItemsCountInPagingCover:(LJPagingCover *)pagingCover;

- (UIView *)pageItem:(UIView *)pageItem atIndex:(NSInteger)index inPagingCover:(LJPagingCover *)pagingCover;

@end



@interface LJPagingCover : UIView

@property (nonatomic, weak) id<LJPageCoverDelegate> delegate;
@property (nonatomic, weak) id<LJPageCoverDataSource> dataSource;

@property (nonatomic, readonly) NSInteger currentPageIndex;
@property (nonatomic, readonly) UIView *currentPageItem;
@property (nonatomic, assign) CGRect visibleRect;

- (void)reloadData;
- (void)scrollToPageItemAtIndex:(NSInteger)index animation:(BOOL)animation;
- (void)registerClassforPageItem:(Class)pageItemClass;
- (UIView *)pageItemAtIndex:(NSInteger)index;

@end
