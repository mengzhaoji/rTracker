//
//  RootViewController.m
//  rTracker
//
//  Created by Robert Miller on 16/03/2010.
//  Copyright Robert T. Miller 2010. All rights reserved.
//

#import "RootViewController.h"
#import "rTrackerAppDelegate.h"
#import "addTrackerController.h"
#import "configTlistController.h"
#import "useTrackerController.h"
#import "rTracker-resource.h"
#import "privacyV.h"

#import "CSVParser.h"

#import "dbg-defs.h"

@implementation RootViewController

@synthesize tlist;
@synthesize privateBtn, helpBtn, privacyObj;

#pragma mark -
#pragma mark core object methods and support

- (void)dealloc {
	
	DBGLog(@"rvc dealloc");
	self.tlist = nil;
	[tlist release];
	
    [super dealloc];
}

/*
- (void)applicationWillTerminate:(NSNotification *)notification {
	DBGLog(@"rvc: app will terminate");
	// close trackerList
	
}
*/

#pragma mark -
#pragma mark load CSV files waiting for input

//
// original code:
//-------------------
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//-------------------

- (void) loadInputFiles {
    DBGLog(@"loadInputFiles");
    NSString *docsDir = [rTracker_resource ioFilePath:nil access:YES];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];

    [self.tlist loadTopLayoutTable];
	//[self.tableView reloadData];
    
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString: @"csv"]) {
            NSString *fname = [file lastPathComponent];
            NSRange inmatch = [fname rangeOfString:@"_in.csv" options:NSBackwardsSearch|NSAnchoredSearch];
            DBGLog(@"consider input: %@",fname);
            
            if (inmatch.location == NSNotFound) {
                
            } else if (inmatch.length == 7) {  // matched all 7 chars of _in.csv at end of file name
                NSString *tname = [fname substringToIndex:inmatch.location];
                DBGLog(@"load input: %@ as %@",fname,tname);
                int ndx=0;
                for (NSString *tracker in self.tlist.topLayoutNames) {
                    if ([tracker isEqualToString:tname]) {
                        //DBGLog(@"match to: %@",tracker);
                        NSString *target = [docsDir stringByAppendingPathComponent:file];
                        //NSError *error = nil;
                        NSString *csvString = [NSString stringWithContentsOfFile:target encoding:NSUTF8StringEncoding error:NULL];
                        
                        /*
                        if (!csvString)
                        {
                         DBGErr(@"Couldn't read file at path %s\n. Error: %s",
                                   [file UTF8String],
                                   [[error localizedDescription] ? [error localizedDescription] : [error description] UTF8String]);
                            NSAssert(0,@"file issue.");
                        }
                        */
                        if (csvString)
                        {
                            trackerObj *to = [[trackerObj alloc] init:[self.tlist getTIDfromName:tname]];

                            CSVParser *parser = [[CSVParser alloc] initWithString:csvString separator:@"," hasHeader:YES fieldNames:nil];
                            [parser parseRowsForReceiver:to selector:@selector(receiveRecord:)]; // receiveRecord in trackerObj.m
                            [parser release];
                            [to release];
                        }
                        ndx++;
                    }
                }
            }
            
        }
    }
    [localFileManager release];    
}

#pragma mark -
#pragma mark view support

- (void)viewDidLoad {
	DBGLog(@"rvc: viewDidLoad privacy= %d",[privacyV getPrivacyValue]);

    self.title = @"rTracker";

	UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]
								initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								target:self
								action:@selector(btnAddTracker)];
	self.navigationItem.rightBarButtonItem = addBtn;
    //self.navigationController.navigationBar.translucent = YES;  // this makes buttons appear behind navbar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	[addBtn release];
	
	[self setToolbarItems:[NSArray arrayWithObjects: 
						   //self.flexibleSpaceButtonItem,
						   //self.payBtn, 
                           self.privateBtn, 
                           self.helpBtn,
                           //self.multiGraphBtn, 
						   //self.flexibleSpaceButtonItem, 
						   nil] 
				 animated:NO];

    //self.navigationController.toolbar.translucent = YES;
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd1-320-460.png"]];
    self.tableView.backgroundView = bg;
    [bg release];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	//[payBtn release];
	[privateBtn release];
    [helpBtn release];
	//[multiGraphBtn release];

	self.tlist = [[trackerList alloc] init];

    [self loadInputFiles];
    
	/*
	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:UIApplicationWillTerminateNotification
											   object:app];
	
	 */
	
	[super viewDidLoad];
	
}

