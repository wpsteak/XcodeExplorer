//
//  BDNotificationsWindowController.m
//  XcodeExplorer
//
//  Created by Craig Edwards on 28/11/12.
//  Copyright (c) 2012 BlackDog Foundry. All rights reserved.
//

#import "XCENotificationsWindowController.h"

@implementation XCENotificationsWindowController

-(id)init {
	self = [super initWithWindowNibName:@"XCENotificationsWindowController"];
	if (self) {
		notifications = [[NSMutableArray array] retain];
		regularExpressions = [[NSMutableArray array] retain];
	}
	return self;
}

-(void)windowDidLoad {
	[filterTextField setStringValue:@"NS.*"];
}

#
#pragma mark - Notification registering
#
-(IBAction)toggleRecording:(id)sender {
	if ([[sender title] isEqualToString:@"Start"]) {
		[notifications removeAllObjects];
		[tableView reloadData];
		[self parseRegexTextField];
		
		[sender setTitle:@"Stop"];
		[filterTextField setEnabled:NO];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationListener:) name:nil object:nil];
	}
	else {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[filterTextField setEnabled:YES];
		[sender setTitle:@"Start"];
	}
}

-(void)notificationListener:(NSNotification *)notification {
	NSString *name = [notification name];
	
	// loop through our list of regular expressions and if any of
	// them match, then we'll throw this notification away
	for (NSRegularExpression *regularExpression in regularExpressions) {
		NSTextCheckingResult *match = [regularExpression firstMatchInString:name options:0 range:NSMakeRange(0, name.length)];
		if (match != nil)
			return;
	}

	[notifications addObject:notification];
	[tableView reloadData];
}

-(void)parseRegexTextField {
	[regularExpressions removeAllObjects];
	
	// ignore empty string
	if ([[filterTextField stringValue] length] == 0)
		return;
	
	NSArray *patterns = [[filterTextField stringValue] componentsSeparatedByString:@","];
	for (NSString *pattern in patterns) {
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
		if (regex != nil)
			[regularExpressions addObject:regex];
	}
}

#
#pragma mark - Table management
#
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [notifications count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSNotification *notification = notifications[row];
	if ([[tableColumn identifier] isEqualToString:@"name"]) {
		return [notification name];
	}
	else if ([[tableColumn identifier] isEqualToString:@"object"]) {
		return [[[notification object] description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	}
	else if ([[tableColumn identifier] isEqualToString:@"userInfo"]) {
		return [[[notification userInfo] description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	}
	return @"Yikes!";
}

-(void)dealloc {
	[notifications release];
	[super dealloc];
}

@end
