//
//  TimeAndClockViewController.m
//  LoveSports
//
//  Created by jamie on 15/1/27.
//  Copyright (c) 2015年 zorro. All rights reserved.
//
#define vMetricSystemTag   10099
#define vHandTag   10100


#define vTableViewLeaveTop   0   //tableView距离顶部的距离

#define vTableViewMoveLeftX 0  //tableview向左移20
#define vOneCellHeight    (kIPhone4s ? 44 : 45.0) //cell单行高度
#define vOneCellWidth     (kScreenWidth + vTableViewMoveLeftX)

#define vSectionHeight    30

#import "TimeAndClockViewController.h"
#import "BSModalDatePickerView.h"


@interface TimeAndClockViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSMutableArray *_titleArray;
    
    UITableView *_listTableView;
    BOOL _showDistance;
    BOOL _isEditing;  //是否在编辑中
}

@end

@implementation TimeAndClockViewController
@synthesize _thisModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"时间与闹钟";
    self.view.backgroundColor = kBackgroundColor;   //设置通用背景颜色
    self.navigationItem.leftBarButtonItem = [[ObjectCTools shared] createLeftBarButtonItem:@"返回" target:self selector:@selector(goBackPrePage) ImageName:@""];
    
    NSArray *list1Array = [NSArray arrayWithObjects:@"24小时制", @"自动设置", nil];
    NSArray *list2Array = [NSArray arrayWithObjects:@"振动闹钟", nil];
    _titleArray = [NSMutableArray arrayWithObjects:list1Array, list2Array, nil];
    
    [self addTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated: NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self reloadUserInfoTableView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //将要消失时更新存储
    [[BraceletInfoModel getUsingLKDBHelper] insertToDB:_thisModel];
}

- (void) reloadUserInfoTableView
{
    //    [_titleArray removeObjectAtIndex:1];
    //    NSMutableArray *tempList2Array = [NSMutableArray arrayWithObjects:@"振动闹钟", nil];
    //
    //    for (HandSetAlarmClock __weak *clockTime in _thisModel._allHandSetAlarmClock)
    //    {
    //        [tempList2Array addObject:clockTime];
    //    }
    //    [_titleArray addObject:tempList2Array];
    
    [_listTableView reloadData];
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

- (void) changeSwith:(UISwitch *) theSwitch
{
    if (theSwitch.tag < 1000)
    {
        if (theSwitch.tag == 0)
        {
            NSLog(@"更改是否24时制的状态：%d", theSwitch.on);
            _thisModel._is24HoursTime = theSwitch.on;
        }
        if (theSwitch.tag == 1)
        {
            NSLog(@"更改是否自动设置的状态：%d", theSwitch.on);
            _thisModel._isAutomaticAlarmClock = theSwitch.on;
            
            if (_thisModel._isAutomaticAlarmClock)
            {
                _thisModel._isHandAlarmClock = NO;
            }
        }
        [self reloadUserInfoTableView];
        
        return;
    }
    else
    {
        if (theSwitch.tag % 1000 == 0)
        {
            NSLog(@"更改是否设置手动闹钟的状态：%d", theSwitch.on);
            _thisModel._isHandAlarmClock = theSwitch.on;
            
            if (_thisModel._isHandAlarmClock)
            {
                _thisModel._isAutomaticAlarmClock = NO;
            }
             [self reloadUserInfoTableView];
        }
        else
        {
            HandSetAlarmClock __weak *tempModel = [_thisModel._allHandSetAlarmClock objectAtIndex:theSwitch.tag % 1000 - 2];
            tempModel._isOpen = theSwitch.on;
            
        }
       
    }
    
}

- (void) changeTimeWithIndex: (NSInteger ) index
{
    NSDate *theDate = [NSDate date];
    HandSetAlarmClock __weak *tempHandClock = [_thisModel._allHandSetAlarmClock objectAtIndex:index];
    
    NSString *setTimeString = tempHandClock._setTime;
    if (![NSString isNilOrEmpty:setTimeString ])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];     //大写HH，强制24小时
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [dateFormatter setTimeZone:timeZone];
        theDate = [dateFormatter dateFromString:setTimeString];
    }
    BSModalDatePickerView *datePicker = [[BSModalDatePickerView alloc] initWithDate:theDate];
    datePicker.showTodayButton = NO;
    datePicker.mode = UIDatePickerModeTime;
    [datePicker presentInView:self.view
                    withBlock:^(BOOL madeChoice) {
                        if (madeChoice) {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"HH:mm"];     //大写HH，强制24小时
                            NSTimeZone *timeZone = [NSTimeZone localTimeZone];
                            [dateFormatter setTimeZone:timeZone];
                            NSString *choiceString = [dateFormatter stringFromDate:datePicker.selectedDate];
                            if (![choiceString isEqualToString:setTimeString])
                            {
                                NSLog(@"修改闹钟时间吧， 为 %@", choiceString);
                                tempHandClock._setTime = choiceString;
                                [self reloadUserInfoTableView];
                            }
                        }
                    }];
    
}



