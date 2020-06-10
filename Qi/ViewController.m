//
//  ViewController.m
//  琦琦加油
//
//  Created by Jianzhimao on 2020/6/1.
//  Copyright © 2020 Jianzhimao. All rights reserved.
//

#import "ViewController.h"
#import "VoiceCell.h"
#import "EMCDDeviceManager.h"
#import <Masonry.h>
#import <POP.h>
#import <AVKit/AVKit.h>

@interface ViewController () <UITableViewDataSource , UITableViewDelegate>
@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIView * headerView;
@property (strong, nonatomic) NSMutableArray * voices;
@property (strong, nonatomic) NSMutableArray * suffix_PathName; // 所有文件后缀
@property (strong, nonatomic) NSMutableArray * currentVoices;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemGray6Color];
    } else {
        self.view.backgroundColor = [UIColor systemGrayColor];
    }
    [self ui_headerView];
    [self handleTheFuckingNames];
    [self.tableView reloadData];
}

- (void)click_all:(UIButton *)sender {
    self.currentVoices = self.voices.mutableCopy;
    [self.tableView reloadData];
}

/// 随机前一半，取5个 , 1 - 26
- (void)click_left:(UIButton *)sender {
    NSMutableSet *randomSet = [[NSMutableSet alloc] init];
    while ([randomSet count] < 5) {
        int r = arc4random() % 26; // 可以为0，即数组首元素，对应1.m4a； 可以为25，对应26.m4a; 理应不超过26
        if (r == 26) {
            NSLog(@" 出错了 GG");
        }
        [randomSet addObject:[self.voices objectAtIndex:r]];
    }
    
    NSArray *randomArray = [randomSet allObjects];
    [self.currentVoices removeAllObjects];
    [self.currentVoices addObjectsFromArray:randomArray];
    [self.tableView reloadData];
}

/// 随机后一半，取5个, 27 - 52
- (void)click_right:(UIButton *)sender {
    // 从大数组里面取出下标27之后的数
    __block NSMutableArray *ret = [NSMutableArray array];
    [self.voices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 25) {
            [ret addObject:obj];
        }
    }];
    
    NSMutableSet *randomSet = [[NSMutableSet alloc] init];
    while ([randomSet count] < 5) {
        int r = arc4random() % ret.count;
        [randomSet addObject:[ret objectAtIndex:r]];
    }
    
    NSArray *randomArray = [randomSet allObjects];
    [self.currentVoices removeAllObjects];
    [self.currentVoices addObjectsFromArray:randomArray];
    [self.tableView reloadData];
}

- (void)ui_headerView {
    UIColor *b_Color = [UIColor colorWithRed:0.58 green:0.69 blue:0.80 alpha:1.00];
    
    UIButton *all_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [all_button addTarget:self action:@selector(click_all:) forControlEvents:UIControlEventTouchUpInside];
    all_button.showsTouchWhenHighlighted = YES;
    all_button.layer.cornerRadius = 8;
    [all_button setTitle:@"给爸爸看全部音频" forState:UIControlStateNormal];
    [all_button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [all_button setBackgroundColor:b_Color];
    [self.headerView addSubview:all_button];
    [all_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.top.equalTo(self.headerView).offset(10);
        make.height.offset(40);
        make.width.offset(150);
    }];
    
    UIButton *left_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [left_button addTarget:self action:@selector(click_left:) forControlEvents:UIControlEventTouchUpInside];
    left_button.showsTouchWhenHighlighted = YES;
    left_button.layer.cornerRadius = 8;
    [left_button setTitle:@"1~26随机搞他🐴5个" forState:UIControlStateNormal];
    [left_button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [left_button setBackgroundColor:b_Color];
    [self.headerView addSubview:left_button];
    [left_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(10);
        make.bottom.equalTo(self.headerView).offset(-20);
        make.height.offset(40);
        make.width.offset(160);
    }];
    
    UIButton *right_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [right_button addTarget:self action:@selector(click_right:) forControlEvents:UIControlEventTouchUpInside];
    right_button.showsTouchWhenHighlighted = YES;
    right_button.layer.cornerRadius = 8;
    [right_button setTitle:@"27~52随机搞他🐴5个" forState:UIControlStateNormal];
    [right_button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [right_button setBackgroundColor:b_Color];
    [self.headerView addSubview:right_button];
    [right_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView).offset(-10);
        make.bottom.equalTo(self.headerView).offset(-20);
        make.height.offset(40);
        make.width.offset(160);
    }];
}

