//
//  HistoryItem.h
//  puush
//
//  Created by Dean Herbert on 10/05/29.
//  Copyright 2010 haxors. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HistoryItem : NSView {
	int uploadId;
	NSString *date;
	NSString *url;
	NSString *filename;
	NSTextField *labelFilename;
	NSTextField *labelDate;
	NSButton *buttonCopy;
	NSButton *buttonDelete;
	BOOL isHovering;
}

@property (assign) int uploadId;
@property (assign) BOOL isHovering;

@property (retain) NSString *date;
@property (retain) NSString *url;
@property (retain) NSString *filename;
@property (retain) NSTextField *labelFilename;
@property (retain) NSTextField *labelDate;

@property (retain) NSButton *buttonCopy;
@property (retain) NSButton *buttonDelete;

- (id)initWithId:(int)uploadId date:(NSString*)date url:(NSString*)url filename:(NSString*)filename height:(int)height;
- (void)resetState;

@end
