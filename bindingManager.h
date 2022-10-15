//
//  bindingManager.h
//  puush
//
//  Created by Dean Herbert on 10/05/24.
//  Copyright 2010 haxors. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyCombination.h"

#define KeyCombination(X,Y) [KeyCombination keyCombinationWithKeyCode:X modifiers:Y]

@interface BindingManager : NSObject {
	NSMutableArray *bindings;
}

@property (retain,nonatomic) NSMutableArray *bindings;

enum KeyBinding {
	None = 0,
	BI_SelectArea,
	BI_FullscreenScreenshot,
	BI_UploadFile
};

- (void) initializeBindings;

- (void) readBindingFromConfig:(int)binding withDefault:(KeyCombination*)combination;
- (void) setBindingFor:(int)binding withCombination:(KeyCombination*)combination;

- (NSString*) getStringRepresentationForBinding:(int)binding;
- (NSString*) getStringRepresentationForCombination:(KeyCombination*)combination;

@end
