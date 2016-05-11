//
//  MTView.m
//  MobileTerminal
//
//  Created by Steven Troughton-Smith on 23/03/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "MTView.h"
#import "VT100TextView.h"
#import "PTY.h"
#import <dlfcn.h>

#include <pthread.h>

static id sharedInstance;

void MTBackupDataSegment();
void MTRestoreDataSegment();
void callEntryPointOfImage(char *path, int argc, char **argv);


char _textBuffer[1024];
NSUInteger _textBufferIdx = 0;

@implementation NSArray (charArray)


- (char**)getArray
{
	unsigned count = (unsigned)[self count];
	char **array = (char **)malloc((count + 1) * sizeof(char*));
	memset(array, 0, count * sizeof(char));

	for (unsigned i = 0; i < count; i++)
	{
		array[i] = strdup([[self objectAtIndex:i] UTF8String]);
	}
	array[count] = NULL;
	return array;
}

@end

struct threadParams {
	char* data;
};

void processCommand(void *context)
{
	
//	struct threadParams *p = context;
	
//	freopen([[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] UTF8String], "a+", stdout);
//	freopen([[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] UTF8String], "a+", stderr);
	
	//[NSString stringWithUTF8String:_textBuffer]
	NSArray *components = [[NSString stringWithUTF8String:_textBuffer] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	memset(_textBuffer, 0, 1024*sizeof(char));
	optind = 1;
	//optarg = "";
	// 0 == app
	// argc = 1+
	
	
	//	NSLog(@"cmpts = %@", components);
	//if (!isatty(STDERR_FILENO))
	
	int argc = (int)components.count;
	
	
	char **argv = [components getArray];
	
	
	if (argc <= 1)
	{
		argc = 1;
		argv[1] = NULL;
		
	}
	
	//	NSLog(@"argc = %i, argv = %s", argc, argv[1]);
	
	//	if (argc < 2)
	//	{
	//		argc = 1;
	//		argv[0] = 0;
	//	}
	//	else
	//	{
	//	}
	
//	MTBackupDataSegment();
	
	NSArray *builtinCommands = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bin"] error:nil];
	

	
	
//	MTRestoreDataSegment();

	if ([components[0] isEqualToString:@"cd"])
	{
		if (strcmp(argv[1],"~")==0)
		{
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *basePath = paths.firstObject;
			
			chdir(basePath.UTF8String);
		}
		else
			chdir(argv[1]);
	}
	
	if ([components[0] isEqualToString:@"clear"])
	{
		printf("\e[2J\e[H");
//		[textView clearScreen];
	}
	
	if ([components[0] isEqualToString:@"help"])
	{
		printf("%s\n", [builtinCommands componentsJoinedByString:@"\n"].UTF8String);
	}
	
	if ([components[0] isEqualToString:@"pwd"])
	{
		char *buf[1024];
		getcwd(&buf, 1024);
		printf("%s\n", buf);
	}
	
	if ([components[0] hasPrefix:@"/"] || [components[0] hasPrefix:@"."])
	{
		if ([components[0] hasPrefix:@"."])
		{
			// relpath
			char *buf[1024];
			getcwd(&buf, 1024);
			
			NSString *fullPath = [[NSString stringWithUTF8String:buf] stringByAppendingPathComponent:[components[0] substringFromIndex:1]];
			
			callEntryPointOfImage(fullPath.UTF8String, argc, argv);

		}
		else
		
			callEntryPointOfImage([components[0] UTF8String], argc, argv);
	}
	
	if ([builtinCommands containsObject:components[0]])
	{
		callEntryPointOfImage([[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:components[0]] UTF8String], argc, argv);
	}
	else if ([components[0] length])
	{
//		printf("- %s: command not found\n", [components[0] UTF8String]);
	}
	
	
	fflush(stdout);
	fflush(stderr);
	
	//pthread_exit(NULL);
}


@implementation MTView

-(void)tick
{
//	NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath:[NSString stringWithFormat:@"%@/mt_stdout.txt",NSTemporaryDirectory()]];
//	NSData *inputData = [NSData dataWithData:[input readDataToEndOfFile]];
//	NSString *inputString = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
//
//		if (inputString)
//			textView.text = inputString;
//
	
	/*
	NSString *s = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()]  usedEncoding:nil error:nil];

	if (s)
		textView.text = s;*/
	
	
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	// Make sure that the text view is laid out, which re-computes the terminal
	// size in rows and columns.
	[textView layoutSubviews];
	
	// Send the terminal the actual size of our vt100 view.  This should be
	// called any time we change the size of the view.  This should be a no-op if
	// the size has not changed since the last time we called it.
//	[pty setWidth:[textView width] withHeight:[textView height]];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		stdOutHandle = [NSFileHandle fileHandleForReadingAtPath:[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()]];
		commandHistory = [NSMutableArray arrayWithCapacity:3];
		
//		_textBuffer = malloc(8096*sizeof(char));
		memset(_textBuffer, 0, 1024*sizeof(char));

	
//		freopen([[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] UTF8String], "a+", stdin);

		
//		textBuffer = [NSMutableString string];
		textView = [[VT100TextView alloc] initWithFrame:self.bounds];
		//pty = [[PTY alloc] initWithFileHandle:stdOutHandle];

		self.backgroundColor = [UIColor blackColor];
		self.opaque = YES;
//
		textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

		
		[textView setFont:[UIFont fontWithName:@"Courier New" size:18]];
//		[textView setNeedsLayout];
		
		
		[@"\n" writeToFile:[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] atomically:NO encoding:NSUTF8StringEncoding error:nil];

		
//		link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
//		link.frameInterval = 2;
//		
//		[link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *basePath = paths.firstObject;
		
		chdir(basePath.UTF8String);
		
//		[[NSFileManager defaultManager] copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bin/ls"] toPath:[basePath stringByAppendingPathComponent:@"ls"] error:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dataAvailable:)
													 name:NSFileHandleReadCompletionNotification
												   object:stdOutHandle];
		
		[stdOutHandle readInBackgroundAndNotify];

		[textView clearScreen];

		[self addSubview:textView];
		


	}
	return self;
}


