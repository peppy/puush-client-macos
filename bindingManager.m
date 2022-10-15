//
//  bindingManager.m
//  puush
//
//  Created by Dean Herbert on 10/05/24.
//  Copyright 2010 haxors. All rights reserved.
//

#import "BindingManager.h"
#import "puush.h"
#import <Carbon/Carbon.h>
#import "preferencesWindow.h"

@implementation BindingManager

@synthesize bindings;

//---------------------------------------------------------- 
// SRCarbonToCocoaFlags()
//---------------------------------------------------------- 
NSUInteger SRCarbonToCocoaFlags( NSUInteger carbonFlags )
{
	NSUInteger cocoaFlags = 0;
	
	if (carbonFlags & cmdKey) cocoaFlags |= NSCommandKeyMask;
	if (carbonFlags & optionKey) cocoaFlags |= NSAlternateKeyMask;
	if (carbonFlags & controlKey) cocoaFlags |= NSControlKeyMask;
	if (carbonFlags & shiftKey) cocoaFlags |= NSShiftKeyMask;
	if (carbonFlags & NSFunctionKeyMask) cocoaFlags += NSFunctionKeyMask;
	
	return cocoaFlags;
}

//---------------------------------------------------------- 
// SRCocoaToCarbonFlags()
//---------------------------------------------------------- 
NSUInteger SRCocoaToCarbonFlags( NSUInteger cocoaFlags )
{
	NSUInteger carbonFlags = 0;
	
	if (cocoaFlags & NSCommandKeyMask) carbonFlags |= cmdKey;
	if (cocoaFlags & NSAlternateKeyMask) carbonFlags |= optionKey;
	if (cocoaFlags & NSControlKeyMask) carbonFlags |= controlKey;
	if (cocoaFlags & NSShiftKeyMask) carbonFlags |= shiftKey;
	if (cocoaFlags & NSFunctionKeyMask) carbonFlags |= NSFunctionKeyMask;
	
	return carbonFlags;
}

- (id) init
{
	id us = [super init];
	
	const int CAPACITY = 5;
	
	self.bindings = [NSMutableArray arrayWithCapacity:CAPACITY];
	for (int i = 0; i < CAPACITY; i++)
		[bindings addObject:[KeyCombination keyCombinationWithKeyCode:0 modifiers:0]];
	
	
	
	[self initializeBindings];

	return us;
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData)
{
	EventHotKeyID eventId;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(eventId),NULL,&eventId);

	//Need to override these keys to allow binding them in preferences.
	//Kinda hacky, but works.
	preferencesWindow *prefs = [preferencesWindow Instance];
	if (prefs != nil)
	{
		NSButton *button = [[prefs generalView] activeBindingButton];
		
		if (button != nil)
		{
			switch (eventId.id)
			{
				case 10:
					[[puush bindingManager] setBindingFor:button.tag withCombination:KeyCombination(kVK_ANSI_3, cmdKey+shiftKey)];
					break;
				case 11:
					[[puush bindingManager] setBindingFor:button.tag withCombination:KeyCombination(kVK_ANSI_4, cmdKey+shiftKey)];
					break;
			}
			
			[[prefs generalView] load];
			
			return true;
		}
	}

	switch (eventId.id)
	{
		case 10:
		case 11:
			[puush startMonitoringFiles];
			break;
		case 12:
			[puush stopMonitoringFiles];
			break;
		case BI_SelectArea:
			[[puush Instance] startInteractiveCapture:nil];
			break;
		case BI_FullscreenScreenshot:
			[[puush Instance] startDesktopCapture:nil];
			break;
		case BI_UploadFile:
			[[puush Instance] startUploadFileSelection:nil];
			break;	
	}
	
	return noErr;
}

EventHotKeyRef binding1;
EventHotKeyRef binding2;
EventHotKeyRef binding3;

BOOL initialBindComplete = false;

