//
//  GTPreferencesController.m
//
//  Created by Dave Carlton on 05/07/10.
//  Copyright 2010 PolyMicro Systems. All rights reserved.
//

#import "GTPreferencesController.h"
#import "GTDocumentController.h"

@implementation GTPreferencesController

NSString *const kFinderTitle = @"Double-click a path component to reveal it in the Finder.";
NSString *const kExplainTitle = @"<html><center>Drag a file system object to this area or click 'Set Path...'</center></html>";

static NSUserDefaults * gDefaults;

- (id) init {
	if(self=[super init]) {
		gDefaults = [[GTDocumentController sharedInstance] defaults];
	}
	return self;
} 

- (void)awakeFromNib
{
	// make the place holder string
	NSString* myHTMLString = [NSString stringWithString:kExplainTitle];
	NSData* myData = [myHTMLString dataUsingEncoding:NSUTF8StringEncoding];
	NSAttributedString* textToBeInserted = [[[NSAttributedString alloc] initWithHTML:myData documentAttributes:nil] autorelease];

	NSPathControl *path = [[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.GTCompareApplication"];
	[comparePathControl setPathStyle: NSPathStyleStandard];
	[[comparePathControl cell] setPlaceholderAttributedString: textToBeInserted];
    [comparePathControl setTarget:self];
    [comparePathControl setDoubleAction:@selector(pathControlDoubleClick:)];
	[comparePathControl setDelegate:self];
	[comparePathExplain setHidden: YES];

	[projectPathControl setPathStyle: NSPathStyleStandard];
	[[projectPathControl cell] setPlaceholderAttributedString: textToBeInserted];	
    [projectPathControl setTarget:self];
    [projectPathControl setDoubleAction:@selector(pathControlDoubleClick:)];
	[projectPathControl setDelegate:self];
	[projectPathExplain setHidden: YES];
}

-(void)updatePathExplain: (NSPathControl *)pathControl explainText: (NSTextField *)explainText
{	
	NSUInteger numItems = [[pathControl pathComponentCells] count];
	
	// if the control has a path (more then 0 components), output the explanatory text
	if (numItems > 0)
	{
		[explainText setHidden: NO];
		
		if ([pathControl pathStyle] == NSPathStyleStandard || [pathControl pathStyle] == NSPathStyleNavigationBar)
		{
			[explainText setStringValue:kExplainTitle];
		}
		else
		{
			// all other path styles have no explanatory text
			[explainText setStringValue:@""];
		}
	}
	else
	{
		// no path components, don't use explanatory text
		[explainText setHidden:YES];
	}
	
	[explainText setNeedsDisplay: YES];
	NSURL * pathURL = [pathControl URL];
	
	NSData *theData=[NSArchiver archivedDataWithRootObject:pathURL];

	[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:pathURL
									  forKey:@"GTCompareApplication"];
	BOOL result = [gDefaults synchronize];
}

-(void)updatePathExplain 
{
	[self updatePathExplain: comparePathControl explainText:comparePathExplain];
	[self updatePathExplain: projectPathControl explainText:projectPathExplain];
}

-(void)updateProjectPathExplain
{	
	NSUInteger numItems = [[projectPathControl pathComponentCells] count];
	
	// if the control has a path (more then 0 components), output the explanatory text
	if (numItems > 0)
	{
		[projectPathExplain setHidden: NO];
		
		if ([projectPathControl pathStyle] == NSPathStyleStandard || [projectPathControl pathStyle] == NSPathStyleNavigationBar)
		{
			[projectPathExplain setStringValue:kExplainTitle];
		}
		else
		{
			// all other path styles have no explanatory text
			[projectPathExplain setStringValue:@""];
		}
	}
	else
	{
		// no path components, don't use explanatory text
		[projectPathExplain setHidden:YES];
	}
	
	[projectPathExplain setNeedsDisplay: YES];
}


// -------------------------------------------------------------------------------
//	openPanelDidEnd:returnCode:contextInfo:
//
//	Called when the NSOpenPanel (via "Set Path..." button) completes.
// -------------------------------------------------------------------------------
- (void)openPanelDidEnd:(NSOpenPanel*)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// hide the open panel
	[panel orderOut:self];
	
	// if the return code wasn't ok, don't do anything.
	if (returnCode != NSOKButton)
		return;
	
	// get the first URL returned from the Open Panel and set it at the first path component of the control
	NSArray* paths = [panel URLs];
	NSURL* url = [paths objectAtIndex: 0];
	
	NSArray * pathInfo = (NSArray *)contextInfo;
	NSPathControl * pathControl = [(NSArray *)contextInfo objectAtIndex: 0];
	NSTextField * explainText = [(NSArray *)contextInfo objectAtIndex: 1];
	[pathControl setURL: url];
	
	// update the explanation text to show the user how they can reveal the path component
	[self updatePathExplain: pathControl explainText: explainText];	
	[pathInfo release];
}

- (NSOpenPanel *) openPathPanel {
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:YES];
	[panel setResolvesAliases:YES];
	[panel setTitle:@"Choose a file object"];
	[panel setPrompt:@"Choose"];
	return panel;
}

