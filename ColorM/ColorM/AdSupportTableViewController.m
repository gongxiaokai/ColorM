//
//  AdSupportTableViewController.m
//  ColorM
//
//  Created by gongwenkai on 2017/2/4.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "AdSupportTableViewController.h"
#import "GDTMobBannerView.h"
@interface AdSupportTableViewController ()
@property(nonatomic,copy)NSArray *adsArray;
@property(nonatomic,copy)NSArray *adsViewArray;
@end
static NSString *cellID = @"suppotAdsCell";

@implementation AdSupportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)adsArray{
    if (!_adsArray) {
        _adsArray = [[NSArray alloc] initWithObjects:GDT_ADSUPPOT1,GDT_ADSUPPOT2,GDT_ADSUPPOT3,GDT_ADSUPPOT4,GDT_ADSUPPOT5, nil];
    }
    return _adsArray;
}

- (NSArray *)adsViewArray{
    if (!_adsViewArray) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *placeId in self.adsArray) {
            GDTMobBannerView *bannerView = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)appkey:GDT_APPID placementId:placeId];
            
            bannerView.currentViewController = self;
            bannerView.isAnimationOn = NO;
            bannerView.showCloseBtn = NO;
            bannerView.isGpsOn = YES;
            [bannerView loadAdAndShow];

            [array addObject:bannerView];
        }
        _adsViewArray = [NSArray arrayWithArray:array];
    }
    return _adsViewArray;
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    [cell.contentView addSubview:self.adsViewArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *lab = [[UILabel alloc] init];
    lab.text = @"支持本应用就帮忙点点广告吧~";
    lab.textColor = [UIColor darkGrayColor];
    lab.backgroundColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:14];
    lab.numberOfLines = 0;

    lab.frame = CGRectMake(10, 10, CGRectGetWidth(self.view.frame)-20, 44);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44+20)];
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:lab];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44+20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UILabel *lab = [[UILabel alloc] init];
    lab.text = @"Bug提交请联系我: 139391025@qq.com";
    lab.textColor = [UIColor darkGrayColor];
    lab.backgroundColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:14];
    lab.numberOfLines = 0;
    
    lab.frame = CGRectMake(10, 10, CGRectGetWidth(self.view.frame)-20, 44);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44+20)];
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:lab];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44+20;
}
@end
