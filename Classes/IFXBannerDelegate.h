//
//  IFXBannerDelegate.h
//  TTTT
//
//  Created by 张大宗 on 2017/3/21.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFXBannerData.h"

@protocol IFXBannerDelegate <NSObject>

- (void)didClickBanner:(id<IFXBannerData>)data;

@end
