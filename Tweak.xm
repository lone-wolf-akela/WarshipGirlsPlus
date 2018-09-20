static BOOL EnableAndroid = NO;
static BOOL AntiCensor = YES;
static BOOL NotificationFix = YES;
static void loadPrefs()
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lonewolfakela.warshipgirlsplusprefs.plist"];
    if(prefs)
    {
        EnableAndroid = ( [prefs objectForKey:@"EnableAndroid"] ? [[prefs objectForKey:@"EnableAndroid"] boolValue] : EnableAndroid );
	AntiCensor = ( [prefs objectForKey:@"AntiCensor"] ? [[prefs objectForKey:@"AntiCensor"] boolValue] : AntiCensor );
	NotificationFix = ( [prefs objectForKey:@"NotificationFix"] ? [[prefs objectForKey:@"NotificationFix"] boolValue] : NotificationFix );
    }
    [prefs release];
}

%hook NSUserDefaults
- (id) objectForKey:(id)key
{
	if([key isEqualToString:@"crazy"])
	{
		if(AntiCensor)
			return  [NSNumber numberWithInt : 1];
		else
			return  %orig;
	}
	else
	{
		return %orig;
	}
}
%end

%hook NSURLRequest
- (id) initWithURL:(id)url cachePolicy:(unsigned long long)policy timeoutInterval:(double)interval
{	
	NSString * urlStr = [url absoluteString];	
	if ([urlStr containsString:@"version.jr.moefantasy.com"]) 
	{
		loadPrefs();
	}
	
	if (EnableAndroid)
	{		
		if ([urlStr containsString:@"version.jr.moefantasy.com"]) 
		{
			urlStr = [urlStr stringByReplacingOccurrencesOfString:@"/100111/"
		                             withString:@"/100011/"];
			urlStr = [urlStr stringByReplacingOccurrencesOfString:@"channel=100020"
		                             withString:@"channel=100021"];
			NSURL *newurl = [NSURL URLWithString:urlStr];
			return %orig(newurl, policy, interval);
		}		
		else
		{
			return %orig;
		}		
	}
	else
	{
		return %orig;
	}
}
%end

%hook UIApplication
- (void) cancelAllLocalNotifications
{
	if(NotificationFix)
	{
		//do nothing
	}
	else
	{
		%orig;
	}
}

/*- (void) cancelLocalNotification: (id)arg
{
	//do nothing
}*/

%end

%ctor
{
	loadPrefs();
}