- (void)bindHotkeys
{
	//Register the Hotkeys
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	eventType.eventKind=kEventHotKeyPressed;
	
	if (!initialBindComplete)
	{
		InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
		initialBindComplete = true;
	}
	else {
		UnregisterEventHotKey(binding1);
		UnregisterEventHotKey(binding2);
		UnregisterEventHotKey(binding3);
	}
	
	KeyCombination *combo = [[self bindings] objectAtIndex:BI_SelectArea];
	if (combo.keycode != 0 && !(combo.keycode == kVK_ANSI_4 && combo.modifiers == cmdKey+shiftKey))
	{
		gMyHotKeyID.id = BI_SelectArea;
		RegisterEventHotKey(combo.keycode, combo.modifiers, gMyHotKeyID, GetApplicationEventTarget(), kEventHotKeyExclusive, &binding1);
	}
	else {
		gMyHotKeyID.id = 11;
		RegisterEventHotKey(kVK_ANSI_4, cmdKey+shiftKey, gMyHotKeyID, GetApplicationEventTarget(), kEventHotKeyExclusive, &binding1);
	}

	
	combo = [[self bindings] objectAtIndex:BI_FullscreenScreenshot];
	if (combo.keycode != 0 && !(combo.keycode == kVK_ANSI_4 && combo.modifiers == cmdKey+shiftKey))
	{
		gMyHotKeyID.id = BI_FullscreenScreenshot;
		RegisterEventHotKey(combo.keycode, combo.modifiers, gMyHotKeyID, GetApplicationEventTarget(), kEventHotKeyExclusive, &binding2);
	}
	else {
		gMyHotKeyID.id = 10;
		RegisterEventHotKey(kVK_ANSI_3, cmdKey+shiftKey, gMyHotKeyID, GetApplicationEventTarget(), kEventHotKeyExclusive, &binding2);
	}

	combo = [[self bindings] objectAtIndex:BI_UploadFile];
	if (combo.keycode != 0)
	{
		gMyHotKeyID.id = BI_UploadFile;
		RegisterEventHotKey(combo.keycode, combo.modifiers, gMyHotKeyID, GetApplicationEventTarget(), kEventHotKeyExclusive, &binding3);
	}
}

- (void) initializeBindings
{
	[self readBindingFromConfig:BI_SelectArea withDefault:KeyCombination(kVK_ANSI_4,cmdKey+shiftKey)];
	[self readBindingFromConfig:BI_FullscreenScreenshot withDefault:KeyCombination(kVK_ANSI_3,cmdKey+shiftKey)];
	[self readBindingFromConfig:BI_UploadFile withDefault:KeyCombination(kVK_ANSI_U,cmdKey+shiftKey)];
	
	[self bindHotkeys];
}

- (void) readBindingFromConfig:(int)binding withDefault:(KeyCombination*)combination
{
	NSString *bindingName = [NSString stringWithFormat:@"binding%d",binding];

	NSString *str = [[puush config] stringForKey:bindingName];
	
	KeyCombination* combo = combination;
	
	if (str != nil)
	{
		NSArray *split = [str componentsSeparatedByString:@","];
		int modifier = [(NSString*)[split objectAtIndex:0] intValue];
		int keyCode = [(NSString*)[split objectAtIndex:1] intValue];
		
		if (keyCode > 0)
			combo = KeyCombination(keyCode, modifier);
	}
	
	NSMenuItem *menu = nil;
	
	switch (binding)
	{
		case BI_SelectArea:
			menu = [[puush Instance] menuItemSelectArea];
			break;
		case BI_FullscreenScreenshot:
			menu = [[puush Instance] menuItemDesktopScreenshot];
			break;
		case BI_UploadFile:
			menu = [[puush Instance] menuItemUploadFile];
			break;
	}
	
	if (menu != nil)
	{
		//private API call
		[menu _setKeyEquivalentVirtualKeyCode:combo.keycode];
		
		[menu setKeyEquivalentModifierMask:SRCarbonToCocoaFlags(combo.modifiers)];
	}

	[self setBindingFor:binding withCombination:combo];
}

