//
//  ColorFavTableViewController.m
//  ColorM
//
//  Created by gongwenkai on 2017/1/30.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "ColorFavTableViewController.h"
#import "CoreDataOperations.h"
#import "ColorFavTableViewCell.h"
#import <StoreKit/StoreKit.h>
#import "GDTMobBannerView.h"
@interface ColorFavTableViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic,strong) NSArray *profuctIdArr;
@property (nonatomic,copy) NSString *currentProId;
@property (nonatomic,strong)NSArray *favArray;
@end
static NSString *cellID = @"cellIdendity";

@implementation ColorFavTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"ColorFavTableViewCell" bundle:nil] forCellReuseIdentifier:@"ColorFavCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"will");
    [super viewWillAppear:animated];

    NSArray *array = [[CoreDataOperations sharedInstance] showFavList];
    self.favArray = [NSArray arrayWithArray:array];
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"t");

    return self.favArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ColorFavTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ColorFavCell" forIndexPath:indexPath];
    if (cell == NULL) {
        [tableView registerNib:[UINib nibWithNibName:@"ColorFavTableViewCell" bundle:nil] forCellReuseIdentifier:@"ColorFavCell"];
        
    }
    Fav *obj = self.favArray[indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置日期格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //将日期转换成字符串输出
    NSString *currentDateStr = [dateFormatter   stringFromDate:obj.timestamp];
    ColorFavCellModel *model = [[ColorFavCellModel alloc] init];
    model.oxStr = obj.colorOX;
    model.rgbStr = obj.colorRGB;
    model.favTimeStr = currentDateStr;
    model.colorID = obj.colorID;
    cell.model = model;
    
    
    return cell;
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CGRectGetWidth(self.view.frame)* 0.2;

}

//滑动删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ColorFavTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[CoreDataOperations sharedInstance] deleteWithModel:cell.model];
        NSArray *array = [[CoreDataOperations sharedInstance] showFavList];
        self.favArray = [NSArray arrayWithArray:array];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GDTMobBannerView *bannerView = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)
                                                                    appkey:GDT_APPID placementId:GDT_BANNER_FAV];
    
    bannerView.currentViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    bannerView.isAnimationOn = NO;
    bannerView.showCloseBtn = NO;
    bannerView.isGpsOn = YES;
    [bannerView loadAdAndShow];
    return bannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int isBuy = [[CoreDataOperations sharedInstance] isBuyNoAds];
    if (isBuy == 0) {
        return 50;
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ColorFavTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *oxStr = [NSString stringWithFormat:@"ox%@",cell.model.oxStr];
    NSString *rgbStr = [NSString stringWithFormat:@"RGB(%@)",cell.model.rgbStr];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"复制到剪切板" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:oxStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:oxStr];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:rgbStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:rgbStr];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];

}


#pragma mark - 内购
- (IBAction)clickPhures:(id)sender {
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"购买去广告服务" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        

        NSString *product = @"123";
        _currentProId = product;
        if([SKPaymentQueue canMakePayments]){
            [self requestProductData:product];
        }else{
            NSLog(@"不允许程序内付费");
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"已购买直接去广告" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


//请求商品
- (void)requestProductData:(NSString *)type{
    NSLog(@"-------------请求对应的产品信息----------------");
    
    
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        NSLog(@"--------------没有商品------------------");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:_currentProId]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------反馈信息结束-----------------");
}
//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
-(void)verifyPurchaseWithPaymentTransaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:AppStore];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dic);
    if([dic[@"status"] intValue]==0){
        NSLog(@"购买成功！");
        [[CoreDataOperations sharedInstance] buyNoAds];
        [self.tableView reloadData];

        NSDictionary *dicReceipt= dic[@"receipt"];
        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        if ([productIdentifier isEqualToString:@"123"]) {
            NSInteger purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
        }else{
            [defaults setBool:YES forKey:productIdentifier];
        }
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else{
        NSLog(@"购买失败，未通过验证！");
    }
}
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    
    
    for(SKPaymentTransaction *tran in transaction){
        

        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [[CoreDataOperations sharedInstance] buyNoAds];
                [self.tableView reloadData];
                
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [[CoreDataOperations sharedInstance] buyNoAds];
                [self.tableView reloadData];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
@end
