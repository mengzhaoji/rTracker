//
//  voBoolean.h
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "voState.h"

@interface voBoolean : voState {
    UIButton *imageButton;
}

@property (nonatomic,retain) UIButton *imageButton;

@end