- (void) refreshView {
	[self.tlist loadTopLayoutTable];
	[self.tableView reloadData];
    
	if ([self.tlist.topLayoutNames count] == 0) {
		if (self.navigationItem.leftBarButtonItem != nil) {
			self.navigationItem.leftBarButtonItem = nil;
		}
	} else {
		if (self.navigationItem.leftBarButtonItem == nil) {
			
			UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
										target:self
										action:@selector(btnEdit)];
			self.navigationItem.leftBarButtonItem = editBtn;
			[editBtn release];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {

	DBGLog(@"rvc: viewWillAppear privacy= %d", [privacyV getPrivacyValue]);	
	[self refreshView];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	DBGWarn(@"rvc didReceiveMemoryWarning");
	// Release any cached data, images, etc that aren't in use.

    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
	
	DBGLog(@"rvc viewDidUnload");

	self.title = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[self setToolbarItems:nil
				 animated:NO];
	
	self.tlist = nil;
	
	//DBGLog(@"pb rc= %d  mgb rc= %d", [self.privateBtn retainCount], [self.multiGraphBtn retainCount]);
	
}


#pragma mark -
#pragma mark button accessor getters

/*
 - (UIBarButtonItem *) payBtn {
	if (payBtn == nil) {
		payBtn = [[UIBarButtonItem alloc]
					  initWithTitle:@"$"
					  style:UIBarButtonItemStyleBordered
					  target:self
					  action:@selector(btnPay)];
	}
	return payBtn;
}
*/

- (UIBarButtonItem *) privateBtn {
	if (privateBtn == nil) {
        privateBtn = [[UIBarButtonItem alloc]
					   //initWithTitle:@"private"
                       initWithImage:[UIImage imageNamed:@"lock-button.png"]
					   style:UIBarButtonItemStylePlain
					   target:self
					   action:@selector(btnPrivate)];
	} else {
        if (PVNOSHOW != self.privacyObj.showing) {
            //self.privateBtn.title = @"dismiss";
        } else {
            //self.privateBtn.title = @"private";
            //self.privateBtn.image = [UIImage imageNamed:@"lock-button.png"];
        }
    }
	return privateBtn;
}

- (UIBarButtonItem *) helpBtn {
	if (helpBtn == nil) {
		helpBtn = [[UIBarButtonItem alloc]
                      initWithTitle:@"help"
                      style:UIBarButtonItemStyleBordered
                      target:self
                      action:@selector(btnHelp)];
	} 
	return helpBtn;
}

/*
 - (UIBarButtonItem *) multiGraphBtn {
	if (multiGraphBtn == nil) {
		multiGraphBtn = [[UIBarButtonItem alloc]
					  initWithTitle:@"Multi-Graph"
					  style:UIBarButtonItemStyleBordered
					  target:self
					  action:@selector(btnMultiGraph)];
	}
	return multiGraphBtn;
}
*/

- (privacyV*) privacyObj {
	if (privacyObj == nil) {
		privacyObj = [[privacyV alloc] initWithParentView:self.view];
	}
	privacyObj.tob = (id) self.tlist;  // not set at init
	return privacyObj;
}



#pragma mark -
#pragma mark button action methods

- (void) btnAddTracker {
	addTrackerController *atc = [[addTrackerController alloc] initWithNibName:@"addTrackerController" bundle:nil ];
	atc.tlist = self.tlist;
	[self.navigationController pushViewController:atc animated:YES];
    //[rTracker_resource myNavPushTransition:self.navigationController vc:atc animOpt:UIViewAnimationOptionTransitionCurlUp];
    
	[atc release];
}

- (IBAction)btnEdit {
	configTlistController *ctlc = [[configTlistController alloc] initWithNibName:@"configTlistController" bundle:nil ];
	ctlc.tlist = self.tlist;
	[self.navigationController pushViewController:ctlc animated:YES];
    
    //[rTracker_resource myNavPushTransition:self.navigationController vc:ctlc animOpt:UIViewAnimationOptionTransitionFlipFromLeft];
    
	[ctlc release];
}
	
- (void)btnMultiGraph {
	DBGLog(@"btnMultiGraph was pressed!");
}

- (void)btnPrivate {
	[self.privacyObj togglePrivacySetter ];
    /*
	if (PVNOSHOW != self.privacyObj.showing) {
		self.privateBtn.title = @"dismiss";
	} else {
		self.privateBtn.title = @"private";
		[self refreshView];
	}
     */
    [self refreshView];
}

- (void) btnHelp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.realidata.com/rTracker/iPhone/userGuide"]];
}

- (void)btnPay {
	DBGLog(@"btnPay was pressed!");
	
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tlist.topLayoutNames count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //DBGLog(@"rvc table cell at index %d label %@",[indexPath row],[tlist.topLayoutNames objectAtIndex:[indexPath row]]);
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        //UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkgnd-cell1-320-56.png"]];
        //[cell setBackgroundView:bg];
        //[bg release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	// Configure the cell.
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [NSString stringWithFormat:@"      %@",[self.tlist.topLayoutNames objectAtIndex:row]];  // gross but simplest offset option
    //cell.textLabel.backgroundColor = [UIColor clearColor];

    return cell;
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger row = [indexPath row];
	//DBGLog(@"selected row %d : %@", row, [self.tlist.topLayoutNames objectAtIndex:row]);
	
	trackerObj *to = [[trackerObj alloc] init:[self.tlist getTIDfromIndex:row]];
	[to describe];

	useTrackerController *utc = [[useTrackerController alloc] initWithNibName:@"useTrackerController" bundle:nil ];
	utc.tracker = to;
	[self.navigationController pushViewController:utc animated:YES];
    
    //[self myNavTransition:utc animOpt:UIViewAnimationOptionTransitionFlipFromLeft];
    
    
	[utc release];
	
	[to release];
	
}

@end

