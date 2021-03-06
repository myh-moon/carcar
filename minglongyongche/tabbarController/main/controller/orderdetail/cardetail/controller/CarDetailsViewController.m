//
//  CarDetailsViewController.m
//  minglongyongche
//
//  Created by jiamanu on 2018/4/3.
//  Copyright © 2018年 minglongkeji. All rights reserved.
//

#import "CarDetailsViewController.h"
#import "OrderCommitViewController.h"
#import "LoginViewController.h" //登录

 //footer
#import "DetailOrderView.h"

//短租
#import "CarDetailBannerItem.h"
#import "CarDetailItem.h"
#import "CarListItem.h"
#import "CarDetailLimitItem.h"
#import "CarDetailConfigItem.h"
#import "CarDetailTipsItem.h"

//婚车
#import "CarFixedItem.h"
#import "CarOrderItem.h"

//二手车
#import "WordItem.h"

#import "ShortRentResult.h"

@interface CarDetailsViewController ()

@property (nonatomic,strong) UITableView *carDetailTableView;
@property (nonatomic,strong) DetailOrderView *orderBottomView;
@property (nonatomic,strong) RETableViewManager *manager;

@property (nonatomic,strong) NSMutableArray *detailArray;

@end

@implementation CarDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.leftBarItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavBtn];
    [self.rightNavBtn setImage:[UIImage imageNamed:@"share"] forState:0];
    MLWeakSelf;
    [self.rightNavBtn addAction:^(UIButton *btn) {
        [weakself showHint:@"分享"];
    }];
    
    [self.view addSubview:self.carDetailTableView];
    [self.view addSubview:self.orderBottomView];
    
    [self.view setNeedsUpdateConstraints];
    
    self.manager = [[RETableViewManager alloc] initWithTableView:self.carDetailTableView];
    
//    if ([self.type isEqualToString:@"短租"]) {
        self.manager[@"CarDetailBannerItem"] = @"BannnerCell";
        self.manager[@"CarDetailItem"] = @"CarDetailTextCell";
        self.manager[@"CarDetailLimitItem"] = @"CarDetailLimitCell";
        self.manager[@"CarDetailConfigItem"] = @"CarDetailConfigCell";
        self.manager[@"CarDetailTipsItem"] = @"CarDetailTipsCell";
//    }
    
    [self getDetailOfCarWithZId:self.zid];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
       
        [self.carDetailTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge: ALEdgeBottom];
        [self.carDetailTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.orderBottomView];
        
//        [self.carDetailTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
//        [self.carDetailTableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
//        [self.carDetailTableView autoPinToTopLayoutGuideOfViewController:self withInset:0];
        
        [self.orderBottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.orderBottomView autoSetDimension:ALDimensionHeight toSize:60];
        
        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

#pragma mark - getter
- (UITableView *)carDetailTableView {
    if (!_carDetailTableView) {
        _carDetailTableView  = [UITableView newAutoLayoutView];
        _carDetailTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, bigSpacing)];
    }
    return _carDetailTableView;
}

- (DetailOrderView *)orderBottomView {
    if (!_orderBottomView) {
        _orderBottomView = [DetailOrderView newAutoLayoutView];
        
        //文字显示
        [_orderBottomView.collectionButton.btnImageView setImage:[UIImage imageNamed:@"collectlion"]];
        _orderBottomView.collectionButton.btnLabel.text = @"收藏";
        
//        [RACObserve(_orderBottomView.collectionButton.btnLabel, text) subscribeNext:^(id x) {
//            if (x) {
//                <#statements#>
//            }
//        }];
        
        MLWeakSelf;
        RACSignal *signal = [RACSignal combineLatest:@[RACObserve(_orderBottomView.collectionButton.btnLabel, text)] reduce:^id(NSString *text){
            [weakself.orderBottomView.collectionButton addAction:^(UIButton *btn) {
                if (!TOKEN) {
                    [weakself toLoginifNotLoginFromController:weakself];
                }else{
                    if ([text isEqualToString:@"收藏"]) {
                        [weakself addCollectionWithZid:weakself.zid];
                    }else{
                        [weakself deleteCollectionWithZid:weakself.zid];
                    }
                }
            }];
            return @"collect";
        }];
        
        [signal subscribeNext:^(id x) {
            
        }];
        
        
        
        //target
        [_orderBottomView setDidSelectedBtn:^(NSInteger tag) {
            if (!TOKEN) {
                [weakself toLoginifNotLoginFromController:weakself];
            }else {
                    if(tag == 35){
                    OrderCommitViewController *orderCommitVC = [[OrderCommitViewController alloc] init];
                    if (weakself.detailArray.count > 0 ) {
                        orderCommitVC.carModel = weakself.detailArray[0];
                    }
                    [weakself.navigationController pushViewController:orderCommitVC animated:YES];
                }
            }
        }];
    }
    return _orderBottomView;
}

