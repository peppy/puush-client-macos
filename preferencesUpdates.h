//
//  preferencesGeneral.h
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface preferencesUpdates : NSView {
	NSTextField *lastUpdated;
}

@property (retain) IBOutlet NSTextField *lastUpdated;

- (void)load;

@end
