//
//  IFXBannerViewProtocol.h
//  TTTT
//
//  Created by 张大宗 on 2017/3/21.
//  Copyright © 2017年 张大宗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFXBannerData.h"

@protocol IFXBannerViewProtocol <NSObject>

- (void)setBannerCell:(id<IFXBannerData>)data;

- (CGFloat) viewHeight;

@end
