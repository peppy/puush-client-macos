//
//  menuItemView.m
//  MenubarApp
//
//  Created by Austin Gatchell on 4/18/10.
//  Copyright 2010 Austin Gatchell. All rights reserved.
//

#import "menuItemView.h"
#import "puush.h"
#import "FileUpload.h"
#import "ASIFormDataRequest.h"

@implementation menuItemView

@synthesize currentStatus;

NSImage *menuIconSelected;
NSImage *menuIconDragging;

BOOL isMenuVisible;
BOOL draggingActive;

- (id)initWithFrame:(NSRect)frame {
	//initial status
	self = [super initWithFrame:frame];	
	if (self) {

		// Register the view to accept only text drags
		NSArray *dragTypes = [[NSArray alloc] initWithObjects:NSFilenamesPboardType, nil];
		[self registerForDraggedTypes:dragTypes];
		[dragTypes release];
	}
	
	menuIconSelected = [[NSImage imageNamed:@"status-icon-selected"] retain];
	
	menuIconDragging = [[NSImage imageNamed:@"status-file-drop"] retain];
	
	[self performSelectorInBackground:@selector(updateThread) withObject:nil];
	
	return self;
}

int lastProgress = -1;

- (void)updateThread
{
	while (true)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSImage *newImage = nil;
		
		ASIFormDataRequest *request = [[FileUpload Instance] currentUpload];
		
		if (isMenuVisible)
		{
			if (request != nil)
			{
				int sentBytes = request.postLength > 131072 ? request.totalBytesSent - 131072 : request.totalBytesSent;
				if (sentBytes < 0) sentBytes = 0;
				
				int totalBytes = request.postLength > 131072 ? request.postLength - 131072: request.postLength; 
				
				float progress = ((float)sentBytes / totalBytes) * 100;
				
				[[puush Instance] performSelectorOnMainThread:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:YES];
			}
		}
		else
		{
			if (request == nil)
			{
				if (lastProgress >= 0)
				{
					lastProgress = -5;
					newImage = [[NSImage imageNamed:@"complete"] retain];
				}
				else if (lastProgress < -1)
				{
					lastProgress++;
					if (lastProgress == -1)
						newImage = [[NSImage imageNamed:@"status-icon"] retain];
				}
			}
			else {
				
				int sentBytes = request.postLength > 131072 ? request.totalBytesSent - 131072 : request.totalBytesSent;
				if (sentBytes < 0) sentBytes = 0;

				int totalBytes = request.postLength > 131072 ? request.postLength - 131072: request.postLength; 
				
				float progress = ((float)sentBytes / totalBytes) * 100;
								
				int intprogress = ((int)progress / 10) * 10 + ((int)progress % 10 >= 5 ? 10 : 0);
				
				if (intprogress < 0) intprogress = 0;
				
				if (lastProgress < 0 || intprogress < lastProgress)
					lastProgress = 0;
				else if (intprogress > lastProgress)
					lastProgress += 5;

				newImage = [[NSImage imageNamed:[NSString stringWithFormat:@"progress%d",lastProgress]] retain];
			}
		}
		
		if (newImage != nil)
		{
			self.currentStatus = newImage;
			[newImage release];
			
			[self setNeedsDisplay:true];
		}

		[NSThread sleepForTimeInterval:lastProgress < 0 ? 0.4f : 0.016f];
		
		[pool release];
	}
}

- (void)setImage:(NSImage*)image
{
	self.currentStatus = image;
	[self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)dirtyRect {

	// The rectangle to draw the image from and the point to draw it at
	
	NSRect rect = NSMakeRect(0, 0, 22, 22);
	NSPoint point = NSMakePoint(1, 1);
	
	[[[menuBarItem Instance] statusItem] drawStatusBarBackgroundInRect:[self bounds] withHighlight:isMenuVisible];
	
	// Draw the status image
	if (draggingActive)
		[menuIconDragging drawAtPoint:point fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	else if (isMenuVisible)
		[menuIconSelected drawAtPoint:point fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	else
		[self.currentStatus drawAtPoint:point fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {

	if ((NSDragOperationCopy & [sender draggingSourceOperationMask]) == NSDragOperationCopy)
		return NSDragOperationCopy;

	return NSDragOperationNone;
}

-(NSDragOperation) draggingEntered:(id)sender
{
	draggingActive = true;
	[self setNeedsDisplay:true];
	
	return [super draggingEntered:sender];
}

-(void) draggingExited:(id)sender
{
	draggingActive = false;
	[self setNeedsDisplay:true];
}

- (void)mouseDown:(NSEvent *)event {

	[[self menu] setDelegate:self];
    [[menuBarItem Instance] showMenu];
	
	[self setNeedsDisplay:true];
}

- (void)rightMouseDown:(NSEvent *)event {
    // Treat right-click just like left-click
    [self mouseDown:event];
}

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
    [menu setDelegate:nil];    
    [self setNeedsDisplay:YES];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	draggingActive = false;
	[self setNeedsDisplay:YES];
	
	// Get the dragging pasteboard
	NSPasteboard *paste = [sender draggingPasteboard];
	NSArray *dragTypes = [[NSArray alloc] initWithObjects:NSFilenamesPboardType, nil];
	NSString *desiredType = [paste availableTypeFromArray:dragTypes];
	[dragTypes release];

	// If it is the desired type, print the dragged text
	if (desiredType == NSFilenamesPboardType) {
	
		for (NSString *filename in [paste propertyListForType:NSFilenamesPboardType])
		{
			[[FileUpload Instance] uploadFile:filename deleteAfterUpload:false];
		}

		// Return YES, because the operation was successful
		return YES;
	}

	return NO;
}

@end
