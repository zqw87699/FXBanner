//
//  FXBannerView.m
//  TTTT
//
//  Created by 张大宗 on 2017/3/22.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import "FXBannerView.h"
#import "Masonry.h"
#import "RACUtiles.h"
#import "FXCommon.h"
#import "ReactiveObjC.h"

#define BannerWidth [[UIScreen mainScreen] bounds].size.width

@interface FXBannerView()<UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic,weak) IBOutlet UIPageControl *refPageControl;

@property (nonatomic,weak) UITapGestureRecognizer *refTapGesture;

@property (nonatomic,weak) NSObject<IFXBannerDelegate>* bannerViewDelegate;

@property (nonatomic,assign) NSInteger timerTag;

@property (nonatomic,strong) NSMutableArray* bannerViewList;

@end

@implementation FXBannerView

+ (instancetype)addBannerForView:(UIView *)view Height:(CGFloat)height{
    FXBannerView *banner = [FXBannerView fx_instance];
    if (banner) {
        [view addSubview:banner];
        [banner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.right.equalTo(view.mas_right);
            make.top.equalTo(view.mas_top);
            make.height.equalTo(@(height));
        }];
    }
    return banner;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _scrollInterval = 4.0f;
    _enabledAutoScroll = YES;
    _enabledPage = YES;
    
    [self.refPageControl setNumberOfPages:[_bannerItems count]];
    
    [self initDelegate];
    
    FX_WEAK_REF_TYPE selfObject = self;
    [[self rac_valuesAndChangesForKeyPath:@"scrollInterval" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(id  _Nullable x) {
        [selfObject performSelectorOnMainThread:@selector(refreshTimer) withObject:nil waitUntilDone:NO];
    }];
    
    [[self rac_valuesAndChangesForKeyPath:@"enabledAutoScroll" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(id  _Nullable x) {
        [selfObject performSelectorOnMainThread:@selector(refreshTimer) withObject:nil waitUntilDone:NO];
    }];
    
    [[self rac_valuesAndChangesForKeyPath:@"bannerItems" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(id  _Nullable x) {
        [selfObject performSelectorOnMainThread:@selector(refreshBannerItemsUI) withObject:nil waitUntilDone:NO];
    }];
    
    [[self rac_valuesAndChangesForKeyPath:@"enabledPage" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(id  _Nullable x) {
        [selfObject performSelectorOnMainThread:@selector(refreshTimer) withObject:nil waitUntilDone:NO];
    }];
}

- (void)dealloc {
    _bannerViewDelegate = nil;
}

- (void)setBannerDelegate:(NSObject<IFXBannerDelegate> *)delegate{
    _bannerViewDelegate = delegate;
}

- (void)initDelegate{
    
    FX_WEAK_REF_TYPE selfObject = self;
    [[self rac_signalForSelector:@selector(scrollViewWillBeginDragging:) fromProtocol:@protocol(UIScrollViewDelegate)] subscribeNext:^(id  _Nullable x) {
         [selfObject stopScroll];
    }];
    
    [[self rac_signalForSelector:@selector(scrollViewDidEndDragging:willDecelerate:) fromProtocol:@protocol(UIScrollViewDelegate)] subscribeNext:^(id  _Nullable x) {
        [selfObject startScroll];
    }];
    
    [[self rac_signalForSelector:@selector(scrollViewDidScroll:) fromProtocol:@protocol(UIScrollViewDelegate)] subscribeNext:^(id  _Nullable x) {
        NSInteger index = (NSInteger)(floor((selfObject.scrollView.contentOffset.x+BannerWidth/2.0f)/BannerWidth));
        if(index == 0) {
            [selfObject.scrollView setContentOffset:CGPointMake(selfObject.scrollView.contentOffset.x+BannerWidth*[selfObject.bannerItems count], selfObject.scrollView.contentOffset.y)];
            index = [selfObject.bannerItems count] ;
        } else if (index == [selfObject.bannerItems count]+1) {
            index = 1;
            [selfObject.scrollView setContentOffset:CGPointMake(selfObject.scrollView.contentOffset.x-BannerWidth*[selfObject.bannerItems count], selfObject.scrollView.contentOffset.y)];
        }
        selfObject.refPageControl.currentPage = index-1;
    }];

    [self.scrollView setDelegate:self];
}

-(void) refreshBannerItemsUI {
    
    NSMutableArray *bannerList = [[NSMutableArray alloc] init];
    [bannerList addObject:_bannerItems.lastObject];
    [bannerList addObjectsFromArray:_bannerItems];
    [bannerList addObject:_bannerItems.firstObject];
    
    [_scrollView setScrollEnabled:[_bannerItems count]>1?YES:NO];
    [_scrollView setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width*[bannerList count], self.frame.size.height)];
    [_scrollView setContentOffset:CGPointMake(BannerWidth, _scrollView.contentOffset.y) animated:NO];
    
    for (int i=0; i<[_bannerViewList count]; i++) {
        [[_bannerViewList objectAtIndex:i] removeFromSuperview];
    }
    [_bannerViewList removeAllObjects];
 
    FX_WEAK_REF_TYPE selfObject = self;
    for (int i=0; i<[bannerList count]; i++) {
        UIImageView * v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[bannerList[i] bannerImg]]];
        [self.scrollView addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(i*BannerWidth));
            make.right.equalTo(@(i*BannerWidth+BannerWidth));
            make.top.equalTo(selfObject.scrollView.mas_top);
            make.height.equalTo(selfObject.scrollView.mas_height);
        }];
        [_bannerViewList addObject:v];
    }
    if (!_refTapGesture) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [self.scrollView addGestureRecognizer:tap];
         [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
         [selfObject.bannerViewDelegate didClickBanner:_bannerItems[selfObject.refPageControl.currentPage]];
         }];
        _refTapGesture = tap;
    }
    
    [self.refPageControl setNumberOfPages:[_bannerItems count]];
    if ([_bannerItems count] <= 1) {
        [self stopScroll];
    }
    [self refreshTimer];
}

- (void)refreshTimer{
    if (_enabledAutoScroll && _scrollInterval > 0) {
        [self startScroll];
    } else {
        [self stopScroll];
    }
}

- (void)stopScroll{
    [RACUtiles forceEnd:self.timerTag];
}

- (void)startScroll{
    [self stopScroll];

    if ( _enabledAutoScroll && _scrollInterval > 0 && [_bannerItems count] > 1) {
        //定时器，每_scrollInterval执行一次
        FX_WEAK_REF_TYPE selfObject = self;
        self.timerTag = [RACUtiles timerWithInterval:_scrollInterval Block:^(NSInteger tag) {
            [selfObject.scrollView setContentOffset:CGPointMake(selfObject.scrollView.contentOffset.x +BannerWidth, selfObject.scrollView.contentOffset.y) animated:YES];
        }];
    }
}

@end