// -------------------------------------------------------------------------------
//	getComparePath:sender:
//
//	User clicked "Set Path..." button to pick a file system object.
// -------------------------------------------------------------------------------
- (IBAction)getComparePath:(id)sender
{
	NSOpenPanel *panel;
	panel = [self openPathPanel];
	
	NSArray *pathInfo = [[NSArray arrayWithObjects: comparePathControl, comparePathExplain, nil] retain];
	[panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[self window]
					modalDelegate:self
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
					  contextInfo:pathInfo];
}

- (IBAction)getProjectPath:(id)sender
{
	NSOpenPanel *panel;
	panel = [self openPathPanel];
	
	NSArray *pathInfo = [[NSArray arrayWithObjects:projectPathControl, projectPathExplain, nil] retain];
	[panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[self window]
					modalDelegate:self
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
					  contextInfo:pathInfo];
}

// -------------------------------------------------------------------------------
//	willDisplayOpenPanel:openPanel:
//
//	Delegate method to NSPathControl to determine how the NSOpenPanel will look/behave.
// -------------------------------------------------------------------------------
- (void)pathControl:(NSPathControl*)pathControl willDisplayOpenPanel:(NSOpenPanel*)openPanel
{	
	// change the wind title and choose buttons titles
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:YES];
	[openPanel setResolvesAliases:YES];
	[openPanel setTitle:@"Choose a file object"];
	[openPanel setPrompt:@"Choose"];
}

// -------------------------------------------------------------------------------
//	pathControlDoubleClick:sender:
//
//  This method is the "double-click" action for the control.
//	Since we are a standard or navigation style we ask for the control's path component.
// -------------------------------------------------------------------------------
- (void)pathControlDoubleClick:(id)sender
{
    if ([projectPathControl clickedPathComponentCell] != nil)
		[[NSWorkspace sharedWorkspace] openURL:[[projectPathControl clickedPathComponentCell] URL]];
}

// -------------------------------------------------------------------------------
//	menuItemAction:sender:
//
//  This is the action method from our custom menu item: "Reveal in  Finder".
//	Since we are a popup we ask for the control's URL (not one of the path components).
// -------------------------------------------------------------------------------
- (void)menuItemAction:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[projectPathControl URL]];
}

// -------------------------------------------------------------------------------
//	willPopUpMenu:menu:
//
//	Delegate method on NSPathControl (as NSPathStylePopUp) that determines what popup menus 
//	will look like.  In our case we add "Reveal in Finder".
// -------------------------------------------------------------------------------
- (void)pathControl:(NSPathControl*)pathControl willPopUpMenu:(NSMenu*)menu
{
	// add the "Reveal in Finder" menu item (but only for file system paths, not our custom path);
	NSMenuItem* newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Reveal in Finder" action:@selector(menuItemAction:) keyEquivalent:@""];
	[newItem setTarget:self];
	
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:newItem];
	[newItem release];
}

// -------------------------------------------------------------------------------
//	validateDrop:pinfo
//
//	This method is called when something is dragged over the control.
//	Return NSDragOperationNone to refuse the drop, or anything else to accept it.
// -------------------------------------------------------------------------------
- (NSDragOperation)pathControl:(NSPathControl*)pathControl validateDrop:(id <NSDraggingInfo>)info
{
	return NSDragOperationCopy;
}

// -------------------------------------------------------------------------------
//	acceptDrop:info
//
//	In order to accept the dropped contents previously accepted from
//	validateDrop:, you must implement this method.  We get the new URL from the
//	pasteboardand set it to the path control, and update the explanatory text if needed. 
// -------------------------------------------------------------------------------
-(BOOL)pathControl:(NSPathControl*)pathControl acceptDrop:(id <NSDraggingInfo>)info
{
	BOOL result = NO;
	
	NSURL* url = [NSURL URLFromPasteboard:[info draggingPasteboard]];
	if (url != nil)
	{
		[pathControl setURL: url];
		[self updatePathExplain];	// the user how they can reveal the path component
		result = YES;
	}
	
	return result;
}

// -------------------------------------------------------------------------------
//	shouldDragPathComponentCell:pathComponentCell:pasteboard
//
//	This method is called when a drag is about to begin.
//	Is shows how to customize dragging by preventing "volumes" from being dragged.
// -------------------------------------------------------------------------------
- (BOOL)pathControl:(NSPathControl*)pathControl shouldDragPathComponentCell:(NSPathComponentCell*)pathComponentCell withPasteboard:(NSPasteboard*)pasteboard
{
	BOOL result = YES;
	
	NSURL* url = [pathComponentCell URL];
	if (url && [url isFileURL])
	{
		NSArray* pathPieces = [[url path] pathComponents];
		if ([pathPieces count] < 4)
			result = NO;	// don't allow dragging volumes
	}
	
	return result;
}

- (IBAction)deminiaturize:(id)sender {
    
}

- (IBAction)makeKeyAndOrderFront:(id)sender {
    
}

- (IBAction)miniaturize:(id)sender {
    
}

- (IBAction)orderBack:(id)sender {
    
}

- (IBAction)orderFront:(id)sender {
    
}

- (IBAction)orderOut:(id)sender {
    
}

- (IBAction)performClose:(id)sender {
    
}

- (IBAction)performMiniaturize:(id)sender {
    
}

- (IBAction)performZoom:(id)sender {
    
}

- (IBAction)print:(id)sender {
    
}

- (IBAction)runToolbarCustomizationPalette:(id)sender {
    
}

- (IBAction)toggleToolbarShown:(id)sender {
    
}
@end
