//
//  HistoryItem.m
//  puush
//
//  Created by Dean Herbert on 10/05/29.
//  Copyright 2010 haxors. All rights reserved.
//

#import "HistoryItem.h"
#import "ASIFormDataRequest.h"
#import "puushCommon.h"

#define WIDTH 230
#define HEIGHT 26


@implementation HistoryItem

@synthesize url;
@synthesize uploadId;
@synthesize date;
@synthesize filename;

@synthesize labelFilename;
@synthesize labelDate;

@synthesize buttonCopy;
@synthesize buttonDelete;

@synthesize isHovering;

- (id)initWithId:(int)uploadId date:(NSString*)date url:(NSString*)url filename:(NSString*)filename height:(int)height
{
    self = [super initWithFrame:NSMakeRect(0,height,WIDTH,HEIGHT)];
	
	self.uploadId = uploadId;
	self.date = date;
	self.url = url;
	
	NSTextField *line2 = [[[NSTextField alloc] initWithFrame:NSMakeRect(20,0,WIDTH - 30,HEIGHT)] autorelease];
	[line2 setEditable:false];
	[line2 setBezeled:false];
	[[line2 cell] setWraps:false];
	[[line2 cell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[line2 setDrawsBackground:false];
	[line2 setStringValue:[NSString stringWithFormat:@"%@",filename]];
	[line2 setFont:[NSFont boldSystemFontOfSize:10]];
	
	self.labelFilename = line2;
	
	[self addSubview:line2];
	
	NSTextField *line1 = [[[NSTextField alloc] initWithFrame:NSMakeRect(20,2,WIDTH - 30,HEIGHT-15)] autorelease];
	[line1 setEditable:false];
	[line1 setBezeled:false];
	[line1 setBordered:false];
	[line1 setStringValue:[NSString stringWithFormat:@"%@", date]];
	[line1 setDrawsBackground:false];
	[line1 setFont:[NSFont menuFontOfSize:9]];
	
	self.labelDate = line1;
	
	[self addSubview:line1];
	
	NSButton *button = [[[NSButton alloc] initWithFrame:NSMakeRect(WIDTH - 47, 2, 45, 12)] autorelease];
	[button setBezelStyle:NSRecessedBezelStyle];
	[button setTitle:@"delete"];
	[button setAction:@selector(doDelete)];
	[button setTarget:self];
	[button setFont:[NSFont menuFontOfSize:8]];
	[button setHidden:true];
	
	self.buttonDelete = button;
	
	[self addSubview:button];
	
	button = [[[NSButton alloc] initWithFrame:NSMakeRect(WIDTH - 49 - 35, 2, 35, 12)] autorelease];
	[button setBezelStyle:NSRecessedBezelStyle];
	[button setTitle:@"copy"];
	[button setAction:@selector(doCopy)];
	[button setTarget:self];
	[button setFont:[NSFont menuFontOfSize:8]];
	[button setHidden:true];
	
	self.buttonCopy = button;
	
	[self addSubview:button];
	
	NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:[filename pathExtension]];
    [image setSize:NSMakeSize(16, 16)];
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(4, (HEIGHT - 16) / 2, 16, 16)];
    [imageView setImage:image];
	
	[self addSubview:imageView];
	
    return self;
}

-(void) dealloc
{
	self.url = nil;
	self.date = nil;
	self.filename = nil;
	
	self.labelFilename = nil;
	self.labelDate = nil;
	
	self.buttonCopy = nil;
	self.buttonDelete = nil;

	[super dealloc];
}

- (void)resetCursorRects {
    [super resetCursorRects];

	[self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:true];

}

-(BOOL) acceptsFirstResponder
{
	return true;
}

-(void) mouseDown:(NSEvent *)theEvent
{
	
}

-(void) mouseUp:(NSEvent *)theEvent
{
	[[menuBarItem Instance] hideMenu];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

-(void) doDelete
{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[puushCommon getApiUrlFor:@"del"]];
	[request setPostValue:[NSString stringWithFormat:@"%d",[self uploadId]] forKey:@"i"];
	[request setPostValue:[[puush config] stringForKey:@"key"] forKey:@"k"];
	[request setTimeOutSeconds:10];
	[request setPostValue:@"poop" forKey:@"z"];
	[request startSynchronous];
	
	[[HistoryView Instance] gotHistory:request];
}

-(void) doCopy
{
	[[menuBarItem Instance] hideMenu];
	[puush copyToClipboard:url];
}

-(void) mouseEntered:(NSEvent *)theEvent
{
	[labelFilename setTextColor:[NSColor whiteColor]];
	[labelDate setTextColor:[NSColor whiteColor]];
	
	[buttonCopy setHidden:false];
	[buttonDelete setHidden:false];
	
	isHovering = true;
	
	
	[self setNeedsDisplay:true];
}

-(void) mouseExited:(NSEvent *)theEvent
{
	[self resetState];
}

- (void)resetState
{
	isHovering = false;
	
	[labelFilename setTextColor:[NSColor blackColor]];
	[labelDate setTextColor:[NSColor darkGrayColor]];
	
	[buttonCopy setHidden:true];
	[buttonDelete setHidden:true];
	
	[self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)dirtyRect {
	if (isHovering)
	{
		NSArray *colors = [NSArray arrayWithObjects:
							[NSColor colorWithDeviceRed:(float)89/255 green:(float)129/255 blue:(float)239/255 alpha:1],
							[NSColor colorWithDeviceRed:(float)10/255 green:(float)84/255 blue:(float)236/255 alpha:1],
							nil
						   ];
		NSGradient *grad = [[[NSGradient alloc] initWithColors:colors] autorelease];
		[grad drawInRect:dirtyRect angle:270];
		
	}
	[super drawRect:dirtyRect];
    // Drawing code here.
}

@end
