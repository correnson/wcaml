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
  //---- Populate Menus -----
  
  //---- That's It ----------
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