- (NSMutableArray *)detailArray {
    if (!_detailArray) {
        _detailArray = [NSMutableArray new];
    }
    return _detailArray;
}

#pragma mark - method
- (void) setupCarDetailTableView {
    
    RETableViewSection *detailSection = [RETableViewSection section];
    detailSection.headerHeight = 0;
    detailSection.footerHeight = 0;
    [self.manager addSection:detailSection];
    
    CarModel *carModel = self.detailArray[0];
    
    //1.短租
    //banner
    CarDetailBannerItem *item0 = [[CarDetailBannerItem alloc] initWithCarModel:carModel];
    item0.selectionStyle = UITableViewCellSelectionStyleNone;
    [detailSection addItem:item0];
    
    //详情
    CarDetailItem *item1 = [[CarDetailItem alloc] initWithCarDetaiModel:carModel];
    item1.selectionStyle = UITableViewCellSelectionStyleNone;
    [detailSection addItem:item1];
    
    //用车限制
    CarDetailLimitItem *item3 = [[CarDetailLimitItem alloc] init];
    item3.selectionStyle = UITableViewCellSelectionStyleNone;
    [detailSection addItem:item3];
    
    //车辆配置
    CarDetailConfigItem *item5 = [[CarDetailConfigItem alloc] initWithCarDetaiModel:carModel];
    item5.selectionStyle = UITableViewCellSelectionStyleNone;
    [detailSection addItem:item5];
    
//    取车需知
    CarDetailTipsItem *item6 = [[CarDetailTipsItem alloc] init];
    item6.selectionStyle = UITableViewCellSelectionStyleNone;
    [detailSection addItem:item6];
}

//详情
- (void)getDetailOfCarWithZId:(NSString *)zid {
    NSString *carDetail;
    
    if (!TOKEN) {
       carDetail = [NSString stringWithFormat:@"%@%@%@",MLBaseUrl,MLCarDetailOfShortRent,zid];
    }else{
        carDetail = [NSString stringWithFormat:@"%@%@%@/%@",MLBaseUrl,MLCarDetailOfShortRent,zid,TOKEN];
    }
    
    NSDictionary *pp = @{@"type" : @"1"};
    
    MLWeakSelf;
    [self requestDataGetWithString:carDetail params:pp successBlock:^(id responseObject) {
        
        ShortRentResult *carResult = [ShortRentResult mj_objectWithKeyValues:responseObject];
        
        CarModel *carModel = carResult.data;
        if (carModel) {
            [weakself.detailArray addObject:carModel];
            [weakself setupCarDetailTableView];
            [weakself.carDetailTableView reloadData];
        }
        
        //显示收藏文字
        if ([carModel.sc isEqualToString:@"0"]) {
            [weakself.orderBottomView.collectionButton.btnImageView setImage:[UIImage imageNamed:@"collectlion"]];
            weakself.orderBottomView.collectionButton.btnLabel.text = @"收藏";
        }else{
            [weakself.orderBottomView.collectionButton.btnImageView setImage:[UIImage imageNamed:@"collected"]];
            weakself.orderBottomView.collectionButton.btnLabel.text = @"已收藏";
        }
    } andFailBlock:^(NSError *error) {
    }];
}

//添加收藏
- (void) addCollectionWithZid:(NSString *)zid {
    
    NSString *addCollectionStr = [NSString stringWithFormat:@"%@%@%@",MLBaseUrl,MLCollectionOfAdd,TOKEN];
    
    NSDictionary *param = @{@"aid" : zid,@"type" : @"1"};
    
    MLWeakSelf;
    [self requestDataPostWithString:addCollectionStr params:param successBlock:^(id responseObject) {
        
        BaseModel *model = [BaseModel mj_objectWithKeyValues:responseObject];
        [weakself showHint:model.info];
        
        if ([model.status isEqualToString:@"200"]) {
            weakself.orderBottomView.collectionButton.btnLabel.text = @"已收藏";
            [weakself.orderBottomView.collectionButton.btnImageView setImage:[UIImage imageNamed:@"collected"]];
        }
        
    } andFailBlock:^(NSError *error) {
        
    }];
}

//取消收藏
- (void) deleteCollectionWithZid:(NSString *)zid {
    NSString *deleteStr = [NSString stringWithFormat:@"%@%@%@/%@",MLBaseUrl,MLCollectionOfCancel,TOKEN,zid];
    
    MLWeakSelf;
    [self requestDataGetWithString:deleteStr params:nil successBlock:^(id responseObject) {
        BaseModel *model = [BaseModel mj_objectWithKeyValues:responseObject];
        [weakself showHint:model.info];
        
        if ([model.status isEqualToString:@"200"]) {
            weakself.orderBottomView.collectionButton.btnLabel.text = @"收藏";
            [weakself.orderBottomView.collectionButton.btnImageView setImage:[UIImage imageNamed:@"collectlion"]];
        }
   } andFailBlock:^(NSError *error) {
       
   }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
