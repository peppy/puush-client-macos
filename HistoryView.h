//
//  HistoryView.h
//  puush
//
//  Created by Dean Herbert on 10/05/29.
//  Copyright 2010 haxors. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HistoryView : NSView {
	NSMutableArray *historyItems;
	NSTextField *infoField;
}

@property (retain) NSMutableArray *historyItems;
@property (retain) IBOutlet NSTextField *infoField;

+ (void)updateHistory;
+ (id)Instance;

@end
