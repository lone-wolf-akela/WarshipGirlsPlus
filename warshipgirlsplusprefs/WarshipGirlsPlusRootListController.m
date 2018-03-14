#include "WarshipGirlsPlusRootListController.h"

#import <unistd.h>

@implementation WarshipGirlsPlusRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

/*
This is a method that Karen (angelXwind) uses for several of her tweaks, notably mikoto and PreferenceOrganizer 2 as of this writing.

Her method involves overriding setPreferenceValue:specifier and readPreferenceValue: in the preference bundle to restore the old, pre-iOS 8 behaviour as it completely bypasses CFPreferences and writes directly to file.

This way, you can continue to read from the plist without worrying about cfprefsd. CFNotifications are still posted upon preference set.

This method has been tested to work in iOS 5, 6, 7, and 8.

Add this in your PSListController implementation code:
*/
- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath: path]) 
	{
		// If the file doesn’t exist, create an empty dictionary
		NSMutableDictionary *data;
		data = [[NSMutableDictionary alloc] init];
		[data writeToFile:path atomically:YES];
	}

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

@end
