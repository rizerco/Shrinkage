//
//  AdvancedPreferencesViewController.m
//  Shrinkage
//
//  Created by Luke Rogers on 17/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import "AdvancedPreferencesViewController.h"

@implementation AdvancedPreferencesViewController

- (id)init
{
    if((self = [super initWithNibName:@"AdvancedPreferencesViewController" bundle:nil]))
	{
		
	}
	return self;
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"AdvancedPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Advanced", @"Toolbar item name for the Advanced preference pane");
}

@end
