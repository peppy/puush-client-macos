//
//  menuBarItem.h
//  puush
//
//  Created by Dean Herbert on 10/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface menuBarItem : NSObject {
	NSStatusItem *statusItem;
	NSMenu *dropdownMenu;
}

@property (assign) IBOutlet NSMenu *dropdownMenu;
@property (assign) NSStatusItem *statusItem;

- (void)showMenu;
- (void)hideMenu;

+ (menuBarItem*)Instance;

@end
