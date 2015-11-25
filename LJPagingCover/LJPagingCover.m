//
//  LJPagingCover.m
//  ContextTest
//
//  Created by 婧 李 on 15/9/2.
//  Copyright (c) 2015年 Lisa. All rights reserved.
//

#import "LJPagingCover.h"

@interface LJPagingCover()<UIScrollViewDelegate>
{
    CGFloat    itemHeight;
    CGFloat    itemWidth;
    CGFloat    itemSpace;
    
    NSInteger  queueCount;
    NSInteger  maxCount;
    
    NSInteger  dataIndex;
    NSInteger  queueIndex;
    NSInteger  preIndex;
    NSInteger  lastIndex;
    
    Class      cellClass;
    
    BOOL isReloading;
    BOOL isScrolling;
}

@property (nonatomic,strong) UIScrollView *scrollView;
@property (atomic,strong) NSMutableArray *viewQueue;
@end


@implementation LJPagingCover

- (void)dealloc{
    [_viewQueue removeAllObjects];
    self.viewQueue = nil;
    
    self.delegate = nil;
    self.dataSource = nil;
    self.scrollView.delegate = nil;
    self.scrollView = nil;
    
    cellClass = nil;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = YES;
        self.opaque = YES;
        
        self.viewQueue = [[NSMutableArray alloc] init];
        lastIndex = -1;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.pagingEnabled = YES;
        _scrollView.clipsToBounds = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];

    }
    return self;
}

- (CGRect)visibleRect{
    CGSize size = [_dataSource pageItemSizeInPagingCover:self];
    itemWidth = size.width;
    itemHeight = size.height;
    
    if([_dataSource respondsToSelector:@selector(pageItemSpaceInPagingCover:)]){
        itemSpace = [_dataSource pageItemSpaceInPagingCover:self];
    }
    
    CGFloat originX = (self.frame.size.width - itemWidth - itemSpace*2)/2;
    _visibleRect = CGRectMake(originX + itemSpace, 0, itemWidth, itemHeight);
    return _visibleRect;
}


