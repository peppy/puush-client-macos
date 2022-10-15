//
//  menuItemView.h
//  MenubarApp
//
//  Created by Austin Gatchell on 4/18/10.
//  Copyright 2010 Austin Gatchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface menuItemView : NSView {
	NSImage *currentStatus;
}

@property (retain) NSImage *currentStatus;

- (void)setImage:(NSImage*)image;

@end
