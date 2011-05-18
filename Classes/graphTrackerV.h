//
//  graphTrackerV.h
//  rTracker
//
//  Created by Robert Miller on 28/09/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trackerObj.h"
#import "valueObj.h"

#define NOXMARK -1.0f

@interface graphTrackerV : UIScrollView {
	trackerObj *tracker;
    BOOL doDrawGraph;
    CGFloat xMark;
    id parentGTVC;
}

@property(nonatomic,retain) trackerObj *tracker;
@property(nonatomic) BOOL doDrawGraph;
@property(nonatomic) CGFloat xMark;
@property(nonatomic,retain) id parentGTVC;

//- (void)setTransform:(CGAffineTransform)newValue;

@end