#pragma mark ---------------- TableView delegate -----------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (_thisModel._isAutomaticAlarmClock)
            {
                return 3;
            }
            return 2;
        }
            break;
        case 1:
        {
            if (_thisModel._isHandAlarmClock)
            {
                return ([[_titleArray objectAtIndex:1] count] + _thisModel._allHandSetAlarmClock.count + 1 );
            }
            return 1;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (void) setEdit: (UIButton *) button
{
    _isEditing = !_isEditing;
    button.selected = _isEditing;
    
    if (_isEditing)
    {
        [_listTableView setEditing:YES];
    }
    else
    {
        [_listTableView setEditing:NO];
    }
    [self reloadUserInfoTableView];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //不使用复用机制
    UITableViewCell *oneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    
    //label
    CGRect titleFrame = CGRectMake(0, 0, 100, vOneCellHeight);
    UILabel *title = [[ObjectCTools shared] getACustomLableFrame:titleFrame
                                                 backgroundColor:[UIColor clearColor]
                                                            text:@"123"
                                                       textColor:kLabelTitleDefaultColor
                                                            font:[UIFont systemFontOfSize:14]
                                                   textAlignment:NSTextAlignmentLeft
                                                   lineBreakMode:0
                                                   numberOfLines:0];
    title.center = CGPointMake(vTableViewMoveLeftX + 16.0 + title.width / 2.0, vOneCellHeight / 2.0);
    
    //右侧箭头
    UIImageView *rightImageView = [[ObjectCTools shared] getACustomImageViewWithCenter:CGPointMake(vOneCellWidth - vOneCellHeight / 2.0 + 5, vOneCellHeight / 2.0) withImageName:@"right.png" withImageZoomSize:1.0];
    //    [oneCell.contentView addSubview:rightImageView];
    
    
    //右侧titlelable
    UILabel *rightTitle = [[ObjectCTools shared] getACustomLableFrame:titleFrame
                                                      backgroundColor:[UIColor clearColor]
                                                                 text:@""
                                                            textColor:kLabelTitleDefaultColor
                                                                 font:[UIFont systemFontOfSize:14]
                                                        textAlignment:NSTextAlignmentCenter
                                                        lineBreakMode:NSLineBreakByCharWrapping
                                                        numberOfLines:0];
    
    [rightTitle setWidth:rightImageView.x - title.right - 2 - 18];
    //    NSLog(@"lent = %f", rightTitle.width);
    
    UISwitch *slideSwitchH = [[UISwitch alloc]init];
    [slideSwitchH setFrame:CGRectMake(0, 0, 164.0, 26.0)];
    slideSwitchH.center = CGPointMake(rightImageView.centerX  - slideSwitchH.width / 2.0, vOneCellHeight / 2.0);
    [slideSwitchH setOnTintColor:kButtonBackgroundColor];
    slideSwitchH.tag = indexPath.section * 1000 + indexPath.row;
    [slideSwitchH addTarget:self action:@selector(changeSwith:) forControlEvents:UIControlEventValueChanged];
    [oneCell addSubview:slideSwitchH];
    
    if (indexPath.section == 0)
    {
        [oneCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        switch (indexPath.row)
        {
            case 0:
            {
                slideSwitchH.on = _thisModel._is24HoursTime;
                [title setText:[[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
                [oneCell.contentView addSubview:title];
            }
                break;
            case 1:
            {
                slideSwitchH.on = _thisModel._isAutomaticAlarmClock;
                [title setText:[[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
                [oneCell.contentView addSubview:title];
                
            }
                break;
            case 2:
            {
                NSMutableString *showAutomaticCloclString = [[NSMutableString alloc] init];
                for (int i = 0; i < _thisModel._allAutomaticSetAlarmClock.count; i++)
                {
                    HandSetAlarmClock *clockTime = [_thisModel._allAutomaticSetAlarmClock objectAtIndex:i];
                    [showAutomaticCloclString appendFormat:@"     %@      ", [clockTime getShowTimeWithIs24HoursTime:_thisModel._is24HoursTime]];
                    if (i % 2)
                    {
                        [showAutomaticCloclString appendString:@"\n"];
                    }
                }
                if (!(_thisModel._allAutomaticSetAlarmClock.count % 2))
                {
                    [showAutomaticCloclString appendString:@"               "];
                }
                [rightTitle setText:showAutomaticCloclString];
                [oneCell.contentView addSubview:rightTitle];
                
                [slideSwitchH setHidden:YES];
            }
                break;
                
            default:
                break;
        }
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            [oneCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            slideSwitchH.on = _thisModel._isHandAlarmClock;
            [title setText:[[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            [oneCell.contentView addSubview:title];
        }
        else if (indexPath.row == 1)
        {
            [oneCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UIButton  *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [customButton setFrame:CGRectMake(vOneCellHeight, 0, vOneCellHeight, vOneCellHeight)];
            [customButton setBackgroundColor:[UIColor clearColor]];
            [customButton setTitle:@"删除" forState:UIControlStateNormal];
            [customButton setTitle:@"完成" forState:UIControlStateSelected];
            [customButton setSelected:_isEditing];
            [customButton setTitleColor:kRGBAlpha(0, 122, 255, 1.0) forState:UIControlStateNormal];
            [customButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [customButton addTarget:self action:@selector(setEdit:) forControlEvents:UIControlEventTouchUpInside];
//            [rightImageView setImage:[UIImage imageNamed:@"添加按钮"]];
            [oneCell.contentView addSubview:customButton];
            
            [slideSwitchH setHidden:YES];
            
            UIButton  *customButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [customButton2 setFrame:CGRectMake(vOneCellWidth - vOneCellHeight * 2.0, 0, vOneCellHeight, vOneCellHeight)];
            [customButton2 setBackgroundColor:[UIColor clearColor]];
            [customButton2 setTitle:@"添加" forState:UIControlStateNormal];
            [customButton2 setTitleColor:kRGBAlpha(0, 122, 255, 1.0) forState:UIControlStateNormal];
            [customButton2.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [oneCell.contentView addSubview:customButton2];
        }
        else
        {
            NSLog(@"row = %ld", (long)indexPath.row);
            HandSetAlarmClock *clockTime = [_thisModel._allHandSetAlarmClock objectAtIndex:indexPath.row - 2];
            
            [rightTitle setText:[clockTime getShowTimeWithIs24HoursTime:_thisModel._is24HoursTime]];
            [rightTitle sizeToFit];
            [rightTitle setX:vOneCellHeight];
            [rightTitle setCenterY:vOneCellHeight / 2.0];
            [oneCell.contentView addSubview:rightTitle];
            slideSwitchH.on = clockTime._isOpen;
            [slideSwitchH setX:vOneCellWidth - vOneCellHeight - slideSwitchH.width];
//            [oneCell.contentView addSubview:rightImageView];
            
        }
        return oneCell;
    }
    
    [rightTitle sizeToFit];
    [rightTitle setCenter:CGPointMake(vOneCellWidth / 2.0, oneCell.height / 2.0)];
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
    
    if (indexPath.section == 1 && indexPath.row >= 2)
    {
        [self changeTimeWithIndex:indexPath.row - 2];
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2)
    {
        return  ((_thisModel._allAutomaticSetAlarmClock.count + 1) / 2) * vOneCellHeight;
    }
    return vOneCellHeight;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backGroundColor = kBackgroundColor;
    
    [cell setBackgroundColor:backGroundColor];
    
    //解决分割线左侧短-2
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

// 删除功能----------------------------------
//能否修改cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section  == 1  && indexPath.row > 1)
    {
        return YES;
    }
    return NO;
}

//首先激活编辑功能，即左滑出按钮。
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;
    if (indexPath.section  == 1  && indexPath.row > 1)
    {
        result = UITableViewCellEditingStyleDelete;
    }
    return result;
}
// 删除事件
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除cell
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //删除帐号
        [_thisModel._allHandSetAlarmClock removeObjectAtIndex:indexPath.row - 2];
        [self reloadUserInfoTableView];
    }
}

// 后面的是删除按钮文案为中文。 默认是英文的delete
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


@end