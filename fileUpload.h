//
//  fileUpload.h
//  puush
//
//  Created by Dean Herbert on 10/05/24.
//  Copyright 2010 haxors. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIFormDataRequest.h"

@interface FileUpload : NSObject {
	ASIFormDataRequest *currentUpload;
}

@property (retain) ASIFormDataRequest *currentUpload;

+ (FileUpload*) Instance;

- (BOOL)uploadFile:(NSString*)filename deleteAfterUpload:(BOOL)deleteAfterUpload;
- (void)cancelUpload;

@end
