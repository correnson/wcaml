#import "CS.h"

// ---------------------------------------------------------------------------
// --- Main Loop
// ---------------------------------------------------------------------------

static NSAutoreleasePool *wcaml_pool = nil ;


value wcaml_init(value unit)
{
  wcaml_pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];
  CSAppDelegate *delegate = [[CSAppDelegate alloc] init];
  [NSApp setDelegate:delegate];
  [CSAppDelegate appMainMenu];
  return Val_unit ;
}

value wcaml_main(value unit)
{
  [wcaml_pool release];
  [NSApp run];
  return Val_unit ;
}

value wcaml_quit(value unit)
{
  [NSApp terminate:nil];
  return Val_unit ;
}

// ---------------------------------------------------------------------------
