//
//  GeneralPreferencesViewController.h
//  Shrinkage
//
//  Created by Luke Rogers on 17/02/2012.
//  Copyright (c) 2012 Rizer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@protocol GeneralPreferencesDelegate <NSObject>
- (void)shouldRescanDirectory:(NSString*)directoryPath;
@end

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController,NSTableViewDataSource,NSTableViewDelegate>

@property (nonatomic, strong) NSMutableArray *includedDirectories;
@property (nonatomic, strong) IBOutlet NSTableView *includedDirectoriesTableView;
@property (nonatomic, strong) IBOutlet NSButton *addIncludedDirectoryButton;
@property (nonatomic, strong) IBOutlet NSButton *removeIncludedDirectoryButton;
@property (nonatomic, strong) IBOutlet NSButton *rescanButton;
@property (nonatomic, strong) NSMutableArray *excludedDirectories;
@property (nonatomic, strong) IBOutlet NSTableView *excludedDirectoriesTableView;
@property (nonatomic, strong) IBOutlet NSButton *addExcludedDirectoryButton;
@property (nonatomic, strong) IBOutlet NSButton *removeExcludedDirectoryButton;
@property (nonatomic, strong) IBOutlet NSButton *launchAutomaticallyCheckbox;
@property (nonatomic, strong) id <GeneralPreferencesDelegate> delegate;

- (void)askUserForDirectoryForInclusion:(BOOL)isForInclusion;
- (IBAction)askUserForDirectoryToInclude:(id)sender;
- (IBAction)askUserForDirectoryToExclude:(id)sender;
- (void)removeSelectedItemForInclusion:(BOOL)isForInclusion;
- (IBAction)removeIncludedSelectedItem:(id)sender;
- (IBAction)removeExcludedSelectedItem:(id)sender;
- (IBAction)rescanSelectedDirectory:(id)sender;
- (IBAction)visitWebsite:(id)sender;
- (IBAction)visitSupportWebsite:(id)sender;
- (IBAction)toggleLaunchAtLogin:(id)sender;

@end
