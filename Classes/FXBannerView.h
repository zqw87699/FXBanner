//
//  FXBannerView.h
//  TTTT
//
//  Created by 张大宗 on 2017/3/22.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFXBannerDelegate.h"
#import "IFXBannerData.h"
#import "BaseFXView.h"

@interface FXBannerView : BaseFXView

/**
 *  滚动时间间隔
 *  default 4s
 */
@property (nonatomic, assign) int scrollInterval;

/**
 *  是否启用自动滚动
 *  default YES
 */
@property (nonatomic, assign) BOOL enabledAutoScroll;

/**
 *  是否启用自动滚动
 *  default YES
 */
@property (nonatomic, assign) BOOL enabledPage;

/**
 *  banner 项列表
 */
@property (nonatomic, copy) NSArray<id<IFXBannerData>> *bannerItems;

+ (instancetype) addBannerForView:(UIView*)view Height:(CGFloat)height;

- (void)setBannerDelegate:(NSObject<IFXBannerDelegate>*)delegate;

-(void) stopScroll;


@end