- (void) setBindingFor:(int)binding withCombination:(KeyCombination*)combination
{
	if (combination.keycode == 0)
	{
		[[puush config] removeObjectForKey:[NSString stringWithFormat:@"binding%d",binding]];
		return;
	}
	
	[bindings replaceObjectAtIndex:binding withObject:combination];
	
	[[puush config] 
		setValue:[NSString stringWithFormat:@"%d,%d",combination.modifiers,combination.keycode]
		forKey:[NSString stringWithFormat:@"binding%d",binding]];
}

- (NSString*) getStringRepresentationForBinding:(int)binding
{
	return [self getStringRepresentationForCombination:[bindings objectAtIndex:binding]];
}

- (NSString*) getStringRepresentationForCombination:(KeyCombination*)combination
{
	NSMutableString *buildString = [NSMutableString string];
	
	if ((combination.modifiers & cmdKey) > 0) [buildString appendString:@"⌘"];
	if ((combination.modifiers & shiftKey) > 0) [buildString appendString:@"⇧"];
	if ((combination.modifiers & optionKey) > 0) [buildString appendString:@"⌥"];
	if ((combination.modifiers & controlKey) > 0) [buildString appendString:@"⌃"];
	
	NSString *key;
	
	switch (combination.keycode)
	{
		case 0x00:
			key = @"A";
			break;
		case 0x01:
			key = @"S";
			break;
		case 0x02:
			key = @"D";
			break;
		case 0x03:
			key = @"F";
			break;
		case 0x04:
			key = @"H";
			break;
		case 0x05:
			key = @"G";
			break;
		case 0x06:
			key = @"Z";
			break;
		case 0x07:
			key = @"X";
			break;
		case 0x08:
			key = @"C";
			break;
		case 0x09:
			key = @"V";
			break;
		case 0x0B:
			key = @"B";
			break;
		case 0x0C:
			key = @"Q";
			break;
		case 0x0D:
			key = @"W";
			break;
		case 0x0E:
			key = @"E";
			break;
		case 0x0F:
			key = @"R";
			break;
		case 0x10:
			key = @"Y";
			break;
		case 0x11:
			key = @"T";
			break;
		case 0x12:
			key = @"1";
			break;
		case 0x13:
			key = @"2";
			break;
		case 0x14:
			key = @"3";
			break;
		case 0x15:
			key = @"4";
			break;
		case 0x16:
			key = @"6";
			break;
		case 0x17:
			key = @"5";
			break;
		case 0x18:
			key = @"Equal";
			break;
		case 0x19:
			key = @"9";
			break;
		case 0x1A:
			key = @"7";
			break;
		case 0x1B:
			key = @"Minus";
			break;
		case 0x1C:
			key = @"8";
			break;
		case 0x1D:
			key = @"0";
			break;
		case 0x1E:
			key = @"RightBracket";
			break;
		case 0x1F:
			key = @"O";
			break;
		case 0x20:
			key = @"U";
			break;
		case 0x21:
			key = @"LeftBracket";
			break;
		case 0x22:
			key = @"I";
			break;
		case 0x23:
			key = @"P";
			break;
		case 0x25:
			key = @"L";
			break;
		case 0x26:
			key = @"J";
			break;
		case 0x27:
			key = @"Quote";
			break;
		case 0x28:
			key = @"K";
			break;
		case 0x29:
			key = @"Semicolon";
			break;
		case 0x2A:
			key = @"Backslash";
			break;
		case 0x2B:
			key = @"Comma";
			break;
		case 0x2C:
			key = @"Slash";
			break;
		case 0x2D:
			key = @"N";
			break;
		case 0x2E:
			key = @"M";
			break;
		case 0x2F:
			key = @"Period";
			break;
		case 0x32:
			key = @"Grave";
			break;
		case 0x41:
			key = @"KeypadDecimal";
			break;
		case 0x43:
			key = @"KeypadMultiply";
			break;
		case 0x45:
			key = @"KeypadPlus";
			break;
		case 0x47:
			key = @"KeypadClear";
			break;
		case 0x4B:
			key = @"KeypadDivide";
			break;
		case 0x4C:
			key = @"KeypadEnter";
			break;
		case 0x4E:
			key = @"KeypadMinus";
			break;
		case 0x51:
			key = @"KeypadEquals";
			break;
		case 0x52:
			key = @"Keypad0";
			break;
		case 0x53:
			key = @"Keypad1";
			break;
		case 0x54:
			key = @"Keypad2";
			break;
		case 0x55:
			key = @"Keypad3";
			break;
		case 0x56:
			key = @"Keypad4";
			break;
		case 0x57:
			key = @"Keypad5";
			break;
		case 0x58:
			key = @"Keypad6";
			break;
		case 0x59:
			key = @"Keypad7";
			break;
		case 0x5B:
			key = @"Keypad8";
			break;
		case 0x5C:
			key = @"Keypad9";
			break;
		case 0x24:
			key = @"Return";
			break;
		case 0x30:
			key = @"Tab";
			break;
		case 0x31:
			key = @"Space";
			break;
		case 0x33:
			key = @"Delete";
			break;
		case 0x35:
			key = @"Escape";
			break;
		case 0x37:
			key = @"Command";
			break;
		case 0x38:
			key = @"Shift";
			break;
		case 0x39:
			key = @"CapsLock";
			break;
		case 0x3A:
			key = @"Option";
			break;
		case 0x3B:
			key = @"Control";
			break;
		case 0x3C:
			key = @"RightShift";
			break;
		case 0x3D:
			key = @"RightOption";
			break;
		case 0x3E:
			key = @"RightControl";
			break;
		case 0x3F:
			key = @"Function";
			break;
		case 0x40:
			key = @"F17";
			break;
		case 0x48:
			key = @"VolumeUp";
			break;
		case 0x49:
			key = @"VolumeDown";
			break;
		case 0x4A:
			key = @"Mute";
			break;
		case 0x4F:
			key = @"F18";
			break;
		case 0x50:
			key = @"F19";
			break;
		case 0x5A:
			key = @"F20";
			break;
		case 0x60:
			key = @"F5";
			break;
		case 0x61:
			key = @"F6";
			break;
		case 0x62:
			key = @"F7";
			break;
		case 0x63:
			key = @"F3";
			break;
		case 0x64:
			key = @"F8";
			break;
		case 0x65:
			key = @"F9";
			break;
		case 0x67:
			key = @"F11";
			break;
		case 0x69:
			key = @"F13";
			break;
		case 0x6A:
			key = @"F16";
			break;
		case 0x6B:
			key = @"F14";
			break;
		case 0x6D:
			key = @"F10";
			break;
		case 0x6F:
			key = @"F12";
			break;
		case 0x71:
			key = @"F15";
			break;
		case 0x72:
			key = @"Help";
			break;
		case 0x73:
			key = @"Home";
			break;
		case 0x74:
			key = @"PageUp";
			break;
		case 0x75:
			key = @"ForwardDelete";
			break;
		case 0x76:
			key = @"F4";
			break;
		case 0x77:
			key = @"End";
			break;
		case 0x78:
			key = @"F2";
			break;
		case 0x79:
			key = @"PageDown";
			break;
		case 0x7A:
			key = @"F1";
			break;
		case 0x7B:
			key = @"LeftArrow";
			break;
		case 0x7C:
			key = @"RightArrow";
			break;
		case 0x7D:
			key = @"DownArrow";
			break;
		case 0x7E:
			key = @"UpArrow";
			break;
		case 0x0A:
			key = @"ISO_Section";
			break;
		case 0x5D:
			key = @"JIS_Yen";
			break;
		case 0x5E:
			key = @"JIS_Underscore";
			break;
		case 0x5F:
			key = @"JIS_KeypadComma";
			break;
		case 0x66:
			key = @"JIS_Eisu";
			break;
		case 0x68:
			key = @"JIS_Kana";
	}
	
	[buildString appendString:key];
	
	return buildString;
}

@end
