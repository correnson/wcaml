/* -------------------------------------------------------------------------- */
/* --- WCaml NSApplication Class                                          --- */
/* -------------------------------------------------------------------------- */

#import "CS.h"
#import "CSapp.h"

// --------------------------------------------------------------------------
// --- Predefined Application Menu
// --------------------------------------------------------------------------

static void wcaml_application_menu(NSMenu *menu)
{
  NSString *name ;
  NSMenuItem *item ;
  NSString *title ;
  //---- Application Name -----
  name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

  //--- About ---------------
  [[menu addItemWithTitle:[NSString stringWithFormat:@"About %@" , name]
		   action:@selector(orderFrontStandardAboutPanel:)
	    keyEquivalent:@""] setTarget:NSApp];

  //--- Preferences ---------------
  [menu addItem:[NSMenuItem separatorItem]];
  title = [NSString stringWithFormat:@"Preferences%C", (unichar)0x2026];
  [menu addItemWithTitle:title action:NULL keyEquivalent:@","];

  //--- Services ------------------
  [menu addItem:[NSMenuItem separatorItem]];
  item = [menu addItemWithTitle:@"Services" action:NULL keyEquivalent:@""];
  NSMenu *servicesMenu = [[[NSMenu alloc] initWithTitle:@"Services"] autorelease];
  [menu setSubmenu:servicesMenu forItem:item];
  [NSApp setServicesMenu:servicesMenu];

  //--- Hide, Hide Others, Show All ---------
  [menu addItem:[NSMenuItem separatorItem]];
  [[menu addItemWithTitle:[NSString stringWithFormat:@"Hide %@", name]
		   action:@selector(hide:) keyEquivalent:@"h"] 
    setTarget:NSApp];
  
  item = [menu addItemWithTitle:@"Hide Others"
			 action:@selector(hideOtherApplications:)
		  keyEquivalent:@"h"];
  [item setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
  [item setTarget:NSApp];
  
  item = [menu addItemWithTitle:NSLocalizedString(@"Show All", nil)
			 action:@selector(unhideAllApplications:)
		  keyEquivalent:@""];
  [item setTarget:NSApp];

  //--- Quit --------------------------------
  [menu addItem:[NSMenuItem separatorItem]];
  item = [menu addItemWithTitle:[NSString stringWithFormat:@"Quit %@" , name]
			 action:@selector(terminate:) keyEquivalent:@"q"];
  [item setTarget:NSApp];
}

// --------------------------------------------------------------------------
// --- Predefined Window Menu
// --------------------------------------------------------------------------

static void wcaml_window_menu(NSMenu *menu)
{
  [menu addItemWithTitle:NSLocalizedString(@"Minimize", nil)
		  action:@selector(performMiniaturize:)
	   keyEquivalent:@"m"];
  [menu addItemWithTitle:NSLocalizedString(@"Zoom", nil)
		  action:@selector(performZoom:)
	   keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:NSLocalizedString(@"Bring All to Front", nil)
		  action:@selector(arrangeInFront:)
	   keyEquivalent:@""];
}

void wcaml_main_menu(void)
{
  NSMenu *menubar ;
  NSMenuItem *item ;
  NSMenu *menu ;
  
  //---- Menu Bar -------------
  menubar = [[[NSMenu alloc] initWithTitle:@"MainMenu"] autorelease];
  [NSApp setMainMenu:menubar];

  //---- Application Menu -----
  item = [menubar addItemWithTitle:@"Apple" action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:@"Apple"] autorelease];
  [NSApp performSelector:@selector(setAppleMenu:) withObject:menu];
  [menubar setSubmenu:menu forItem:item];
  wcaml_application_menu(menu);
  
  //---- Window Menu ----------
  item = [menubar addItemWithTitle:@"Window" action:NULL keyEquivalent:@""];
  menu = [[[NSMenu alloc] initWithTitle:@"Window"] autorelease];
  [menubar setSubmenu:menu forItem:item];
  wcaml_window_menu(menu);
  [NSApp setWindowsMenu:menu];

  //---- That's It ------------
}

// --------------------------------------------------------------------------
// --- CSDelegate Implementation
// --------------------------------------------------------------------------

@implementation CSAppDelegate
+ (void) appMainMenu
{
  wcaml_main_menu();
}
@end

// --------------------------------------------------------------------------
