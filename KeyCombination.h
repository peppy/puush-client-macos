//
//  KeyCombination.h
//  puush
//
//  Created by Dean Herbert on 10/05/25.
//  Copyright 2010 haxors. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KeyCombination : NSObject {
	int modifiers;
	int keycode;
}

@property int modifiers;
@property int keycode;

+ (KeyCombination*) keyCombinationWithKeyCode:(int)keycode modifiers:(int)modifiers;

@end
