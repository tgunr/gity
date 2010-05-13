//
//  GTPreferencesController.h
//
//  Created by Dave Carlton on 05/07/10.
//  Copyright 2010 PolyMicro Systems. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GTPreferencesController : NSWindowController  {
	//    IBOutlet id delegate;
	//    IBOutlet NSView *initialFirstResponder;
	//    IBOutlet NSMenu *menu;
	IBOutlet NSPathControl*	comparePathControl;
	IBOutlet NSPathControl*	projectPathControl;
	IBOutlet NSTextField*	comparePathExplain;
	IBOutlet NSTextField*	projectPathExplain;
	IBOutlet NSButton*		setComparePathButton;
	IBOutlet NSButton*		setProjectPathButton;
}
- (IBAction)deminiaturize:(id)sender;
- (IBAction)makeKeyAndOrderFront:(id)sender;
- (IBAction)miniaturize:(id)sender;
- (IBAction)orderBack:(id)sender;
- (IBAction)orderFront:(id)sender;
- (IBAction)orderOut:(id)sender;
- (IBAction)performClose:(id)sender;
- (IBAction)performMiniaturize:(id)sender;
- (IBAction)performZoom:(id)sender;
- (IBAction)print:(id)sender;
- (IBAction)runToolbarCustomizationPalette:(id)sender;
- (IBAction)toggleToolbarShown:(id)sender;
- (IBAction)getComparePath:(id)sender;
- (IBAction)getProjectPath:(id)sender;
@end
