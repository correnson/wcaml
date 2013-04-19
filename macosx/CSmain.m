#import "CSapp.h"
#import "CSmain.h"

// ---------------------------------------------------------------------------
// --- Main Loop
// ---------------------------------------------------------------------------

static NSAutoreleasePool * wcaml_pool = nil ;

value wcaml_init(value unit)
{
  wcaml_pool = [[NSAutoreleasePool alloc] init];
  [CSApplication sharedApplication];
  [NSApp finishLaunching];
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
