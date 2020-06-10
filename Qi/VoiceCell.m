//
//  VoiceCell.m
//  琦琦加油
//
//  Created by Jianzhimao on 2020/6/1.
//  Copyright © 2020 Jianzhimao. All rights reserved.
//

#import "VoiceCell.h"

static NSString * const kCellID = @"VoiceCell";

@implementation VoiceCell


#pragma mark *******init*********

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUIs];
    }
    return self;
}

+ (instancetype)cellAllocWithTableView:(UITableView *)tableView {
    VoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[VoiceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellID];
    }
    
    return cell;
}

- (void)initUIs {
    
}


@end