- (void)dataAvailable:(NSNotification *)aNotification {
	NSData* data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	if ([data length] == 0) {
		// I would expect from the documentation that an EOF would be present as
		// an entry in the userinfo dictionary as @"NSFileHandleError", but that is
		// never present.  Instead, it seems to just appear as an empty data
		// message.  This usually happens when someone just types "exit".  Simply
		// restart the subprocess when this happens.
		
		// On EOF, either (a) the user typed "exit" or (b) the terminal never
		// started in first place due to a misconfiguration of the BSD subsystem
		// (can't find /bin/login, etc).  To allow the user to proceed in case (a),
		// display a message with instructions on how to restart the shell.  We
		// don't restart automatically in case of (b), which would put us in an
		// infinite loop.  Print a message on the screen with instructions on how
		// to restart the process.
//		NSData* message = [NSData dataWithBytes:kProcessExitedMessage
//										 length:strlen(kProcessExitedMessage)];
//		[textView readInputStream:message];
//		[self releaseSubProcess];
		[stdOutHandle readInBackgroundAndNotify];

		return;
	}
	
	
	// Forward the subprocess data into the terminal character handler
	[textView readInputStream:data];
	
	// Queue another read
	[stdOutHandle readInBackgroundAndNotify];
}

//- (void)stream:(NSInputStream *)aStream handleEvent:(NSStreamEvent)eventCode
//{
//	if (eventCode == NSStreamEventHasBytesAvailable)
//	{
//		uint8_t buf[1024];
//		[aStream read:&buf maxLength:1024];
//		
//		/*
//		NSString *readBuffer = [NSString stringWithUTF8String:buf];
//		
//		if (readBuffer)
//			textView.text = [textView.text stringByAppendingString:readBuffer];
//		*/
//		
//		[textView readInputStream:[NSData dataWithBytes:buf length:1024]];
//
//		
//		NSLog(@"bytes = %s", buf);
//	}
//}

-(void)awakeFromNib
{
	[self becomeFirstResponder];
	{
		// Redirection code
		//		[@"" writeToFile:[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		
//		freopen([[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] UTF8String], "a+", stderr);
		//
		
//		fflush(stderr);
		
		//		printf("wtf why aren''t you working?");
		
	}
	
//	printf("y u no work?");
}