- (void)reloadData{
    if(!_dataSource || !cellClass) return;
    
    if(![_dataSource respondsToSelector:@selector(pageItemsCountInPagingCover:)] || ![_dataSource respondsToSelector:@selector(pageItemSizeInPagingCover:)] || ![_dataSource respondsToSelector:@selector(pageItem:atIndex:inPagingCover:)]) return;
    
    isReloading = YES;
    
    NSInteger pageCount = [_dataSource pageItemsCountInPagingCover:self];
    maxCount = pageCount;
    
    CGSize size = [_dataSource pageItemSizeInPagingCover:self];
    itemWidth = size.width;
    itemHeight = size.height;
    
    if([_dataSource respondsToSelector:@selector(pageItemSpaceInPagingCover:)]){
        itemSpace = [_dataSource pageItemSpaceInPagingCover:self];
    }
    
    CGFloat originX = (self.frame.size.width - itemWidth - itemSpace*2)/2;
    _scrollView.frame = CGRectMake(originX, 0, itemWidth+itemSpace, itemHeight);
    
    queueCount = MIN(maxCount, 4);
    _scrollView.contentSize = CGSizeMake((itemWidth + itemSpace)*pageCount, itemHeight);
    
    
    if(lastIndex!=-1){
        NSInteger fromIndex = MIN(maxCount-queueCount, MAX(lastIndex-1, 0)) ;
        
        dataIndex = lastIndex < (queueCount-2) ? queueCount : (lastIndex > (maxCount-queueCount) ? maxCount : (lastIndex+queueCount-1));
        preIndex = MAX(1, MIN(maxCount-3, lastIndex));
        
        for (int i = 0; i<_viewQueue.count; i++) {
            UIView *cell = [_viewQueue objectAtIndex:i];
            if(cell){
                [cell removeFromSuperview];
                [_viewQueue removeObjectAtIndex:i];
                cell = nil;
            }
            
            UIView *newCell = [[cellClass alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
            newCell.opaque = YES;
            [_viewQueue insertObject:newCell atIndex:i];
        }
        
        if(_viewQueue.count > queueCount){
            for (int i=(int)_viewQueue.count-1; i>queueCount-1; i--) {
                UIView *cell = [_viewQueue objectAtIndex:i];
                if(cell){
                    [cell removeFromSuperview];
                    [_viewQueue removeObject:cell];
                    cell = nil;
                }
            }
        }else if(_viewQueue.count < queueCount){
            for (int i=(int)_viewQueue.count; i<queueCount; i++) {
                UIView *cell = [[cellClass alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
                cell.opaque = YES;
                [_viewQueue addObject:cell];
            }
        }
        
        for (int i=0; i<queueCount; i++) {
            NSInteger theQueueIndex = queueIndex+i;
            theQueueIndex = theQueueIndex > queueCount-1 ? (theQueueIndex-queueCount) : theQueueIndex;
            if(theQueueIndex >= _viewQueue.count) continue;
            
            CGRect rect = CGRectMake((fromIndex+i)*(itemWidth + itemSpace) + itemSpace, 0, itemWidth, itemHeight);
            UIView *cell = [_viewQueue objectAtIndex:theQueueIndex];
            UIView *newCell = [_dataSource pageItem:cell atIndex:fromIndex+i inPagingCover:self];
            newCell.frame = rect;
            if(!newCell.superview){
                [_scrollView addSubview:newCell];
            }
        }
        
    }else{
        for (int i=0; i<queueCount; i++) {
            CGRect rect = CGRectMake(i*(itemWidth + itemSpace) + itemSpace, 0, itemWidth, itemHeight);
            UIView *cell = [[cellClass alloc] initWithFrame:rect];
            cell.opaque = YES;
            cell = [_dataSource pageItem:cell atIndex:i inPagingCover:self];
            [_scrollView addSubview:cell];
            [self.viewQueue addObject:cell];
            dataIndex++;
        }
        lastIndex = 0;
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(pageCoverDidEndScroll:)]){
        [_delegate pageCoverDidEndScroll:self];
    }
    
    isReloading = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(_delegate && [_delegate respondsToSelector:@selector(pageCoverDidScroll:)]){
        [_delegate pageCoverDidScroll:self];
    }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.x < 0) return;
    
    isScrolling = YES;
    if(_delegate && [_delegate respondsToSelector:@selector(pageCoverDidScroll:)]){
        [_delegate pageCoverDidScroll:self];
    }
    
    int p = round(scrollView.contentOffset.x / (itemWidth + itemSpace));
    if(p == lastIndex) return;
    
    lastIndex = p;
    
    if(_delegate && [_delegate respondsToSelector:@selector(pageCoverCurrentPageDidChanged:)]){
        [_delegate pageCoverCurrentPageDidChanged:self];
    }
    
    if(p > preIndex && p >= queueCount-2){
        if(p-preIndex <= queueCount-1){
            if(p-preIndex < 2){
                if(p >= maxCount-1) return;
            }else if(p > maxCount-2){
                return;
            }
        }
        [self pullRight:p - preIndex];
    }else if(p < preIndex){
        if(preIndex-p <= queueCount-1){
            if(preIndex-p < 2){
                if(!p) return;
            }else if(p >= maxCount-2){
                return;
            }
        }
        [self pullLeft:preIndex - p];
    }
    
    preIndex = p;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        isScrolling = NO;
        if(_delegate && [_delegate respondsToSelector:@selector(pageCoverDidEndScroll:)]){
            [_delegate pageCoverDidEndScroll:self];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    isScrolling = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(pageCoverDidEndScroll:)]){
        [_delegate pageCoverDidEndScroll:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    isScrolling = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(pageCoverDidEndScroll:)]){
        [_delegate pageCoverDidEndScroll:self];
    }
}

-(void)pullRight:(NSInteger)count{
    
    for(int i = 0; i < count; i++)
    {
        if(dataIndex >= maxCount) continue;
        //DLog(@"right: queueIndex:%d,itemIndex:%d",queueIndex,dataIndex);
        UIView *cell = [_viewQueue objectAtIndex:queueIndex];
        if([_dataSource respondsToSelector:@selector(pageItem:atIndex:inPagingCover:)]){
            cell = [_dataSource pageItem:cell atIndex:dataIndex inPagingCover:self];
        }
        cell.frame = CGRectMake(dataIndex * (itemWidth + itemSpace) + itemSpace, 0, itemWidth, itemHeight);
        dataIndex++;
        queueIndex = queueIndex + 1 == queueCount ? 0: queueIndex + 1;
        
    }
    
}

-(void)pullLeft:(NSInteger)count{
    
    for (int i=0; i<count; i++) {
        dataIndex--;
        queueIndex = queueIndex == 0 ? queueCount - 1: queueIndex - 1;
        
        NSInteger index = queueIndex;
        NSInteger value = dataIndex - queueCount;
        
        //DLog(@"left: queueIndex:%d,itemIndex:%d",index,value);
        
        if(value<0) continue;
        
        UIView *cell = [_viewQueue objectAtIndex:index];
        
        if([_dataSource respondsToSelector:@selector(pageItem:atIndex:inPagingCover:)]){
            cell = [_dataSource pageItem:cell atIndex:value inPagingCover:self];
        }
        
        cell.frame = CGRectMake(value * (itemSpace + itemWidth) + itemSpace, 0, itemWidth, itemHeight);
    }
    
}


- (void)scrollToPageItemAtIndex:(NSInteger)index animation:(BOOL)animation{
    CGPoint point = CGPointMake(index*(itemSpace + itemWidth), 0);
    [_scrollView setContentOffset:point animated:animation];
}

- (NSInteger)currentPageIndex{
    return lastIndex;
}


- (UIView *)pageItemAtIndex:(NSInteger)index{
    
    NSInteger margin = index - lastIndex;
    
    if((margin>0 && margin<(queueCount-1)) || (margin<0 && margin>=-1) ||!margin){
        for (UIView *view in _viewQueue) {
            NSInteger count = round((view.frame.origin.x-itemSpace) / (itemWidth + itemSpace)) ;
            
            if(count == index){
                return view;
            }
        }
    }
    
    
    return nil;
}

- (void)registerClassforPageItem:(Class)pageItemClass{
    if(pageItemClass != cellClass){
        cellClass = pageItemClass;
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self){
        return _scrollView;
    }else{
        return hitView;
    }
}

@end
