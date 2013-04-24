// --------------------------------------------------------------------------
// --- Window Port                                                        ---
// --------------------------------------------------------------------------

#import "CSwindow.h"

static NSPoint cascading ;

value wcaml_nswindow_cascading(value unit)
{
  NSRect frame = [[NSScreen mainScreen] visibleFrame] ;
  cascading = frame.origin ;
  return Val_unit ;
}

// ---------------------------------------------------------------------------
// --- Window creation
// ---------------------------------------------------------------------------

value wcaml_nswindow_create(value vkey)
{
  //static CSWindowDelegate * delegate = nil ;
  NSRect frame = NSMakeRect(0,0,200,100);
  NSWindow * wref = 
    [[NSWindow alloc] 
      initWithContentRect:frame
		styleMask:(NSTitledWindowMask|
			   NSClosableWindowMask|
			   NSMiniaturizableWindowMask|
			   NSResizableWindowMask)
		  backing:NSBackingStoreBuffered
		    defer:YES
     ] ;
  //if (!delegate) delegate = [[CSWindowDelegate alloc] init] ;
  //[wref setDelegate:delegate] ;
  NSWindowController * controller = [wref windowController] ;
  [controller setShouldCascadeWindows:NO];
  NSString * key = ID(NSString,vkey);
  BOOL framed = [wref setFrameUsingName:key] ;
  if (!framed)
    cascading = [wref cascadeTopLeftFromPoint:cascading];
  [wref setFrameAutosaveName:key];
  [wref makeKeyAndOrderFront:nil];
  return (value) wref ;
}

// ---------------------------------------------------------------------------
// --- Window decoration
// ---------------------------------------------------------------------------

value wcaml_nswindow_set_title(value vwin,value vtitle)
{
  [ID(NSWindow,vwin) setTitle:ID(NSString,vtitle)];
  return Val_unit;
}

value wcaml_nswindow_set_edited(value vwin,value vedited)
{
  [ID(NSWindow,vwin) setDocumentEdited:BOOL(vedited)];
  return Val_unit;
}

// ---------------------------------------------------------------------------
