//
//  KeyCombination.m
//  puush
//
//  Created by Dean Herbert on 10/05/25.
//  Copyright 2010 haxors. All rights reserved.
//

#import "KeyCombination.h"


@implementation KeyCombination

@synthesize modifiers;
@synthesize keycode;

+ (KeyCombination*) keyCombinationWithKeyCode:(int)keycode modifiers:(int)modifiers
{
	KeyCombination* comb = [[[self alloc] init] autorelease];
	comb.modifiers = modifiers;
	comb.keycode = keycode;
	return comb;
}

@end
