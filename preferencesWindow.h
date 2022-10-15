//
//  preferencesWindow.h
//  puush
//
//  Created by Dean Herbert on 10/05/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "preferencesGeneral.h"
#import "preferencesUpdates.h"
#import "preferencesAccount.h"

@interface preferencesWindow : DBPrefsWindowController<LoginDelegate> {
	preferencesGeneral *generalView;
	preferencesUpdates *updatesView;
	preferencesAccount *accountView;
}

+ (preferencesWindow*) Instance;

@property (retain) IBOutlet preferencesGeneral *generalView;
@property (retain) IBOutlet preferencesUpdates *updatesView;
@property (retain) IBOutlet preferencesAccount *accountView;

@end
