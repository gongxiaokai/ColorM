//
//  CoreDataOperations.h
//  ColorM
//
//  Created by gongwenkai on 2017/1/30.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ColorM+CoreDataModel.h"
#import "ColorFavCellModel.h"



@interface CoreDataOperations : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//单例
+ (instancetype)sharedInstance;

//保存颜色 添加到收藏列表
- (void)saveColorOX:(NSString*)oxStr andRGB:(NSString*)rgbStr;

//删除
- (void)deleteWithModel:(ColorFavCellModel*)model;

//列出收藏颜色
- (NSArray*)showFavList;

- (int)isBuyNoAds;
//购买去广告
- (void)buyNoAds;
//广告重置 出现
- (void)adsReset;
@end
