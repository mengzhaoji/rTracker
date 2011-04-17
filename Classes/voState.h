//
//  voState.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "valueObj.h"
#import "trackerObj.h"
#import "configTVObjVC.h"
#import "rTracker-constants.h"

#define MyTracker ((trackerObj*) self.vo.parentTracker)
#define f(x) ((CGFloat) (x))

@interface voState : NSObject <voProtocol> {

	valueObj *vo;
    CGRect voFrame;
    
}

@property (nonatomic,assign) valueObj *vo;
@property (nonatomic) CGRect voFrame;

- (id) init;
- (id) initWithVO:(valueObj*)valo;
- (void) loadConfig;
- (void) setOptDictDflts;
- (BOOL) cleanOptDictDflts:(NSString*)key;

- (UITableViewCell*) voTVEnabledCell:(UITableView *)tableView;
+ (NSArray*) voGraphSetNum;

@end