-(BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)insertText:(NSString *)text
{
	freopen([[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] UTF8String], "a+", stdout);
	freopen([[NSString stringWithFormat:@"%@/mt_stdout.txt", NSTemporaryDirectory()] UTF8String], "a+", stderr);
	
	if (strcmp(text.UTF8String,"\n")==0)
	{
		printf("\r\n");

//		NSLog(@"processCommand %@", textBuffer);
		[self processCommand];
	}
	else
	{
		printf(text.UTF8String);
		
		_textBuffer[_textBufferIdx++] = text.UTF8String[0];
		
//		
//		[textBuffer appendString:text];
	}
	
	fflush(stdout);
	fflush(stderr);
}

- (void)deleteBackward
{
	if (_textBufferIdx > 0)
	{
		_textBuffer[_textBufferIdx--] = '\0';
		printf("\b \b");
	}
	
	fflush(stdout);

//	if (textBuffer.length)
//		[textBuffer deleteCharactersInRange:NSMakeRange(textBuffer.length-1, 1)];
}


#define NUM_THREADS     1

pthread_t processThread = 0;
pthread_mutex_t lock;

_historyIndex = 0;
_historyMax = 0;


-(void)processCommand
{
	[commandHistory insertObject:[NSString stringWithUTF8String:_textBuffer] atIndex:_historyIndex];
	
	//if (_historyIndex+1 < commandHistory.count)
	//	[commandHistory removeObjectsInRange:NSMakeRange(_historyIndex+1, commandHistory.count)];
	
	
	pthread_create(&processThread, NULL, processCommand, NULL);

	
	_textBufferIdx = 0;
	_historyIndex++;
	_historyMax = _historyIndex;
}

-(void)upArrow
{
	if (_historyIndex > 0)
	{
		_historyIndex--;
		
		strcpy(_textBuffer, [commandHistory[_historyIndex] UTF8String]);
		printf("\e[2K\e[%iD",_textBufferIdx+1);
		_textBufferIdx = [commandHistory[_historyIndex] length]-1;
		_textBuffer[_textBufferIdx+1]=0;
		printf(_textBuffer);
	}
	fflush(stdout);
}

-(void)downArrow
{
	if (_historyIndex < _historyMax-1)
	{
		
		_historyIndex++;
		strcpy(_textBuffer, [commandHistory[_historyIndex] UTF8String]);
		printf("\e[2K\e[%iD",_textBufferIdx+1);
		_textBufferIdx = [commandHistory[_historyIndex] length]-1;
		_textBuffer[_textBufferIdx+1]=0;
		printf(_textBuffer);

	}
	fflush(stdout);
}

-(void)tab
{
	char *buf[1024];
	getcwd(&buf, 1024);
	
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithUTF8String:buf] error:nil];
	
	NSString *tb = [NSString stringWithUTF8String:_textBuffer];
	NSArray *cmpts = [tb componentsSeparatedByString:@" "];
	
	for (NSString *item in dirContents)
	{
		if ([item hasPrefix:cmpts.lastObject])
		{
			for (int i = [[cmpts lastObject] length]; i < item.length; i++)
			{
				_textBuffer[_textBufferIdx++] = item.UTF8String[i];
				printf("%c", item.UTF8String[i]);
			}

			break;
		}
	}
	fflush(stdout);
}

-(void)controlC
{
	//pthread_exit(NULL);
	
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
//		pthread_mutex_lock(&lock);
//		pthread_join(processThread,NULL);
		//pthread_exit(NULL);
		
		pthread_kill(processThread, SIGQUIT);
//		pthread_mutex_unlock(&lock);
		
		//		pthread_exit(NULL);

	});
	//if (pthread_join(processThread,NULL))

	
	printf("^C\n");
	fflush(stdout);
	fflush(stderr);
}

-(NSArray <UIKeyCommand *>*)keyCommands
{
	return @[
			 [UIKeyCommand keyCommandWithInput:@"c" modifierFlags:UIKeyModifierControl action:@selector(controlC)],
			 [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(upArrow)],
			 [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(downArrow)],
			 [UIKeyCommand keyCommandWithInput:@"	" modifierFlags:0 action:@selector(tab)]

			 ];
}

@end
