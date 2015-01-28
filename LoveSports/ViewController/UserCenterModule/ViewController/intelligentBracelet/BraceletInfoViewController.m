//
//  BraceletInfoViewController.m
//  Woyoli
//
//  Created by jamie on 14-12-2.
//  Copyright (c) 2014年 Missionsky. All rights reserved.
//
#define vGenderChoiceAciotnSheetTag  1234   //性别选择sheet  Tag
#define vPhotoGetAciotnSheetTag    1235  //相片选择sheet  tag

#define v_signOutButtonHeight (kIPhone4s ? 45 : 55.0 ) //退出按钮高度

#define vTableViewLeaveTop   0   //tableView距离顶部的距离

#define vTableViewMoveLeftX 0  //tableview向左移20
#define vOneCellHeight    (kIPhone4s ? 44 : 45.0) //cell单行高度
#define vOneCellWidth     (kScreenWidth + vTableViewMoveLeftX)

#define vHeightMin   60
#define vHeightMax   220

#define vWeightMin   20
#define vWeightMax   250

#import "BraceletInfoViewController.h"

#import "TargetViewController.h"
#import "CustomViewController.h"

@interface BraceletInfoViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    
    NSArray *_cellTitleArray;
    UITableView *_listTableView;
    
    BOOL _haveNewVersion;   //是否有新版本
    
    TargetViewController *_targetVC;
    CustomViewController *_customVC;
    
}
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation BraceletInfoViewController
@synthesize _thisBraceletInfoModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"用户信息";
    self.view.backgroundColor = kBackgroundColor;   //设置通用背景颜色
    self.navigationItem.leftBarButtonItem = [[ObjectCTools shared] createLeftBarButtonItem:@"返回" target:self selector:@selector(goBackPrePage) ImageName:@""];
    
    //初始化
    _cellTitleArray = [NSArray arrayWithObjects:@"每日目标", @"自定义", @"", @"时间与闹钟", @"久坐提醒", @"防丢提醒", @"固件升级", @"恢复到默认设置", nil];

    //tableview
    [self addTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated: NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    NSLog(@"在此请求是否有新固件版本，请求完后再做标记并刷新list");
    //假设有
    _haveNewVersion = YES;
    [self reloadUserInfoTableView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //将要消失时更新存储
    [[BraceletInfoModel getUsingLKDBHelper] insertToDB:_thisBraceletInfoModel];
}

- (void) reloadUserInfoTableView
{
    [_listTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---------------- 页面布局 -----------------
- (void) addTableView
{
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, vTableViewLeaveTop, vOneCellWidth, kScreenHeight - vTableViewLeaveTop) style:UITableViewStylePlain];
    
    [_listTableView setBackgroundColor:kBackgroundColor];
    [[ObjectCTools shared] setExtraCellLineHidden:_listTableView];
    [_listTableView setDelegate:self];
    [_listTableView setDataSource:self];
    _listTableView.center = CGPointMake(_listTableView.centerX - vTableViewMoveLeftX, _listTableView.centerY);
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _listTableView.separatorColor = kHoldPlacerColor;
    [self.view addSubview:_listTableView];
    
    //解决分割线左侧短-1
    if ([_listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark ---------------- User-choice -----------------
//返回上一页
- (void) goBackPrePage{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) goToTarget
{
    NSLog(@"设置每日目标");
    
    if (!_targetVC)
    {
        _targetVC = [[TargetViewController alloc] init];
    }
    _targetVC._thisModel = _thisBraceletInfoModel;
    [self.navigationController pushViewController:_targetVC animated:YES];
}

- (void) goToCustom
{
    NSLog(@"设置自定义");
    
    if (!_customVC)
    {
        _customVC = [[CustomViewController alloc] init];
    }
    _customVC._thisModel = _thisBraceletInfoModel;
    [self.navigationController pushViewController:_customVC animated:YES];
}

- (void) goToTimeAndClock
{
    NSLog(@"设置时间和闹钟");
    
}

- (void) goToUpdateSystem
{
    NSLog(@"固件升级");
}

- (void) goToRecoverDefaultSet
{
    NSLog(@"恢复默认设置");
}

- (void) changeSwith:(UISwitch *) theSwitch
{
    if (theSwitch.tag == 4)
    {
        NSLog(@"更改久坐提醒的状态：%d", theSwitch.on);
        _thisBraceletInfoModel._longTimeSetRemind = theSwitch.on;
        
        return;
    }
    if (theSwitch.tag == 5)
    {
        NSLog(@"更改防丢提醒的状态：%d", theSwitch.on);
        _thisBraceletInfoModel._PreventLossRemind = theSwitch.on;
        
        return;
    }
}

#pragma mark ---------------- UIAlertView delegate -----------------
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"check index = %ld", (long)buttonIndex);
    if (buttonIndex == 1)
    {
        
    }
}

#pragma mark ---------------- TableView delegate -----------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cellTitleArray count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //不使用复用机制
    UITableViewCell *oneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    if ([NSString isNilOrEmpty:[_cellTitleArray objectAtIndex:indexPath.row]])
    {
        oneCell.userInteractionEnabled = NO;
        return oneCell;
    }
    
    //label
    CGRect titleFrame = CGRectMake(0, 0, 100, vOneCellHeight);
    UILabel *title = [[ObjectCTools shared] getACustomLableFrame:titleFrame
                                                 backgroundColor:[UIColor clearColor]
                                                            text:[_cellTitleArray objectAtIndex:indexPath.row]
                                                       textColor:kLabelTitleDefaultColor
                                                            font:[UIFont systemFontOfSize:14]
                                                   textAlignment:NSTextAlignmentLeft
                                                   lineBreakMode:0
                                                   numberOfLines:0];
    [title sizeToFit];
    title.center = CGPointMake(vTableViewMoveLeftX + 16.0 + title.width / 2.0, vOneCellHeight / 2.0);
    [oneCell.contentView addSubview:title];
    
    //右侧箭头
    UIImageView *rightImageView = [[ObjectCTools shared] getACustomImageViewWithCenter:CGPointMake(vOneCellWidth - vOneCellHeight / 2.0 + 5, vOneCellHeight / 2.0) withImageName:@"right.png" withImageZoomSize:1.0];
    [oneCell.contentView addSubview:rightImageView];
    
    
    //右侧titlelable
    UILabel *rightTitle = [[ObjectCTools shared] getACustomLableFrame:titleFrame
                                                      backgroundColor:[UIColor clearColor]
                                                                 text:@""
                                                            textColor:kLabelTitleDefaultColor
                                                                 font:[UIFont systemFontOfSize:12]
                                                        textAlignment:NSTextAlignmentCenter
                                                        lineBreakMode:NSLineBreakByCharWrapping
                                                        numberOfLines:2];
    
    [rightTitle setWidth:rightImageView.x - title.right - 2 - 18];
    //    NSLog(@"lent = %f", rightTitle.width);
    
    UISwitch *slideSwitchH = [[UISwitch alloc]init];
    [slideSwitchH setFrame:CGRectMake(0, 0, 164.0, 26.0)];
    slideSwitchH.center = CGPointMake(rightImageView.centerX  - slideSwitchH.width / 2.0, vOneCellHeight / 2.0);
    [slideSwitchH setOnTintColor:kButtonBackgroundColor];
    slideSwitchH.tag = indexPath.row;
    [slideSwitchH addTarget:self action:@selector(changeSwith:) forControlEvents:UIControlEventValueChanged];
    
    
    switch (indexPath.row)
    {
        case 4:
        {
            [rightTitle setText:kBraceletLongSetRemind];
            [rightTitle setCenter:CGPointMake(vOneCellWidth / 2.0, vOneCellHeight / 2.0)];
            [oneCell.contentView addSubview:rightTitle];
            
            slideSwitchH.on = _thisBraceletInfoModel._longTimeSetRemind;
            [oneCell.contentView addSubview:slideSwitchH];
            
            [rightImageView setHidden:YES];
            
            oneCell.selectionStyle =  UITableViewCellSelectionStyleNone;
        }
            break;
        case 5:
        {
            slideSwitchH.on = _thisBraceletInfoModel._PreventLossRemind;
            [oneCell.contentView addSubview:slideSwitchH];
            
            [rightImageView setHidden:YES];
            
            oneCell.selectionStyle =  UITableViewCellSelectionStyleNone;
        }
            break;
        case 6:
        {
            [rightTitle setText:_thisBraceletInfoModel._deviceVersion];
            [rightTitle setCenter:CGPointMake(vOneCellWidth / 2.0, vOneCellHeight / 2.0)];
            [oneCell.contentView addSubview:rightTitle];
        }
            break;
            
        default:
            break;
    }
    
    
    //设置点选颜色
    //    [oneCell setSelectedBackgroundView:[[UIView alloc] initWithFrame:oneCell.frame]];
    //    //kHexRGB(0x0e822f)
    //    oneCell.selectedBackgroundView.backgroundColor = kHexRGBAlpha(0x0e822f, 0.6);
    //
    return oneCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击第%ld行",  (long)indexPath.row);
    //去除点击的选中色
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
    
    switch (indexPath.row )
    {
        case 0:
            [self goToTarget];
            break;
        case 1:
            [self goToCustom];
            break;
            
        case 3:
            [self goToTimeAndClock];
            break;
            
        case 6:
            [self goToUpdateSystem];
            break;
        case 7:
            [self goToRecoverDefaultSet];
            break;
        default:
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NSString isNilOrEmpty:[_cellTitleArray objectAtIndex:indexPath.row]])
    {
        return 13.0;
    }
    return vOneCellHeight;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return @"";
    }
    return nil;
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backGroundColor = kBackgroundColor;
    if ([NSString isNilOrEmpty:[_cellTitleArray objectAtIndex:indexPath.row]])
    {
        backGroundColor = kRGB(243.0, 243.0, 243.0);
    }
    
    [cell setBackgroundColor:backGroundColor];
    
    //解决分割线左侧短-2
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



@end
