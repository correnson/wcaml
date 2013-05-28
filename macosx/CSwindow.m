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
// --- Callbacks
// ---------------------------------------------------------------------------

void wcaml_callback_nswindow_focus(NSWindow *window,BOOL focus)
{
  static value *service = NULL ;
  if (!service) service = caml_named_value("nswindow_focus");
  if (service) caml_callback2( *service , (value) window , VBOOL(focus) );
  return;
}

void wcaml_callback_nswindow_close(NSWindow *window)
{
  static value *service = NULL ;
  if (!service) service = caml_named_value("nswindow_close");
  if (service) caml_callback2( *service , (value) window , Val_unit );
  return;
}

// ---------------------------------------------------------------------------
// --- Delegate
// ---------------------------------------------------------------------------

@implementation CSWinDelegate

- (void)windowDidBecomeMain:(NSNotification *)notification
{
  wcaml_callback_nswindow_focus( [notification object] , YES );
}

- (void)windowDidResignMain:(NSNotification *)notification
{
  wcaml_callback_nswindow_focus( [notification object] , NO );
}

- (BOOL)windowShouldClose:(id)sender
{
  wcaml_callback_nswindow_close( (NSWindow*) sender );
  return NO; // To break the normal close operation.
}

@end

// ---------------------------------------------------------------------------
// --- NSWindow
// ---------------------------------------------------------------------------

value wcaml_nswindow_create(value vkey)
{
  //---- Window -----------------------
  NSWindow *wref = 
    [[NSWindow alloc] 
      initWithContentRect:NSMakeRect(0,0,200,100)
		styleMask:(NSTitledWindowMask|
			   NSClosableWindowMask|
			   NSMiniaturizableWindowMask|
			   NSResizableWindowMask)
		  backing:NSBackingStoreBuffered
		    defer:YES
     ] ;
  [wref setReleasedWhenClosed:NO];
  //---- Delegate --------------------
  static CSWinDelegate *delegate = nil ;
  if (!delegate) delegate = [[CSWinDelegate alloc] init] ;
  [wref setDelegate:delegate] ;
  //---- Positionning ----------------
  NSWindowController *controller = [wref windowController] ;
  [controller setShouldCascadeWindows:NO];
  NSString *key = ID(NSString,vkey);
  BOOL framed = [wref setFrameUsingName:key] ;
  if (!framed)
    cascading = [wref cascadeTopLeftFromPoint:cascading];
  [wref setFrameAutosaveName:key];
  return (value) wref ;
}

// ---------------------------------------------------------------------------
// --- Decorations
// ---------------------------------------------------------------------------

value wcaml_nswindow_set_title(value vwindow,value vtitle)
{
  [ID(NSWindow,vwindow) setTitle:ID(NSString,vtitle)];
  return Val_unit;
}

value wcaml_nswindow_set_edited(value vwindow,value vedited)
{
  [ID(NSWindow,vwindow) setDocumentEdited:BOOL(vedited)];
  return Val_unit;
}

value wcaml_nswindow_set_content(value vwindow,value vcontent)
{
  NSWindow *window = ID(NSWindow,vwindow);
  NSView *content = ID(NSView,vcontent);
  [window setContentView:content];
  return Val_unit;
}

// ---------------------------------------------------------------------------
// --- Visibility
// ---------------------------------------------------------------------------

value wcaml_nswindow_request_focus(value vwindow)
{
  [ID(NSWindow,vwindow) makeKeyAndOrderFront:nil];
}

value wcaml_nswindow_show(value vwindow)
{
  [ID(NSWindow,vwindow) orderFront:nil];
}

value wcaml_nswindow_hide(value vwindow)
{
  [ID(NSWindow,vwindow) orderOut:nil];
}

// ---------------------------------------------------------------------------