/// 处理音频文件名
- (void)handleTheFuckingNames {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"voices" ofType:@"bundle"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    // [enumerator nextObject]:
    // 一级：path -> /Users/jianzhimao/Library/Developer/CoreSimulator/Devices/0A3EB4D7-5ECA-4D5B-B698-7575F5054C28/data/Containers/Bundle/Application/BA49C386-A4AE-4793-A3FD-C7A84162E1D3/琦琦加油App.app/voices.bundle/
    // 二级：[enumerator nextObject] -> 9.m4a
    
    // 把前缀拿出来排序
    NSMutableArray *prefix_arr = [NSMutableArray new];
    while((path = [enumerator nextObject]) != nil) {
        if ([path containsString:@"m4a"]) {
            NSArray * t_array = [path componentsSeparatedByString:@"."];
            if (t_array.count) {
                [prefix_arr addObject:t_array[0]];
            }
        }
    }
    
    // 冒泡排一波
    int count  = 0;
    int forcount  = 0;
    BOOL flag = YES;
    for (int i = 0; i < prefix_arr.count && flag; i++) {
        forcount++;
        flag = NO;
        for (int j = (int)prefix_arr.count-2; j >= i; j--) {
            count++;
            if ([prefix_arr[j] intValue] > [prefix_arr[j+1] intValue]) {
                [prefix_arr exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                flag = YES;
            }
        }
    }
    
    // 再拼接文件名
    NSString *_path = [[NSBundle mainBundle]pathForResource:@"voices" ofType:@"bundle"];
    __block NSString *test = @"";
    [prefix_arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *finalPathName = [NSString stringWithFormat:@"%@/%@.m4a", _path , obj]; test = finalPathName;
        NSString *suffix_PathName = [NSString stringWithFormat:@"%@.m4a", obj];
        [self.voices addObject:finalPathName];
        [self.suffix_PathName addObject:suffix_PathName];
    }];
    self.currentVoices = self.voices.mutableCopy;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentVoices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceCell *cell = [VoiceCell cellAllocWithTableView:tableView];
    NSString *voice = self.currentVoices[indexPath.row];
    NSArray * t_array = [voice componentsSeparatedByString:@"/"]; // 拿后缀名
    NSString *suffixName = [NSString stringWithFormat:@"%@",t_array.lastObject];
    cell.textLabel.text = suffixName;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithRed:0.58 green:0.69 blue:0.80 alpha:1.00];
    
    NSURL *fileURL = [NSURL fileURLWithPath:voice];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
//    NSFileManager *manage = [NSFileManager defaultManager];
//    NSDictionary *fileAtt = [manage attributesOfItemAtPath:suffixName error:nil];
    float current = CMTimeGetSeconds(asset.duration);
    NSLog(@" %lf  " , current);

    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"音频长度 %.2f" , current];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 13.0, *)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSoft];
        [generator prepare];
        [generator impactOccurred];
    }
    
    NSString *voice = self.currentVoices[indexPath.row];
    [[EMCDDeviceManager sharedInstance]asyncPlayingWithPath:voice completion:^(NSError *error) {
        NSLog(@"oops~~ %@ " , error);
    }];
}



- (UITableView *)tableView {
    if (!_tableView) {
        if (@available(iOS 13.0, *)) {
            _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleInsetGrouped];
        } else {
            _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        }
        _tableView.rowHeight = 60;
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor systemGray6Color];
        } else {
            _tableView.backgroundColor = [UIColor systemGrayColor];
        }
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.headerView.mas_bottom).offset(8);
            make.bottom.equalTo(self.view);
        }];
    }
    return _tableView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 200)];
        if (@available(iOS 13.0, *)) {
            _headerView.backgroundColor = [UIColor systemGray6Color];
        } else {
            _headerView.backgroundColor = [UIColor systemGrayColor];
        }
        _headerView.layer.cornerRadius = 10.f;
        _headerView.layer.shadowColor = [UIColor grayColor].CGColor;
        _headerView.layer.shadowOpacity = 1;
        _headerView.layer.shadowOffset = CGSizeMake(4, 4);
        [self.view addSubview:_headerView];
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.height.offset(140);
        }];
    }
    return _headerView;
}

- (NSMutableArray *)voices {
    if (!_voices) {
        _voices = [NSMutableArray array];
    }
    return _voices;
}

- (NSMutableArray *)currentVoices {
    if (!_currentVoices) {
        _currentVoices = [NSMutableArray array];
    }
    return _currentVoices;
}

- (NSMutableArray *)suffix_PathName {
    if (!_suffix_PathName) {
        _suffix_PathName = [NSMutableArray array];
    }
    return _suffix_PathName;
}


@end
