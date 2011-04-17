//
//  voNumber.m
//  rTracker
//
//  Created by Robert Miller on 01/11/2010.
//  Copyright 2010 Robert T. Miller. All rights reserved.
//

#import "voNumber.h"
#import "dbg-defs.h"

@implementation voNumber

@synthesize dtf;

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	DBGLog1(@"tf begin editing vid=%d",self.vo.vid);
    //*activeField = textField;
	((trackerObj*) self.vo.parentTracker).activeControl = (UIControl*) textField;
}

- (void)tfvoFinEdit:(UITextField*)tf {
	tf.textColor = [UIColor blackColor];
	[self.vo.value setString:tf.text];
    tf.backgroundColor = [UIColor whiteColor];
    
	//self.vo.display = nil; // so will redraw this cell only
	[[NSNotificationCenter defaultCenter] postNotificationName:rtValueUpdatedNotification object:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	DBGLog1(@"tf end editing vid=%d",self.vo.vid);
	[self tfvoFinEdit:textField];
    //*activeField = nil;
	((trackerObj*) self.vo.parentTracker).activeControl = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	// the user pressed the "Done" button, so dismiss the keyboard
	//DBGLog2(@"textField done: %@  vid=%d", textField.text,self.vo.vid);
	// [self tfvoFinEdit:textField];  // textFieldDidEndEditing will be called, just dismiss kybd here
	[textField resignFirstResponder];
	return YES;
}

- (UITextField*) dtf {
    if (nil == dtf) {
        dtf = [[UITextField alloc] initWithFrame:self.voFrame];
        
        dtf.borderStyle = UITextBorderStyleRoundedRect;  //Bezel;
        dtf.textColor = [UIColor blackColor];
        dtf.font = [UIFont systemFontOfSize:17.0];
        dtf.backgroundColor = [UIColor whiteColor];
        dtf.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
        
        dtf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;	// use the number input only
        dtf.placeholder = @"<enter number>";
        dtf.textAlignment = UITextAlignmentRight;
        //[dtf addTarget:self action:@selector(numTextFieldClose:) forControlEvents:UIControlEventTouchUpOutside];
        
        dtf.returnKeyType = UIReturnKeyDone;
        
        dtf.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
        
        dtf.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
        dtf.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
        
        // Add an accessibility label that describes what the text field is for.
        [dtf setAccessibilityLabel:NSLocalizedString(@"enter a number", @"")];
        
    }
    //DBGLog1(@"num dtf rc= %d",[dtf retainCount]);
    return dtf;
}

- (UIView*)voDisplay:(CGRect)bounds {
	self.voFrame = bounds;

	//if (![self.vo.value isEqualToString:dtf.text]) {
        
        if ([self.vo.value isEqualToString:@""]) {
            if ([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"] /* && ![to hasData] */) {  // only if new entry
                trackerObj *to = (trackerObj*)self.vo.parentTracker;
                to.sql = [NSString stringWithFormat:@"select count(*) from voData where id=%d and date<%d",
                          self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                int v = [to toQry2Int];
                if (v>0) {
                    to.sql = [NSString stringWithFormat:@"select val from voData where id=%d and date<%d order by date desc limit 1;",
                              self.vo.vid,(int)[to.trackerDate timeIntervalSince1970]];
                    NSString *r = [to toQry2Str];
                    self.dtf.textColor = [UIColor redColor]; //[UIColor lightGrayColor];
                    self.dtf.backgroundColor = [UIColor grayColor];
                    self.dtf.text = r;
                }
                to.sql = nil;
            } else {
                self.dtf.text = @"";
            }
        } else {
            self.dtf.backgroundColor = [UIColor whiteColor];
            self.dtf.textColor = [UIColor blackColor];
            self.dtf.text = self.vo.value;
        }
        
        //DBGLog2(@"dtf: vo val= %@  dtf.text= %@", self.vo.value, self.dtf.text);
	//}
    
    DBGLog1(@"number voDisplay: %@", self.dtf.text);
    return self.dtf;
}


- (NSArray*) voGraphSet {
	return [voState voGraphSetNum];
}

#pragma mark -
#pragma mark options page 

- (void) setOptDictDflts {
    
    if (nil == [self.vo.optDict objectForKey:@"nswl"]) 
        [self.vo.optDict setObject:(NSWLDFLT ? @"1" : @"0") forKey:@"nswll"];
    
    if (nil == [self.vo.optDict objectForKey:@"autoscale"]) 
        [self.vo.optDict setObject:(AUTOSCALEDFLT ? @"1" : @"0") forKey:@"autoscale"];

    return [super setOptDictDflts];
}

- (BOOL) cleanOptDictDflts:(NSString*)key {
    
    NSString *val = [self.vo.optDict objectForKey:key];
    if (nil == val) 
        return YES;
    
    if (([key isEqualToString:@"nswl"] && [val isEqualToString:(NSWLDFLT ? @"1" : @"0")])
        ||
        ([key isEqualToString:@"autoscale"] && [val isEqualToString:(AUTOSCALEDFLT ? @"1" : @"0")])
        ) {
        [self.vo.optDict removeObjectForKey:key];
        return YES;
    }
    
    return [super cleanOptDictDflts:key];
}

- (void) voDrawOptions:(configTVObjVC*)ctvovc {

	CGRect frame = {MARGIN,ctvovc.lasty,0.0,0.0};
	
	CGRect labframe = [ctvovc configLabel:@"start with last saved value:" frame:frame key:@"swlLab" addsv:YES];
	frame = (CGRect) {labframe.size.width+MARGIN+SPACE, frame.origin.y,labframe.size.height,labframe.size.height};
	[ctvovc configCheckButton:frame 
						key:@"swlBtn" 
					  state:([[self.vo.optDict objectForKey:@"nswl"] isEqualToString:@"1"]) ]; // default:0
	frame.origin.x = MARGIN;
	frame.origin.y += MARGIN + frame.size.height;
	
	frame = [ctvovc yAutoscale:frame];
	
	frame.origin.y += frame.size.height + MARGIN;
	frame.origin.x = MARGIN;
	
	//-- title label
	
	labframe = [ctvovc configLabel:@"Other options:" frame:frame key:@"noLab" addsv:YES];
	
	ctvovc.lasty = frame.origin.y + labframe.size.height + MARGIN;

	[super voDrawOptions:ctvovc];
}

@end