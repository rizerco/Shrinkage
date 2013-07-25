//
//  GeneralPreferencesViewController.m
//  Shrinkage
//
//  Created by Luke Rogers on 17/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import "GeneralPreferencesViewController.h"
#import "LaunchAtLoginController.h"

@implementation GeneralPreferencesViewController

@synthesize includedDirectories;
@synthesize includedDirectoriesTableView;
@synthesize addIncludedDirectoryButton;
@synthesize removeIncludedDirectoryButton;
@synthesize rescanButton;
@synthesize excludedDirectories;
@synthesize excludedDirectoriesTableView;
@synthesize addExcludedDirectoryButton;
@synthesize removeExcludedDirectoryButton;
@synthesize launchAutomaticallyCheckbox;
@synthesize delegate;

- (id)init
{
    if((self = [super initWithNibName:@"GeneralPreferencesViewController" bundle:nil]))
	{
		NSArray *directoriesToInclude = [[NSUserDefaults standardUserDefaults] valueForKey:@"IncludedDirectories"];
		[self setIncludedDirectories:[NSMutableArray arrayWithArray:directoriesToInclude]];
		NSArray *directoriesToExclude = [[NSUserDefaults standardUserDefaults] valueForKey:@"ExcludedDirectories"];
		[self setExcludedDirectories:[NSMutableArray arrayWithArray:directoriesToExclude]];
	}
	return self;
}

- (void)viewWillAppear
{
	LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	BOOL launchesAutomatically = [launchController launchAtLogin];
	[[self launchAutomaticallyCheckbox] setState:launchesAutomatically];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

#pragma mark - NSTableViewDataSource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if([tableView isEqualTo:[self includedDirectoriesTableView]])
	{
		return [[self includedDirectories] count];
	}
	else
	{
		return [[self excludedDirectories] count];
	}
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if([tableView isEqualTo:[self includedDirectoriesTableView]])
	{
		return [[self includedDirectories] objectAtIndex:row];
	}
	else
	{
		return [[self excludedDirectories] objectAtIndex:row];
	}
}

#pragma mark - NSTableViewDelegate methods
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSLog(@"table view selection changed");
	NSInteger selectedRow = [[self includedDirectoriesTableView] selectedRow];
	if(selectedRow >= 0)
	{
		[[self removeIncludedDirectoryButton] setEnabled:YES];
		[[self rescanButton] setEnabled:YES];
	}
	else
	{
		[[self removeIncludedDirectoryButton] setEnabled:NO];
		[[self rescanButton] setEnabled:NO];
	}
	
	selectedRow = [[self excludedDirectoriesTableView] selectedRow];
	if(selectedRow >= 0)
	{
		[[self removeExcludedDirectoryButton] setEnabled:YES];
	}
	else
	{
		[[self removeExcludedDirectoryButton] setEnabled:NO];
	}
}

#pragma mark - Actions
- (void)askUserForDirectoryForInclusion:(BOOL)isForInclusion
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	
	[panel beginSheetModalForWindow:[[NSApplication sharedApplication] keyWindow] completionHandler:^(NSInteger result)
	 {
		 if(result == NSFileHandlingPanelOKButton)
		 {
			 // Open the image.
			 NSLog(@"selected %@",[[panel URL] path]);
			 if(isForInclusion)
			 {
				 [[self includedDirectories] addObject:[[panel URL] path]];
				 [[self includedDirectoriesTableView] reloadData];
				 [[NSUserDefaults standardUserDefaults] setValue:[self includedDirectories] forKey:@"IncludedDirectories"];
			 }
			 else
			 {
				 [[self excludedDirectories] addObject:[[panel URL] path]];
				 [[self excludedDirectoriesTableView] reloadData];
				 [[NSUserDefaults standardUserDefaults] setValue:[self excludedDirectories] forKey:@"ExcludedDirectories"];
			 }
			 [[NSUserDefaults standardUserDefaults] synchronize];
			 [[NSNotificationCenter defaultCenter] postNotificationName:@"ObserveredDirectoriesChanged" object:nil];
		 }
	 }];
}

- (IBAction)askUserForDirectoryToInclude:(id)sender
{
	[self askUserForDirectoryForInclusion:YES];
}

- (IBAction)askUserForDirectoryToExclude:(id)sender
{
	[self askUserForDirectoryForInclusion:NO];
}

- (void)removeSelectedItemForInclusion:(BOOL)isForInclusion
{
	if(isForInclusion)
	{
		NSInteger selectedRow = [[self includedDirectoriesTableView] selectedRow];
		if(selectedRow >= 0)
		{
		
			[[self includedDirectories] removeObjectAtIndex:selectedRow];
			[[self includedDirectoriesTableView] reloadData];
			[[NSUserDefaults standardUserDefaults] setValue:[self includedDirectories] forKey:@"IncludedDirectories"];
		}
	}
	else
	{
		NSInteger selectedRow = [[self excludedDirectoriesTableView] selectedRow];
		if(selectedRow >= 0)
		{
			[[self excludedDirectories] removeObjectAtIndex:selectedRow];
			[[self excludedDirectoriesTableView] reloadData];
			[[NSUserDefaults standardUserDefaults] setValue:[self excludedDirectories] forKey:@"ExcludedDirectories"];
		}
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ObserveredDirectoriesChanged" object:nil];
}

- (IBAction)removeIncludedSelectedItem:(id)sender
{
	[self removeSelectedItemForInclusion:YES];
}

- (IBAction)removeExcludedSelectedItem:(id)sender
{
	[self removeSelectedItemForInclusion:NO];
}

- (IBAction)rescanSelectedDirectory:(id)sender
{
	NSInteger selectedRow = [[self includedDirectoriesTableView] selectedRow];
	if(selectedRow >= 0)
	{
		NSString *directoryPath = [[self includedDirectories] objectAtIndex:selectedRow];
		[[self delegate] shouldRescanDirectory:directoryPath];
	}
}

- (IBAction)visitWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://rizergames.com"]];
}

- (IBAction)visitSupportWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://rizergames.com/shrinkage"]];
}

- (IBAction)toggleLaunchAtLogin:(id)sender
{
	LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
	[launchController setLaunchAtLogin:[sender state]];
}

#pragma mark - Login control


@end
