//
//  MTView.h
//  MobileTerminal
//
//  Created by Steven Troughton-Smith on 23/03/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VT100TextView;
@class PTY;

@interface MTView : UIView <UIKeyInput, NSStreamDelegate>
{
	VT100TextView *textView;
	NSInputStream *inputStream;
	CADisplayLink *link;
	NSFileHandle *stdOutHandle;
	PTY* pty;
	NSMutableArray *commandHistory;
	//NSMutableString *textBuffer;

}

+ (instancetype)sharedInstance;
-(NSMutableString *)textBuffer;
@end
