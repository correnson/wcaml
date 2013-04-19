/* -------------------------------------------------------------------------- */
/* --- WCaml NSApplication Class                                          --- */
/* -------------------------------------------------------------------------- */

#import "CSapp.h"

// --------------------------------------------------------------------------
// --- CSDelegate Implementation
// --------------------------------------------------------------------------

@implementation CSDelegate

-(id) init 
{
  if ((self = [super init])) {
    theAppName = [[[NSBundle mainBundle] 
		    objectForInfoDictionaryKey:@"CFBundleName"] retain];
    if (!theAppName)
      theAppName = @"WCaml" ;
  }
  return self;
}

-(void) dealloc 
{
  [theAppName release];
  theAppName = nil;
  [super dealloc];
}

-(NSString *) appName {
  return [[theAppName retain] autorelease];
}

-(void) applicationWillFinishLaunching:(NSNotification *)aNotification 
{
  NSMenu * menubar ;
  NSMenuItem * item ;
  NSMenu * submenu ;
  //---- Menu Bar -----
  menubar = [[[NSMenu alloc] initWithTitle:@"MainMenu"] autorelease];
  //---- Application Menu -----
  item = [menubar addItemWithTitle:@"Apple" action:NULL keyEquivalent:@""];
  submenu = [[[NSMenu alloc] initWithTitle:@"Apple"] autorelease];
  [NSApp performSelector:@selector(setAppleMenu:) withObject:submenu];
  [menubar setSubmenu:submenu forItem:item];
  [self makeAppMenu:submenu];
  //---- That's It ----------
  [NSApp setMainMenu:menubar];
}

-(void) makeAppMenu:(NSMenu *)menu
{
  NSMenuItem * item ;
  //--- About ---------------
  [[menu addItemWithTitle:[NSString stringWithFormat:@"About %@" , theAppName]
		   action:@selector(orderFrontStandardAboutPanel:)
	    keyEquivalent:@""] setTarget:NSApp];
  //--- Preferences ---------------
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:NSLocalizedString(@"Preferences...", nil)
		  action:NULL keyEquivalent:@","];
  //--- Services ------------------
  [menu addItem:[NSMenuItem separatorItem]];
  item = [menu addItemWithTitle:NSLocalizedString(@"Services", nil)
			 action:NULL keyEquivalent:@""];
  NSMenu * servicesMenu = 
    [[[NSMenu alloc] initWithTitle:@"Services"] autorelease];
  [menu setSubmenu:servicesMenu forItem:item];
  [NSApp setServicesMenu:servicesMenu];
  //--- Hide, Hide Others, Show All ---------
  [menu addItem:[NSMenuItem separatorItem]];
  [[menu addItemWithTitle:[NSString stringWithFormat:@"Hide %@", theAppName]
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
  item = [menu addItemWithTitle:[NSString stringWithFormat:@"Quit %@" , theAppName]
			 action:@selector(terminate:) keyEquivalent:@"q"];
  [item setTarget:NSApp];
  //-----------------------------------------
}
@end

// --------------------------------------------------------------------------
// --- CSApplication Implementation
// --------------------------------------------------------------------------

@implementation CSApplication

-(id) init {

  if ((self = [super init]))
    [self setDelegate:[[CSDelegate alloc] init]];
  return self;
}

-(void) dealloc {
  id delegate = [self delegate];
  if (delegate) {
    [self setDelegate:nil];
    [delegate release];
  }
  [super dealloc];
}

@end

// --------------------------------------------------------------------------
