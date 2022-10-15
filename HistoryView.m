//
//  HistoryView.m
//  puush
//
//  Created by Dean Herbert on 10/05/29.
//  Copyright 2010 haxors. All rights reserved.
//

#import "HistoryView.h"
#import "HistoryItem.h"
#import "ASIFormDataRequest.h"
#import "puushCommon.h"

@implementation HistoryView

@synthesize historyItems;
@synthesize infoField;

#define EMPTY_HEIGHT 20
#define WIDTH 230

#define ITEM_HEIGHT 26

static HistoryView *instance;

+ (id)Instance
{
	return instance;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
	
	instance = self;

	self.historyItems = [[[NSMutableArray alloc] init] autorelease];
	
    return self;
}

- (int)itemCount
{
	return [historyItems count];
}

- (BOOL) acceptsFirstResponder
{
	return true;
}

- (void)viewDidMoveToWindow {
    [[self window] becomeKeyWindow];
	
	//reset the state of history items
	for (HistoryItem *h in historyItems)
		[h resetState];
}

BOOL isUpdatingHistory;

- (void)gotHistory:(ASIHTTPRequest *)request
{
	isUpdatingHistory = false;
	
	if ([request error] != nil)
		return;
		
	int response = -2;
	
	NSArray *lines;
	
	if ([[request responseString] length] != 0)
	{
		lines = [[request responseString] componentsSeparatedByString:@"\n"];
		response = [[lines objectAtIndex:0] intValue];
	}
	
	//todo: handle failures
	switch (response)
	{
		case -1:
			[puush handleInvalidAuthentication];
			return;
		case -2:
			//unknown/other
			return;
	}
		
	for (HistoryItem *h in historyItems)
		[h removeFromSuperview];
		
	[historyItems removeAllObjects];
	
	int actualKodexSucksCocksLineCount = 0;
	for (NSString *lineofCOCKS in lines)
		if ([lineofCOCKS length] > 3)
			actualKodexSucksCocksLineCount++;
	
	int displayCount = actualKodexSucksCocksLineCount < 5 ? actualKodexSucksCocksLineCount : 5;

	int y = (displayCount - 1) * ITEM_HEIGHT;
	
	BOOL firstLine = true; //we skip the first line because that is the response code.
	
	for (NSString *line in lines)
	{
		if ([line length] == 0 || displayCount == 0) break;
		
		if (firstLine)
		{
			firstLine = false;
			continue;
		}
		
		NSArray *parts = [line componentsSeparatedByString:@","];
		int uploadId = [((NSString*)[parts objectAtIndex:0]) intValue];
		NSString *date = [parts objectAtIndex:1];
		NSString *url = [parts objectAtIndex:2];
		NSString *filename = [parts objectAtIndex:3];
		
		HistoryItem *h = [[[HistoryItem alloc] initWithId:uploadId date:date url:url filename:filename height:y] autorelease];
		[historyItems addObject:h];
		
		[self addSubview:h];
		
		y -= ITEM_HEIGHT;
		displayCount--;
	}
	
	[infoField setHidden: [self itemCount] > 0];

	if ([self itemCount] == 0)
		[infoField setStringValue:@"No upload history!"];
	
	[self setNeedsDisplay:true];
}

- (void)_updateHistory
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//pull new history from the internets
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[puushCommon getApiUrlFor:@"hist"]] autorelease];
	[request setPostValue:[[puush config] stringForKey:@"key"] forKey:@"k"];
	[request setRetryCount:2];
	[request setTimeOutSeconds:10];
	
	[request setDelegate:[HistoryView Instance]];
	[request setDidFinishSelector:@selector(gotHistory:)];
	[request setDidFailSelector:@selector(gotHistory:)];
	
	[request startAsynchronous];
	
	[pool release];

}

+ (void)updateHistory
{
	if (![puushCommon isLoggedIn]) return;
	
	if (isUpdatingHistory) return;
	isUpdatingHistory = true;
	
	[[HistoryView Instance] performSelectorInBackground:@selector(_updateHistory) withObject:nil];
}

- (void)drawRect:(NSRect)dirtyRect {
    int frameHeight = EMPTY_HEIGHT + (self.itemCount > 0 ? self.itemCount : 1) * ITEM_HEIGHT;
	
	[self setFrameSize:NSMakeSize(WIDTH,frameHeight)];
	
	[super drawRect:dirtyRect];
}

@end
